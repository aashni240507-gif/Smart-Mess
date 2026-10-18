<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Food Wastage Tracking - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="wastage" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Food Wastage Tracking & Reduction</h5>
            </div>
            <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#logWastageModal">
                <i class="bi bi-plus-circle me-1"></i> Log Meal Wastage
            </button>
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

            <!-- Metrics Overview Cards -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Food Prepared</div>
                        <div class="metric-value">${totalPrepared} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Total cooked food</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Food Served</div>
                        <div class="metric-value">${totalServed} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Dined by students</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-rose">
                        <div class="metric-title">Food Wasted</div>
                        <div class="metric-value">${totalWasted} <span class="fs-6 text-muted">kg</span></div>
                        <div class="metric-subtitle">Leftover / discarded</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card ${wastagePct > 10 ? 'accent-rose' : 'accent-green'}">
                        <div class="metric-title">Wastage Ratio</div>
                        <div class="metric-value">${wastagePct}%</div>
                        <div class="metric-subtitle">(Wasted / Prepared) × 100</div>
                    </div>
                </div>
            </div>

            <!-- Wastage Table -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-trash3 me-1 text-danger"></i> Mess Kitchen Wastage Log</h6>
                    <span class="badge bg-light text-muted border">${wastageRecords.size()} recorded meals</span>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Meal Date</th>
                                <th>Meal</th>
                                <th>Food Prepared</th>
                                <th>Food Served</th>
                                <th>Food Wasted</th>
                                <th>Wastage %</th>
                                <th>Recorded By</th>
                                <th>Recorded At</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty wastageRecords}">
                                    <tr>
                                        <td colspan="8" class="text-center py-4 text-muted">No wastage records registered yet.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="w" items="${wastageRecords}">
                                        <tr>
                                            <td class="fw-semibold">${w.menuDate}</td>
                                            <td>
                                                <span class="badge ${w.mealName == 'Breakfast' ? 'bg-warning text-dark' : (w.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                    ${w.mealName}
                                                </span>
                                            </td>
                                            <td>${w.foodPrepared} kg</td>
                                            <td>${w.foodServed} kg</td>
                                            <td><span class="text-danger fw-bold">${w.foodWasted} kg</span></td>
                                            <td>
                                                <span class="badge ${w.wastagePercentage > 10 ? 'bg-danger' : 'bg-success'}">
                                                    ${w.wastagePercentage}%
                                                </span>
                                            </td>
                                            <td>${w.recordedByName}</td>
                                            <td class="small text-muted">${w.recordedAt}</td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- Modal: Log Meal Wastage -->
<div class="modal fade" id="logWastageModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/wastage" method="post">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold"><i class="bi bi-scale me-1 text-primary"></i> Record Food Quantities (kg)</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="wasteMenuSelect" class="form-label small fw-semibold">Select Meal Schedule</label>
                        <select class="form-select form-select-sm" id="wasteMenuSelect" name="menuId" required>
                            <option value="">-- Choose Meal Menu --</option>
                            <c:forEach var="m" items="${menus}">
                                <option value="${m.menuId}">${m.menuDate} - ${m.mealName} (${m.foodItems})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-md-4">
                            <label for="foodPrepared" class="form-label small fw-semibold">Prepared (kg)</label>
                            <input type="number" step="0.1" min="0" class="form-control form-control-sm" 
                                   id="foodPrepared" name="foodPrepared" placeholder="e.g. 100.0" required>
                        </div>
                        <div class="col-md-4">
                            <label for="foodServed" class="form-label small fw-semibold">Served (kg)</label>
                            <input type="number" step="0.1" min="0" class="form-control form-control-sm" 
                                   id="foodServed" name="foodServed" placeholder="e.g. 90.0" required>
                        </div>
                        <div class="col-md-4">
                            <label for="foodWasted" class="form-label small fw-semibold">Wasted (kg)</label>
                            <input type="number" step="0.1" min="0" class="form-control form-control-sm" 
                                   id="foodWasted" name="foodWasted" placeholder="e.g. 10.0" required>
                        </div>
                    </div>

                    <!-- Live Calculated Wastage Percentage -->
                    <div class="p-3 bg-light rounded border text-center">
                        <small class="text-muted d-block">Live Calculated Wastage Percentage:</small>
                        <span id="wastagePctDisplay" class="fs-4 fw-bold text-success">0.00%</span>
                        <div class="small text-muted mt-1">Formula: (Wasted / Prepared) × 100</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Save Record</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
