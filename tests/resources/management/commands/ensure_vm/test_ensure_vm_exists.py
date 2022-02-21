from resources.management.commands.ensure_vm import ensure_vm_exists
from resources.models import VirtualMachine, Hypervisor
from tests.testcase import TestCase


class TestEnsureVmExists(TestCase):
    def setUp(self):
        self.set_up_patch(
            'resources.management.commands.ensure_vm.print'
        )
        self.set_up_patch(
            'resources.management.commands.ensure_vm.pprint'
        )
        Hypervisor.objects.create(
            name='h1',
            interface='eth0'
        )

        self.kwargs = {
            'name': 'vm1',
            'ram': 4096,
            'cpu': 2,
            'hypervisor': 'h1',
            'role': 'default',
            'profile': 'default',
            'image': 'debian-10-openstack-amd64.qcow2',
            'saltmaster_ip': None,
            'enabled': True,
            'extra_storage_in_gb': 1,
            'extra_storage_pool': 'default',
            'ipv6_overlay': True
        }

    def test_ensure_vm_exists_creates_vm_idempotently(self):
        ensure_vm_exists(**self.kwargs)
        ensure_vm_exists(**self.kwargs)

        hypervisor = self.kwargs.pop('hypervisor')
        ram_in_mb = self.kwargs.pop('ram')
        VirtualMachine.objects.get(
            ram_in_mb=ram_in_mb,
            host=Hypervisor.objects.get(name=hypervisor),
            **self.kwargs
        )

    def test_no_vms_exist_if_no_are_created(self):
        all_vms = VirtualMachine.objects.all()

        self.assertEqual(0, len(all_vms))
