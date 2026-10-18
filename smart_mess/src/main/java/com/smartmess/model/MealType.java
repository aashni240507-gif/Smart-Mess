package com.smartmess.model;

/**
 * Model representing a meal type (Breakfast, Lunch, Dinner).
 */
public class MealType {
    private int mealTypeId;
    private String mealName;

    public MealType() {}

    public MealType(int mealTypeId, String mealName) {
        this.mealTypeId = mealTypeId;
        this.mealName = mealName;
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
}
