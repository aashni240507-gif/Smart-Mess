package com.smartmess.dao;

import com.smartmess.model.Menu;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for MENU table in Oracle.
 * Handles menu CRUD, date-based schedule lookups, and duplicate checking.
 */
public class MenuDAO {

    /**
     * Retrieves today's breakfast, lunch, and dinner menus.
     */
    public List<Menu> findTodayMenus() {
        String sql = "SELECT m.MENU_ID, m.MENU_DATE, m.MEAL_TYPE_ID, mt.MEAL_NAME, m.FOOD_ITEMS, m.NOTES " +
                     "FROM MENU m " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE TRUNC(m.MENU_DATE) = TRUNC(SYSDATE) " +
                     "ORDER BY m.MEAL_TYPE_ID ASC";

        return executeQueryList(sql);
    }

    /**
     * Retrieves menus for a specific date.
     */
    public List<Menu> findByDate(Date date) {
        String sql = "SELECT m.MENU_ID, m.MENU_DATE, m.MEAL_TYPE_ID, mt.MEAL_NAME, m.FOOD_ITEMS, m.NOTES " +
                     "FROM MENU m " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE TRUNC(m.MENU_DATE) = TRUNC(?) " +
                     "ORDER BY m.MEAL_TYPE_ID ASC";

        List<Menu> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToMenu(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO findByDate Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Retrieves a single menu by its primary key MENU_ID.
     */
    public Menu findById(int menuId) {
        String sql = "SELECT m.MENU_ID, m.MENU_DATE, m.MEAL_TYPE_ID, mt.MEAL_NAME, m.FOOD_ITEMS, m.NOTES " +
                     "FROM MENU m " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "WHERE m.MENU_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, menuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToMenu(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO findById Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Checks if a menu already exists for a specific date and meal type.
     */
    public boolean existsByDateAndMealType(Date date, int mealTypeId) {
        String sql = "SELECT COUNT(*) FROM MENU WHERE TRUNC(MENU_DATE) = TRUNC(?) AND MEAL_TYPE_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, date);
            ps.setInt(2, mealTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO existsByDateAndMealType Error] " + e.getMessage());
        }
        return false;
    }

    /**
     * Inserts a new menu entry into Oracle.
     */
    public boolean createMenu(Menu menu) {
        String sql = "INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, menu.getMenuDate());
            ps.setInt(2, menu.getMealTypeId());
            ps.setString(3, menu.getFoodItems().trim());
            ps.setString(4, menu.getNotes() != null ? menu.getNotes().trim() : null);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MenuDAO createMenu Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Updates an existing menu's food items and notes.
     */
    public boolean updateMenu(Menu menu) {
        String sql = "UPDATE MENU SET FOOD_ITEMS = ?, NOTES = ? WHERE MENU_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, menu.getFoodItems().trim());
            ps.setString(2, menu.getNotes() != null ? menu.getNotes().trim() : null);
            ps.setInt(3, menu.getMenuId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MenuDAO updateMenu Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Deletes a menu by ID.
     */
    public boolean deleteMenu(int menuId) {
        String sql = "DELETE FROM MENU WHERE MENU_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, menuId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MenuDAO deleteMenu Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Retrieves recent menus with limit.
     */
    public List<Menu> findAll(int limit) {
        String sql = "SELECT m.MENU_ID, m.MENU_DATE, m.MEAL_TYPE_ID, mt.MEAL_NAME, m.FOOD_ITEMS, m.NOTES " +
                     "FROM MENU m " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "ORDER BY m.MENU_DATE DESC, m.MEAL_TYPE_ID ASC " +
                     "FETCH FIRST ? ROWS ONLY";

        List<Menu> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToMenu(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM MENU";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO countAll Error] " + e.getMessage());
        }
        return 0;
    }

    private List<Menu> executeQueryList(String sql) {
        List<Menu> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToMenu(rs));
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAO query Error] " + e.getMessage());
        }
        return list;
    }

    private Menu mapRowToMenu(ResultSet rs) throws SQLException {
        Menu m = new Menu();
        m.setMenuId(rs.getInt("MENU_ID"));
        m.setMenuDate(rs.getDate("MENU_DATE"));
        m.setMealTypeId(rs.getInt("MEAL_TYPE_ID"));
        m.setMealName(rs.getString("MEAL_NAME"));
        m.setFoodItems(rs.getString("FOOD_ITEMS"));
        m.setNotes(rs.getString("NOTES"));
        return m;
    }
}
