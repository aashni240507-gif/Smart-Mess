package com.smartmess.filter;

import com.smartmess.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Authentication and Authorization Servlet Filter.
 * Enforces session-based authentication and role restrictions.
 * Demonstrates filter chain concept in Java Web Architecture.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.substring(contextPath.length());

        // 1. Allow public static assets and auth endpoints
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Check user session
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Unauthenticated user trying to access protected resource
            res.sendRedirect(contextPath + "/login?error=Please login to access SmartMess");
            return;
        }

        // 3. Role-based endpoint authorization
        String role = user.getRole();

        // Admin-only paths
        if (path.startsWith("/users") && !"ADMIN".equalsIgnoreCase(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator role required.");
            return;
        }

        // Staff and Admin operations (Menu management mutations, Wastage tracking)
        if (path.startsWith("/wastage") && "STUDENT".equalsIgnoreCase(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only mess staff or admin can manage food wastage.");
            return;
        }

        // Pass control down the filter chain
        chain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        if (path.equals("/") || path.equals("/index.jsp") || path.equals("/login") || 
            path.equals("/login.jsp") || path.equals("/register") || path.equals("/register.jsp")) {
            return true;
        }
        return path.startsWith("/assets/") || path.startsWith("/css/") || 
               path.startsWith("/js/") || path.startsWith("/images/");
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
