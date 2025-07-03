from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from .forms import RegisterForm
from .models import Course, Enrollment, Lesson, Quiz, Question, QuizResult

def home(request):
    courses = Course.objects.all()
    return render(request, 'courses/home.html', {'courses': courses})

def register(request):
    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            return redirect('home')
    else:
        form = RegisterForm()
    return render(request, 'courses/register.html', {'form': form})

@login_required
def enroll(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    Enrollment.objects.get_or_create(user=request.user, course=course)
    return redirect('dashboard')

@login_required
def dashboard(request):
    enrollments = Enrollment.objects.filter(user=request.user)
    results = QuizResult.objects.filter(user=request.user)
    return render(request, 'courses/dashboard.html', {'enrollments': enrollments, 'results': results})
@login_required
def profile(request):
    enrollments = Enrollment.objects.filter(user=request.user)
    results = QuizResult.objects.filter(user=request.user)
    return render(request, 'courses/profile.html', {'enrollments': enrollments, 'results': results})

@login_required
def course_detail(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    if not Enrollment.objects.filter(user=request.user, course=course).exists():
        return redirect('home')
    lessons = course.lessons.all()
    quizzes = course.quizzes.all()
    return render(request, 'courses/course_detail.html', {'course': course, 'lessons': lessons, 'quizzes': quizzes})

@login_required
def take_quiz(request, quiz_id):
    quiz = get_object_or_404(Quiz, id=quiz_id)
    if request.method == 'POST':
        score = 0
        total = quiz.questions.count()
        for question in quiz.questions.all():
            selected = request.POST.get(f'question_{question.id}')
            if selected == question.correct_answer:
                score += 1
        QuizResult.objects.create(user=request.user, quiz=quiz, score=score)
        return redirect('dashboard')
    return render(request, 'courses/take_quiz.html', {'quiz': quiz})