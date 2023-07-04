from drf_spectacular.utils import OpenApiResponse, extend_schema, inline_serializer
from rest_framework import serializers, status
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView

from webapi.serializers.tokens import ReadRefreshTokenSerializer


class TokenRefreshView(BaseTokenRefreshView):
    @extend_schema(
        operation_id="refresh_token",
        request=TokenRefreshSerializer,
        responses={
            status.HTTP_200_OK: ReadRefreshTokenSerializer,
            status.HTTP_401_UNAUTHORIZED: OpenApiResponse(
                response=inline_serializer(
                    name="TokenRefreshUnauthorizedResponse",
                    fields={
                        "detail": serializers.CharField(required=True),
                        "code": serializers.CharField(required=True),
                    },
                ),
            ),
        },
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
