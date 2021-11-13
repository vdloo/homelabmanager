from resources.management.commands.populate_database import create_hypervisors
from resources.models import Hypervisor
from tests.testcase import TestCase


class TestCreateHypervisors(TestCase):
    def setUp(self):
        self.set_up_patch(
            'resources.management.commands.populate_database.print'
        )
        self.expected_hypervisors = [
            ('h1', 'eth0'),
            ('h2', 'enp1s0')
        ]
        self.set_up_patch(
            'resources.management.commands.populate_database.HYPERVISORS',
            self.expected_hypervisors
        )

    def test_create_hypervisors_creates_expected_hypervisors(self):
        create_hypervisors()

        for name, interface in self.expected_hypervisors:
            Hypervisor.objects.get(name=name, interface=interface)

    def test_no_hypervisors_exist_if_no_are_created(self):
        all_hypervisors = Hypervisor.objects.all()

        self.assertEqual(0, len(all_hypervisors))
