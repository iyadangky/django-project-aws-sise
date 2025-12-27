from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm
from .models import ConsultationRequest

def index(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        phone = request.POST.get('phone')
        if name and phone:
            ConsultationRequest.objects.create(name=name, phone=phone)
            return render(request, 'landing/index.html', {'success': True})
    return render(request, 'landing/index.html')

def custom_login(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            login(request, form.get_user())
            return redirect('dashboard')
    else:
        form = AuthenticationForm()
    return render(request, 'landing/login.html', {'form': form})

def custom_logout(request):
    logout(request)
    return redirect('index')

@login_required
def dashboard(request):
    requests = ConsultationRequest.objects.all().order_by('-created_at')
    return render(request, 'landing/dashboard.html', {'requests': requests})
