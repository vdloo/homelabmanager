import factory

from resources.models import VirtualMachine, Hypervisor, Profile


class ProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Profile

    name = factory.sequence(lambda n: "profile{}".format(n))
    enabled = False


class HypervisorFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Hypervisor

    name = factory.sequence(lambda n: "hypervisor{}".format(n))
    interface = 'eno1'


class VirtualMachineFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = VirtualMachine

    cpu = 4
    ram_in_mb = 1024
    name = factory.sequence(lambda n: "node_{}".format(n))
    role = factory.sequence(lambda n: "role_{}".format(n))
    enabled = True
    host = factory.SubFactory(HypervisorFactory)
    profile = factory.SubFactory(ProfileFactory)
    extra_storage_in_gb = '8'
    extra_storage_pool = 'default'
