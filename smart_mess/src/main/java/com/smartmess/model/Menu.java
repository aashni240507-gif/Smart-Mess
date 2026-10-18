package com.smartmess.model;

import java.sql.Date;

/**
 * Model representing a daily meal menu schedule.
 */
public class Menu {
    private int menuId;
    private Date menuDate;
    private int mealTypeId;
    private String mealName; // Joined from MEAL_TYPES
    private String foodItems;
    private String notes;

    public Menu() {}

    public Menu(int menuId, Date menuDate, int mealTypeId, String mealName, String foodItems, String notes) {
        this.menuId = menuId;
        this.menuDate = menuDate;
        this.mealTypeId = mealTypeId;
        this.mealName = mealName;
        this.foodItems = foodItems;
        this.notes = notes;
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

    public int getMealTypeId() {
        return mealTypeId;
    }

    public void setMealTypeId(int mealTypeId) {
        this.mealTypeId = mealTypeId;
    }

    public String getMealName() {
        return mealName;
    }

    public void setMealName(String mealName) {
        this.mealName = mealName;
    }

    public String getFoodItems() {
        return foodItems;
    }

    public void setFoodItems(String foodItems) {
        this.foodItems = foodItems;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
