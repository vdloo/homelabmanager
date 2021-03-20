from django.contrib import admin
from resources.models import Resource
from django.contrib.auth.models import User
from django.contrib.auth.models import Group


class ResourceAdmin(admin.ModelAdmin):
    list_display = ('name', 'ram_in_mb', 'interface', 'cpu', 'host', 'role', 'profile', 'image')
    list_filter = ('name', 'ram_in_mb', 'interface', 'cpu', 'host', 'role', 'profile', 'image')
    search_fields = ('name', 'host', 'role', 'profile')


admin.site.register(Resource, ResourceAdmin)
admin.site.unregister(User)
admin.site.unregister(Group)
