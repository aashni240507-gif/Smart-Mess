package com.smartmess.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model representing student feedback for a meal menu.
 * Ratings range from 1 to 5.
 */
public class Feedback {
    private int feedbackId;
    private int userId;
    private String userName;   // Joined from USERS
    private int menuId;
    private Date menuDate;     // Joined from MENU
    private String mealName;   // Joined from MEAL_TYPES
    private int foodQuality;   // 1 to 5
    private int taste;         // 1 to 5
    private int cleanliness;   // 1 to 5
    private String comments;
    private Timestamp createdAt;

    public Feedback() {}

    public Feedback(int feedbackId, int userId, String userName, int menuId, Date menuDate, String mealName, int foodQuality, int taste, int cleanliness, String comments, Timestamp createdAt) {
        this.feedbackId = feedbackId;
        this.userId = userId;
        this.userName = userName;
        this.menuId = menuId;
        this.menuDate = menuDate;
        this.mealName = mealName;
        this.foodQuality = foodQuality;
        this.taste = taste;
        this.cleanliness = cleanliness;
        this.comments = comments;
        this.createdAt = createdAt;
    }

    public int getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
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

    public int getFoodQuality() {
        return foodQuality;
    }

    public void setFoodQuality(int foodQuality) {
        this.foodQuality = foodQuality;
    }

    public int getTaste() {
        return taste;
    }

    public void setTaste(int taste) {
        this.taste = taste;
    }

    public int getCleanliness() {
        return cleanliness;
    }

    public void setCleanliness(int cleanliness) {
        this.cleanliness = cleanliness;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public double getAverageScore() {
        return Math.round(((foodQuality + taste + cleanliness) / 3.0) * 100.0) / 100.0;
    }
}
