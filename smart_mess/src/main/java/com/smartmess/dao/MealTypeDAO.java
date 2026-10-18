package com.smartmess.dao;

import com.smartmess.model.MealType;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for MEAL_TYPES lookup table in Oracle.
 */
public class MealTypeDAO {

    public List<MealType> findAll() {
        List<MealType> list = new ArrayList<>();
        String sql = "SELECT MEAL_TYPE_ID, MEAL_NAME FROM MEAL_TYPES ORDER BY MEAL_TYPE_ID ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new MealType(rs.getInt("MEAL_TYPE_ID"), rs.getString("MEAL_NAME")));
            }
        } catch (SQLException e) {
            System.err.println("[MealTypeDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    public MealType findById(int id) {
        String sql = "SELECT MEAL_TYPE_ID, MEAL_NAME FROM MEAL_TYPES WHERE MEAL_TYPE_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new MealType(rs.getInt("MEAL_TYPE_ID"), rs.getString("MEAL_NAME"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[MealTypeDAO findById Error] " + e.getMessage());
        }
        return null;
    }
}
