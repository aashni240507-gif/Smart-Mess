package com.smartmess.dao;

import com.smartmess.model.DashboardSummary;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for reports, analytics, and dynamic dashboard metrics.
 * Uses Oracle aggregate functions (COUNT, SUM, AVG) and joined views.
 */
public class ReportDAO {

    /**
     * Aggregates real operational metrics across the system from Oracle.
     */
    public DashboardSummary getDashboardSummary() {
        DashboardSummary ds = new DashboardSummary();

        // 1. User counts
        String userSql = "SELECT " +
                         "  SUM(CASE WHEN ROLE = 'STUDENT' THEN 1 ELSE 0 END) AS STUDENT_COUNT, " +
                         "  SUM(CASE WHEN ROLE = 'STAFF' THEN 1 ELSE 0 END) AS STAFF_COUNT " +
                         "FROM USERS";

        // 2. Menu count
        String menuSql = "SELECT COUNT(*) AS TOTAL_MENUS FROM MENU";

        // 3. Today's Attendance counts
        String attSql = "SELECT " +
                        "  COUNT(a.ATTENDANCE_ID) AS TOTAL_ATT, " +
                        "  SUM(CASE WHEN a.STATUS = 'PRESENT' THEN 1 ELSE 0 END) AS PRESENT_ATT, " +
                        "  SUM(CASE WHEN a.STATUS = 'ABSENT' THEN 1 ELSE 0 END) AS ABSENT_ATT " +
                        "FROM ATTENDANCE a " +
                        "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                        "WHERE TRUNC(m.MENU_DATE) = TRUNC(SYSDATE)";

        // 4. Complaint counts
        String compSql = "SELECT " +
                         "  SUM(CASE WHEN STATUS = 'PENDING' THEN 1 ELSE 0 END) AS PENDING_CNT, " +
                         "  SUM(CASE WHEN STATUS = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS IN_PROG_CNT, " +
                         "  SUM(CASE WHEN STATUS = 'RESOLVED' THEN 1 ELSE 0 END) AS RESOLVED_CNT, " +
                         "  COUNT(*) AS TOTAL_CNT " +
                         "FROM COMPLAINTS";

        // 5. Feedback averages
        String fbSql = "SELECT " +
                       "  ROUND(NVL(AVG(FOOD_QUALITY), 0), 2) AS AVG_Q, " +
                       "  ROUND(NVL(AVG(TASTE), 0), 2) AS AVG_T, " +
                       "  ROUND(NVL(AVG(CLEANLINESS), 0), 2) AS AVG_C, " +
                       "  ROUND(NVL(AVG((FOOD_QUALITY + TASTE + CLEANLINESS) / 3.0), 0), 2) AS AVG_ALL " +
                       "FROM FEEDBACK";

        // 6. Food wastage totals
        String wasteSql = "SELECT " +
                          "  NVL(SUM(FOOD_PREPARED), 0) AS TOTAL_PREP, " +
                          "  NVL(SUM(FOOD_SERVED), 0) AS TOTAL_SERV, " +
                          "  NVL(SUM(FOOD_WASTED), 0) AS TOTAL_WAST " +
                          "FROM WASTAGE";

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(userSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ds.setTotalStudents(rs.getInt("STUDENT_COUNT"));
                    ds.setTotalStaff(rs.getInt("STAFF_COUNT"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(menuSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ds.setTotalMenus(rs.getInt("TOTAL_MENUS"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(attSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ds.setExpectedAttendance(rs.getInt("TOTAL_ATT"));
                    ds.setPresentAttendance(rs.getInt("PRESENT_ATT"));
                    ds.setAbsentAttendance(rs.getInt("ABSENT_ATT"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(compSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ds.setPendingComplaints(rs.getInt("PENDING_CNT"));
                    ds.setInProgressComplaints(rs.getInt("IN_PROG_CNT"));
                    ds.setResolvedComplaints(rs.getInt("RESOLVED_CNT"));
                    ds.setTotalComplaints(rs.getInt("TOTAL_CNT"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(fbSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ds.setAvgFoodQuality(rs.getDouble("AVG_Q"));
                    ds.setAvgTaste(rs.getDouble("AVG_T"));
                    ds.setAvgCleanliness(rs.getDouble("AVG_C"));
                    ds.setOverallRating(rs.getDouble("AVG_ALL"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(wasteSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double prep = rs.getDouble("TOTAL_PREP");
                    double serv = rs.getDouble("TOTAL_SERV");
                    double wast = rs.getDouble("TOTAL_WAST");
                    ds.setTotalFoodPrepared(prep);
                    ds.setTotalFoodServed(serv);
                    ds.setTotalFoodWasted(wast);
                    double pct = prep > 0 ? Math.round((wast / prep) * 10000.0) / 100.0 : 0.0;
                    ds.setWastagePercentage(pct);
                }
            }

        } catch (SQLException e) {
            System.err.println("[ReportDAO getDashboardSummary Error] " + e.getMessage());
        }

        return ds;
    }

    /**
     * Retrieves daily wastage trends for chart rendering.
     */
    public List<Map<String, Object>> getDailyWastageTrends(int days) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT " +
                     "  TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MEAL_DATE, " +
                     "  NVL(SUM(w.FOOD_PREPARED), 0) AS TOTAL_PREP, " +
                     "  NVL(SUM(w.FOOD_SERVED), 0) AS TOTAL_SERV, " +
                     "  NVL(SUM(w.FOOD_WASTED), 0) AS TOTAL_WAST " +
                     "FROM MENU m " +
                     "JOIN WASTAGE w ON m.MENU_ID = w.MENU_ID " +
                     "GROUP BY TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') " +
                     "ORDER BY MEAL_DATE ASC " +
                     "FETCH FIRST ? ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getString("MEAL_DATE"));
                    map.put("prepared", rs.getDouble("TOTAL_PREP"));
                    map.put("served", rs.getDouble("TOTAL_SERV"));
                    map.put("wasted", rs.getDouble("TOTAL_WAST"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO getDailyWastageTrends Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Retrieves average feedback scores grouped by meal type.
     */
    public List<Map<String, Object>> getMealRatingBreakdown() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT " +
                     "  mt.MEAL_NAME, " +
                     "  ROUND(NVL(AVG(f.FOOD_QUALITY), 0), 2) AS QUALITY, " +
                     "  ROUND(NVL(AVG(f.TASTE), 0), 2) AS TASTE, " +
                     "  ROUND(NVL(AVG(f.CLEANLINESS), 0), 2) AS CLEANLINESS, " +
                     "  ROUND(NVL(AVG((f.FOOD_QUALITY + f.TASTE + f.CLEANLINESS) / 3.0), 0), 2) AS OVERALL " +
                     "FROM MEAL_TYPES mt " +
                     "JOIN MENU m ON mt.MEAL_TYPE_ID = m.MEAL_TYPE_ID " +
                     "LEFT JOIN FEEDBACK f ON m.MENU_ID = f.MENU_ID " +
                     "GROUP BY mt.MEAL_TYPE_ID, mt.MEAL_NAME " +
                     "ORDER BY mt.MEAL_TYPE_ID ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("mealName", rs.getString("MEAL_NAME"));
                map.put("quality", rs.getDouble("QUALITY"));
                map.put("taste", rs.getDouble("TASTE"));
                map.put("cleanliness", rs.getDouble("CLEANLINESS"));
                map.put("overall", rs.getDouble("OVERALL"));
                list.add(map);
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO getMealRatingBreakdown Error] " + e.getMessage());
        }
        return list;
    }
}
