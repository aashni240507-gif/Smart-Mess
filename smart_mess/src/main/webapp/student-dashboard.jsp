<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Student Dashboard - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <!-- Dark Navy Sidebar -->
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="dashboard" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Top Navbar -->
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Student Portal</h5>
            </div>
            <div class="d-flex align-items-center gap-3">
                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 rounded-pill">
                    <i class="bi bi-mortarboard-fill me-1"></i> ${sessionScope.user.hostel} | Rm ${sessionScope.user.roomNo}
                </span>
            </div>
        </header>

        <!-- Page Body -->
        <main class="page-body">
            <!-- Flash Messages -->
            <c:if test="${not empty param.msg}">
                <div class="alert alert-success alert-dismissible fade show py-2 small" role="alert">
                    <i class="bi bi-check-circle-fill me-1"></i> ${param.msg}
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show py-2 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i> ${param.error}
                    <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Welcome Banner -->
            <div class="card border-0 rounded-4 p-4 text-white mb-4" 
                 style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h4 class="fw-bold mb-1">Welcome back, ${sessionScope.user.name}! 👋</h4>
                        <p class="text-light opacity-75 mb-0 small">
                            Check today's dining schedule below, confirm your attendance, and share feedback to help us serve better.
                        </p>
                    </div>
                    <div class="col-md-4 text-md-end mt-3 mt-md-0">
                        <a href="${pageContext.request.contextPath}/complaints" class="btn btn-outline-light btn-sm me-2">
                            <i class="bi bi-chat-dots me-1"></i> File Grievance
                        </a>
                        <a href="${pageContext.request.contextPath}/feedback" class="btn btn-primary btn-sm">
                            <i class="bi bi-star me-1"></i> Rate Meals
                        </a>
                    </div>
                </div>
            </div>

            <!-- Stats Overview Row -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Today's Meals</div>
                        <div class="metric-value">${todayMenus.size()}</div>
                        <div class="metric-subtitle">Scheduled for today</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Attendance Marked</div>
                        <div class="metric-value">${attendanceMap.size()}</div>
                        <div class="metric-subtitle">Responses today</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-purple">
                        <div class="metric-title">Reviews Shared</div>
                        <div class="metric-value">${recentFeedback.size()}</div>
                        <div class="metric-subtitle">Recent ratings</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-amber">
                        <div class="metric-title">Open Grievances</div>
                        <div class="metric-value">${pendingComplaints + inProgComplaints}</div>
                        <div class="metric-subtitle">${pendingComplaints} pending, ${inProgComplaints} active</div>
                    </div>
                </div>
            </div>

            <!-- Today's Menu & Live Attendance Marking -->
            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0 text-dark">
                        <i class="bi bi-clock-history me-1 text-success"></i> Today's Food Schedule
                    </h5>
                    <a href="${pageContext.request.contextPath}/menus" class="small text-decoration-none fw-semibold">
                        View Full Calendar &raquo;
                    </a>
                </div>

                <div class="row g-3">
                    <c:choose>
                        <c:when test="${empty todayMenus}">
                                <div class="col-12">
                                    <div class="card p-4 text-center border-0 shadow-sm rounded-3">
                                        <div class="text-muted"><i class="bi bi-calendar-x fs-2"></i></div>
                                        <p class="text-muted mt-2 mb-0">No menus scheduled for today yet.</p>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="m" items="${todayMenus}">
                                    <div class="col-md-4">
                                        <div class="meal-card">
                                            <div class="meal-card-header bg-light">
                                                <div class="d-flex align-items-center gap-2">
                                                    <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                        ${m.mealName}
                                                    </span>
                                                </div>
                                                <!-- Attendance status badge -->
                                                <c:set var="status" value="${attendanceMap[m.menuId]}" />
                                                <c:choose>
                                                    <c:when test="${status == 'PRESENT'}">
                                                        <span class="badge badge-present"><i class="bi bi-check-circle me-1"></i>Eating</span>
                                                    </c:when>
                                                    <c:when test="${status == 'ABSENT'}">
                                                        <span class="badge badge-absent"><i class="bi bi-x-circle me-1"></i>Skipping</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary-subtle text-secondary border">Unmarked</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="meal-card-body">
                                                <h6 class="fw-bold text-dark mb-2">${m.foodItems}</h6>
                                                <c:if test="${not empty m.notes}">
                                                    <p class="small text-muted mb-3"><i class="bi bi-info-circle me-1"></i>${m.notes}</p>
                                                </c:if>

                                                <!-- 1-Click Attendance Buttons -->
                                                <div class="border-top pt-3 mt-auto">
                                                    <small class="text-muted d-block mb-2">Mark Attendance:</small>
                                                    <div class="d-flex gap-2">
                                                        <form action="${pageContext.request.contextPath}/attendance" method="post" class="flex-fill">
                                                            <input type="hidden" name="menuId" value="${m.menuId}">
                                                            <input type="hidden" name="status" value="PRESENT">
                                                            <button type="submit" class="btn btn-sm ${status == 'PRESENT' ? 'btn-success' : 'btn-outline-success'} w-100">
                                                                <i class="bi bi-check2"></i> I'll Eat
                                                            </button>
                                                        </form>
                                                        <form action="${pageContext.request.contextPath}/attendance" method="post" class="flex-fill">
                                                            <input type="hidden" name="menuId" value="${m.menuId}">
                                                            <input type="hidden" name="status" value="ABSENT">
                                                            <button type="submit" class="btn btn-sm ${status == 'ABSENT' ? 'btn-danger' : 'btn-outline-danger'} w-100">
                                                                <i class="bi bi-x-lg"></i> Skip
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                </div>
            </div>

            <!-- Two-column: Recent Attendance & Recent Feedbacks -->
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-calendar3 me-1 text-primary"></i> My Attendance History</h6>
                            <a href="${pageContext.request.contextPath}/attendance" class="small text-decoration-none">View All</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty recentAttendance}">
                                <p class="text-muted small mb-0">No attendance records yet.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>Meal</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="att" items="${recentAttendance}">
                                                <tr>
                                                    <td>${att.menuDate}</td>
                                                    <td><span class="fw-semibold">${att.mealName}</span></td>
                                                    <td>
                                                        <span class="badge ${att.status == 'PRESENT' ? 'badge-present' : 'badge-absent'}">
                                                            ${att.status}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-chat-quote me-1 text-warning"></i> My Recent Feedback</h6>
                            <a href="${pageContext.request.contextPath}/feedback" class="small text-decoration-none">Give Rating</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty recentFeedback}">
                                <p class="text-muted small mb-0">No feedback submitted yet.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>Meal</th>
                                                <th>Score</th>
                                                <th>Review</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="fb" items="${recentFeedback}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-semibold">${fb.mealName}</div>
                                                        <small class="text-muted">${fb.menuDate}</small>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-warning-subtle text-dark border border-warning-subtle">
                                                            ★ ${fb.averageScore}
                                                        </span>
                                                    </td>
                                                    <td class="text-truncate" style="max-width: 180px;">
                                                        <small class="text-muted">${not empty fb.comments ? fb.comments : 'No written review'}</small>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
