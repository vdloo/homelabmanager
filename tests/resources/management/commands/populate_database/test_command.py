from resources.management.commands.populate_database import Command
from tests.testcase import TestCase


class TestCommand(TestCase):
    def setUp(self):
        self.command = Command()

    def test_command_has_correct_help_message(self):
        expected_message = 'Populate the database'

        self.assertEqual(expected_message, self.command.help)

    def test_command_creates_hypervisors(self):
        create_hypervisors = self.set_up_patch(
            'resources.management.commands.populate_database.create_hypervisors'
        )

        self.command.handle()

        create_hypervisors.assert_called_once_with()
