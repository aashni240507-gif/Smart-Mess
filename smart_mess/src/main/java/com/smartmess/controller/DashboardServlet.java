package com.smartmess.controller;

import com.smartmess.dao.*;
import com.smartmess.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller for the role-based main dashboard.
 * Dispatches to student, staff, or administrator dashboard with live Oracle metrics.
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private MenuDAO menuDAO;
    private AttendanceDAO attendanceDAO;
    private FeedbackDAO feedbackDAO;
    private ComplaintDAO complaintDAO;
    private WastageDAO wastageDAO;
    private ReportDAO reportDAO;

    @Override
    public void init() throws ServletException {
        this.menuDAO = new MenuDAO();
        this.attendanceDAO = new AttendanceDAO();
        this.feedbackDAO = new FeedbackDAO();
        this.complaintDAO = new ComplaintDAO();
        this.wastageDAO = new WastageDAO();
        this.reportDAO = new ReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = user.getRole();

        if ("STUDENT".equalsIgnoreCase(role)) {
            loadStudentDashboard(req, resp, user);
        } else if ("STAFF".equalsIgnoreCase(role)) {
            loadStaffDashboard(req, resp, user);
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            loadAdminDashboard(req, resp, user);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    private void loadStudentDashboard(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Today's menus
        List<Menu> todayMenus = menuDAO.findTodayMenus();
        // Student's marked attendance for today
        Map<Integer, String> attendanceMap = attendanceDAO.getTodayAttendanceMap(user.getUserId());
        // Recent attendance history
        List<Attendance> recentAttendance = attendanceDAO.findHistoryByUser(user.getUserId(), 5);
        // Recent feedback submitted by student
        List<Feedback> recentFeedback = feedbackDAO.findRecentByUser(user.getUserId(), 5);
        // Complaint counts
        int pendingComplaints = complaintDAO.countByUserAndStatus(user.getUserId(), "PENDING");
        int inProgComplaints = complaintDAO.countByUserAndStatus(user.getUserId(), "IN_PROGRESS");
        int resolvedComplaints = complaintDAO.countByUserAndStatus(user.getUserId(), "RESOLVED");

        req.setAttribute("todayMenus", todayMenus);
        req.setAttribute("attendanceMap", attendanceMap);
        req.setAttribute("recentAttendance", recentAttendance);
        req.setAttribute("recentFeedback", recentFeedback);
        req.setAttribute("pendingComplaints", pendingComplaints);
        req.setAttribute("inProgComplaints", inProgComplaints);
        req.setAttribute("resolvedComplaints", resolvedComplaints);

        req.getRequestDispatcher("/student-dashboard.jsp").forward(req, resp);
    }

    private void loadStaffDashboard(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        List<Menu> todayMenus = menuDAO.findTodayMenus();
        List<Wastage> recentWastage = wastageDAO.findAll(5);
        List<Complaint> pendingComplaints = complaintDAO.findAll("PENDING", null);
        List<Feedback> recentFeedback = feedbackDAO.findRecentOverall(5);
        double[] totals = wastageDAO.getTotals();

        req.setAttribute("todayMenus", todayMenus);
        req.setAttribute("recentWastage", recentWastage);
        req.setAttribute("pendingComplaints", pendingComplaints);
        req.setAttribute("recentFeedback", recentFeedback);
        req.setAttribute("totalPrepared", totals[0]);
        req.setAttribute("totalServed", totals[1]);
        req.setAttribute("totalWasted", totals[2]);
        req.setAttribute("wastagePct", totals[3]);

        req.getRequestDispatcher("/staff-dashboard.jsp").forward(req, resp);
    }

    private void loadAdminDashboard(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        DashboardSummary summary = reportDAO.getDashboardSummary();
        List<Menu> todayMenus = menuDAO.findTodayMenus();
        List<Complaint> pendingComplaints = complaintDAO.findAll("PENDING", null);
        List<Wastage> recentWastage = wastageDAO.findAll(5);

        req.setAttribute("summary", summary);
        req.setAttribute("todayMenus", todayMenus);
        req.setAttribute("pendingComplaints", pendingComplaints);
        req.setAttribute("recentWastage", recentWastage);

        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, resp);
    }
}
