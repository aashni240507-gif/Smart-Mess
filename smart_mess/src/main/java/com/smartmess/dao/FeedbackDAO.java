package com.smartmess.dao;

import com.smartmess.model.Feedback;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for FEEDBACK table in Oracle.
 * Handles student food ratings, review submissions, and aggregate quality analytics.
 */
public class FeedbackDAO {

    /**
     * Submits or updates meal feedback for a student using Oracle MERGE statement.
     */
    public boolean submitFeedback(Feedback fb) {
        String sql = "MERGE INTO FEEDBACK f " +
                     "USING (SELECT ? AS u_id, ? AS m_id FROM dual) src " +
                     "ON (f.USER_ID = src.u_id AND f.MENU_ID = src.m_id) " +
                     "WHEN MATCHED THEN " +
                     "    UPDATE SET f.FOOD_QUALITY = ?, f.TASTE = ?, f.CLEANLINESS = ?, " +
                     "               f.COMMENTS = ?, f.CREATED_AT = CURRENT_TIMESTAMP " +
                     "WHEN NOT MATCHED THEN " +
                     "    INSERT (USER_ID, MENU_ID, FOOD_QUALITY, TASTE, CLEANLINESS, COMMENTS, CREATED_AT) " +
                     "    VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, fb.getUserId());
            ps.setInt(2, fb.getMenuId());
            ps.setInt(3, fb.getFoodQuality());
            ps.setInt(4, fb.getTaste());
            ps.setInt(5, fb.getCleanliness());
            ps.setString(6, fb.getComments() != null ? fb.getComments().trim() : null);

            ps.setInt(7, fb.getUserId());
            ps.setInt(8, fb.getMenuId());
            ps.setInt(9, fb.getFoodQuality());
            ps.setInt(10, fb.getTaste());
            ps.setInt(11, fb.getCleanliness());
            ps.setString(12, fb.getComments() != null ? fb.getComments().trim() : null);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO submitFeedback Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Finds feedback given by a user for a specific menu.
     */
    public Feedback findByUserAndMenu(int userId, int menuId) {
        String sql = "SELECT f.FEEDBACK_ID, f.USER_ID, u.NAME AS USER_NAME, " +
                     "       f.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, " +
                     "       f.FOOD_QUALITY, f.TASTE, f.CLEANLINESS, f.COMMENTS, f.CREATED_AT " +
                     "FROM FEEDBACK f " +
                     "JOIN USERS u ON f.USER_ID = u.USER_ID " +
                     "JOIN MENU m ON f.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE f.USER_ID = ? AND f.MENU_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToFeedback(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO findByUserAndMenu Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Lists recent feedback submitted by a specific student.
     */
    public List<Feedback> findRecentByUser(int userId, int limit) {
        String sql = "SELECT f.FEEDBACK_ID, f.USER_ID, u.NAME AS USER_NAME, " +
                     "       f.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, " +
                     "       f.FOOD_QUALITY, f.TASTE, f.CLEANLINESS, f.COMMENTS, f.CREATED_AT " +
                     "FROM FEEDBACK f " +
                     "JOIN USERS u ON f.USER_ID = u.USER_ID " +
                     "JOIN MENU m ON f.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE f.USER_ID = ? " +
                     "ORDER BY f.CREATED_AT DESC " +
                     "FETCH FIRST ? ROWS ONLY";

        List<Feedback> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToFeedback(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO findRecentByUser Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Lists recent feedbacks across all students (for Staff and Admin).
     */
    public List<Feedback> findRecentOverall(int limit) {
        String sql = "SELECT f.FEEDBACK_ID, f.USER_ID, u.NAME AS USER_NAME, " +
                     "       f.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, " +
                     "       f.FOOD_QUALITY, f.TASTE, f.CLEANLINESS, f.COMMENTS, f.CREATED_AT " +
                     "FROM FEEDBACK f " +
                     "JOIN USERS u ON f.USER_ID = u.USER_ID " +
                     "JOIN MENU m ON f.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "ORDER BY f.CREATED_AT DESC " +
                     "FETCH FIRST ? ROWS ONLY";

        List<Feedback> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToFeedback(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO findRecentOverall Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Calculates overall average scores: [quality, taste, cleanliness, overall composite].
     */
    public double[] getAverageScores() {
        String sql = "SELECT ROUND(NVL(AVG(FOOD_QUALITY), 0), 2) AS AVG_Q, " +
                     "       ROUND(NVL(AVG(TASTE), 0), 2) AS AVG_T, " +
                     "       ROUND(NVL(AVG(CLEANLINESS), 0), 2) AS AVG_C, " +
                     "       ROUND(NVL(AVG((FOOD_QUALITY + TASTE + CLEANLINESS) / 3.0), 0), 2) AS AVG_ALL " +
                     "FROM FEEDBACK";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return new double[] {
                    rs.getDouble("AVG_Q"),
                    rs.getDouble("AVG_T"),
                    rs.getDouble("AVG_C"),
                    rs.getDouble("AVG_ALL")
                };
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO getAverageScores Error] " + e.getMessage());
        }
        return new double[] { 0.0, 0.0, 0.0, 0.0 };
    }

    private Feedback mapRowToFeedback(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setFeedbackId(rs.getInt("FEEDBACK_ID"));
        f.setUserId(rs.getInt("USER_ID"));
        f.setUserName(rs.getString("USER_NAME"));
        f.setMenuId(rs.getInt("MENU_ID"));
        f.setMenuDate(rs.getDate("MENU_DATE"));
        f.setMealName(rs.getString("MEAL_NAME"));
        f.setFoodQuality(rs.getInt("FOOD_QUALITY"));
        f.setTaste(rs.getInt("TASTE"));
        f.setCleanliness(rs.getInt("CLEANLINESS"));
        f.setComments(rs.getString("COMMENTS"));
        f.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        return f;
    }
}
