from django.conf import settings
from django.db import models
from django.utils import timezone


class Task(models.Model):
    class StatusChoices(models.TextChoices):
        BACKLOG = "backlog" "バックログ"
        IN_PROGRESS = "in_progress", "進行中"
        IN_REVIEWS = "in_reviews", "レビュー中"
        FINISHED = "finished", "完了"

    title = models.CharField("タイトル", max_length=300)
    thumbnail = models.CharField("サムネイルID", max_length=500, null=True, blank=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    status = models.CharField("ステータス", max_length=12, default=StatusChoices.BACKLOG, choices=StatusChoices.choices)
    created_at = models.DateTimeField("登録日時", default=timezone.now, blank=True)
    updated_at = models.DateTimeField("更新日時", default=timezone.now, blank=True)

    class Meta:
        db_table = "task"
        ordering = ["pk"]
        verbose_name = "タスク"
        verbose_name_plural = "タスク"
