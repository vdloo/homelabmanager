import factory

from resources.models import Resource


class ResourceFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Resource

    cpu = 4
    ram_in_mb = 1024
    name = factory.sequence(lambda n: "node_{}".format(n))
    role = factory.sequence(lambda n: "role_{}".format(n))
    host = factory.sequence(lambda n: "hypervisor{}".format(n))
