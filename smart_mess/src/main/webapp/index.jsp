<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartMess - Smart College Mess Food Management System</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Top Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark" style="background-color: var(--navy-dark);">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="${pageContext.request.contextPath}/">
                <span class="badge bg-success p-2 fs-6"><i class="bi bi-egg-fried"></i></span>
                <span>SmartMess</span>
            </a>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm px-3">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                </a>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-sm px-3">
                    <i class="bi bi-person-plus me-1"></i> Student Register
                </a>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <div class="py-5 text-white" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);">
        <div class="container py-4 text-center">
            <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 rounded-pill mb-3">
                <i class="bi bi-database-check me-1"></i> Powered by Java Servlets & Oracle Database 21c
            </span>
            <h1 class="display-5 fw-bold mb-3">Smart College Mess Food Management System</h1>
            <p class="lead text-light opacity-75 mx-auto" style="max-width: 750px;">
                Digitizing daily meal schedules, student attendance forecasting, food feedback, 
                grievance handling, and food wastage tracking for college dining halls.
            </p>
            <div class="d-flex justify-content-center gap-3 mt-4">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-lg px-4 shadow">
                    Launch Application <i class="bi bi-arrow-right ms-1"></i>
                </a>
                <a href="#demo-accounts" class="btn btn-outline-light btn-lg px-4">
                    Demo Credentials <i class="bi bi-key ms-1"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- Core Features Grid -->
    <div class="container py-5">
        <div class="row g-4 text-center mb-5">
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm p-4 rounded-4">
                    <div class="fs-1 text-success mb-3"><i class="bi bi-calendar-check"></i></div>
                    <h5 class="fw-bold">Daily Menu & Attendance</h5>
                    <p class="text-muted small">
                        View daily breakfast, lunch, and dinner. Students mark meal presence/absence to prevent food wastage.
                    </p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm p-4 rounded-4">
                    <div class="fs-1 text-primary mb-3"><i class="bi bi-star-half"></i></div>
                    <h5 class="fw-bold">Feedback & Grievances</h5>
                    <p class="text-muted small">
                        Submit 1-5 star ratings on food quality, taste, and cleanliness. File and track complaints from pending to resolved.
                    </p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm p-4 rounded-4">
                    <div class="fs-1 text-danger mb-3"><i class="bi bi-graph-down-arrow"></i></div>
                    <h5 class="fw-bold">Wastage Analytics</h5>
                    <p class="text-muted small">
                        Mess staff logs food prepared, served, and wasted in kg. Live percentage calculation and graphical reports.
                    </p>
                </div>
            </div>
        </div>

        <!-- Demo Accounts Section -->
        <div id="demo-accounts" class="card border-0 shadow-sm rounded-4 p-4 p-md-5 bg-white">
            <div class="text-center mb-4">
                <h3 class="fw-bold text-dark">Ready-to-Test Demo Accounts</h3>
                <p class="text-muted">Use these pre-configured Oracle accounts to explore all three roles immediately.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="border rounded-3 p-3 bg-light h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="badge bg-danger">ADMIN ROLE</span>
                            <i class="bi bi-shield-lock text-danger fs-5"></i>
                        </div>
                        <h6 class="fw-bold mb-1">Administrator</h6>
                        <p class="small text-muted mb-2">Full analytics, user management, and complaint oversight.</p>
                        <div class="small font-monospace bg-white p-2 border rounded">
                            <div><strong>Email:</strong> admin@smartmess.edu</div>
                            <div><strong>Password:</strong> admin123</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?email=admin@smartmess.edu" class="btn btn-outline-danger btn-sm w-100 mt-3">
                            Sign In as Admin
                        </a>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="border rounded-3 p-3 bg-light h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="badge bg-primary">STAFF ROLE</span>
                            <i class="bi bi-person-badge text-primary fs-5"></i>
                        </div>
                        <h6 class="fw-bold mb-1">Mess Staff (Chef)</h6>
                        <p class="small text-muted mb-2">Menu management, daily wastage recording, and complaint tracking.</p>
                        <div class="small font-monospace bg-white p-2 border rounded">
                            <div><strong>Email:</strong> staff@smartmess.edu</div>
                            <div><strong>Password:</strong> staff123</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?email=staff@smartmess.edu" class="btn btn-outline-primary btn-sm w-100 mt-3">
                            Sign In as Staff
                        </a>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="border rounded-3 p-3 bg-light h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="badge bg-success">STUDENT ROLE</span>
                            <i class="bi bi-mortarboard text-success fs-5"></i>
                        </div>
                        <h6 class="fw-bold mb-1">Hostel Student</h6>
                        <p class="small text-muted mb-2">Mark meal attendance, submit ratings, and file grievance tickets.</p>
                        <div class="small font-monospace bg-white p-2 border rounded">
                            <div><strong>Email:</strong> student@smartmess.edu</div>
                            <div><strong>Password:</strong> student123</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?email=student@smartmess.edu" class="btn btn-outline-success btn-sm w-100 mt-3">
                            Sign In as Student
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="py-4 text-center text-muted border-top bg-white">
        <div class="container">
            <small>&copy; 2026 SmartMess Project — Built for Java Servlets and Oracle DBMS Academic Evaluation.</small>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
