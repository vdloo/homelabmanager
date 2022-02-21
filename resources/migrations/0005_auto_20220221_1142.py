# Generated by Django 3.1.7 on 2022-02-21 11:42

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resources', '0004_virtualmachine_ipv6_overlay'),
    ]

    operations = [
        migrations.AddField(
            model_name='virtualmachine',
            name='ipv6_privkey',
            field=models.CharField(default=None, max_length=256, null=True),
        ),
        migrations.AddField(
            model_name='virtualmachine',
            name='ipv6_pubkey',
            field=models.CharField(default=None, max_length=256, null=True),
        ),
    ]
