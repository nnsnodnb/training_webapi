from django.contrib.auth import get_user_model
from rest_framework import serializers


class UserSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(help_text="ID")
    username = serializers.CharField(help_text="ユーザネーム")

    class Meta:
        model = get_user_model()
        fields = (
            "id",
            "username",
        )
