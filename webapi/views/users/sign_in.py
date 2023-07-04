from drf_spectacular.utils import OpenApiResponse, extend_schema, inline_serializer
from rest_framework import serializers, status
from rest_framework_simplejwt.views import TokenObtainPairView as BaseTokenObtainPairView

from webapi.serializers.tokens import ReadTokenSerializer, WriteTokenSerializer


class TokenObtainPairView(BaseTokenObtainPairView):
    serializer_class = WriteTokenSerializer

    @extend_schema(
        operation_id="signIn",
        request=WriteTokenSerializer,
        responses={
            status.HTTP_200_OK: ReadTokenSerializer,
            status.HTTP_400_BAD_REQUEST: OpenApiResponse(
                response=inline_serializer(
                    name="SignInBadRequestResponse",
                    fields={
                        "username": serializers.ListSerializer(
                            child=serializers.CharField(required=True), required=False
                        ),
                        "password": serializers.ListSerializer(
                            child=serializers.CharField(required=True),
                            required=False,
                        ),
                    },
                ),
            ),
            status.HTTP_401_UNAUTHORIZED: OpenApiResponse(
                response=inline_serializer(
                    name="SignInUnauthorizedResponse",
                    fields={
                        "detail": serializers.CharField(required=True),
                    },
                ),
            ),
        },
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
