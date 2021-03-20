from django.db import models


class Resource(models.Model):
    create = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=100)
    interface = models.CharField(max_length=100)
    ram_in_mb = models.PositiveSmallIntegerField()
    cpu = models.PositiveSmallIntegerField()
    host = models.CharField(max_length=100)
    role = models.CharField(max_length=100)
    profile = models.CharField(max_length=100)
    image = models.CharField(max_length=100)

    class Meta:
        ordering = ('profile', 'name')
        unique_together = ('name', 'profile')
