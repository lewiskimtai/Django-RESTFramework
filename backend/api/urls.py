from django.urls import path
from .views import RegisterView, LoginView, HomeView

urlpatterns = [
    path('auth/register/', RegisterView.as_view()),
    path('auth/login/', LoginView.as_view()),
    path('home/', HomeView.as_view()),
]
