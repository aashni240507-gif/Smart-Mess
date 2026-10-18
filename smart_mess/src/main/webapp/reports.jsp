<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="title" value="Reports & Analytics - SmartMess" />
</jsp:include>

<div class="app-wrapper">
    <jsp:include page="/includes/sidebar.jsp">
        <jsp:param name="activePage" value="reports" />
    </jsp:include>

    <div class="main-content">
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <h5 class="mb-0 fw-bold">Reports & Decision Analytics</h5>
            </div>
            <div>
                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                    <i class="bi bi-printer me-1"></i> Print / Export PDF
                </button>
            </div>
        </header>

        <main class="page-body">
            <!-- Summary Metric Row -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-green">
                        <div class="metric-title">Total Prepared (kg)</div>
                        <div class="metric-value">${summary.totalFoodPrepared}</div>
                        <div class="metric-subtitle">Across all recorded meals</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-blue">
                        <div class="metric-title">Total Served (kg)</div>
                        <div class="metric-value">${summary.totalFoodServed}</div>
                        <div class="metric-subtitle">Consumed by students</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card accent-rose">
                        <div class="metric-title">Total Wasted (kg)</div>
                        <div class="metric-value">${summary.totalFoodWasted}</div>
                        <div class="metric-subtitle">Discarded leftover</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="metric-card ${summary.wastagePercentage > 10 ? 'accent-rose' : 'accent-green'}">
                        <div class="metric-title">Efficiency Ratio</div>
                        <div class="metric-value">${summary.wastagePercentage}%</div>
                        <div class="metric-subtitle">Target: Below 8%</div>
                    </div>
                </div>
            </div>

            <!-- Chart Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-7">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-bar-chart-line me-1 text-primary"></i> Daily Food Wastage Trend</h6>
                            <span class="badge bg-light text-muted border">Prepared vs Wasted</span>
                        </div>
                        <div style="height: 280px; position: relative;">
                            <canvas id="reportWastageChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-star-half me-1 text-warning"></i> Quality Ratings by Meal</h6>
                            <span class="badge bg-light text-muted border">Breakfast / Lunch / Dinner</span>
                        </div>
                        <div style="height: 280px; position: relative;">
                            <canvas id="mealRatingChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tables Row -->
            <div class="row g-4">
                <!-- Daily Wastage Breakdown Table -->
                <div class="col-lg-7">
                    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="card-header bg-white py-3 border-bottom">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-calendar4-week me-1 text-primary"></i> Daily Operational Totals</h6>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Prepared (kg)</th>
                                        <th>Served (kg)</th>
                                        <th>Wasted (kg)</th>
                                        <th>Wastage %</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="t" items="${wastageTrends}">
                                        <tr>
                                            <td class="fw-semibold">${t.date}</td>
                                            <td>${t.prepared} kg</td>
                                            <td>${t.served} kg</td>
                                            <td><span class="text-danger fw-bold">${t.wasted} kg</span></td>
                                            <td>
                                                <span class="badge ${t.prepared > 0 && (t.wasted / t.prepared * 100) > 10 ? 'bg-danger' : 'bg-success'}">
                                                    ${t.prepared > 0 ? Math.round((t.wasted / t.prepared * 100) * 10.0) / 10.0 : 0.0}%
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Meal Type Rating Breakdown Table -->
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="card-header bg-white py-3 border-bottom">
                            <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-trophy me-1 text-warning"></i> Meal Quality Comparison</h6>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Meal</th>
                                        <th>Quality</th>
                                        <th>Taste</th>
                                        <th>Clean</th>
                                        <th>Score</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="rb" items="${ratingBreakdown}">
                                        <tr>
                                            <td class="fw-bold">${rb.mealName}</td>
                                            <td>${rb.quality}</td>
                                            <td>${rb.taste}</td>
                                            <td>${rb.cleanliness}</td>
                                            <td>
                                                <span class="badge bg-warning-subtle text-dark border">
                                                    ★ ${rb.overall}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </main>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const rawData = ${chartDataJson != null ? chartDataJson : '{}'};
    const trends = rawData.wastageTrends || [];
    const ratings = rawData.ratingBreakdown || [];

    // Chart 1: Wastage Trend
    const wCtx = document.getElementById('reportWastageChart');
    if (wCtx) {
        new Chart(wCtx, {
            type: 'bar',
            data: {
                labels: trends.map(t => t.date),
                datasets: [
                    { label: 'Prepared (kg)', data: trends.map(t => t.prepared), backgroundColor: '#3b82f6' },
                    { label: 'Wasted (kg)', data: trends.map(t => t.wasted), backgroundColor: '#f43f5e' }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: { y: { beginAtZero: true } }
            }
        });
    }

    // Chart 2: Meal Ratings
    const rCtx = document.getElementById('mealRatingChart');
    if (rCtx) {
        new Chart(rCtx, {
            type: 'bar',
            data: {
                labels: ratings.map(r => r.mealName),
                datasets: [
                    { label: 'Quality', data: ratings.map(r => r.quality), backgroundColor: '#10b981' },
                    { label: 'Taste', data: ratings.map(r => r.taste), backgroundColor: '#f59e0b' },
                    { label: 'Cleanliness', data: ratings.map(r => r.cleanliness), backgroundColor: '#8b5cf6' }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: { y: { min: 0, max: 5 } }
            }
        });
    }
});
</script>

<jsp:include page="/includes/footer.jsp" />
