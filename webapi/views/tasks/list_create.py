from rest_framework.generics import ListCreateAPIView


class TaskListCreateAPIView(ListCreateAPIView):
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)

    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
