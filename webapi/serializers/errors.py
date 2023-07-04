from rest_framework import serializers


class NotFoundSerializer(serializers.Serializer):
    detail = serializers.CharField(required=True)

    class Meta:
        fields = ("detail",)
