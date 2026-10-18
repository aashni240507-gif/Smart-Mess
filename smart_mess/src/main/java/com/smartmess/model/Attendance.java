package com.smartmess.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model representing a student's attendance record for a menu.
 */
public class Attendance {
    private int attendanceId;
    private int userId;
    private String userName;   // Joined from USERS
    private int menuId;
    private Date menuDate;     // Joined from MENU
    private String mealName;   // Joined from MEAL_TYPES
    private String status;     // PRESENT or ABSENT
    private Timestamp markedAt;

    public Attendance() {}

    public Attendance(int attendanceId, int userId, String userName, int menuId, Date menuDate, String mealName, String status, Timestamp markedAt) {
        this.attendanceId = attendanceId;
        this.userId = userId;
        this.userName = userName;
        this.menuId = menuId;
        this.menuDate = menuDate;
        this.mealName = mealName;
        this.status = status;
        this.markedAt = markedAt;
    }

    public int getAttendanceId() {
        return attendanceId;
    }

    public void setAttendanceId(int attendanceId) {
        this.attendanceId = attendanceId;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getMarkedAt() {
        return markedAt;
    }

    public void setMarkedAt(Timestamp markedAt) {
        this.markedAt = markedAt;
    }
}
