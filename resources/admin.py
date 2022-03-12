from django.contrib import admin
from resources.models import VirtualMachine, Hypervisor, Profile
from django.contrib.auth.models import User
from django.contrib.auth.models import Group


class VirtualMachineAdmin(admin.ModelAdmin):
    list_display = ('name', 'ram_in_mb', 'cpu', 'host', 'role', 'profile', 'image', 'enabled')
    list_filter = ('name', 'ram_in_mb', 'cpu', 'host', 'role', 'profile', 'image', 'enabled')
    search_fields = ('name', 'host', 'role', 'profile', 'enabled')


class HypervisorAdmin(admin.ModelAdmin):
    list_display = ('name', 'interface')
    list_filter = ('name', 'interface')
    search_fields = ('name', 'interface')


class ProfileAdmin(admin.ModelAdmin):
    list_display = ('name', 'enabled')
    list_filter = ('name', 'enabled')
    search_fields = ('name', 'enabled')


admin.site.register(VirtualMachine, VirtualMachineAdmin)
admin.site.register(Hypervisor, HypervisorAdmin)
admin.site.register(Profile, ProfileAdmin)
admin.site.unregister(User)
admin.site.unregister(Group)
