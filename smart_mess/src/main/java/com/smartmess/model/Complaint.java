package com.smartmess.model;

import java.sql.Timestamp;

/**
 * Model representing student complaints and their lifecycle status.
 * Status values: PENDING, IN_PROGRESS, RESOLVED.
 */
public class Complaint {
    private int complaintId;
    private int userId;
    private String userName;         // Joined from USERS
    private String userEmail;        // Joined from USERS
    private String hostel;           // Joined from USERS
    private String roomNo;           // Joined from USERS
    private int categoryId;
    private String categoryName;     // Joined from COMPLAINT_CATEGORIES
    private String description;
    private String status;
    private Timestamp createdAt;
    private Timestamp resolvedAt;

    public Complaint() {}

    public Complaint(int complaintId, int userId, String userName, String userEmail, String hostel, String roomNo, int categoryId, String categoryName, String description, String status, Timestamp createdAt, Timestamp resolvedAt) {
        this.complaintId = complaintId;
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.hostel = hostel;
        this.roomNo = roomNo;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.resolvedAt = resolvedAt;
    }

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
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

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getHostel() {
        return hostel;
    }

    public void setHostel(String hostel) {
        this.hostel = hostel;
    }

    public String getRoomNo() {
        return roomNo;
    }

    public void setRoomNo(String roomNo) {
        this.roomNo = roomNo;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(status);
    }

    public boolean isInProgress() {
        return "IN_PROGRESS".equalsIgnoreCase(status);
    }

    public boolean isResolved() {
        return "RESOLVED".equalsIgnoreCase(status);
    }
}
