from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import exceptions, serializers

from db.models.tasks import Task

from .users import UserSerializer


class ReadTaskModelSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(help_text="ID")
    title = serializers.CharField(help_text="タイトル")
    thumbnail = serializers.CharField(required=False, allow_null=True, help_text="画像ID")
    user = UserSerializer()
    status = serializers.ChoiceField(choices=Task.StatusChoices.choices, help_text="ステータス")
    created_at = serializers.DateTimeField(source="created", help_text="作成日")
    updated_at = serializers.DateTimeField(source="updated", help_text="更新日")

    class Meta:
        model = Task
        fields = (
            "id",
            "title",
            "thumbnail",
            "user",
            "status",
            "created_at",
            "updated_at",
        )


class WriteTaskModelSerializer(serializers.ModelSerializer):
    title = serializers.CharField(required=True, max_length=300, help_text="タイトル")
    image_id = serializers.CharField(
        required=False, max_length=500, allow_null=True, source="thumbnail", help_text="画像ID"
    )
    user = serializers.HiddenField(default=get_user_model().objects.none())
    status = serializers.ChoiceField(
        required=False, choices=Task.StatusChoices.choices, default=Task.StatusChoices.BACKLOG, help_text="ステータス"
    )
    updated_at = serializers.HiddenField(default=timezone.now, source="updated", help_text="更新日")

    class Meta:
        model = Task
        fields = ("title", "title", "image_id", "user", "status", "updated_at")

    def validate_user(self, _):
        if (request := self.context.get("request")) is None:
            raise exceptions.NotFound()
        return request.user


class PartialStatusUpdateTaskModelSerializer(serializers.ModelSerializer):
    status = serializers.ChoiceField(choices=Task.StatusChoices.choices, help_text="ステータス")

    class Meta:
        model = Task
        fields = ("status",)
