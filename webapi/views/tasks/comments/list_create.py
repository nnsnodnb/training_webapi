from django.shortcuts import get_object_or_404
from drf_rw_serializers.generics import ListCreateAPIView
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status

from db.models import Comment, Task
from webapi.serializers.comments import PaginationCommentSerializer, ReadCommentSerializer, WriteCommentSerializer


class CommentListCreateAPIView(ListCreateAPIView):
    """
    get: タスクへのコメント一覧取得

    post: タスクへのコメントの新規作成
    """

    queryset = Comment.objects.select_related("user", "task")
    read_serializer_class = ReadCommentSerializer
    write_serializer_class = WriteCommentSerializer

    @swagger_auto_schema(
        responses={status.HTTP_200_OK: openapi.Response("response", PaginationCommentSerializer)},
    )
    def get(self, request, *args, **kwargs):
        _ = get_object_or_404(Task.objects.select_related("user"), pk=kwargs["pk"], user_id=request.user.id)
        return super().get(request, *args, **kwargs)

    @swagger_auto_schema(
        request_body=WriteCommentSerializer,
        responses={
            status.HTTP_201_CREATED: openapi.Response("created", ReadCommentSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
        },
    )
    def post(self, request, *args, **kwargs):
        _ = get_object_or_404(Task.objects.select_related("user"), pk=kwargs["pk"], user_id=request.user.id)
        return super().post(request, *args, **kwargs)
