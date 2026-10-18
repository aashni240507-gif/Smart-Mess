<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Meal Attendance - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="attendance" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Meal Attendance Tracking</h5>
            </div>
            <span class="badge bg-light text-secondary border px-3 py-2">
                <i class="bi bi-calendar3 me-1"></i> Today's Operations
            </span>
        </header>

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

            <!-- Student View: Mark Today & View History -->
            <c:if test="${sessionScope.user.student}">
                <!-- Mark Attendance for Today's Meals -->
                    <div class="card border-0 shadow-sm rounded-3 p-4 mb-4">
                        <h6 class="fw-bold text-dark mb-1"><i class="bi bi-check2-circle me-1 text-success"></i> Mark Your Attendance for Today</h6>
                        <p class="text-muted small mb-3">Help the mess staff prepare the right quantity of food and prevent unnecessary wastage.</p>

                        <c:choose>
                            <c:when test="${empty todayMenus}">
                                <div class="alert alert-light border small text-muted mb-0">No meals scheduled for today yet.</div>
                            </c:when>
                            <c:otherwise>
                                <div class="row g-3">
                                    <c:forEach var="m" items="${todayMenus}">
                                        <div class="col-md-4">
                                            <div class="card border p-3 h-100 bg-light">
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                        ${m.mealName}
                                                    </span>
                                                    <c:set var="curStatus" value="${attendanceMap[m.menuId]}" />
                                                    <c:choose>
                                                        <c:when test="${curStatus == 'PRESENT'}">
                                                            <span class="badge badge-present"><i class="bi bi-check-circle me-1"></i>PRESENT</span>
                                                        </c:when>
                                                        <c:when test="${curStatus == 'ABSENT'}">
                                                            <span class="badge badge-absent"><i class="bi bi-x-circle me-1"></i>ABSENT</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary-subtle text-secondary border">NOT MARKED</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <p class="small text-dark mb-3 fw-semibold">${m.foodItems}</p>

                                                <div class="mt-auto d-flex gap-2">
                                                    <form action="${pageContext.request.contextPath}/attendance" method="post" class="flex-fill">
                                                        <input type="hidden" name="menuId" value="${m.menuId}">
                                                        <input type="hidden" name="status" value="PRESENT">
                                                        <button type="submit" class="btn btn-sm ${curStatus == 'PRESENT' ? 'btn-success' : 'btn-outline-success'} w-100">
                                                            <i class="bi bi-check2"></i> Mark Present
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/attendance" method="post" class="flex-fill">
                                                        <input type="hidden" name="menuId" value="${m.menuId}">
                                                        <input type="hidden" name="status" value="ABSENT">
                                                        <button type="submit" class="btn btn-sm ${curStatus == 'ABSENT' ? 'btn-danger' : 'btn-outline-danger'} w-100">
                                                            <i class="bi bi-x-lg"></i> Mark Absent
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Personal History -->
                    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="card-header bg-white py-3 border-bottom">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-clock-history me-1 text-primary"></i> My Attendance Record Log</h6>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Meal</th>
                                        <th>Attendance Status</th>
                                        <th>Timestamp Recorded</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty history}">
                                            <tr>
                                                <td colspan="4" class="text-center py-4 text-muted">No attendance records yet.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="h" items="${history}">
                                                <tr>
                                                    <td class="fw-semibold">${h.menuDate}</td>
                                                    <td>${h.mealName}</td>
                                                    <td>
                                                        <span class="badge ${h.status == 'PRESENT' ? 'badge-present' : 'badge-absent'}">
                                                            ${h.status}
                                                        </span>
                                                    </td>
                                                    <td class="small text-muted">${h.markedAt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
            </c:if>

            <!-- Staff / Admin Overview -->
            <c:if test="${!sessionScope.user.student}">
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div class="metric-card accent-green">
                                <div class="metric-title">Present Today (Eating)</div>
                                <div class="metric-value">${todayPresent}</div>
                                <div class="metric-subtitle">Confirmed student diners</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="metric-card accent-blue">
                                <div class="metric-title">Total Headcount Responses</div>
                                <div class="metric-value">${todayTotal}</div>
                                <div class="metric-subtitle">Including marked absent</div>
                            </div>
                        </div>
                    </div>

                    <div class="card border-0 shadow-sm rounded-3 p-4">
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-people me-1 text-primary"></i> Headcount Verification by Meal Schedule</h6>
                        <div class="table-responsive">
                            <table class="table table-custom table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Meal</th>
                                        <th>Menu Details</th>
                                        <th>Status Tracking</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${todayMenus}">
                                        <tr>
                                            <td class="fw-semibold">${m.menuDate}</td>
                                            <td>
                                                <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                    ${m.mealName}
                                                </span>
                                            </td>
                                            <td class="small">${m.foodItems}</td>
                                            <td>
                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                    <i class="bi bi-check2 me-1"></i> Active Headcount Monitoring
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
            </c:if>

        </main>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
