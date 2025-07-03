from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('register/', views.register, name='register'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('accounts/profile/', views.profile, name='profile'),
    path('enroll/<int:course_id>/', views.enroll, name='enroll'),
    path('course/<int:course_id>/', views.course_detail, name='course_detail'),
    path('quiz/<int:quiz_id>/', views.take_quiz, name='take_quiz'),
]