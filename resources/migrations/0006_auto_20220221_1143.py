# Generated by Django 3.1.7 on 2022-02-21 11:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resources', '0005_auto_20220221_1142'),
    ]

    operations = [
        migrations.AlterField(
            model_name='virtualmachine',
            name='ipv6_privkey',
            field=models.CharField(blank=True, default=None, max_length=256, null=True),
        ),
        migrations.AlterField(
            model_name='virtualmachine',
            name='ipv6_pubkey',
            field=models.CharField(blank=True, default=None, max_length=256, null=True),
        ),
    ]
