from rest_framework import serializers
from resources.models import VirtualMachine, Hypervisor, Profile


class VirtualMachineSerializer(serializers.ModelSerializer):
    class Meta:
        model = VirtualMachine
        fields = ('id', 'name', 'ram_in_mb', 'cpu', 'host', 'profile')


class HypervisorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hypervisor
        fields = ('id', 'name', 'interface')


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ('id', 'name')
