from drf_rw_serializers.generics import RetrieveUpdateDestroyAPIView
from drf_spectacular.utils import extend_schema, inline_serializer, OpenApiResponse, OpenApiTypes
from rest_framework import serializers, status

from db.models.tasks import Task
from webapi.serializers.tasks import ReadTaskModelSerializer, WriteTaskModelSerializer


class TaskRetrieveUpdateDestroyAPIView(RetrieveUpdateDestroyAPIView):
    http_method_names = ["get", "put", "delete"]
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = WriteTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @extend_schema(
        operation_id="get_task",
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="GetTaskNotFoundResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        description="指定したタスクの詳細を取得",
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        operation_id="update_task",
        request=WriteTaskModelSerializer,
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiResponse(
                response=inline_serializer(
                    name="UpdateTaskBadRequestResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="UpdateTaskNotFoundResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        description="指定したタスクの情報更新",
    )
    def put(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)

    @extend_schema(
        operation_id="delete_task",
        responses={
            status.HTTP_204_NO_CONTENT: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="DeleteTaskNotFoundResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        description="指定したタスクの削除",
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)
