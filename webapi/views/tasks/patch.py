from drf_rw_serializers.generics import UpdateAPIView
from drf_spectacular.utils import extend_schema
from rest_framework import status

from db.models import Task
from webapi.serializers.tasks import PartialStatusUpdateTaskModelSerializer, ReadTaskModelSerializer


class TaskPartialUpdateAPIView(UpdateAPIView):
    http_method_names = ["patch"]
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = PartialStatusUpdateTaskModelSerializer

    def get_serializer_class(self):
        return self.read_serializer_class

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @extend_schema(
        operation_id="updateTaskStatus",
        request=PartialStatusUpdateTaskModelSerializer,
        responses={
            status.HTTP_200_OK: ReadTaskModelSerializer,
        },
        tags=["task"],
        description="指定したタスクのステータスを変更",
    )
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)
