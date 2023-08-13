from drf_spectacular.utils import OpenApiResponse, OpenApiTypes, extend_schema, inline_serializer
from rest_framework import serializers, status
from rest_framework.generics import DestroyAPIView


class UserDestroyAPIView(DestroyAPIView):
    def get_object(self):
        return self.request.user

    @extend_schema(
        operation_id="deleteUser",
        responses={
            status.HTTP_204_NO_CONTENT: OpenApiTypes.NONE,
            status.HTTP_401_UNAUTHORIZED: OpenApiResponse(
                response=inline_serializer(
                    name="DeleteUserUnauthorizedResponse",
                    fields={
                        "detail": serializers.CharField(required=True),
                        "code": serializers.CharField(required=True),
                    },
                ),
            ),
        },
        tags=["user"],
    )
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
