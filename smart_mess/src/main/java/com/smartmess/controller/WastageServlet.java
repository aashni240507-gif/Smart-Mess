package com.smartmess.controller;

import com.smartmess.dao.MenuDAO;
import com.smartmess.dao.WastageDAO;
import com.smartmess.model.Menu;
import com.smartmess.model.User;
import com.smartmess.model.Wastage;
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
 * Controller for food wastage tracking in kilograms.
 * Restricted to mess staff and administrators.
 * Validates preparation, serving, and wasted quantity constraints.
 */
@WebServlet("/wastage")
public class WastageServlet extends HttpServlet {

    private WastageDAO wastageDAO;
    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {
        this.wastageDAO = new WastageDAO();
        this.menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Only staff or administrators can track food wastage.");
            return;
        }

        List<Menu> menus = menuDAO.findAll(20);
        List<Wastage> wastageRecords = wastageDAO.findAll(30);
        double[] totals = wastageDAO.getTotals();

        req.setAttribute("menus", menus);
        req.setAttribute("wastageRecords", wastageRecords);
        req.setAttribute("totalPrepared", totals[0]);
        req.setAttribute("totalServed", totals[1]);
        req.setAttribute("totalWasted", totals[2]);
        req.setAttribute("wastagePct", totals[3]);

        req.getRequestDispatcher("/wastage.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Only staff or administrators can track food wastage.");
            return;
        }

        int menuId = ValidationUtil.parseInt(req.getParameter("menuId"), 0);
        double prepared = ValidationUtil.parseDouble(req.getParameter("foodPrepared"), -1.0);
        double served = ValidationUtil.parseDouble(req.getParameter("foodServed"), -1.0);
        double wasted = ValidationUtil.parseDouble(req.getParameter("foodWasted"), -1.0);

        if (menuId <= 0 || prepared < 0 || served < 0 || wasted < 0) {
            resp.sendRedirect(req.getContextPath() + "/wastage?error=Please select a meal and provide valid non-negative quantities.");
            return;
        }

        if (served > prepared) {
            resp.sendRedirect(req.getContextPath() + "/wastage?error=Food served cannot exceed total food prepared.");
            return;
        }

        if (wasted > prepared) {
            resp.sendRedirect(req.getContextPath() + "/wastage?error=Food wasted cannot exceed total food prepared.");
            return;
        }

        Wastage w = new Wastage();
        w.setMenuId(menuId);
        w.setFoodPrepared(prepared);
        w.setFoodServed(served);
        w.setFoodWasted(wasted);
        w.setRecordedBy(user.getUserId());

        boolean ok = wastageDAO.recordWastage(w);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/wastage?msg=Food wastage metrics successfully recorded.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/wastage?error=Failed to record wastage in database.");
        }
    }
}
