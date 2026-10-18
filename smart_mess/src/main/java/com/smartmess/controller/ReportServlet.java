package com.smartmess.controller;

import com.google.gson.Gson;
import com.smartmess.dao.ReportDAO;
import com.smartmess.model.DashboardSummary;
import com.smartmess.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for operational reports, data visualization, and analytical summaries.
 * Provides both HTML view rendering and JSON endpoints for Chart.js visualizations.
 */
@WebServlet("/reports")
public class ReportServlet extends HttpServlet {

    private ReportDAO reportDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.reportDAO = new ReportDAO();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Staff or Administrator role required.");
            return;
        }

        String format = req.getParameter("format");
        if ("json".equalsIgnoreCase(format)) {
            serveJsonData(req, resp);
            return;
        }

        DashboardSummary summary = reportDAO.getDashboardSummary();
        List<Map<String, Object>> wastageTrends = reportDAO.getDailyWastageTrends(14);
        List<Map<String, Object>> ratingBreakdown = reportDAO.getMealRatingBreakdown();

        req.setAttribute("summary", summary);
        req.setAttribute("wastageTrends", wastageTrends);
        req.setAttribute("ratingBreakdown", ratingBreakdown);
        req.setAttribute("chartDataJson", gson.toJson(createChartDataMap(wastageTrends, ratingBreakdown, summary)));

        req.getRequestDispatcher("/reports.jsp").forward(req, resp);
    }

    private void serveJsonData(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        DashboardSummary summary = reportDAO.getDashboardSummary();
        List<Map<String, Object>> wastageTrends = reportDAO.getDailyWastageTrends(14);
        List<Map<String, Object>> ratingBreakdown = reportDAO.getMealRatingBreakdown();

        Map<String, Object> data = createChartDataMap(wastageTrends, ratingBreakdown, summary);
        resp.getWriter().write(gson.toJson(data));
    }

    private Map<String, Object> createChartDataMap(List<Map<String, Object>> wastageTrends,
                                                   List<Map<String, Object>> ratingBreakdown,
                                                   DashboardSummary summary) {
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("wastageTrends", wastageTrends);
        chartData.put("ratingBreakdown", ratingBreakdown);
        chartData.put("summary", summary);
        return chartData;
    }
}
