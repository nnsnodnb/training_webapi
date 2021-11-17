from drf_rw_serializers.generics import CreateAPIView
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import permissions, status
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response

from webapi.serializers.images import ReadImageSerializer, WriteImageSerializer


class ImageCreateAPIView(CreateAPIView):
    """
    post: 画像アップロードAPI
    """

    parser_classes = (MultiPartParser,)
    permission_classes = (permissions.IsAuthenticated,)
    read_serializer_class = ReadImageSerializer
    write_serializer_class = WriteImageSerializer

    @swagger_auto_schema(
        request_body=WriteImageSerializer,
        responses={
            status.HTTP_200_OK: openapi.Response("uploaded", ReadImageSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
        },
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def create(self, request, *args, **kwargs):
        write_serializer = self.get_write_serializer(data=request.data)
        write_serializer.is_valid(raise_exception=True)
        self.perform_create(write_serializer)

        read_serializer = self.get_read_serializer(write_serializer.instance)

        return Response(read_serializer.data, status=status.HTTP_200_OK)
