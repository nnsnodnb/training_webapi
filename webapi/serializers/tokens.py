from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.models import update_last_login
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from rest_framework_simplejwt.exceptions import exceptions
from rest_framework_simplejwt.serializers import PasswordField
from rest_framework_simplejwt.settings import api_settings
from rest_framework_simplejwt.tokens import RefreshToken


class ReadTokenSerializer(serializers.Serializer):

    refresh = serializers.CharField()
    access = serializers.CharField()

    class Meta:
        fields = (
            "refresh",
            "access",
        )


class WriteTokenSerializer(serializers.Serializer):
    username_field = get_user_model().USERNAME_FIELD

    default_error_messages = {"no_active_account": _("No active account found with the given credentials")}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.fields[self.username_field] = serializers.CharField()
        self.fields["password"] = PasswordField()

    @classmethod
    def get_token(cls, user):
        return RefreshToken.for_user(user)

    def validate(self, attrs):
        username = attrs[self.username_field]
        password = attrs["password"]

        authenticate_kwargs = {
            self.username_field: username,
            "password": password,
        }
        try:
            authenticate_kwargs["request"] = self.context["request"]
        except KeyError:
            pass

        self.user = authenticate(**authenticate_kwargs)

        if not self.user:
            if get_user_model().objects.filter(username=username).exists():
                raise exceptions.AuthenticationFailed(
                    self.error_messages["no_active_account"],
                    "no_active_account",
                )

            self.user = get_user_model().objects.create_user(username=username, password=password)

        if not api_settings.USER_AUTHENTICATION_RULE(self.user):
            raise exceptions.AuthenticationFailed(
                self.error_messages["no_active_account"],
                "no_active_account",
            )

        refresh = self.get_token(self.user)

        data = {"refresh": str(refresh), "access": str(refresh.access_token)}

        if api_settings.UPDATE_LAST_LOGIN:
            update_last_login(None, self.user)

        return data
