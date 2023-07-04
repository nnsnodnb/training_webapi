from datetime import timedelta

from django.utils import timezone
from drf_rw_serializers.generics import GenericAPIView
from drf_spectacular.utils import OpenApiExample, OpenApiResponse, extend_schema, inline_serializer
from maintenance_mode.core import get_maintenance_mode
from rest_framework import exceptions, serializers, status
from rest_framework.response import Response


class MaintenanceJSONAPIView(GenericAPIView):
    authentication_classes = ()
    http_method_names = ["get"]
    permission_classes = ()

    @extend_schema(
        operation_id="maintenance",
        responses={
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=inline_serializer(
                    name="MaintenanceNotFoundResponse",
                    fields={
                        "detail": serializers.CharField(required=True),
                    },
                ),
            ),
            status.HTTP_503_SERVICE_UNAVAILABLE: OpenApiResponse(
                response=inline_serializer(
                    name="MaintenanceServiceUnavailableResponse",
                    fields={
                        "error_detail": inline_serializer(
                            name="MaintenanceServiceUnavailableResponseChild",
                            fields={
                                "title": serializers.CharField(required=True),
                                "body": serializers.CharField(required=True),
                            },
                        ),
                    },
                ),
                examples=[
                    OpenApiExample(
                        name="example",
                        value={
                            "error_detail": {
                                "title": "現在サービスはメンテナンス中です。",
                                "body": "終了は2023年7月4日2時00分を予定しています。",
                            },
                        },
                    ),
                ],
            ),
        },
        description="メンテナンス情報を取得",
    )
    def get(self, request, *args, **kwargs):
        if get_maintenance_mode():
            date = (timezone.now() + timedelta(hours=2 + 9)).strftime("%Y年%m月%d日 %H時00分")
            data = {
                "error_detail": {"title": "現在サービスはメンテナンス中です。", "body": f"終了は{date}を予定しています。"},
            }
            return Response(data=data, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        else:
            raise exceptions.NotFound()
