from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from drf_rw_serializers.generics import RetrieveUpdateDestroyAPIView

from db.models.tasks import Task
from webapi.serializers.tasks import ReadTaskModelSerializer, WriteTaskModelSerializer


class TaskRetrieveUpdateDestroyAPIView(RetrieveUpdateDestroyAPIView):
    """
    get: 指定したタスクの詳細を取得

    put: 指定したタスクの情報更新

    delete: 指定したタスクの削除
    """

    http_method_names = ["get", "put", "delete"]
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = WriteTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @swagger_auto_schema(
        responses={
            status.HTTP_200_OK: openapi.Response("response", ReadTaskModelSerializer),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        },
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @swagger_auto_schema(
        request_body=WriteTaskModelSerializer,
        responses={
            status.HTTP_200_OK: openapi.Response("updated", ReadTaskModelSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        },
    )
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)

    @swagger_auto_schema(
        responses={
            status.HTTP_204_NO_CONTENT: openapi.Response("deleted"),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        }
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)
