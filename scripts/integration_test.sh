#!/usr/bin/env bash
set -e

SUCCESS=false
HOMELABMANAGERPORT=$(shuf -i 4500-5500 -n 1)
TESTVMIP="192.168.1.$(shuf -i 20-250 -n 1)"
ROLETOTEST=${1-shellserver}
echo "Testing role $ROLETOTEST on homelabmanager 127.0.0.1:$HOMELABMANAGERPORT with VM IP $TESTVMIP"

function terraform_environment()
{
    # Ensure an environment
    export LIBVIRT_DEFAULT_URI="qemu:///system" 
    mkdir -p /tmp/integration-test-environment/terraform
    cd /tmp/integration-test-environment/terraform
    touch checksum
    chronic wget "127.0.0.1:$HOMELABMANAGERPORT/terraform/?host=$1" -O main.tf
    chronic sudo terraform init || /bin/true
    chronic sudo terraform validate
    if ! cat checksum | md5sum --quiet -c; then
        md5sum main.tf > checksum
        sudo terraform destroy --auto-approve || /bin/true
        sudo virsh list --all | grep -v debian-10 | grep -v focal | grep -v ubuntu18 | grep -v arch-openstack | grep shut | awk '{print$2}' | xargs -I {} sh -c 'sudo virsh destroy {} || /bin/true; sudo virsh undefine {} || /bin/true' || /bin/true
        cd /var/lib/libvirt/images
        ls /var/lib/libvirt/images | grep -v focal | grep -v bionic-server | grep -v debian-10 | grep -v arch-openstack | xargs -I {} sudo rm -rf "{}"
        cd -
        sudo terraform apply --auto-approve || /bin/true
        sleep 1
        sudo terraform apply --auto-approve
    fi
}

function kill_any_homelabmanager_api()
{
    pkill -f "127.0.0.1:$HOMELABMANAGERPORT" || /bin/true
}

function print_test_result()
{
    if $SUCCESS; then
        echo "Tests passed!"
        exit 0
    else
        echo "Test failed!"
        /bin/false
        exit 1
    fi
}

# Clean up from any previous attempt
kill_any_homelabmanager_api
sudo rm -rf /tmp/integration-test-environment

# Copy the repo to the test environment
HOMELABDIR=$(dirname $(dirname $(realpath -s "$0")))
mkdir -p /tmp/integration-test-environment
cd /tmp/integration-test-environment
cp -R $HOMELABDIR /tmp/integration-test-environment/

# Start the homelabmanager API
cd /tmp/integration-test-environment/homelabmanager
python3 -m venv venv
. venv/bin/activate
pip3 install -r requirements/dev.txt
ACTIVE_INTERFACE=$(ip addr | awk '/state UP/ {print $2}' | cut -d ':' -f1 | tail -n 1)
./manage.py migrate
sed -i "s/eth0/$ACTIVE_INTERFACE/g" fixtures/integrationtest.json
sed -i "s/192.168.1.123/$TESTVMIP/g" fixtures/integrationtest.json
sed -i "s/shellserver/$ROLETOTEST/g" fixtures/integrationtest.json
./manage.py loaddata fixtures/integrationtest.json
export VM_SALTMASTER_IP=127.0.0.1
./manage.py runserver 127.0.0.1:$HOMELABMANAGERPORT &
sleep 5

if test -d /tmp/integration-test-environment/terraform; then
    terraform_environment cleanup
fi
terraform_environment local

echo "Giving things some time to get started"
sleep 120

# Check if the unit tests pass on the server
MACHINECHECKMAXATTEMPTS=10
MACHINECHECKCOUNT=0
while [ -z "$MACHINECHECKPID" ] && [ "$MACHINECHECKCOUNT" -lt "$MACHINECHECKMAXATTEMPTS" ] && ! sudo virsh -c qemu:///system qemu-agent-command integrationtest_on_local "{\"execute\": \"guest-exec-status\", \"arguments\": { \"pid\": $MACHINECHECKPID }}" | jq -r '.return.["out-data"]' | base64 --decode | grep 'All tests pass'; do
    let MACHINECHECKCOUNT=MACHINECHECKCOUNT+1
    echo "Checking if machine-check is passing yet"
    MACHINECHECKPID=$(sudo virsh -c qemu:///system qemu-agent-command integrationtest_on_local '{"execute": "guest-exec", "arguments": { "path": "/usr/bin/machine-check", "arg": [ ], "capture-output": true }}' | jq .return.pid);
    sleep 30;
done

if [ "$MACHINECHECKCOUNT" -lt "$MACHINECHECKMAXATTEMPTS" ]; then
    echo "Tests passed!"
    SUCCESS=true
else
    echo "Ran out of attempts! Test failed. The machine-check assertions did not pass, or failed to run."
fi

terraform_environment cleanup

# Clean up after ourselves
trap 'terraform_environment cleanup' EXIT
trap kill_any_homelabmanager_api EXIT
trap print_test_result EXIT
