from rest_framework import serializers
from resources.models import VirtualMachine, Hypervisor


class VirtualMachineSerializer(serializers.ModelSerializer):
    class Meta:
        model = VirtualMachine
        fields = ('id', 'name', 'ram_in_mb', 'cpu', 'host', 'profile')


class HypervisorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hypervisor
        fields = ('id', 'name', 'interface')
