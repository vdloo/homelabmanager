# Generated by Django 3.1.7 on 2021-12-18 10:48

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resources', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='virtualmachine',
            name='static_ip',
            field=models.GenericIPAddressField(blank=True, null=True),
        ),
    ]
