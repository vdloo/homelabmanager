from unittest.mock import Mock, call, ANY

from resources.management.commands.ensure_vm import Command
from resources.models import Hypervisor, Profile, STORAGE_POOL_CHOICES
from tests.testcase import TestCase


class TestCommand(TestCase):
    def setUp(self):
        self.command = Command()
        self.options = {
            'name': 'vm1',
            'ram': 4096,
            'cpu': 2,
            'hypervisor': 'h1',
            'role': 'default',
            'profile': 'default',
            'image': 'debian-10-openstack-amd64.qcow2',
            'enabled': True,
            'extra_storage_in_gb': 1,
            'extra_storage_pool': 'default',
            'saltmaster_ip': '1.2.3.4',
            'no_ipv6_overlay': True,
        }
        Hypervisor.objects.create(
            name='h1',
            interface='eth0'
        )
        Profile.objects.create(
            name='default'
        )

    def test_command_has_correct_help_message(self):
        expected_message = 'Ensure a VM exists'

        self.assertEqual(expected_message, self.command.help)

    def test_command_ensures_vm_exists(self):
        ensure_vm_exists = self.set_up_patch(
            'resources.management.commands.ensure_vm.ensure_vm_exists'
        )

        self.command.handle(**self.options)

        ensure_vm_exists.assert_called_once_with(
            name='vm1',
            ram=4096,
            cpu=2,
            hypervisor='h1',
            role='default',
            profile='default',
            image='debian-10-openstack-amd64.qcow2',
            enabled=True,
            extra_storage_in_gb=1,
            extra_storage_pool='default',
            saltmaster_ip='1.2.3.4',
            ipv6_overlay=False
        )

    def test_command_adds_correct_arguments(self):
        self.maxDiff = None

        parser = Mock()

        self.command.add_arguments(parser)

        expected_calls = [
            call(
                '--name',
                help=ANY,
                required=True
            ),
            call(
                '--ram',
                type=int,
                help=ANY,
                required=True
            ),
            call(
                '--cpu',
                type=int,
                help=ANY,
                required=True
            ),
            call(
                '--hypervisor',
                help=ANY,
                choices=[h.name for h in Hypervisor.objects.all()],
                default=Hypervisor.objects.first().name
            ),
            call(
                '--role',
                help=ANY,
                required=True
            ),
            call(
                '--profile',
                help=ANY,
                choices=[p.name for p in Profile.objects.all()],
                default=Profile.objects.first().name
            ),
            call(
                '--image',
                help=ANY,
                default='debian-10-openstack-amd64.qcow2'
            ),
            call(
                '--enabled',
                help=ANY,
                action='store_true'
            ),
            call(
                '--extra-storage-in-gb',
                type=int,
                help=ANY,
                default=1
            ),
            call(
                '--extra-storage-pool',
                help=ANY,
                choices=[x for (x, _) in STORAGE_POOL_CHOICES],
                default=STORAGE_POOL_CHOICES[0][0]
            ),
            call(
                '--saltmaster-ip',
                help=ANY,
                default=None
            ),
            call(
                '--no-ipv6-overlay',
                help=ANY,
                action='store_true'
            ),
        ]
        self.assertSequenceEqual(expected_calls, parser.add_argument.mock_calls)
