"""homelabmgr URL Configuration
"""
from django.contrib import admin
from django.urls import path
from resources import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('terraform/', views.terraform, name='terraform'),
]
