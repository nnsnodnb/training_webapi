from drf_rw_serializers.generics import ListCreateAPIView
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status

from db.models.tasks import Task
from webapi.serializers.tasks import PaginationTaskSerializer, ReadTaskModelSerializer, WriteTaskModelSerializer


class TaskListCreateAPIView(ListCreateAPIView):
    """
    get: タスク一覧の取得

    post: タスクの新規作成
    """

    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = WriteTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @swagger_auto_schema(
        responses={status.HTTP_200_OK: openapi.Response("response", PaginationTaskSerializer)},
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @swagger_auto_schema(
        request_body=WriteTaskModelSerializer,
        responses={
            status.HTTP_201_CREATED: openapi.Response("created", ReadTaskModelSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
        },
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
