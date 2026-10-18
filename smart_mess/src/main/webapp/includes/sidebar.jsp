<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="sidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-brand">
            <span class="brand-icon"><i class="bi bi-egg-fried"></i></span>
            <span>SmartMess</span>
        </a>
    </div>

    <ul class="sidebar-nav">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/dashboard" 
               class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>Dashboard</span>
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/menus" 
               class="nav-link ${param.activePage == 'menus' ? 'active' : ''}">
                <i class="bi bi-calendar-week"></i>
                <span>Daily Menus</span>
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/attendance" 
               class="nav-link ${param.activePage == 'attendance' ? 'active' : ''}">
                <i class="bi bi-check2-square"></i>
                <span>Meal Attendance</span>
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/feedback" 
               class="nav-link ${param.activePage == 'feedback' ? 'active' : ''}">
                <i class="bi bi-star"></i>
                <span>Food Feedback</span>
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/complaints" 
               class="nav-link ${param.activePage == 'complaints' ? 'active' : ''}">
                <i class="bi bi-chat-left-dots"></i>
                <span>Complaints</span>
            </a>
        </li>

        <!-- Staff and Admin Only Links -->
        <c:if test="${sessionScope.user.staff || sessionScope.user.admin}">
            <li class="nav-item mt-3 mb-1">
                <small class="text-uppercase text-secondary fw-bold px-3" style="font-size: 0.72rem; letter-spacing: 1px;">Operations</small>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/wastage" 
                   class="nav-link ${param.activePage == 'wastage' ? 'active' : ''}">
                    <i class="bi bi-trash3"></i>
                    <span>Food Wastage</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/reports" 
                   class="nav-link ${param.activePage == 'reports' ? 'active' : ''}">
                    <i class="bi bi-graph-up-arrow"></i>
                    <span>Reports & Analytics</span>
                </a>
            </li>
        </c:if>

        <!-- Admin Only Links -->
        <c:if test="${sessionScope.user.admin}">
            <li class="nav-item mt-3 mb-1">
                <small class="text-uppercase text-secondary fw-bold px-3" style="font-size: 0.72rem; letter-spacing: 1px;">Administration</small>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/users" 
                   class="nav-link ${param.activePage == 'users' ? 'active' : ''}">
                    <i class="bi bi-people"></i>
                    <span>User Management</span>
                </a>
            </li>
        </c:if>
    </ul>

    <div class="sidebar-footer">
        <div class="user-profile-badge">
            <div class="user-avatar">
                ${sessionScope.user != null ? sessionScope.user.name.substring(0, 1).toUpperCase() : 'U'}
            </div>
            <div class="overflow-hidden me-auto">
                <div class="text-white fw-semibold text-truncate" style="font-size: 0.9rem;">
                    ${sessionScope.user != null ? sessionScope.user.name : 'Guest User'}
                </div>
                <div class="badge ${sessionScope.user.admin ? 'bg-danger' : (sessionScope.user.staff ? 'bg-primary' : 'bg-success')}" style="font-size: 0.7rem;">
                    ${sessionScope.user != null ? sessionScope.user.role : 'VISITOR'}
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="text-secondary hover-text-white" title="Logout">
                <i class="bi bi-box-arrow-right fs-5"></i>
            </a>
        </div>
    </div>
</aside>
