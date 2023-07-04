from drf_rw_serializers.generics import RetrieveUpdateDestroyAPIView
from drf_spectacular.utils import OpenApiTypes, extend_schema
from rest_framework import status

from db.models.tasks import Task
from webapi.serializers.errors import NotFoundSerializer
from webapi.serializers.tasks import ReadTaskModelSerializer, WriteTaskModelSerializer


class TaskRetrieveUpdateDestroyAPIView(RetrieveUpdateDestroyAPIView):
    http_method_names = ["get", "put", "delete"]
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = WriteTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @extend_schema(
        operation_id="getTask",
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
            status.HTTP_404_NOT_FOUND: NotFoundSerializer,
        },
        description="指定したタスクの詳細を取得",
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        operation_id="updateTask",
        request=WriteTaskModelSerializer,
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: NotFoundSerializer,
        },
        description="指定したタスクの情報更新",
    )
    def put(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)

    @extend_schema(
        operation_id="deleteTask",
        responses={
            status.HTTP_204_NO_CONTENT: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: NotFoundSerializer,
        },
        description="指定したタスクの削除",
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)
