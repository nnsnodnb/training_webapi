from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

app_name = "webapi"

urlpatterns = [
    path("v1/users/sign-in", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("v1/users/refresh", TokenRefreshView.as_view(), name="token_refresh"),
]
