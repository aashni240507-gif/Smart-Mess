<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - SmartMess</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100 py-5">

    <div class="container" style="max-width: 440px;">
        <!-- Logo & Title -->
        <div class="text-center mb-4">
            <a href="${pageContext.request.contextPath}/" class="text-decoration-none">
                <div class="brand-icon mx-auto mb-2" style="width: 52px; height: 52px; border-radius: 12px; background: linear-gradient(135deg, #10b981, #059669); color: white; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
                    <i class="bi bi-egg-fried"></i>
                </div>
                <h3 class="fw-bold text-dark mb-0">SmartMess</h3>
            </a>
            <p class="text-muted small mt-1">College Mess Food Management System</p>
        </div>

        <div class="card border-0 shadow-sm rounded-4 bg-white p-4">
            <h5 class="fw-bold text-dark mb-3">Sign In</h5>

            <!-- Flash Error Message -->
            <c:if test="${not empty error || not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show py-2 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i>
                    ${not empty error ? error : param.error}
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Flash Success Message -->
            <c:if test="${not empty msg || not empty param.msg}">
                <div class="alert alert-success alert-dismissible fade show py-2 small" role="alert">
                    <i class="bi bi-check-circle-fill me-1"></i>
                    ${not empty msg ? msg : param.msg}
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post" class="needs-validation">
                <div class="mb-3">
                    <label for="loginEmail" class="form-label small fw-semibold text-secondary">Email Address</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control" id="loginEmail" name="email" 
                               value="${param.email != null ? param.email : email}" placeholder="e.g. student@smartmess.edu" required autofocus>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="loginPassword" class="form-label small fw-semibold text-secondary">Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="loginPassword" name="password" 
                               placeholder="Enter your password" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2 mt-2">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                </button>
            </form>

            <!-- Quick Demo Credential Autofill Buttons -->
            <div class="mt-4 pt-3 border-top">
                <small class="text-muted d-block text-center mb-2 fw-semibold">Quick Demo 1-Click Fill:</small>
                <div class="d-flex justify-content-center gap-2">
                    <button type="button" class="btn btn-outline-success btn-sm" 
                            onclick="fillDemoCredentials('student@smartmess.edu', 'student123')">
                        <i class="bi bi-mortarboard"></i> Student
                    </button>
                    <button type="button" class="btn btn-outline-primary btn-sm" 
                            onclick="fillDemoCredentials('staff@smartmess.edu', 'staff123')">
                        <i class="bi bi-person-badge"></i> Staff
                    </button>
                    <button type="button" class="btn btn-outline-danger btn-sm" 
                            onclick="fillDemoCredentials('admin@smartmess.edu', 'admin123')">
                        <i class="bi bi-shield-lock"></i> Admin
                    </button>
                </div>
            </div>

            <div class="mt-3 text-center">
                <span class="small text-muted">New student? </span>
                <a href="${pageContext.request.contextPath}/register" class="small fw-semibold text-success text-decoration-none">
                    Create an account
                </a>
            </div>
        </div>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/" class="text-muted small text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i> Back to Homepage
            </a>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
