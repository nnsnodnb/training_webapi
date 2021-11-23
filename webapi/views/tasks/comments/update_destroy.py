from drf_rw_serializers.generics import GenericAPIView
from drf_rw_serializers.mixins import UpdateModelMixin
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import mixins, status

from db.models import Comment
from webapi.serializers.comments import ReadCommentSerializer, WriteCommentSerializer


class CommentUpdateDestroyAPIView(UpdateModelMixin, mixins.DestroyModelMixin, GenericAPIView):
    """
    put: 指定したコメントの情報更新

    delete: 指定したコメントの削除
    """

    http_method_names = ["put", "delete"]
    queryset = Comment.objects.select_related("user", "task")
    read_serializer_class = ReadCommentSerializer
    write_serializer_class = WriteCommentSerializer
    lookup_url_kwarg = "comment_id"

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user, task_id=self.request.parser_context["kwargs"]["pk"])

    @swagger_auto_schema(
        request_body=WriteCommentSerializer,
        responses={
            status.HTTP_200_OK: openapi.Response("ok", ReadCommentSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        },
    )
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @swagger_auto_schema(
        responses={
            status.HTTP_204_NO_CONTENT: openapi.Response("deleted"),
            status.HTTP_404_NOT_FOUND: openapi.Response("not found"),
        },
    )
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
