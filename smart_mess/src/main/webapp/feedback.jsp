<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Food Feedback - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="feedback" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Food Quality & Taste Feedback</h5>
            </div>
            <span class="badge bg-light text-secondary border px-3 py-2">
                <i class="bi bi-star-fill text-warning me-1"></i> 5-Star Rating System
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

            <!-- Student View: Submit Feedback & History -->
            <c:if test="${sessionScope.user.student}">
                    <div class="row g-4">
                        <div class="col-lg-5">
                            <div class="card border-0 shadow-sm rounded-3 p-4">
                                <h6 class="fw-bold text-dark mb-1"><i class="bi bi-star-half me-1 text-warning"></i> Submit Meal Feedback</h6>
                                <p class="text-muted small mb-3">Rate food quality, taste, and cleanliness for today's meals.</p>

                                <form action="${pageContext.request.contextPath}/feedback" method="post">
                                    <div class="mb-3">
                                        <label for="menuId" class="form-label small fw-semibold">Select Meal</label>
                                        <select class="form-select form-select-sm" id="menuId" name="menuId" required>
                                            <option value="">-- Choose Meal --</option>
                                            <c:forEach var="m" items="${todayMenus}">
                                                <option value="${m.menuId}">${m.mealName} (${m.foodItems})</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- Quality Rating -->
                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold d-block mb-1">Food Quality (1 to 5)</label>
                                        <input type="hidden" name="foodQuality" id="qualityInput" value="5">
                                        <div class="star-rating" data-input-id="qualityInput">
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                        </div>
                                    </div>

                                    <!-- Taste Rating -->
                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold d-block mb-1">Taste & Flavor (1 to 5)</label>
                                        <input type="hidden" name="taste" id="tasteInput" value="5">
                                        <div class="star-rating" data-input-id="tasteInput">
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                        </div>
                                    </div>

                                    <!-- Cleanliness Rating -->
                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold d-block mb-1">Dining Hall Cleanliness (1 to 5)</label>
                                        <input type="hidden" name="cleanliness" id="cleanInput" value="5">
                                        <div class="star-rating" data-input-id="cleanInput">
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                            <i class="bi bi-star-fill star selected"></i>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="comments" class="form-label small fw-semibold">Written Comments (Optional)</label>
                                        <textarea class="form-control form-control-sm" id="comments" name="comments" rows="3" 
                                                  placeholder="Any suggestion for the mess committee?"></textarea>
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-sm w-100 py-2">
                                        <i class="bi bi-send me-1"></i> Submit Review
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Previous Feedback List -->
                        <div class="col-lg-7">
                            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                                <div class="card-header bg-white py-3 border-bottom">
                                    <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-chat-heart me-1 text-primary"></i> My Past Submissions</h6>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>Date & Meal</th>
                                                <th>Ratings</th>
                                                <th>Comments</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty myFeedbacks}">
                                                    <tr>
                                                        <td colspan="3" class="text-center py-4 text-muted">You haven't submitted any feedback yet.</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="fb" items="${myFeedbacks}">
                                                        <tr>
                                                            <td>
                                                                <span class="fw-semibold">${fb.mealName}</span>
                                                                <div class="small text-muted">${fb.menuDate}</div>
                                                            </td>
                                                            <td>
                                                                <small class="d-block text-muted">Q: ${fb.foodQuality} | T: ${fb.taste} | C: ${fb.cleanliness}</small>
                                                                <span class="badge bg-warning-subtle text-dark border">
                                                                    ★ ${fb.averageScore} / 5.0
                                                                </span>
                                                            </td>
                                                            <td class="small text-muted">${not empty fb.comments ? fb.comments : '-'}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
            </c:if>

            <!-- Staff & Admin View: Averages and All Reviews -->
            <c:if test="${!sessionScope.user.student}">
                    <!-- Average Metrics Cards -->
                    <div class="row g-3 mb-4">
                        <div class="col-6 col-md-3">
                            <div class="metric-card accent-green">
                                <div class="metric-title">Food Quality</div>
                                <div class="metric-value">★ ${avgQuality}</div>
                                <div class="metric-subtitle">Average score / 5.0</div>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="metric-card accent-blue">
                                <div class="metric-title">Taste & Flavor</div>
                                <div class="metric-value">★ ${avgTaste}</div>
                                <div class="metric-subtitle">Average score / 5.0</div>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="metric-card accent-purple">
                                <div class="metric-title">Cleanliness</div>
                                <div class="metric-value">★ ${avgCleanliness}</div>
                                <div class="metric-subtitle">Average score / 5.0</div>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="metric-card accent-amber">
                                <div class="metric-title">Overall Composite</div>
                                <div class="metric-value">★ ${avgOverall}</div>
                                <div class="metric-subtitle">Cumulative average</div>
                            </div>
                        </div>
                    </div>

                    <!-- All Feedbacks Table -->
                    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-people me-1 text-primary"></i> Student Feedback Log</h6>
                            <span class="badge bg-light text-muted border">${allFeedbacks.size()} reviews</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Date & Meal</th>
                                        <th>Quality</th>
                                        <th>Taste</th>
                                        <th>Cleanliness</th>
                                        <th>Average</th>
                                        <th>Review Comments</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="fb" items="${allFeedbacks}">
                                        <tr>
                                            <td class="fw-semibold">${fb.userName}</td>
                                            <td>
                                                <div>${fb.mealName}</div>
                                                <small class="text-muted">${fb.menuDate}</small>
                                            </td>
                                            <td>${fb.foodQuality} / 5</td>
                                            <td>${fb.taste} / 5</td>
                                            <td>${fb.cleanliness} / 5</td>
                                            <td>
                                                <span class="badge bg-warning-subtle text-dark border">★ ${fb.averageScore}</span>
                                            </td>
                                            <td class="small text-muted text-truncate" style="max-width: 250px;">
                                                ${not empty fb.comments ? fb.comments : '-'}
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
