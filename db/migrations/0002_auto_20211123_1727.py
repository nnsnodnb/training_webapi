# Generated by Django 3.2.9 on 2021-11-23 08:27

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ("db", "0001_initial"),
    ]

    operations = [
        migrations.RenameField(
            model_name="task",
            old_name="created_at",
            new_name="created",
        ),
        migrations.RenameField(
            model_name="task",
            old_name="updated_at",
            new_name="updated",
        ),
    ]