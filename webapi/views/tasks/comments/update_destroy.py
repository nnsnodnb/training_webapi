from drf_rw_serializers.generics import GenericAPIView
from drf_rw_serializers.mixins import UpdateModelMixin
from drf_spectacular.utils import OpenApiTypes, extend_schema
from rest_framework import mixins, status

from db.models import Comment
from webapi.serializers.comments import ReadCommentSerializer, WriteCommentSerializer
from webapi.serializers.errors import NotFoundSerializer


class CommentUpdateDestroyAPIView(UpdateModelMixin, mixins.DestroyModelMixin, GenericAPIView):
    http_method_names = ["put", "delete"]
    queryset = Comment.objects.select_related("user", "task")
    read_serializer_class = ReadCommentSerializer
    write_serializer_class = WriteCommentSerializer
    lookup_url_kwarg = "comment_id"

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user, task_id=self.request.parser_context["kwargs"]["pk"])

    @extend_schema(
        operation_id="updateTaskComment",
        request=WriteCommentSerializer,
        responses={
            status.HTTP_200_OK: ReadCommentSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: NotFoundSerializer,
        },
        description="指定したコメントの情報更新",
    )
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @extend_schema(
        operation_id="deleteTaskComment",
        responses={
            status.HTTP_204_NO_CONTENT: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: NotFoundSerializer,
        },
        description="指定したコメントの削除",
    )
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
