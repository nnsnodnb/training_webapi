from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView

from webapi.serializers.tokens import ReadRefreshTokenSerializer


class TokenRefreshView(BaseTokenRefreshView):
    @swagger_auto_schema(
        request_body=TokenRefreshSerializer,
        responses={status.HTTP_200_OK: openapi.Response("OK", ReadRefreshTokenSerializer)},
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
