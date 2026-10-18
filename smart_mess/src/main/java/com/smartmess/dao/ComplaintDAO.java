package com.smartmess.dao;

import com.smartmess.model.Complaint;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for COMPLAINTS table in Oracle.
 * Handles filing complaints, status updates (PENDING -> IN_PROGRESS -> RESOLVED),
 * and student/staff ownership filtering.
 */
public class ComplaintDAO {

    /**
     * Files a new complaint in Oracle.
     */
    public boolean createComplaint(Complaint c) {
        String sql = "INSERT INTO COMPLAINTS (USER_ID, CATEGORY_ID, DESCRIPTION, STATUS) " +
                     "VALUES (?, ?, ?, 'PENDING')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, c.getUserId());
            ps.setInt(2, c.getCategoryId());
            ps.setString(3, c.getDescription().trim());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO createComplaint Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Finds a complaint by ID with student and category details.
     */
    public Complaint findById(int complaintId) {
        String sql = "SELECT c.COMPLAINT_ID, c.USER_ID, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL, " +
                     "       u.HOSTEL, u.ROOM_NO, c.CATEGORY_ID, cat.CATEGORY_NAME, " +
                     "       c.DESCRIPTION, c.STATUS, c.CREATED_AT, c.RESOLVED_AT " +
                     "FROM COMPLAINTS c " +
                     "JOIN USERS u ON c.USER_ID = u.USER_ID " +
                     "JOIN COMPLAINT_CATEGORIES cat ON c.CATEGORY_ID = cat.CATEGORY_ID " +
                     "WHERE c.COMPLAINT_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToComplaint(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO findById Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Lists complaints filed by a specific student.
     */
    public List<Complaint> findByUserId(int userId) {
        String sql = "SELECT c.COMPLAINT_ID, c.USER_ID, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL, " +
                     "       u.HOSTEL, u.ROOM_NO, c.CATEGORY_ID, cat.CATEGORY_NAME, " +
                     "       c.DESCRIPTION, c.STATUS, c.CREATED_AT, c.RESOLVED_AT " +
                     "FROM COMPLAINTS c " +
                     "JOIN USERS u ON c.USER_ID = u.USER_ID " +
                     "JOIN COMPLAINT_CATEGORIES cat ON c.CATEGORY_ID = cat.CATEGORY_ID " +
                     "WHERE c.USER_ID = ? " +
                     "ORDER BY c.CREATED_AT DESC";

        List<Complaint> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToComplaint(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO findByUserId Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Lists complaints with optional filtering by status and category (for Staff and Admin).
     */
    public List<Complaint> findAll(String statusFilter, Integer categoryFilter) {
        StringBuilder sql = new StringBuilder(
            "SELECT c.COMPLAINT_ID, c.USER_ID, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL, " +
            "       u.HOSTEL, u.ROOM_NO, c.CATEGORY_ID, cat.CATEGORY_NAME, " +
            "       c.DESCRIPTION, c.STATUS, c.CREATED_AT, c.RESOLVED_AT " +
            "FROM COMPLAINTS c " +
            "JOIN USERS u ON c.USER_ID = u.USER_ID " +
            "JOIN COMPLAINT_CATEGORIES cat ON c.CATEGORY_ID = cat.CATEGORY_ID WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND c.STATUS = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }
        if (categoryFilter != null && categoryFilter > 0) {
            sql.append("AND c.CATEGORY_ID = ? ");
            params.add(categoryFilter);
        }
        sql.append("ORDER BY c.CREATED_AT DESC");

        List<Complaint> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToComplaint(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Updates complaint lifecycle status.
     * If RESOLVED, sets RESOLVED_AT timestamp; otherwise clears it.
     */
    public boolean updateStatus(int complaintId, String newStatus) {
        String cleanStatus = newStatus.trim().toUpperCase();
        String sql;
        if ("RESOLVED".equals(cleanStatus)) {
            sql = "UPDATE COMPLAINTS SET STATUS = ?, RESOLVED_AT = CURRENT_TIMESTAMP WHERE COMPLAINT_ID = ?";
        } else {
            sql = "UPDATE COMPLAINTS SET STATUS = ?, RESOLVED_AT = NULL WHERE COMPLAINT_ID = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cleanStatus);
            ps.setInt(2, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO updateStatus Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Counts complaints with a given status across the system.
     */
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM COMPLAINTS WHERE STATUS = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO countByStatus Error] " + e.getMessage());
        }
        return 0;
    }

    /**
     * Counts complaints for a specific user with a given status.
     */
    public int countByUserAndStatus(int userId, String status) {
        String sql = "SELECT COUNT(*) FROM COMPLAINTS WHERE USER_ID = ? AND STATUS = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, status.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintDAO countByUserAndStatus Error] " + e.getMessage());
        }
        return 0;
    }

    private Complaint mapRowToComplaint(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setComplaintId(rs.getInt("COMPLAINT_ID"));
        c.setUserId(rs.getInt("USER_ID"));
        c.setUserName(rs.getString("USER_NAME"));
        c.setUserEmail(rs.getString("USER_EMAIL"));
        c.setHostel(rs.getString("HOSTEL"));
        c.setRoomNo(rs.getString("ROOM_NO"));
        c.setCategoryId(rs.getInt("CATEGORY_ID"));
        c.setCategoryName(rs.getString("CATEGORY_NAME"));
        c.setDescription(rs.getString("DESCRIPTION"));
        c.setStatus(rs.getString("STATUS"));
        c.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        c.setResolvedAt(rs.getTimestamp("RESOLVED_AT"));
        return c;
    }
}
