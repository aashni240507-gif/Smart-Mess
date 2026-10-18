package com.smartmess.dao;

import com.smartmess.model.Attendance;
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
 * Data Access Object for ATTENDANCE table in Oracle.
 * Handles meal attendance registration, student attendance history,
 * and duplicate attendance prevention via Oracle MERGE.
 */
public class AttendanceDAO {

    /**
     * Records or updates student attendance atomically using Oracle MERGE statement.
     * Prevents duplicate rows while allowing students to switch status (PRESENT/ABSENT).
     */
    public boolean markAttendance(int userId, int menuId, String status) {
        String sql = "MERGE INTO ATTENDANCE a " +
                     "USING (SELECT ? AS u_id, ? AS m_id FROM dual) src " +
                     "ON (a.USER_ID = src.u_id AND a.MENU_ID = src.m_id) " +
                     "WHEN MATCHED THEN " +
                     "    UPDATE SET a.STATUS = ?, a.MARKED_AT = CURRENT_TIMESTAMP " +
                     "WHEN NOT MATCHED THEN " +
                     "    INSERT (USER_ID, MENU_ID, STATUS, MARKED_AT) " +
                     "    VALUES (?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            ps.setString(3, status.trim().toUpperCase());
            ps.setInt(4, userId);
            ps.setInt(5, menuId);
            ps.setString(6, status.trim().toUpperCase());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO markAttendance Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Looks up attendance for a given user and menu.
     */
    public Attendance findByUserAndMenu(int userId, int menuId) {
        String sql = "SELECT a.ATTENDANCE_ID, a.USER_ID, u.NAME AS USER_NAME, " +
                     "       a.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, a.STATUS, a.MARKED_AT " +
                     "FROM ATTENDANCE a " +
                     "JOIN USERS u ON a.USER_ID = u.USER_ID " +
                     "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE a.USER_ID = ? AND a.MENU_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToAttendance(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO findByUserAndMenu Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns a student's personal attendance history.
     */
    public List<Attendance> findHistoryByUser(int userId, int limit) {
        String sql = "SELECT a.ATTENDANCE_ID, a.USER_ID, u.NAME AS USER_NAME, " +
                     "       a.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, a.STATUS, a.MARKED_AT " +
                     "FROM ATTENDANCE a " +
                     "JOIN USERS u ON a.USER_ID = u.USER_ID " +
                     "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE a.USER_ID = ? " +
                     "ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC " +
                     "FETCH FIRST ? ROWS ONLY";

        List<Attendance> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToAttendance(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO findHistoryByUser Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Fetches attendance status map (menuId -> status) for a student for today's menus.
     */
    public Map<Integer, String> getTodayAttendanceMap(int userId) {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT a.MENU_ID, a.STATUS " +
                     "FROM ATTENDANCE a " +
                     "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                     "WHERE a.USER_ID = ? AND TRUNC(m.MENU_DATE) = TRUNC(SYSDATE)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("MENU_ID"), rs.getString("STATUS"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO getTodayAttendanceMap Error] " + e.getMessage());
        }
        return map;
    }

    /**
     * Counts student attendance marked PRESENT for today.
     */
    public int countTodayPresent() {
        String sql = "SELECT COUNT(*) FROM ATTENDANCE a " +
                     "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                     "WHERE a.STATUS = 'PRESENT' AND TRUNC(m.MENU_DATE) = TRUNC(SYSDATE)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO countTodayPresent Error] " + e.getMessage());
        }
        return 0;
    }

    /**
     * Counts total attendance records marked across today's meals.
     */
    public int countTodayTotal() {
        String sql = "SELECT COUNT(*) FROM ATTENDANCE a " +
                     "JOIN MENU m ON a.MENU_ID = m.MENU_ID " +
                     "WHERE TRUNC(m.MENU_DATE) = TRUNC(SYSDATE)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO countTodayTotal Error] " + e.getMessage());
        }
        return 0;
    }

    private Attendance mapRowToAttendance(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setAttendanceId(rs.getInt("ATTENDANCE_ID"));
        a.setUserId(rs.getInt("USER_ID"));
        a.setUserName(rs.getString("USER_NAME"));
        a.setMenuId(rs.getInt("MENU_ID"));
        a.setMenuDate(rs.getDate("MENU_DATE"));
        a.setMealName(rs.getString("MEAL_NAME"));
        a.setStatus(rs.getString("STATUS"));
        a.setMarkedAt(rs.getTimestamp("MARKED_AT"));
        return a;
    }
}
