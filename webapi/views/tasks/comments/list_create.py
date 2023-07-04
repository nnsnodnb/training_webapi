from django.shortcuts import get_object_or_404
from drf_rw_serializers.generics import ListCreateAPIView
from drf_spectacular.utils import OpenApiParameter, OpenApiTypes, extend_schema
from rest_framework import status

from db.models import Comment, Task
from webapi.serializers.comments import ReadCommentSerializer, WriteCommentSerializer


class CommentListCreateAPIView(ListCreateAPIView):
    queryset = Comment.objects.select_related("user", "task")
    read_serializer_class = ReadCommentSerializer
    write_serializer_class = WriteCommentSerializer

    def filter_queryset(self, queryset):
        return queryset.filter(user=self.request.user, task_id=self.request.parser_context["kwargs"]["pk"])

    @extend_schema(
        operation_id="fetchTaskComments",
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
            status.HTTP_200_OK: ReadCommentSerializer,
        },
        tags=["task_comment"],
        description="タスクへのコメント一覧取得",
    )
    def get(self, request, *args, **kwargs):
        _ = get_object_or_404(Task.objects.select_related("user"), pk=kwargs["pk"], user_id=request.user.id)
        return super().get(request, *args, **kwargs)

    @extend_schema(
        operation_id="createTaskComments",
        parameters=[
            OpenApiParameter(
                name="authorization",
                type=OpenApiTypes.STR,
                location=OpenApiParameter.HEADER,
                required=True,
            ),
        ],
        request=WriteCommentSerializer,
        responses={
            status.HTTP_201_CREATED: ReadCommentSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiTypes.NONE,
        },
        tags=["task_comment"],
        description="タスクへのコメントの新規作成",
    )
    def post(self, request, *args, **kwargs):
        _ = get_object_or_404(Task.objects.select_related("user"), pk=kwargs["pk"], user_id=request.user.id)
        return super().post(request, *args, **kwargs)
