from django.core.management import BaseCommand
from resources.models import Hypervisor

HYPERVISORS = [
    ('h52', 'eth0'),
    ('h54', 'enp3s0'),
    ('h55', 'enp2s0'),
    ('h56', 'eno1'),
    ('h59', 'ens3f3'),
    ('h60', 'enp5s0f3'),
    ('h61', 'eno1')
]


def create_hypervisors():
    for name, interface in HYPERVISORS:
        _, created = Hypervisor.objects.get_or_create(
            name=name,
            interface=interface
        )
        created_message = f"Created new Hypervisor '{name}' with interface '{interface}'"
        exists_message = f"Hypervisor '{name}' with interface '{interface}' already exists"
        print(created_message if created else exists_message)


class Command(BaseCommand):
    help = 'Populate the database'

    def handle(self, *args, **options):
        create_hypervisors()
