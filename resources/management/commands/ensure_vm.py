from pprint import pprint
from django.forms.models import model_to_dict
from django.core.management import BaseCommand

from resources.models import VirtualMachine, Hypervisor, Profile, STORAGE_POOL_CHOICES

DEFAULT_PROFILE = 'default'
DEFAULT_IMAGE = 'debian-10-openstack-amd64.qcow2'
DEFAULT_EXTRA_STORAGE_IN_GB = 1
DEFAULT_EXTRA_STORAGE_POOL = STORAGE_POOL_CHOICES[0][0]


def ensure_vm_exists(
        name, ram, cpu, hypervisor, role, profile, image,
        enabled, extra_storage_in_gb, extra_storage_pool,
        saltmaster_ip, ipv6_overlay
):
    vm, created = VirtualMachine.objects.get_or_create(
        name=name,
        ram_in_mb=ram,
        cpu=cpu,
        host=Hypervisor.objects.filter(name=hypervisor).first(),
        role=role,
        profile=Profile.objects.filter(name=profile).first(),
        image=image,
        enabled=enabled,
        extra_storage_in_gb=extra_storage_in_gb,
        extra_storage_pool=extra_storage_pool,
        saltmaster_ip=saltmaster_ip,
        ipv6_overlay=ipv6_overlay
    )
    created_message = f"Created new VM '{name}'"
    exists_message = f"VM '{name}' already exists"
    print(created_message if created else exists_message)
    pprint(model_to_dict(vm))


class Command(BaseCommand):
    help = 'Ensure a VM exists'

    def add_arguments(self, parser):
        default_hypervisor = Hypervisor.objects.first().name
        default_profile = Profile.objects.first().name

        parser.add_argument(
            '--name',
            help='The name of the vm',
            required=True
        )
        parser.add_argument(
            '--ram',
            type=int,
            help='Ram in MB',
            required=True
        )
        parser.add_argument(
            '--cpu',
            type=int,
            help='Amount of vcpus to allocate',
            required=True
        )
        parser.add_argument(
            '--hypervisor',
            help=f"The Hypervisor to put the VM on. Defaults to '{default_hypervisor}'",
            choices=[h.name for h in Hypervisor.objects.all()],
            default=default_hypervisor
        )
        parser.add_argument(
            '--role',
            help='The role to assign to the VM',
            required=True
        )
        parser.add_argument(
            '--profile',
            help=f"What profile to assign for the VM. Defaults to '{default_profile}'",
            choices=[p.name for p in Profile.objects.all()],
            default=default_profile
        )
        parser.add_argument(
            '--image',
            help=f"What image to use for the VM. Defaults to '{DEFAULT_IMAGE}'",
            default=DEFAULT_IMAGE
        )
        parser.add_argument(
            '--enabled',
            help="Pass --enabled to enable the VM. It's disabled by default",
            action='store_true'
        )
        parser.add_argument(
            '--extra-storage-in-gb',
            type=int,
            help=f"How much extra storage in GB is needed. Defaults to '{DEFAULT_EXTRA_STORAGE_IN_GB}'",
            default=DEFAULT_EXTRA_STORAGE_IN_GB
        )
        parser.add_argument(
            '--extra-storage-pool',
            help=f"The storage pool to put the extra storage on. Defaults to '{DEFAULT_EXTRA_STORAGE_POOL}'",
            choices=[x for (x, _) in STORAGE_POOL_CHOICES],
            default=DEFAULT_EXTRA_STORAGE_POOL
        )
        parser.add_argument(
            '--saltmaster-ip',
            help=f"The saltmaster the vm should listen to. Defaults to 'VM_SALTMASTER_IP' in the environment",
            default=None
        )
        parser.add_argument(
            '--no-ipv6-overlay',
            help="Pass --no-ipv6-overlay to disable the ipv6 overlay on this new VM",
            action='store_true'
        )

    def handle(self, *args, **options):
        ensure_vm_exists(
            name=options['name'],
            ram=options['ram'],
            cpu=options['cpu'],
            hypervisor=options['hypervisor'],
            role=options['role'],
            profile=options['profile'],
            image=options['image'],
            enabled=options['enabled'],
            extra_storage_in_gb=options['extra_storage_in_gb'],
            extra_storage_pool=options['extra_storage_pool'],
            saltmaster_ip=options['saltmaster_ip'],
            ipv6_overlay=not options['no_ipv6_overlay']
        )
