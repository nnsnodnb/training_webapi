from django.urls import path

from .views.images import ImageCreateAPIView
from .views.tasks.comments.list_create import CommentListCreateAPIView
from .views.tasks.comments.update_destroy import CommentUpdateDestroyAPIView
from .views.tasks.list_create import TaskListCreateAPIView
from .views.tasks.patch import TaskPartialUpdateAPIView
from .views.tasks.retrieve_update_destroy import TaskRetrieveUpdateDestroyAPIView
from .views.users.destroy import UserDestroyAPIView
from .views.users.refresh import TokenRefreshView
from .views.users.sign_in import TokenObtainPairView

app_name = "webapi"

urlpatterns = [
    path("v1/users", UserDestroyAPIView.as_view(), name="user_delete"),
    path("v1/users/sign-in", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("v1/users/refresh", TokenRefreshView.as_view(), name="token_refresh"),
    path("v1/images", ImageCreateAPIView.as_view(), name="image_create"),
    path("v1/tasks", TaskListCreateAPIView.as_view(), name="tasks_list_create"),
    path("v1/tasks/<int:pk>", TaskRetrieveUpdateDestroyAPIView.as_view(), name="tasks_retrieve_update_delete"),
    path("v1/tasks/<int:pk>/status", TaskPartialUpdateAPIView.as_view(), name="tasks_status_partial_update"),
    path("v1/tasks/<int:pk>/comments", CommentListCreateAPIView.as_view(), name="tasks_comments_list_create"),
    path(
        "v1/tasks/<int:pk>/comments/<int:comment_id>",
        CommentUpdateDestroyAPIView.as_view(),
        name="tasks_comment_update_delete",
    ),
]
