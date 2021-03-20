from django.test import TestCase
from django.urls import reverse

from resources.factory import ResourceFactory


class TestTerraform(TestCase):
    def setUp(self):
        self.resource_1 = ResourceFactory.create()
        self.resource_2 = ResourceFactory.create()
        self.resource_3 = ResourceFactory.create(role='shellserver', host='hypervisor88')
        self.resource_4 = ResourceFactory.create(role='shellserver', host='hypervisor88')
        self.resource_5 = ResourceFactory.create(host='hypervisor99')
        self.resource_6 = ResourceFactory.create(host='hypervisor99')
        self.terraform_url = reverse('terraform')

    def test_terraform_returns_bad_request_if_no_hypervisor_name_specified(self):
        ret = self.client.get(self.terraform_url)

        self.assertEqual(ret.status_code, 400)

    def test_terraform_does_not_return_bad_request_if_a_hypervisor_name_is_specified(self):
        ret = self.client.get(self.terraform_url + '?host=hypervisor99')

        self.assertEqual(ret.status_code, 200)

    def test_terraform_returns_only_cloud_init_for_roles_of_hypervisor_if_no_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=notusedhypervisor')

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'libvirt_cloudinit_disk' in l]
        self.assertEqual(0, len(cloudinit_disk_lines))

    def test_terraform_returns_only_cloud_init_for_roles_of_hypervisor_if_two_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=hypervisor99')

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'resource "libvirt_cloudinit_disk' in l]
        self.assertEqual(2, len(cloudinit_disk_lines))

    def test_terraform_returns_only_cloud_init_for_roles_of_hypervisor_if_only_one_role_on_two_nodes(self):
        ret = self.client.get(self.terraform_url + '?host=hypervisor88')

        content_lines = ret.content.decode('utf-8').split('\n')
        cloudinit_disk_lines = [l for l in content_lines if 'resource "libvirt_cloudinit_disk' in l]
        self.assertEqual(1, len(cloudinit_disk_lines))

    def test_terraform_returns_correct_number_of_libvirt_domains(self):
        ret = self.client.get(self.terraform_url + '?host=hypervisor99')
        content_lines = ret.content.decode('utf-8').split('\n')
        libvirt_domain_lines = [l for l in content_lines if 'resource "libvirt_domain' in l]
        self.assertEqual(2, len(libvirt_domain_lines))

    def test_terraform_returns_correct_number_of_libvirt_volumes(self):
        ret = self.client.get(self.terraform_url + '?host=hypervisor99')
        content_lines = ret.content.decode('utf-8').split('\n')
        libvirt_volume_lines = [l for l in content_lines if 'resource "libvirt_volume' in l]
        # Note the extra volume in the separate 'storage' pool. The idea is that this
        # can either be on a ramdisk or on the NFS share if so desired.
        self.assertEqual(4, len(libvirt_volume_lines))
