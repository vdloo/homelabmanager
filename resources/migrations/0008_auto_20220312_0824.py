# Generated by Django 3.1.7 on 2022-03-12 08:24

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('resources', '0007_virtualmachine_ipv6_ip'),
    ]

    operations = [
        migrations.CreateModel(
            name='Profile',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
            ],
        ),
        migrations.AlterField(
            model_name='virtualmachine',
            name='profile',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='resources.profile'),
        ),
    ]
