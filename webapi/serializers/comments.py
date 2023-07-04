from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import exceptions, serializers

from db.models import Comment, Task

from .users import UserSerializer


class ReadCommentSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(help_text="ID")
    content = serializers.CharField(help_text="コンテンツ")
    image_ids = serializers.ListSerializer(
        child=serializers.CharField(),
        allow_empty=True,
        help_text="画像IDのリスト",
    )
    user = UserSerializer()
    created_at = serializers.DateTimeField(source="created", help_text="作成日")

    class Meta:
        model = Comment
        fields = ("id", "content", "image_ids", "user", "created_at")


class WriteCommentSerializer(serializers.ModelSerializer):
    content = serializers.CharField(help_text="コンテンツ")
    image_ids = serializers.ListSerializer(
        child=serializers.CharField(),
        allow_empty=True,
        help_text="画像IDのリスト",
    )
    task = serializers.HiddenField(default=Task.objects.none())
    user = serializers.HiddenField(default=get_user_model().objects.none())

    class Meta:
        model = Comment
        fields = (
            "content",
            "image_ids",
            "task",
            "user",
        )

    def validate_task(self, _):
        if (pk := self.context["request"].parser_context.get("kwargs").get("pk")) is None:
            raise exceptions.ValidationError(detail=["タスクを指定してください"])
        return get_object_or_404(Task.objects.select_related("user"), pk=pk, user_id=self.context["request"].user.id)

    def validate_user(self, _):
        if (request := self.context.get("request")) is None:
            raise exceptions.NotFound()
        return request.user
