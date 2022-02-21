from json import loads
from subprocess import check_output

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


def generate_ip6_keypair():
    raw_new_config = check_output(
        "/usr/local/bin/yggdrasil --genconf --json",
        shell=True
    )
    new_config = loads(raw_new_config)
    return new_config['PublicKey'], new_config['PrivateKey']


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
    ipv6_pubkey = models.CharField(max_length=256, default=None, null=True, blank=True)
    ipv6_privkey = models.CharField(max_length=256, default=None, null=True, blank=True)
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

    def save(self, *args, **kwargs):
        if self.ipv6_overlay and not self.ipv6_pubkey or not self.ipv6_privkey:
            self.ipv6_pubkey, self.ipv6_privkey = generate_ip6_keypair()
        super(VirtualMachine, self).save(*args, **kwargs)
