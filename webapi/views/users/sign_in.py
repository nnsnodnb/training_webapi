from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from rest_framework_simplejwt.views import TokenObtainPairView as BaseTokenObtainPairView

from webapi.serializers.tokens import ReadTokenSerializer, WriteTokenSerializer


class TokenObtainPairView(BaseTokenObtainPairView):

    serializer_class = WriteTokenSerializer

    @swagger_auto_schema(
        request_body=WriteTokenSerializer,
        responses={
            status.HTTP_200_OK: openapi.Response("OK", ReadTokenSerializer),
            status.HTTP_400_BAD_REQUEST: openapi.Response("validation error"),
        },
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
