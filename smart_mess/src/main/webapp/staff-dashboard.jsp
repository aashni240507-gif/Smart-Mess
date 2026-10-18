<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Staff Dashboard - SmartMess" />
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
                <h5 class="mb-0 fw-bold">Mess Staff Portal</h5>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="${pageContext.request.contextPath}/menus" class="btn btn-primary btn-sm">
                    <i class="bi bi-plus-circle me-1"></i> Add Daily Menu
                </a>
                <a href="${pageContext.request.contextPath}/wastage" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-trash3 me-1"></i> Log Wastage
                </a>
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

            <!-- Staff Welcome Banner -->
            <div class="card border-0 rounded-4 p-4 text-white mb-4" 
                 style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h4 class="fw-bold mb-1">Mess Operations Control 🍳</h4>
                        <p class="text-light opacity-75 mb-0 small">
                            Logged in as <strong>${sessionScope.user.name}</strong>. Monitor meal attendance, manage schedules, and record kitchen wastage.
                        </p>
                    </div>
                    <div>
                        <span class="badge bg-primary px-3 py-2 fs-6">STAFF ACCOUNT</span>
                    </div>
                </div>
            </div>

            <!-- Stats Overview Row -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Food Prepared</div>
                        <div class="metric-value">${totalPrepared} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Total historical prepared</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Food Served</div>
                        <div class="metric-value">${totalServed} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Total consumed by students</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-rose">
                        <div class="metric-title">Food Wasted</div>
                        <div class="metric-value">${totalWasted} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Total discarded</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card ${wastagePct > 10 ? 'accent-rose' : 'accent-amber'}">
                        <div class="metric-title">Wastage Ratio</div>
                        <div class="metric-value">${wastagePct}%</div>
                        <div class="metric-subtitle">Wasted vs Prepared</div>
                    </div>
                </div>
            </div>

            <!-- Today's Menus and Quick Wastage Entry Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-calendar-event me-1 text-primary"></i> Today's Kitchen Schedule</h6>
                            <a href="${pageContext.request.contextPath}/menus" class="small text-decoration-none">Manage Menus</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty todayMenus}">
                                <div class="alert alert-warning py-2 small mb-0">No menus created for today yet. Use Menu management to create one.</div>
                            </c:when>
                            <c:otherwise>
                                <div class="list-group list-group-flush">
                                    <c:forEach var="m" items="${todayMenus}">
                                        <div class="list-group-item px-0 py-2 border-bottom">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                    ${m.mealName}
                                                </span>
                                                <small class="text-muted">${m.menuDate}</small>
                                            </div>
                                            <div class="fw-semibold text-dark small">${m.foodItems}</div>
                                            <c:if test="${not empty m.notes}">
                                                <small class="text-muted"><i class="bi bi-info-circle me-1"></i>${m.notes}</small>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Pending Complaints Requiring Action -->
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-exclamation-octagon me-1 text-danger"></i> Urgent Student Grievances</h6>
                            <a href="${pageContext.request.contextPath}/complaints" class="small text-decoration-none">All Grievances</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty pendingComplaints}">
                                <div class="text-center py-4 text-muted small">
                                    <i class="bi bi-check2-all fs-2 text-success"></i>
                                    <p class="mb-0 mt-1">No pending complaints. All clean!</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="list-group list-group-flush">
                                    <c:forEach var="c" items="${pendingComplaints}">
                                        <div class="list-group-item px-0 py-2 border-bottom">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="badge bg-secondary-subtle text-secondary border">${c.categoryName}</span>
                                                <span class="badge badge-pending">PENDING</span>
                                            </div>
                                            <p class="small text-dark mb-1">${c.description}</p>
                                            <div class="d-flex justify-content-between align-items-center small text-muted">
                                                <span>Filed by: ${c.userName} (Rm ${c.roomNo})</span>
                                                <a href="${pageContext.request.contextPath}/complaints" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.75rem;">
                                                    Update Status
                                                </a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Recent Wastage Records Table -->
            <div class="card border-0 shadow-sm rounded-3 p-3 mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-trash3 me-1 text-danger"></i> Recent Food Wastage Log</h6>
                    <a href="${pageContext.request.contextPath}/wastage" class="btn btn-sm btn-outline-success">
                        <i class="bi bi-plus-circle me-1"></i> Record New Wastage
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Meal</th>
                                <th>Prepared (kg)</th>
                                <th>Served (kg)</th>
                                <th>Wasted (kg)</th>
                                <th>Wastage %</th>
                                <th>Recorded By</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="w" items="${recentWastage}">
                                <tr>
                                    <td>${w.menuDate}</td>
                                    <td><span class="fw-semibold">${w.mealName}</span></td>
                                    <td>${w.foodPrepared} kg</td>
                                    <td>${w.foodServed} kg</td>
                                    <td><span class="text-danger fw-bold">${w.foodWasted} kg</span></td>
                                    <td>
                                        <span class="badge ${w.wastagePercentage > 10 ? 'bg-danger' : 'bg-success'}">
                                            ${w.wastagePercentage}%
                                        </span>
                                    </td>
                                    <td>${w.recordedByName}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
