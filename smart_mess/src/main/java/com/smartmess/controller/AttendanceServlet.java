package com.smartmess.controller;

import com.smartmess.dao.AttendanceDAO;
import com.smartmess.dao.MenuDAO;
import com.smartmess.model.Attendance;
import com.smartmess.model.Menu;
import com.smartmess.model.User;
import com.smartmess.util.ValidationUtil;
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
 * Controller for meal attendance operations.
 * Allows students to mark meal presence/absence, view attendance history,
 * and enables staff/admin to monitor headcounts.
 */
@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

    private AttendanceDAO attendanceDAO;
    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {
        this.attendanceDAO = new AttendanceDAO();
        this.menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Today's menus for marking attendance
        List<Menu> todayMenus = menuDAO.findTodayMenus();
        req.setAttribute("todayMenus", todayMenus);

        if (user.isStudent()) {
            // Student personal view: today's choices and history
            Map<Integer, String> attendanceMap = attendanceDAO.getTodayAttendanceMap(user.getUserId());
            List<Attendance> history = attendanceDAO.findHistoryByUser(user.getUserId(), 20);

            req.setAttribute("attendanceMap", attendanceMap);
            req.setAttribute("history", history);
        } else {
            // Staff / Admin overview
            int todayPresent = attendanceDAO.countTodayPresent();
            int todayTotal = attendanceDAO.countTodayTotal();

            req.setAttribute("todayPresent", todayPresent);
            req.setAttribute("todayTotal", todayTotal);
        }

        req.getRequestDispatcher("/attendance.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int menuId = ValidationUtil.parseInt(req.getParameter("menuId"), 0);
        String status = req.getParameter("status");

        if (menuId <= 0 || ValidationUtil.isEmpty(status)) {
            resp.sendRedirect(req.getContextPath() + "/attendance?error=Invalid meal selection or status.");
            return;
        }

        String cleanStatus = status.trim().toUpperCase();
        if (!"PRESENT".equals(cleanStatus) && !"ABSENT".equals(cleanStatus)) {
            resp.sendRedirect(req.getContextPath() + "/attendance?error=Status must be PRESENT or ABSENT.");
            return;
        }

        boolean ok = attendanceDAO.markAttendance(user.getUserId(), menuId, cleanStatus);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/attendance?msg=Attendance successfully marked as " + cleanStatus + ".");
        } else {
            resp.sendRedirect(req.getContextPath() + "/attendance?error=Failed to save attendance. Please try again.");
        }
    }
}
