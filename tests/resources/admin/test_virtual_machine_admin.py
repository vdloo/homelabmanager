from django.test import TestCase
from django.urls import reverse

from resources.admin import VirtualMachineAdmin


class TestAutomaticLoginMiddleware(TestCase):
    def setUp(self):
        self.admin_url = reverse('admin:resources_virtualmachine_add')

    def test_resource_admin_has_expected_attributes_for_resource_add(self):
        ret = self.client.get(self.admin_url)

        required_fields = list(VirtualMachineAdmin.list_display)
        required_fields.remove('enabled')
        self.assertEqual(ret.status_code, 200)
        for attribute in required_fields:
            self.assertIn(
                'class="required" for="id_{}"'.format(attribute),
                ret.rendered_content
            )
