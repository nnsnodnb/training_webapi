from rest_framework import serializers


class ReadImageSerializer(serializers.Serializer):

    image_id = serializers.CharField()

    class Meta:
        fields = ("image_id",)


class WriteImageSerializer(serializers.Serializer):

    image = serializers.FileField()

    class Meta:
        fields = ("image",)

    def create(self, validated_data):
        # TODO: パスを返す
        return {"image_id": "/hoge/foo/bar/example.jpg"}
