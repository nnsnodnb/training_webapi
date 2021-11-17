from rest_framework.generics import RetrieveUpdateDestroyAPIView
from rest_framework import permissions, status
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema

from db.models.tasks import Task
from webapi.serializers.tasks import WriteTaskModelSerializer, ReadTaskModelSerializer


class TaskRetrieveUpdateDestroyAPIView(RetrieveUpdateDestroyAPIView):
    """
    get: 指定したタスクの詳細を取得

    put: 指定したタスクの情報更新

    delete: 指定したタスクの削除
    """
    http_method_names = ["get", "put", "delete"]
    queryset = Task.objects.select_related("user")
    serializer_class = WriteTaskModelSerializer
    permission_classes = (permissions.IsAuthenticated,)

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
        }
    )
    def update(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)

    @swagger_auto_schema(
        responses={
            status.HTTP_204_NO_CONTENT: openapi.Response("deleted"),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        }
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)
