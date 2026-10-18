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

/**
 * Controller handling user authentication lifecycle:
 * - Login credential verification with BCrypt
 * - Student self-registration (enforces STUDENT role only)
 * - Safe session invalidation upon logout
 */
@WebServlet({"/login", "/logout", "/register"})
public class AuthServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/login?msg=You have been successfully logged out.");
            return;
        }

        if ("/register".equals(path)) {
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Default to login page
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/login".equals(path)) {
            handleLogin(req, resp);
        } else if ("/register".equals(path)) {
            handleRegister(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (ValidationUtil.isEmpty(email) || ValidationUtil.isEmpty(password)) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.authenticate(email, password);
        if (user == null) {
            req.setAttribute("error", "Invalid email or password. Please try again.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Store user in session
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);

        // Redirect to unified dashboard dispatcher
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String hostel = req.getParameter("hostel");
        String roomNo = req.getParameter("roomNo");

        // Server-side validations
        if (ValidationUtil.isEmpty(name) || ValidationUtil.isEmpty(email) || ValidationUtil.isEmpty(password)) {
            req.setAttribute("error", "Name, email, and password are required.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("error", "Please provide a valid email address.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters long.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
            return;
        }

        if (userDAO.emailExists(email)) {
            req.setAttribute("error", "An account with this email address already exists.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
            return;
        }

        // Create student user with BCrypt hash (Hardcoded role STUDENT for security)
        User newUser = new User();
        newUser.setName(ValidationUtil.escapeHtml(name));
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setRole("STUDENT");
        newUser.setHostel(ValidationUtil.escapeHtml(hostel));
        newUser.setRoomNo(ValidationUtil.escapeHtml(roomNo));

        boolean ok = userDAO.createUser(newUser);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=Registration successful! Please sign in with your credentials.");
        } else {
            req.setAttribute("error", "An unexpected database error occurred during registration. Please try again.");
            forwardRegisterForm(req, resp, name, email, hostel, roomNo);
        }
    }

    private void forwardRegisterForm(HttpServletRequest req, HttpServletResponse resp,
                                    String name, String email, String hostel, String roomNo) 
            throws ServletException, IOException {
        req.setAttribute("name", name);
        req.setAttribute("email", email);
        req.setAttribute("hostel", hostel);
        req.setAttribute("roomNo", roomNo);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
}
