from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views.tasks.list_create import TaskListCreateAPIView
from .views.tasks.retrieve_update_destroy import TaskRetrieveUpdateDestroyAPIView

app_name = "webapi"

urlpatterns = [
    path("v1/users/sign-in", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("v1/users/refresh", TokenRefreshView.as_view(), name="token_refresh"),
    path("v1/tasks", TaskListCreateAPIView.as_view(), name="tasks_list_create"),
    path("v1/tasks/<int:pk>", TaskRetrieveUpdateDestroyAPIView.as_view(), name="tasks_retrieve_update_destroy"),
]
