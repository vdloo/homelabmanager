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


class Profile(models.Model):
    name = models.CharField(max_length=100, unique=True)
    enabled = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if self.enabled:
            all_profiles = Profile.objects.exclude(
                name=self.name
            )
            for profile in all_profiles:
                profile.enabled = False
                profile.save()
        super(Profile, self).save(*args, **kwargs)

    def __str__(self):
        return self.name


def generate_ipv6_keypair():
    raw_new_config = check_output(
        "/usr/local/bin/yggdrasil --genconf --json",
        shell=True
    )
    new_config = loads(raw_new_config)
    return new_config['PublicKey'], new_config['PrivateKey']


def get_ipv6_ip_by_pubkey(pubkey):
    """
    Get the IPv6 overlay IP from the pubkey
    :param str pubkey: The pubkey
    :return str ipv6_address: The IPv6 address
    """
    return check_output(["/usr/local/bin/addrforkey", pubkey]).decode('utf-8').split(' ')[1].strip()


class VirtualMachine(models.Model):
    create = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=100)
    ram_in_mb = models.PositiveSmallIntegerField()
    cpu = models.PositiveSmallIntegerField()
    host = models.ForeignKey('Hypervisor', on_delete=models.CASCADE)
    role = models.CharField(max_length=100)
    profile = models.ForeignKey('Profile', on_delete=models.CASCADE)
    image = models.CharField(max_length=100)
    static_ip = models.GenericIPAddressField(blank=True, null=True)
    saltmaster_ip = models.GenericIPAddressField(blank=True, null=True)
    enabled = models.BooleanField(default=False)
    ipv6_overlay = models.BooleanField(default=True)
    ipv6_pubkey = models.CharField(max_length=256, default=None, null=True, blank=True)
    ipv6_privkey = models.CharField(max_length=256, default=None, null=True, blank=True)
    ipv6_ip = models.CharField(max_length=256, default=None, null=True, blank=True)
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
        if self.ipv6_overlay and (not self.ipv6_pubkey or not self.ipv6_privkey or not self.ipv6_ip):
            self.ipv6_pubkey, self.ipv6_privkey = generate_ipv6_keypair()
            self.ipv6_ip = get_ipv6_ip_by_pubkey(self.ipv6_pubkey)
        super(VirtualMachine, self).save(*args, **kwargs)
