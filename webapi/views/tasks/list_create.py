from drf_rw_serializers.generics import ListCreateAPIView
from drf_spectacular.utils import OpenApiParameter, OpenApiTypes, extend_schema
from rest_framework import status

from db.models.tasks import Task
from webapi.serializers.tasks import ReadTaskModelSerializer, WriteTaskModelSerializer


class TaskListCreateAPIView(ListCreateAPIView):
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = WriteTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @extend_schema(
        operation_id="fetchTasks",
        parameters=[
            OpenApiParameter(
                name="authorization",
                type=OpenApiTypes.STR,
                location=OpenApiParameter.HEADER,
                required=True,
            ),
            OpenApiParameter(
                name="cursor",
                description="The pagination cursor value.",
            ),
        ],
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
        },
        tags=["task"],
        description="タスク一覧の取得",
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        operation_id="createTask",
        parameters=[
            OpenApiParameter(
                name="authorization",
                type=OpenApiTypes.STR,
                location=OpenApiParameter.HEADER,
                required=True,
            ),
        ],
        request=WriteTaskModelSerializer,
        responses={
            status.HTTP_201_CREATED: ReadTaskModelSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiTypes.NONE,
        },
        tags=["task"],
        description="タスクの新規作成",
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
