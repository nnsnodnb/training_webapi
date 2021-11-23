from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import exceptions, serializers

from db.models.tasks import Task

from .users import UserSerializer


class ReadTaskModelSerializer(serializers.ModelSerializer):

    id = serializers.IntegerField()
    title = serializers.CharField()
    thumbnail = serializers.CharField(required=False, allow_null=True)
    user = UserSerializer()
    status = serializers.ChoiceField(choices=Task.StatusChoices.choices)
    created_at = serializers.DateTimeField(source="created")
    updated_at = serializers.DateTimeField(source="updated")

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

    title = serializers.CharField(required=True, max_length=300)
    thumbnail = serializers.CharField(required=False, max_length=500, allow_null=True)
    user = serializers.HiddenField(default=get_user_model().objects.none())
    status = serializers.ChoiceField(
        required=False, choices=Task.StatusChoices.choices, default=Task.StatusChoices.BACKLOG
    )
    updated_at = serializers.HiddenField(default=timezone.now, source="updated")

    class Meta:
        model = Task
        fields = ("title", "title", "thumbnail", "user", "status", "updated_at")

    def validate_user(self, _):
        if (request := self.context.get("request")) is None:
            raise exceptions.NotFound()
        return request.user


class PartialStatusUpdateTaskModelSerializer(serializers.ModelSerializer):

    status = serializers.ChoiceField(choices=Task.StatusChoices.choices)

    class Meta:
        model = Task
        fields = ("status",)


class PaginationTaskSerializer(serializers.Serializer):

    next = serializers.CharField(required=False, allow_null=True)
    previous = serializers.CharField(required=False, allow_null=True)
    results = ReadTaskModelSerializer(many=True)
