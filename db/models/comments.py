from django.conf import settings
from django.contrib.postgres import fields
from django.db import models
from django.utils import timezone


class Comment(models.Model):
    content = models.CharField("コンテンツ", max_length=500)
    image_ids = fields.ArrayField(
        base_field=models.CharField(max_length=500),
        size=4,
        default=list,
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    task = models.ForeignKey("db.Task", on_delete=models.CASCADE)
    created = models.DateTimeField("作成日時", default=timezone.now, blank=True)

    class Meta:
        db_table = "comment"
        ordering = ["pk"]
        verbose_name = "コメント"
        verbose_name_plural = "コメント"
