package com.smartmess.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model representing daily food preparation and wastage metrics in kilograms.
 */
public class Wastage {
    private int wastageId;
    private int menuId;
    private Date menuDate;          // Joined from MENU
    private String mealName;        // Joined from MEAL_TYPES
    private double foodPrepared;    // In KG
    private double foodServed;      // In KG
    private double foodWasted;      // In KG
    private double wastagePercentage;
    private int recordedBy;
    private String recordedByName;  // Joined from USERS
    private Timestamp recordedAt;

    public Wastage() {}

    public Wastage(int wastageId, int menuId, Date menuDate, String mealName, double foodPrepared, double foodServed, double foodWasted, double wastagePercentage, int recordedBy, String recordedByName, Timestamp recordedAt) {
        this.wastageId = wastageId;
        this.menuId = menuId;
        this.menuDate = menuDate;
        this.mealName = mealName;
        this.foodPrepared = foodPrepared;
        this.foodServed = foodServed;
        this.foodWasted = foodWasted;
        this.wastagePercentage = wastagePercentage;
        this.recordedBy = recordedBy;
        this.recordedByName = recordedByName;
        this.recordedAt = recordedAt;
    }

    public int getWastageId() {
        return wastageId;
    }

    public void setWastageId(int wastageId) {
        this.wastageId = wastageId;
    }

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public Date getMenuDate() {
        return menuDate;
    }

    public void setMenuDate(Date menuDate) {
        this.menuDate = menuDate;
    }

    public String getMealName() {
        return mealName;
    }

    public void setMealName(String mealName) {
        this.mealName = mealName;
    }

    public double getFoodPrepared() {
        return foodPrepared;
    }

    public void setFoodPrepared(double foodPrepared) {
        this.foodPrepared = foodPrepared;
    }

    public double getFoodServed() {
        return foodServed;
    }

    public void setFoodServed(double foodServed) {
        this.foodServed = foodServed;
    }

    public double getFoodWasted() {
        return foodWasted;
    }

    public void setFoodWasted(double foodWasted) {
        this.foodWasted = foodWasted;
    }

    public double getWastagePercentage() {
        if (wastagePercentage > 0) return wastagePercentage;
        if (foodPrepared > 0) {
            return Math.round((foodWasted / foodPrepared) * 10000.0) / 100.0;
        }
        return 0.0;
    }

    public void setWastagePercentage(double wastagePercentage) {
        this.wastagePercentage = wastagePercentage;
    }

    public int getRecordedBy() {
        return recordedBy;
    }

    public void setRecordedBy(int recordedBy) {
        this.recordedBy = recordedBy;
    }

    public String getRecordedByName() {
        return recordedByName;
    }

    public void setRecordedByName(String recordedByName) {
        this.recordedByName = recordedByName;
    }

    public Timestamp getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(Timestamp recordedAt) {
        this.recordedAt = recordedAt;
    }
}
