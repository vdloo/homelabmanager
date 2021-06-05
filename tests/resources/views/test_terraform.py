import os
from django.test import TestCase
from django.urls import reverse
from unittest.mock import patch

from resources.factory import VirtualMachineFactory, HypervisorFactory


class TestTerraform(TestCase):
    def setUp(self):
        self.hypervisor_1 = HypervisorFactory.create(name='hypervisor88')
        self.hypervisor_2 = HypervisorFactory.create(name='hypervisor99')
        self.virtual_machine_1 = VirtualMachineFactory.create()
        self.virtual_machine_2 = VirtualMachineFactory.create()
        self.virtual_machine_3 = VirtualMachineFactory.create(
            role='shellserver', host=self.hypervisor_1
        )
        self.virtual_machine_4 = VirtualMachineFactory.create(
            role='shellserver', host=self.hypervisor_1
        )
        self.virtual_machine_5 = VirtualMachineFactory.create(host=self.hypervisor_2)
        self.virtual_machine_6 = VirtualMachineFactory.create(host=self.hypervisor_2)
        self.terraform_url = reverse('terraform')

    def test_terraform_returns_bad_request_if_no_hypervisor_name_specified(self):
        ret = self.client.get(self.terraform_url)

        self.assertEqual(ret.status_code, 400)

    def test_terraform_does_not_return_bad_request_if_a_hypervisor_name_is_specified(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)

        self.assertEqual(ret.status_code, 200)

    def test_terraform_returns_only_cloud_init_for_roles_of_hypervisor_if_no_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=notusedhypervisor')

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'libvirt_cloudinit_disk' in l]
        self.assertEqual(0, len(cloudinit_disk_lines))

    def test_terraform_returns_only_cloud_init_for_nodes_of_hypervisor_if_two_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'resource "libvirt_cloudinit_disk' in l]
        self.assertEqual(2, len(cloudinit_disk_lines))

    def test_terraform_returns_cloud_init_for_nodes_of_hypervisor_if_only_one_role_on_two_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_1.name)

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'resource "libvirt_cloudinit_disk' in l]
        self.assertEqual(2, len(cloudinit_disk_lines))

    def test_terraform_returns_correct_number_of_libvirt_domains(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)
        content_lines = ret.content.decode('utf-8').split('\n')
        libvirt_domain_lines = [l for l in content_lines if 'resource "libvirt_domain' in l]
        self.assertEqual(2, len(libvirt_domain_lines))

    def test_terraform_returns_correct_number_of_libvirt_volumes(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)
        content_lines = ret.content.decode('utf-8').split('\n')
        libvirt_volume_lines = [l for l in content_lines if 'resource "libvirt_volume' in l]
        # Note the extra volume in the separate 'storage' pool. The idea is that this
        # can either be on a ramdisk or on the NFS share if so desired.
        self.assertEqual(4, len(libvirt_volume_lines))

    def test_terraform_returns_correct_storage_pool(self):
        self.virtual_machine_5.extra_storage_pool = 'some_storage_pool'
        self.virtual_machine_5.save()
        self.virtual_machine_6.extra_storage_pool = 'some_other_storage_pool'
        self.virtual_machine_6.save()
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)
        content_lines = ret.content.decode('utf-8').split('\n')
        some_storage_pool_lines = [
            l for l in content_lines if 'pool = "some_storage_pool"' in l
        ]
        some_other_storage_pool_lines = [
            l for l in content_lines if 'pool = "some_other_storage_pool"' in l
        ]
        self.assertEqual(1, len(some_storage_pool_lines))
        self.assertEqual(1, len(some_other_storage_pool_lines))

    @patch.dict(os.environ, {})
    def test_terraform_writes_saltmaster_config(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)

        content_lines = ret.content.decode('utf-8').split('\n')
        saltmaster_line = [
            l for l in content_lines if
            'echo "master: 127.0.0.1" > /etc/salt/minion' in l
        ]
        self.assertTrue(saltmaster_line)

    @patch.dict(os.environ, {'VM_SALTMASTER_IP': '1.2.3.4'})
    def test_terraform_writes_saltmaster_config_for_specified_saltmaster(self):
        ret = self.client.get(self.terraform_url + '?host=' + self.hypervisor_2.name)

        content_lines = ret.content.decode('utf-8').split('\n')
        saltmaster_line = [
            l for l in content_lines if
            'echo "master: 1.2.3.4" > /etc/salt/minion' in l
        ]
        self.assertTrue(saltmaster_line)
