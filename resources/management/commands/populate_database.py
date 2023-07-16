from django.core.management import BaseCommand
from resources.models import Hypervisor, Profile

HYPERVISORS = [
    ('desktop', 'enp0s31f6'),
    ('thinkpad', 'enp0s20f0u4'),
]


def create_hypervisors():
    Profile.objects.create(
        name='default',
        enabled=True
    )
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
