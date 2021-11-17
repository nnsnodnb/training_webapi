from django.contrib import admin

from .models.tasks import Task


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):

    list_display = (
        "id",
        "title",
        "status",
        "user",
        "created_at",
    )
    list_display_links = (
        "id",
        "title",
        "status",
    )
    list_filter = ("status", "user")
    list_select_related = ("user",)
