from drf_rw_serializers.generics import GenericAPIView
from drf_rw_serializers.mixins import UpdateModelMixin
from drf_spectacular.utils import OpenApiResponse, OpenApiTypes, extend_schema, inline_serializer
from rest_framework import mixins, serializers, status

from db.models import Comment
from webapi.serializers.comments import ReadCommentSerializer, WriteCommentSerializer


class CommentUpdateDestroyAPIView(UpdateModelMixin, mixins.DestroyModelMixin, GenericAPIView):
    http_method_names = ["put", "delete"]
    queryset = Comment.objects.select_related("user", "task")
    read_serializer_class = ReadCommentSerializer
    write_serializer_class = WriteCommentSerializer
    lookup_url_kwarg = "comment_id"

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user, task_id=self.request.parser_context["kwargs"]["pk"])

    @extend_schema(
        operation_id="update_task_comment",
        request=WriteCommentSerializer,
        responses={
            status.HTTP_200_OK: ReadCommentSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiResponse(
                response=inline_serializer(
                    name="UpdateTaskCommentBadRequestResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="UpdateTaskCommentNotFoundResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        description="指定したコメントの情報更新",
    )
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @extend_schema(
        operation_id="delete_task_comment",
        responses={
            status.HTTP_204_NO_CONTENT: OpenApiTypes.NONE,
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="DeleteTaskCommentNotFoundResponse",
                    fields={
                        "error_detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        description="指定したコメントの削除",
    )
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
