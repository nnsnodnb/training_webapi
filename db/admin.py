from django.contrib import admin

from .models import Comment, Task


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "content",
        "image_ids",
        "user",
        "task",
        "created",
    )
    list_display_links = (
        "id",
        "content",
    )
    list_filter = (
        "user",
        "task",
    )
    list_select_related = (
        "user",
        "task",
    )


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "title",
        "status",
        "user",
        "created",
    )
    list_display_links = (
        "id",
        "title",
        "status",
    )
    list_filter = ("status", "user")
    list_select_related = ("user",)
