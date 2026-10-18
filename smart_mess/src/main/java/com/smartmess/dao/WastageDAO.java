package com.smartmess.dao;

import com.smartmess.model.Wastage;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for WASTAGE table in Oracle.
 * Handles recording food preparation, serving, and waste quantities in kilograms.
 */
public class WastageDAO {

    /**
     * Records or updates food wastage metrics for a meal menu using Oracle MERGE statement.
     */
    public boolean recordWastage(Wastage w) {
        String sql = "MERGE INTO WASTAGE dst " +
                     "USING (SELECT ? AS m_id FROM dual) src " +
                     "ON (dst.MENU_ID = src.m_id) " +
                     "WHEN MATCHED THEN " +
                     "    UPDATE SET dst.FOOD_PREPARED = ?, dst.FOOD_SERVED = ?, dst.FOOD_WASTED = ?, " +
                     "               dst.RECORDED_BY = ?, dst.RECORDED_AT = CURRENT_TIMESTAMP " +
                     "WHEN NOT MATCHED THEN " +
                     "    INSERT (MENU_ID, FOOD_PREPARED, FOOD_SERVED, FOOD_WASTED, RECORDED_BY, RECORDED_AT) " +
                     "    VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // For MATCHED update
            ps.setInt(1, w.getMenuId());
            ps.setDouble(2, w.getFoodPrepared());
            ps.setDouble(3, w.getFoodServed());
            ps.setDouble(4, w.getFoodWasted());
            ps.setInt(5, w.getRecordedBy());

            // For NOT MATCHED insert
            ps.setInt(6, w.getMenuId());
            ps.setDouble(7, w.getFoodPrepared());
            ps.setDouble(8, w.getFoodServed());
            ps.setDouble(9, w.getFoodWasted());
            ps.setInt(10, w.getRecordedBy());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[WastageDAO recordWastage Error] " + e.getMessage());
            return false;
        }
    }

    /**
     * Finds wastage entry by menu ID.
     */
    public Wastage findByMenuId(int menuId) {
        String sql = "SELECT w.WASTAGE_ID, w.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, " +
                     "       w.FOOD_PREPARED, w.FOOD_SERVED, w.FOOD_WASTED, " +
                     "       w.RECORDED_BY, u.NAME AS RECORDED_BY_NAME, w.RECORDED_AT " +
                     "FROM WASTAGE w " +
                     "JOIN MENU m ON w.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "JOIN USERS u ON w.RECORDED_BY = u.USER_ID " +
                     "WHERE w.MENU_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, menuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToWastage(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[WastageDAO findByMenuId Error] " + e.getMessage());
        }
        return null;
    }

    /**
     * Lists recent wastage records.
     */
    public List<Wastage> findAll(int limit) {
        String sql = "SELECT w.WASTAGE_ID, w.MENU_ID, m.MENU_DATE, mt.MEAL_NAME, " +
                     "       w.FOOD_PREPARED, w.FOOD_SERVED, w.FOOD_WASTED, " +
                     "       w.RECORDED_BY, u.NAME AS RECORDED_BY_NAME, w.RECORDED_AT " +
                     "FROM WASTAGE w " +
                     "JOIN MENU m ON w.MENU_ID = m.MENU_ID " +
                     "JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID " +
                     "JOIN USERS u ON w.RECORDED_BY = u.USER_ID " +
                     "ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC " +
                     "FETCH FIRST ? ROWS ONLY";

        List<Wastage> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToWastage(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[WastageDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    /**
     * Calculates overall food totals: [totalPrepared, totalServed, totalWasted, wastagePercentage].
     */
    public double[] getTotals() {
        String sql = "SELECT NVL(SUM(FOOD_PREPARED), 0) AS TOTAL_PREP, " +
                     "       NVL(SUM(FOOD_SERVED), 0) AS TOTAL_SERV, " +
                     "       NVL(SUM(FOOD_WASTED), 0) AS TOTAL_WAST " +
                     "FROM WASTAGE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                double prep = rs.getDouble("TOTAL_PREP");
                double serv = rs.getDouble("TOTAL_SERV");
                double wast = rs.getDouble("TOTAL_WAST");
                double pct = prep > 0 ? Math.round((wast / prep) * 10000.0) / 100.0 : 0.0;
                return new double[] { prep, serv, wast, pct };
            }
        } catch (SQLException e) {
            System.err.println("[WastageDAO getTotals Error] " + e.getMessage());
        }
        return new double[] { 0.0, 0.0, 0.0, 0.0 };
    }

    private Wastage mapRowToWastage(ResultSet rs) throws SQLException {
        Wastage w = new Wastage();
        w.setWastageId(rs.getInt("WASTAGE_ID"));
        w.setMenuId(rs.getInt("MENU_ID"));
        w.setMenuDate(rs.getDate("MENU_DATE"));
        w.setMealName(rs.getString("MEAL_NAME"));
        w.setFoodPrepared(rs.getDouble("FOOD_PREPARED"));
        w.setFoodServed(rs.getDouble("FOOD_SERVED"));
        w.setFoodWasted(rs.getDouble("FOOD_WASTED"));
        w.setRecordedBy(rs.getInt("RECORDED_BY"));
        w.setRecordedByName(rs.getString("RECORDED_BY_NAME"));
        w.setRecordedAt(rs.getTimestamp("RECORDED_AT"));
        return w;
    }
}
