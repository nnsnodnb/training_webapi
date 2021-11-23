from drf_rw_serializers.generics import UpdateAPIView
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status

from db.models import Task
from webapi.serializers.tasks import PartialStatusUpdateTaskModelSerializer, ReadTaskModelSerializer


class TaskPartialUpdateAPIView(UpdateAPIView):

    http_method_names = ["patch"]
    queryset = Task.objects.select_related("user")
    read_serializer_class = ReadTaskModelSerializer
    write_serializer_class = PartialStatusUpdateTaskModelSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user)

    @swagger_auto_schema(
        request_body=PartialStatusUpdateTaskModelSerializer,
        responses={status.HTTP_200_OK: openapi.Response("OK", ReadTaskModelSerializer)},
    )
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)
