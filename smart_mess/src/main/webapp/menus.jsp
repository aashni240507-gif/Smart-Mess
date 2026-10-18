<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Daily Menus - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="menus" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Daily Menus Schedule</h5>
            </div>
            <c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addMenuModal">
                    <i class="bi bi-plus-lg me-1"></i> Add New Menu
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

            <!-- Filter Card -->
            <div class="card border-0 shadow-sm rounded-3 p-3 mb-4">
                <form action="${pageContext.request.contextPath}/menus" method="get" class="row g-2 align-items-center">
                    <div class="col-auto">
                        <label for="filterDate" class="col-form-label fw-semibold small text-secondary">
                            <i class="bi bi-funnel me-1"></i> Filter by Date:
                        </label>
                    </div>
                    <div class="col-auto">
                        <input type="date" class="form-control form-control-sm" id="filterDate" name="filterDate" value="${filterDate}">
                    </div>
                    <div class="col-auto">
                        <button type="submit" class="btn btn-sm btn-primary">Apply</button>
                        <a href="${pageContext.request.contextPath}/menus" class="btn btn-sm btn-outline-secondary">Reset</a>
                    </div>
                </form>
            </div>

            <!-- Menus Table -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-calendar3 me-1 text-primary"></i> Mess Food Schedules</h6>
                    <span class="badge bg-light text-muted border">${menus.size()} entries</span>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Meal Type</th>
                                <th>Food Items</th>
                                <th>Notes / Special</th>
                                <c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
                                    <th class="text-end">Actions</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty menus}">
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">
                                            No menus found matching your criteria.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="m" items="${menus}">
                                        <tr>
                                            <td class="fw-semibold text-nowrap">${m.menuDate}</td>
                                            <td>
                                                <span class="badge ${m.mealName == 'Breakfast' ? 'bg-warning text-dark' : (m.mealName == 'Lunch' ? 'bg-primary' : 'bg-dark')}">
                                                    ${m.mealName}
                                                </span>
                                            </td>
                                            <td><span class="fw-semibold text-dark">${m.foodItems}</span></td>
                                            <td><small class="text-muted">${not empty m.notes ? m.notes : '-'}</small></td>
                                            <c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
                                                <td class="text-end text-nowrap">
                                                    <!-- Edit Trigger Button -->
                                                    <button type="button" class="btn btn-sm btn-outline-secondary py-1 px-2"
                                                            data-bs-toggle="modal" data-bs-target="#editModal${m.menuId}">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>

                                                    <!-- Delete Form -->
                                                    <form action="${pageContext.request.contextPath}/menus" method="post" 
                                                          style="display: inline-block;" 
                                                          onsubmit="return confirm('Are you sure you want to remove this menu item?');">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="menuId" value="${m.menuId}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-2">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>

                                                    <!-- Edit Modal for this specific menu -->
                                                    <div class="modal fade" id="editModal${m.menuId}" tabindex="-1" aria-hidden="true">
                                                        <div class="modal-dialog text-start">
                                                            <div class="modal-content">
                                                                <form action="${pageContext.request.contextPath}/menus" method="post">
                                                                    <input type="hidden" name="action" value="edit">
                                                                    <input type="hidden" name="menuId" value="${m.menuId}">
                                                                    <div class="modal-header">
                                                                        <h6 class="modal-title fw-bold">Edit Menu (${m.menuDate} - ${m.mealName})</h6>
                                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <div class="mb-3">
                                                                            <label class="form-label small fw-semibold">Food Items</label>
                                                                            <textarea class="form-control" name="foodItems" rows="3" required>${m.foodItems}</textarea>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label class="form-label small fw-semibold">Notes</label>
                                                                            <input type="text" class="form-control" name="notes" value="${m.notes}">
                                                                        </div>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                                                                        <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
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

<!-- Modal: Add New Menu -->
<c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
    <div class="modal fade" id="addMenuModal" tabindex="-1" aria-labelledby="addMenuLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/menus" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header">
                        <h6 class="modal-title fw-bold" id="addMenuLabel"><i class="bi bi-calendar-plus me-1 text-primary"></i> Add Daily Menu Schedule</h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="menuDate" class="form-label small fw-semibold">Menu Date</label>
                            <input type="date" class="form-control" id="menuDate" name="menuDate" required>
                        </div>
                        <div class="mb-3">
                            <label for="mealTypeId" class="form-label small fw-semibold">Meal Type</label>
                            <select class="form-select" id="mealTypeId" name="mealTypeId" required>
                                <option value="">-- Choose Meal Type --</option>
                                <c:forEach var="mt" items="${mealTypes}">
                                    <option value="${mt.mealTypeId}">${mt.mealName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="foodItems" class="form-label small fw-semibold">Food Items</label>
                            <textarea class="form-control" id="foodItems" name="foodItems" rows="3" 
                                      placeholder="e.g. Masala Dosa, Sambar, Coconut Chutney, Coffee" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="notes" class="form-label small fw-semibold">Special Notes (Optional)</label>
                            <input type="text" class="form-control" id="notes" name="notes" placeholder="e.g. Festival Special Feast">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary btn-sm">Create Menu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/includes/footer.jsp" />
