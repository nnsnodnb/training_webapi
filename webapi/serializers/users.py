from django.contrib.auth import get_user_model
from rest_framework import serializers


class UserSerializer(serializers.ModelSerializer):

    id = serializers.IntegerField()
    username = serializers.CharField()

    class Meta:
        model = get_user_model()
        fields = (
            "id",
            "username",
        )
