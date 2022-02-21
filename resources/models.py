from django.db import models

STORAGE_POOL_CHOICES = [
    ('default', 'default'),
    ('storage', 'storage'),
    ('ramdisk', 'ramdisk'),
]


class Hypervisor(models.Model):
    name = models.CharField(max_length=100)
    interface = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class VirtualMachine(models.Model):
    create = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=100)
    ram_in_mb = models.PositiveSmallIntegerField()
    cpu = models.PositiveSmallIntegerField()
    host = models.ForeignKey('Hypervisor', on_delete=models.CASCADE)
    role = models.CharField(max_length=100)
    profile = models.CharField(max_length=100)
    image = models.CharField(max_length=100)
    static_ip = models.GenericIPAddressField(blank=True, null=True)
    saltmaster_ip = models.GenericIPAddressField(blank=True, null=True)
    enabled = models.BooleanField(default=False)
    ipv6_overlay = models.BooleanField(default=True)
    extra_storage_in_gb = models.PositiveSmallIntegerField(
        default=1
    )
    extra_storage_pool = models.CharField(
        max_length=255,
        choices=STORAGE_POOL_CHOICES,
        default='default',
    )

    class Meta:
        ordering = ('profile', 'name')
        unique_together = ('name', 'profile')
