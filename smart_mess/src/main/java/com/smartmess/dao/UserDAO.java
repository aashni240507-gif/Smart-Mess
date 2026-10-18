package com.smartmess.dao;

import com.smartmess.model.User;
import com.smartmess.util.DBConnection;
import com.smartmess.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for USERS table in Oracle.
 * Handles student registration, credential validation, and admin user management.
 */
public class UserDAO {

    /**
     * Authenticates a user by email and plain password.
     * Compares plain password with BCrypt hash stored in Oracle.
     */
    public User authenticate(String email, String plainPassword) {
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO, CREATED_AT " +
                     "FROM USERS WHERE LOWER(EMAIL) = LOWER(?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("PASSWORD_HASH");
                    if (PasswordUtil.checkPassword(plainPassword, storedHash)) {
                        return mapRowToUser(rs);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO authenticate Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Finds a user by their unique email.
     */
    public User findByEmail(String email) {
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO, CREATED_AT " +
                     "FROM USERS WHERE LOWER(EMAIL) = LOWER(?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO findByEmail Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Finds a user by their primary key USER_ID.
     */
    public User findById(int userId) {
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO, CREATED_AT " +
                     "FROM USERS WHERE USER_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO findById Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Creates a new user record in Oracle.
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName().trim());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getRole().trim().toUpperCase());
            ps.setString(5, user.getHostel() != null ? user.getHostel().trim() : null);
            ps.setString(6, user.getRoomNo() != null ? user.getRoomNo().trim() : null);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO createUser Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Checks if an email is already registered.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM USERS WHERE LOWER(EMAIL) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO emailExists Error] " + e.getMessage());
        }
        return false;
    }

    /**
     * Lists all users in the system, sorted by role and name.
     */
    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO, CREATED_AT " +
                     "FROM USERS ORDER BY ROLE ASC, NAME ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToUser(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Updates an existing user's role (Admin action).
     */
    public boolean updateRole(int userId, String newRole) {
        String sql = "UPDATE USERS SET ROLE = ? WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newRole.trim().toUpperCase());
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO updateRole Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Counts users with a given role (STUDENT, STAFF, ADMIN).
     */
    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM USERS WHERE ROLE = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, role.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO countByRole Error] " + e.getMessage());
        }
        return 0;
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("USER_ID"));
        u.setName(rs.getString("NAME"));
        u.setEmail(rs.getString("EMAIL"));
        u.setPasswordHash(rs.getString("PASSWORD_HASH"));
        u.setRole(rs.getString("ROLE"));
        u.setHostel(rs.getString("HOSTEL"));
        u.setRoomNo(rs.getString("ROOM_NO"));
        u.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        return u;
    }
}
