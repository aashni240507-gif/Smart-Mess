package com.smartmess.controller;

import com.smartmess.dao.FeedbackDAO;
import com.smartmess.dao.MenuDAO;
import com.smartmess.model.Feedback;
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

/**
 * Controller for student food feedback and quality ratings.
 * Validates ratings (1-5) and stores reviews in Oracle.
 */
@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private FeedbackDAO feedbackDAO;
    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {
        this.feedbackDAO = new FeedbackDAO();
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

        List<Menu> todayMenus = menuDAO.findTodayMenus();
        req.setAttribute("todayMenus", todayMenus);

        if (user.isStudent()) {
            List<Feedback> myFeedbacks = feedbackDAO.findRecentByUser(user.getUserId(), 20);
            req.setAttribute("myFeedbacks", myFeedbacks);
        } else {
            List<Feedback> allFeedbacks = feedbackDAO.findRecentOverall(30);
            double[] averages = feedbackDAO.getAverageScores();
            req.setAttribute("allFeedbacks", allFeedbacks);
            req.setAttribute("avgQuality", averages[0]);
            req.setAttribute("avgTaste", averages[1]);
            req.setAttribute("avgCleanliness", averages[2]);
            req.setAttribute("avgOverall", averages[3]);
        }

        req.getRequestDispatcher("/feedback.jsp").forward(req, resp);
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
        int quality = ValidationUtil.parseInt(req.getParameter("foodQuality"), 0);
        int taste = ValidationUtil.parseInt(req.getParameter("taste"), 0);
        int cleanliness = ValidationUtil.parseInt(req.getParameter("cleanliness"), 0);
        String comments = req.getParameter("comments");

        if (menuId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/feedback?error=Please select a valid meal.");
            return;
        }

        if (!ValidationUtil.isValidRating(quality) || !ValidationUtil.isValidRating(taste) || 
            !ValidationUtil.isValidRating(cleanliness)) {
            resp.sendRedirect(req.getContextPath() + "/feedback?error=Ratings must be between 1 and 5 stars.");
            return;
        }

        Feedback fb = new Feedback();
        fb.setUserId(user.getUserId());
        fb.setMenuId(menuId);
        fb.setFoodQuality(quality);
        fb.setTaste(taste);
        fb.setCleanliness(cleanliness);
        fb.setComments(ValidationUtil.escapeHtml(comments));

        boolean ok = feedbackDAO.submitFeedback(fb);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/feedback?msg=Thank you! Your feedback has been recorded.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/feedback?error=Failed to submit feedback. Please try again.");
        }
    }
}
