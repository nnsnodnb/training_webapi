from datetime import timedelta

from django.utils import timezone
from maintenance_mode.core import get_maintenance_mode
from rest_framework import exceptions, status
from rest_framework.response import Response
from rest_framework.views import APIView


class MaintenanceJSONAPIView(APIView):
    authentication_classes = ()
    http_method_names = ["get"]
    permission_classes = ()
    swagger_schema = None

    def get(self, request, *args, **kwargs):
        if get_maintenance_mode():
            date = (timezone.now() + timedelta(hours=2 + 9)).strftime("%Y年%m月%d日 %H時00分")
            data = {
                "error_detail": {"title": "現在サービスはメンテナンス中です。", "body": f"終了は{date}を予定しています。"},
            }
            return Response(data=data, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        else:
            raise exceptions.NotFound()
