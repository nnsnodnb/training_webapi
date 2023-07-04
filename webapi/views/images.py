from drf_rw_serializers.generics import CreateAPIView
from drf_spectacular.utils import OpenApiResponse, extend_schema, inline_serializer
from rest_framework import serializers, status
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response

from webapi.serializers.images import ReadImageSerializer, WriteImageSerializer


class ImageCreateAPIView(CreateAPIView):
    parser_classes = (MultiPartParser,)
    read_serializer_class = ReadImageSerializer
    write_serializer_class = WriteImageSerializer

    @extend_schema(
        operation_id="uploadImage",
        request={
            "multipart/form-data": {
                "type": "object",
                "properties": {
                    "image": {
                        "type": "string",
                        "format": "binary",
                    },
                },
                "required": [
                    "image",
                ],
            },
        },
        responses={
            status.HTTP_200_OK: ReadImageSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiResponse(
                response=inline_serializer(
                    name="ImageBadRequestResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        tags=["image"],
        description="画像アップロード",
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def create(self, request, *args, **kwargs):
        write_serializer = self.get_write_serializer(data=request.data)
        write_serializer.is_valid(raise_exception=True)
        self.perform_create(write_serializer)

        read_serializer = self.get_read_serializer(write_serializer.instance)

        return Response(read_serializer.data, status=status.HTTP_200_OK)
