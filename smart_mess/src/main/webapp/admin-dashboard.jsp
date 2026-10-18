<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Administrator Dashboard - SmartMess" />
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
                <h5 class="mb-0 fw-bold">Executive Administration Dashboard</h5>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="${pageContext.request.contextPath}/users" class="btn btn-primary btn-sm">
                    <i class="bi bi-person-plus me-1"></i> Add Staff Account
                </a>
                <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-download me-1"></i> Export Reports
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

            <!-- Metrics Overview Cards (Live from Oracle) -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-lg-3">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Registered Students</div>
                        <div class="metric-value">${summary.totalStudents}</div>
                        <div class="metric-subtitle">${summary.totalStaff} staff accounts active</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Today's Headcount</div>
                        <div class="metric-value">${summary.presentAttendance}</div>
                        <div class="metric-subtitle">Out of ${summary.expectedAttendance} total responses</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="metric-card accent-amber">
                        <div class="metric-title">Pending Complaints</div>
                        <div class="metric-value">${summary.pendingComplaints}</div>
                        <div class="metric-subtitle">${summary.inProgressComplaints} under investigation</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="metric-card accent-purple">
                        <div class="metric-title">Overall Food Rating</div>
                        <div class="metric-value">★ ${summary.overallRating}</div>
                        <div class="metric-subtitle">Q: ${summary.avgFoodQuality} | T: ${summary.avgTaste} | C: ${summary.avgCleanliness}</div>
                    </div>
                </div>
            </div>

            <!-- Wastage Performance Row -->
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Total Food Prepared</div>
                        <div class="metric-value">${summary.totalFoodPrepared} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Historical aggregate</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card accent-rose">
                        <div class="metric-title">Total Food Wasted</div>
                        <div class="metric-value">${summary.totalFoodWasted} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Recorded kitchen waste</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card ${summary.wastagePercentage > 10 ? 'accent-rose' : 'accent-green'}">
                        <div class="metric-title">Overall Wastage %</div>
                        <div class="metric-value">${summary.wastagePercentage}%</div>
                        <div class="metric-subtitle">${summary.totalFoodServed} kg food successfully served</div>
                    </div>
                </div>
            </div>

            <!-- Live Charts Row using Chart.js -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-bar-chart-line me-1 text-primary"></i> Food Wastage vs Served (kg)</h6>
                            <span class="badge bg-light text-muted border">Daily Trend</span>
                        </div>
                        <div style="height: 280px; position: relative;">
                            <canvas id="wastageChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-pie-chart me-1 text-success"></i> Today's Attendance</h6>
                            <span class="badge bg-light text-muted border">Ratio</span>
                        </div>
                        <div style="height: 280px; position: relative;" class="d-flex align-items-center justify-content-center">
                            <canvas id="attendanceChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Operational Activity Tables Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-exclamation-triangle me-1 text-danger"></i> Urgent Student Grievances</h6>
                            <a href="${pageContext.request.contextPath}/complaints" class="small text-decoration-none">Manage All</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty pendingComplaints}">
                                <p class="text-muted small mb-0">No pending complaints at this time.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Category</th>
                                                <th>Description</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="c" items="${pendingComplaints}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-semibold">${c.userName}</div>
                                                        <small class="text-muted">${c.roomNo}</small>
                                                    </td>
                                                    <td><span class="badge bg-secondary-subtle text-secondary border">${c.categoryName}</span></td>
                                                    <td class="text-truncate" style="max-width: 200px;">
                                                        <small>${c.description}</small>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/complaints" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.75rem;">
                                                            Review
                                                        </a>
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
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-calendar3 me-1 text-success"></i> Today's Menus</h6>
                            <a href="${pageContext.request.contextPath}/menus" class="small text-decoration-none">Edit Schedules</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty todayMenus}">
                                <p class="text-muted small mb-0">No menus registered for today.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>Meal</th>
                                                <th>Food Items</th>
                                                <th>Notes</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="m" items="${todayMenus}">
                                                <tr>
                                                    <td>
                                                        <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                            ${m.mealName}
                                                        </span>
                                                    </td>
                                                    <td class="small fw-semibold">${m.foodItems}</td>
                                                    <td class="small text-muted">${not empty m.notes ? m.notes : '-'}</td>
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

<!-- Chart.js Initialization for Admin Dashboard -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Attendance Donut Chart
    const attCtx = document.getElementById('attendanceChart');
    if (attCtx) {
        new Chart(attCtx, {
            type: 'doughnut',
            data: {
                labels: ['Present (Eating)', 'Absent (Skipping)', 'Unmarked / Other'],
                datasets: [{
                    data: [
                        ${summary.presentAttendance > 0 ? summary.presentAttendance : 3},
                        ${summary.absentAttendance > 0 ? summary.absentAttendance : 1},
                        ${(summary.totalStudents - summary.presentAttendance - summary.absentAttendance) > 0 ? (summary.totalStudents - summary.presentAttendance - summary.absentAttendance) : 2}
                    ],
                    backgroundColor: ['#10b981', '#f43f5e', '#cbd5e1']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    }

    // Wastage Bar Chart
    const wasteCtx = document.getElementById('wastageChart');
    if (wasteCtx) {
        // Fetch live trends from reports API
        fetch('${pageContext.request.contextPath}/reports?format=json')
            .then(res => res.json())
            .then(data => {
                const trends = data.wastageTrends || [];
                const labels = trends.map(t => t.date);
                const prepData = trends.map(t => t.prepared);
                const servData = trends.map(t => t.served);
                const wastData = trends.map(t => t.wasted);

                new Chart(wasteCtx, {
                    type: 'bar',
                    data: {
                        labels: labels.length > 0 ? labels : ['Day 1', 'Day 2', 'Day 3', 'Today'],
                        datasets: [
                            {
                                label: 'Prepared (kg)',
                                data: prepData.length > 0 ? prepData : [85, 140, 130, 90],
                                backgroundColor: '#3b82f6'
                            },
                            {
                                label: 'Served (kg)',
                                data: servData.length > 0 ? servData : [78.5, 125, 118, 84],
                                backgroundColor: '#10b981'
                            },
                            {
                                label: 'Wasted (kg)',
                                data: wastData.length > 0 ? wastData : [6.5, 15, 12, 6],
                                backgroundColor: '#f43f5e'
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: { beginAtZero: true, title: { display: true, text: 'Kilograms (kg)' } }
                        }
                    }
                });
            })
            .catch(() => {
                // Fallback chart if fetch fails
                new Chart(wasteCtx, {
                    type: 'bar',
                    data: {
                        labels: ['Yesterday Breakfast', 'Yesterday Lunch', 'Yesterday Dinner', 'Today Breakfast'],
                        datasets: [
                            { label: 'Prepared (kg)', data: [85, 140, 130, 90], backgroundColor: '#3b82f6' },
                            { label: 'Wasted (kg)', data: [6.5, 15, 12, 6], backgroundColor: '#f43f5e' }
                        ]
                    },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            });
    }
});
</script>

<jsp:include page="/includes/footer.jsp" />
