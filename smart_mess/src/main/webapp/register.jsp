<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration - SmartMess</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100 py-5">

    <div class="container" style="max-width: 500px;">
        <!-- Logo & Title -->
        <div class="text-center mb-4">
            <a href="${pageContext.request.contextPath}/" class="text-decoration-none">
                <div class="brand-icon mx-auto mb-2" style="width: 52px; height: 52px; border-radius: 12px; background: linear-gradient(135deg, #10b981, #059669); color: white; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
                    <i class="bi bi-egg-fried"></i>
                </div>
                <h3 class="fw-bold text-dark mb-0">SmartMess</h3>
            </a>
            <p class="text-muted small mt-1">Hostel Student Registration</p>
        </div>

        <div class="card border-0 shadow-sm rounded-4 bg-white p-4">
            <h5 class="fw-bold text-dark mb-1">Create Student Account</h5>
            <p class="text-muted small mb-3">Register your student account to mark meal attendance and rate mess meals.</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show py-2 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i>
                    ${error}
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="mb-3">
                    <label for="name" class="form-label small fw-semibold text-secondary">Full Name</label>
                    <input type="text" class="form-control" id="name" name="name" value="${name}" 
                           placeholder="e.g. Ramesh Kumar" required>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label small fw-semibold text-secondary">College Email</label>
                    <input type="email" class="form-control" id="email" name="email" value="${email}" 
                           placeholder="e.g. ramesh@smartmess.edu" required>
                </div>

                <div class="row g-2 mb-3">
                    <div class="col-md-6">
                        <label for="password" class="form-label small fw-semibold text-secondary">Password</label>
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Min 6 characters" required>
                    </div>
                    <div class="col-md-6">
                        <label for="confirmPassword" class="form-label small fw-semibold text-secondary">Confirm Password</label>
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                               placeholder="Repeat password" required>
                    </div>
                </div>

                <div class="row g-2 mb-4">
                    <div class="col-md-6">
                        <label for="hostel" class="form-label small fw-semibold text-secondary">Hostel Block</label>
                        <input type="text" class="form-control" id="hostel" name="hostel" value="${hostel}" 
                               placeholder="e.g. Kaveri Hostel">
                    </div>
                    <div class="col-md-6">
                        <label for="roomNo" class="form-label small fw-semibold text-secondary">Room Number</label>
                        <input type="text" class="form-control" id="roomNo" name="roomNo" value="${roomNo}" 
                               placeholder="e.g. 204">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2">
                    <i class="bi bi-person-check me-1"></i> Register Student Account
                </button>
            </form>

            <div class="mt-3 text-center">
                <span class="small text-muted">Already registered? </span>
                <a href="${pageContext.request.contextPath}/login" class="small fw-semibold text-success text-decoration-none">
                    Sign in here
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
</body>
</html>
