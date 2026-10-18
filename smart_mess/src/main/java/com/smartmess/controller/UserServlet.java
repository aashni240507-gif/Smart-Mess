package com.smartmess.controller;

import com.smartmess.dao.UserDAO;
import com.smartmess.model.User;
import com.smartmess.util.PasswordUtil;
import com.smartmess.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller for user management.
 * Restricted strictly to Administrator role.
 * Allows viewing users, provisioning staff accounts, and role adjustments.
 */
@WebServlet("/users")
public class UserServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;

        if (current == null || !current.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privileges required.");
            return;
        }

        List<User> userList = userDAO.findAll();
        int studentCount = userDAO.countByRole("STUDENT");
        int staffCount = userDAO.countByRole("STAFF");
        int adminCount = userDAO.countByRole("ADMIN");

        req.setAttribute("userList", userList);
        req.setAttribute("studentCount", studentCount);
        req.setAttribute("staffCount", staffCount);
        req.setAttribute("adminCount", adminCount);

        req.getRequestDispatcher("/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;

        if (current == null || !current.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privileges required.");
            return;
        }

        String action = req.getParameter("action");
        if ("createStaff".equalsIgnoreCase(action)) {
            handleCreateStaff(req, resp);
        } else if ("updateRole".equalsIgnoreCase(action)) {
            handleUpdateRole(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/users");
        }
    }

    private void handleCreateStaff(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String hostel = req.getParameter("hostel");
        String roomNo = req.getParameter("roomNo");

        if (ValidationUtil.isEmpty(name) || ValidationUtil.isEmpty(email) || ValidationUtil.isEmpty(password)) {
            resp.sendRedirect(req.getContextPath() + "/users?error=Staff name, email, and password are required.");
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            resp.sendRedirect(req.getContextPath() + "/users?error=Please provide a valid email address.");
            return;
        }

        if (userDAO.emailExists(email)) {
            resp.sendRedirect(req.getContextPath() + "/users?error=User with this email already exists.");
            return;
        }

        User staff = new User();
        staff.setName(ValidationUtil.escapeHtml(name));
        staff.setEmail(email.trim().toLowerCase());
        staff.setPasswordHash(PasswordUtil.hashPassword(password));
        staff.setRole("STAFF");
        staff.setHostel(ValidationUtil.escapeHtml(hostel));
        staff.setRoomNo(ValidationUtil.escapeHtml(roomNo));

        boolean ok = userDAO.createUser(staff);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/users?msg=Mess staff account successfully created.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/users?error=Failed to create staff account.");
        }
    }

    private void handleUpdateRole(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int targetUserId = ValidationUtil.parseInt(req.getParameter("userId"), 0);
        String newRole = req.getParameter("role");

        if (targetUserId <= 0 || !ValidationUtil.isValidRole(newRole)) {
            resp.sendRedirect(req.getContextPath() + "/users?error=Invalid user ID or role specification.");
            return;
        }

        boolean ok = userDAO.updateRole(targetUserId, newRole);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/users?msg=User role updated successfully.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/users?error=Failed to update user role.");
        }
    }
}
