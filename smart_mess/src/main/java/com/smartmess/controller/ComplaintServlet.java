package com.smartmess.controller;

import com.smartmess.dao.ComplaintCategoryDAO;
import com.smartmess.dao.ComplaintDAO;
import com.smartmess.model.Complaint;
import com.smartmess.model.ComplaintCategory;
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

/**
 * Controller for complaint management.
 * Handles filing grievances, role restrictions, and resolution lifecycle tracking.
 */
@WebServlet("/complaints")
public class ComplaintServlet extends HttpServlet {

    private ComplaintDAO complaintDAO;
    private ComplaintCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        this.complaintDAO = new ComplaintDAO();
        this.categoryDAO = new ComplaintCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<ComplaintCategory> categories = categoryDAO.findAll();
        req.setAttribute("categories", categories);

        if (user.isStudent()) {
            List<Complaint> myComplaints = complaintDAO.findByUserId(user.getUserId());
            req.setAttribute("complaints", myComplaints);
        } else {
            String statusFilter = req.getParameter("status");
            Integer categoryFilter = null;
            String catParam = req.getParameter("categoryId");
            if (!ValidationUtil.isEmpty(catParam)) {
                categoryFilter = ValidationUtil.parseInt(catParam, 0);
            }

            List<Complaint> allComplaints = complaintDAO.findAll(statusFilter, categoryFilter);
            req.setAttribute("complaints", allComplaints);
            req.setAttribute("selectedStatus", statusFilter);
            req.setAttribute("selectedCategory", categoryFilter);
        }

        req.getRequestDispatcher("/complaints.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "create";

        if ("create".equalsIgnoreCase(action)) {
            handleCreateComplaint(req, resp, user);
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            handleUpdateStatus(req, resp, user);
        } else {
            resp.sendRedirect(req.getContextPath() + "/complaints");
        }
    }

    private void handleCreateComplaint(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int categoryId = ValidationUtil.parseInt(req.getParameter("categoryId"), 0);
        String description = req.getParameter("description");

        if (categoryId <= 0 || ValidationUtil.isEmpty(description)) {
            resp.sendRedirect(req.getContextPath() + "/complaints?error=Please select a category and provide description.");
            return;
        }

        Complaint c = new Complaint();
        c.setUserId(user.getUserId());
        c.setCategoryId(categoryId);
        c.setDescription(ValidationUtil.escapeHtml(description));

        boolean ok = complaintDAO.createComplaint(c);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/complaints?msg=Your complaint has been submitted successfully.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/complaints?error=Failed to submit complaint. Please try again.");
        }
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        if (user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Students cannot update complaint resolution status.");
            return;
        }

        int complaintId = ValidationUtil.parseInt(req.getParameter("complaintId"), 0);
        String newStatus = req.getParameter("status");

        if (complaintId <= 0 || ValidationUtil.isEmpty(newStatus)) {
            resp.sendRedirect(req.getContextPath() + "/complaints?error=Invalid complaint or status.");
            return;
        }

        boolean ok = complaintDAO.updateStatus(complaintId, newStatus);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/complaints?msg=Complaint status updated to " + newStatus + ".");
        } else {
            resp.sendRedirect(req.getContextPath() + "/complaints?error=Could not update complaint status.");
        }
    }
}
