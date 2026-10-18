package com.smartmess.dao;

import com.smartmess.model.ComplaintCategory;
import com.smartmess.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for COMPLAINT_CATEGORIES in Oracle.
 */
public class ComplaintCategoryDAO {

    public List<ComplaintCategory> findAll() {
        List<ComplaintCategory> list = new ArrayList<>();
        String sql = "SELECT CATEGORY_ID, CATEGORY_NAME FROM COMPLAINT_CATEGORIES ORDER BY CATEGORY_ID ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new ComplaintCategory(rs.getInt("CATEGORY_ID"), rs.getString("CATEGORY_NAME")));
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintCategoryDAO findAll Error] " + e.getMessage());
        }
        return list;
    }

    public ComplaintCategory findById(int id) {
        String sql = "SELECT CATEGORY_ID, CATEGORY_NAME FROM COMPLAINT_CATEGORIES WHERE CATEGORY_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ComplaintCategory(rs.getInt("CATEGORY_ID"), rs.getString("CATEGORY_NAME"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ComplaintCategoryDAO findById Error] " + e.getMessage());
        }
        return null;
    }
}
