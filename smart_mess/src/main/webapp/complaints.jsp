<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Complaints Management - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="complaints" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Grievance & Complaint Tracking</h5>
            </div>
            <c:if test="${sessionScope.user.student}">
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#newComplaintModal">
                    <i class="bi bi-plus-lg me-1"></i> File New Grievance
                </button>
            </c:if>
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

            <!-- Staff & Admin Filters -->
            <c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
                <div class="card border-0 shadow-sm rounded-3 p-3 mb-4">
                    <form action="${pageContext.request.contextPath}/complaints" method="get" class="row g-2 align-items-center">
                        <div class="col-auto">
                            <label class="small fw-semibold text-secondary"><i class="bi bi-funnel me-1"></i> Filter By:</label>
                        </div>
                        <div class="col-auto">
                            <select class="form-select form-select-sm" name="status">
                                <option value="ALL">All Statuses</option>
                                <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                <option value="RESOLVED" ${selectedStatus == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                            </select>
                        </div>
                        <div class="col-auto">
                            <select class="form-select form-select-sm" name="categoryId">
                                <option value="">All Categories</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" ${selectedCategory == cat.categoryId ? 'selected' : ''}>
                                        ${cat.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-auto">
                            <button type="submit" class="btn btn-sm btn-primary">Filter</button>
                            <a href="${pageContext.request.contextPath}/complaints" class="btn btn-sm btn-outline-secondary">Reset</a>
                        </div>
                    </form>
                </div>
            </c:if>

            <!-- Complaints Table -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0 text-dark">
                        <i class="bi bi-card-checklist me-1 text-primary"></i> 
                        ${sessionScope.user.student ? 'My Filed Grievances' : 'Student Complaints Registry'}
                    </h6>
                    <span class="badge bg-light text-muted border">${complaints.size()} records</span>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0">
                        <thead>
                            <tr>
                                <th># ID</th>
                                <c:if test="${!sessionScope.user.student}">
                                    <th>Student</th>
                                    <th>Hostel / Rm</th>
                                </c:if>
                                <th>Category</th>
                                <th>Grievance Description</th>
                                <th>Status</th>
                                <th>Submitted On</th>
                                <th>Resolved At</th>
                                <c:if test="${!sessionScope.user.student}">
                                    <th class="text-end">Update</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty complaints}">
                                    <tr>
                                        <td colspan="${sessionScope.user.student ? 6 : 8}" class="text-center py-4 text-muted">
                                            No complaints found.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${complaints}">
                                        <tr>
                                            <td class="fw-bold text-muted">#${c.complaintId}</td>
                                            <c:if test="${!sessionScope.user.student}">
                                                <td>
                                                    <div class="fw-semibold">${c.userName}</div>
                                                    <small class="text-muted">${c.userEmail}</small>
                                                </td>
                                                <td><small>${c.hostel} ${not empty c.roomNo ? c.roomNo : ''}</small></td>
                                            </c:if>
                                            <td>
                                                <span class="badge bg-light text-dark border">${c.categoryName}</span>
                                            </td>
                                            <td>
                                                <div class="small text-dark" style="max-width: 300px;">${c.description}</div>
                                            </td>
                                            <td>
                                                <span class="badge ${c.pending ? 'badge-pending' : (c.inProgress ? 'badge-in-progress' : 'badge-resolved')}">
                                                    ${c.status}
                                                </span>
                                            </td>
                                            <td class="small text-muted text-nowrap">${c.createdAt}</td>
                                            <td class="small text-muted text-nowrap">${not empty c.resolvedAt ? c.resolvedAt : '-'}</td>
                                            <c:if test="${!sessionScope.user.student}">
                                                <td class="text-end text-nowrap">
                                                    <!-- Status Update Form Button -->
                                                    <button type="button" class="btn btn-sm btn-outline-primary py-1 px-2"
                                                            data-bs-toggle="modal" data-bs-target="#statusModal${c.complaintId}">
                                                        <i class="bi bi-pencil-square me-1"></i> Status
                                                    </button>

                                                    <!-- Status Update Modal -->
                                                    <div class="modal fade" id="statusModal${c.complaintId}" tabindex="-1" aria-hidden="true">
                                                        <div class="modal-dialog text-start">
                                                            <div class="modal-content">
                                                                <form action="${pageContext.request.contextPath}/complaints" method="post">
                                                                    <input type="hidden" name="action" value="updateStatus">
                                                                    <input type="hidden" name="complaintId" value="${c.complaintId}">
                                                                    <div class="modal-header">
                                                                        <h6 class="modal-title fw-bold">Update Status (#${c.complaintId})</h6>
                                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <p class="small text-muted mb-2"><strong>Issue:</strong> ${c.description}</p>
                                                                        <div class="mb-3">
                                                                            <label class="form-label small fw-semibold">Lifecycle Status</label>
                                                                            <select class="form-select" name="status" required>
                                                                                <option value="PENDING" ${c.pending ? 'selected' : ''}>PENDING</option>
                                                                                <option value="IN_PROGRESS" ${c.inProgress ? 'selected' : ''}>IN_PROGRESS</option>
                                                                                <option value="RESOLVED" ${c.resolved ? 'selected' : ''}>RESOLVED</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                                                                        <button type="submit" class="btn btn-primary btn-sm">Update Status</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </c:if>
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

<!-- Modal: Student File Grievance -->
<c:if test="${sessionScope.user.student}">
    <div class="modal fade" id="newComplaintModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/complaints" method="post">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-header">
                        <h6 class="modal-title fw-bold"><i class="bi bi-chat-square-text me-1 text-danger"></i> File New Mess Grievance</h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="catSelect" class="form-label small fw-semibold">Grievance Category</label>
                            <select class="form-select" id="catSelect" name="categoryId" required>
                                <option value="">-- Choose Category --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${cat.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="desc" class="form-label small fw-semibold">Detailed Description</label>
                            <textarea class="form-control" id="desc" name="description" rows="4" 
                                      placeholder="Explain the issue clearly (e.g. cold food, water dispenser leaking, insufficient serving counter)..." required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary btn-sm">Submit Grievance</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/includes/footer.jsp" />
