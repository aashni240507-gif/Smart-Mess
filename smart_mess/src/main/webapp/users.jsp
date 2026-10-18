<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="User Management - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="users" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">User & Account Administration</h5>
            </div>
            <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#newStaffModal">
                <i class="bi bi-person-plus me-1"></i> Add Staff Account
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
                <div class="col-md-4">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Registered Students</div>
                        <div class="metric-value">${studentCount}</div>
                        <div class="metric-subtitle">Hostel residents</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Mess Staff Members</div>
                        <div class="metric-value">${staffCount}</div>
                        <div class="metric-subtitle">Chefs & supervisors</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card accent-rose">
                        <div class="metric-title">Administrators</div>
                        <div class="metric-value">${adminCount}</div>
                        <div class="metric-subtitle">System managers</div>
                    </div>
                </div>
            </div>

            <!-- Users Registry Table -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-people me-1 text-primary"></i> System Users Directory</h6>
                    <span class="badge bg-light text-muted border">${userList.size()} total accounts</span>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0">
                        <thead>
                            <tr>
                                <th># ID</th>
                                <th>Full Name</th>
                                <th>Email Address</th>
                                <th>Role</th>
                                <th>Hostel & Room</th>
                                <th>Registered Date</th>
                                <th class="text-end">Manage Role</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${userList}">
                                <tr>
                                    <td class="fw-bold text-muted">#${u.userId}</td>
                                    <td class="fw-semibold text-dark">${u.name}</td>
                                    <td>${u.email}</td>
                                    <td>
                                        <span class="badge ${u.admin ? 'bg-danger' : (u.staff ? 'bg-primary' : 'bg-success')}">
                                            ${u.role}
                                        </span>
                                    </td>
                                    <td>${not empty u.hostel ? u.hostel : '-'} ${not empty u.roomNo ? u.roomNo : ''}</td>
                                    <td class="small text-muted">${u.createdAt}</td>
                                    <td class="text-end">
                                        <c:if test="${u.userId != sessionScope.user.userId}">
                                            <form action="${pageContext.request.contextPath}/users" method="post" class="d-inline-flex gap-1 align-items-center">
                                                <input type="hidden" name="action" value="updateRole">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <select name="role" class="form-select form-select-sm" style="width: auto; font-size: 0.8rem;">
                                                    <option value="STUDENT" ${u.student ? 'selected' : ''}>STUDENT</option>
                                                    <option value="STAFF" ${u.staff ? 'selected' : ''}>STAFF</option>
                                                    <option value="ADMIN" ${u.admin ? 'selected' : ''}>ADMIN</option>
                                                </select>
                                                <button type="submit" class="btn btn-sm btn-outline-secondary py-1 px-2" title="Save Role">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${u.userId == sessionScope.user.userId}">
                                            <span class="badge bg-light text-muted border">Current User</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- Modal: Add New Staff Account -->
<div class="modal fade" id="newStaffModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/users" method="post">
                <input type="hidden" name="action" value="createStaff">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold"><i class="bi bi-person-badge me-1 text-primary"></i> Create Mess Staff Account</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="staffName" class="form-label small fw-semibold">Staff Name</label>
                        <input type="text" class="form-control form-control-sm" id="staffName" name="name" 
                               placeholder="e.g. Chef Raman Kumar" required>
                    </div>
                    <div class="mb-3">
                        <label for="staffEmail" class="form-label small fw-semibold">Email Address</label>
                        <input type="email" class="form-control form-control-sm" id="staffEmail" name="email" 
                               placeholder="e.g. staff@smartmess.edu" required>
                    </div>
                    <div class="mb-3">
                        <label for="staffPassword" class="form-label small fw-semibold">Temporary Password</label>
                        <input type="password" class="form-control form-control-sm" id="staffPassword" name="password" 
                               placeholder="e.g. staff123" required>
                    </div>
                    <div class="row g-2 mb-2">
                        <div class="col-md-6">
                            <label for="staffHostel" class="form-label small fw-semibold">Quarters / Block</label>
                            <input type="text" class="form-control form-control-sm" id="staffHostel" name="hostel" 
                                   placeholder="e.g. Staff Quarters">
                        </div>
                        <div class="col-md-6">
                            <label for="staffRoom" class="form-label small fw-semibold">Room / Unit No</label>
                            <input type="text" class="form-control form-control-sm" id="staffRoom" name="roomNo" 
                                   placeholder="e.g. SQ-12">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Create Staff Account</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
