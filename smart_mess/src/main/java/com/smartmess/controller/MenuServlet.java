package com.smartmess.controller;

import com.smartmess.dao.MealTypeDAO;
import com.smartmess.dao.MenuDAO;
import com.smartmess.model.MealType;
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
import java.sql.Date;
import java.util.List;

/**
 * Controller for daily menu schedules.
 * Provides menu viewing, staff/admin CRUD operations, date filtering, and duplicate prevention.
 */
@WebServlet("/menus")
public class MenuServlet extends HttpServlet {

    private MenuDAO menuDAO;
    private MealTypeDAO mealTypeDAO;

    @Override
    public void init() throws ServletException {
        this.menuDAO = new MenuDAO();
        this.mealTypeDAO = new MealTypeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String filterDateStr = req.getParameter("filterDate");
        List<Menu> menus;

        if (!ValidationUtil.isEmpty(filterDateStr)) {
            try {
                Date filterDate = Date.valueOf(filterDateStr.trim());
                menus = menuDAO.findByDate(filterDate);
                req.setAttribute("filterDate", filterDateStr);
            } catch (IllegalArgumentException e) {
                menus = menuDAO.findAll(30);
                req.setAttribute("error", "Invalid date format. Showing recent menus.");
            }
        } else {
            menus = menuDAO.findAll(30);
        }

        List<MealType> mealTypes = mealTypeDAO.findAll();
        req.setAttribute("menus", menus);
        req.setAttribute("mealTypes", mealTypes);

        // Edit menu prefill if requested
        String action = req.getParameter("action");
        if ("edit".equalsIgnoreCase(action)) {
            int menuId = ValidationUtil.parseInt(req.getParameter("menuId"), 0);
            Menu editMenu = menuDAO.findById(menuId);
            req.setAttribute("editMenu", editMenu);
        }

        req.getRequestDispatcher("/menus.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only mess staff or administrators can modify menus.");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "add";

        if ("add".equalsIgnoreCase(action)) {
            handleAddMenu(req, resp);
        } else if ("edit".equalsIgnoreCase(action)) {
            handleEditMenu(req, resp);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDeleteMenu(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/menus");
        }
    }

    private void handleAddMenu(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String dateStr = req.getParameter("menuDate");
        int mealTypeId = ValidationUtil.parseInt(req.getParameter("mealTypeId"), 0);
        String foodItems = req.getParameter("foodItems");
        String notes = req.getParameter("notes");

        if (ValidationUtil.isEmpty(dateStr) || mealTypeId <= 0 || ValidationUtil.isEmpty(foodItems)) {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Date, meal type, and food items are required.");
            return;
        }

        try {
            Date menuDate = Date.valueOf(dateStr.trim());

            if (menuDAO.existsByDateAndMealType(menuDate, mealTypeId)) {
                resp.sendRedirect(req.getContextPath() + "/menus?error=A menu already exists for this date and meal type.");
                return;
            }

            Menu m = new Menu();
            m.setMenuDate(menuDate);
            m.setMealTypeId(mealTypeId);
            m.setFoodItems(ValidationUtil.escapeHtml(foodItems));
            m.setNotes(ValidationUtil.escapeHtml(notes));

            boolean success = menuDAO.createMenu(m);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/menus?msg=Menu item successfully added.");
            } else {
                resp.sendRedirect(req.getContextPath() + "/menus?error=Database error while adding menu.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Invalid date provided.");
        }
    }

    private void handleEditMenu(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int menuId = ValidationUtil.parseInt(req.getParameter("menuId"), 0);
        String foodItems = req.getParameter("foodItems");
        String notes = req.getParameter("notes");

        if (menuId <= 0 || ValidationUtil.isEmpty(foodItems)) {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Menu ID and food items are required.");
            return;
        }

        Menu m = menuDAO.findById(menuId);
        if (m == null) {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Menu not found.");
            return;
        }

        m.setFoodItems(ValidationUtil.escapeHtml(foodItems));
        m.setNotes(ValidationUtil.escapeHtml(notes));

        boolean ok = menuDAO.updateMenu(m);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/menus?msg=Menu updated successfully.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Failed to update menu.");
        }
    }

    private void handleDeleteMenu(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int menuId = ValidationUtil.parseInt(req.getParameter("menuId"), 0);
        if (menuId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Invalid menu ID.");
            return;
        }

        boolean ok = menuDAO.deleteMenu(menuId);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/menus?msg=Menu item removed successfully.");
        } else {
            resp.sendRedirect(req.getContextPath() + "/menus?error=Could not delete menu. It may have linked attendance or feedback records.");
        }
    }
}
