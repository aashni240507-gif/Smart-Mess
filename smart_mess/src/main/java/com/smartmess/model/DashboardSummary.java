package com.smartmess.model;

/**
 * Encapsulates operational metric totals retrieved from Oracle
 * for dynamic Student, Staff, and Administrator dashboards.
 */
public class DashboardSummary {
    private int totalStudents;
    private int totalStaff;
    private int totalMenus;
    private int expectedAttendance;
    private int presentAttendance;
    private int absentAttendance;
    private int pendingComplaints;
    private int inProgressComplaints;
    private int resolvedComplaints;
    private int totalComplaints;
    private double avgFoodQuality;
    private double avgTaste;
    private double avgCleanliness;
    private double overallRating;
    private double totalFoodPrepared;
    private double totalFoodServed;
    private double totalFoodWasted;
    private double wastagePercentage;

    public DashboardSummary() {}

    public int getTotalStudents() {
        return totalStudents;
    }

    public void setTotalStudents(int totalStudents) {
        this.totalStudents = totalStudents;
    }

    public int getTotalStaff() {
        return totalStaff;
    }

    public void setTotalStaff(int totalStaff) {
        this.totalStaff = totalStaff;
    }

    public int getTotalMenus() {
        return totalMenus;
    }

    public void setTotalMenus(int totalMenus) {
        this.totalMenus = totalMenus;
    }

    public int getExpectedAttendance() {
        return expectedAttendance;
    }

    public void setExpectedAttendance(int expectedAttendance) {
        this.expectedAttendance = expectedAttendance;
    }

    public int getPresentAttendance() {
        return presentAttendance;
    }

    public void setPresentAttendance(int presentAttendance) {
        this.presentAttendance = presentAttendance;
    }

    public int getAbsentAttendance() {
        return absentAttendance;
    }

    public void setAbsentAttendance(int absentAttendance) {
        this.absentAttendance = absentAttendance;
    }

    public int getPendingComplaints() {
        return pendingComplaints;
    }

    public void setPendingComplaints(int pendingComplaints) {
        this.pendingComplaints = pendingComplaints;
    }

    public int getInProgressComplaints() {
        return inProgressComplaints;
    }

    public void setInProgressComplaints(int inProgressComplaints) {
        this.inProgressComplaints = inProgressComplaints;
    }

    public int getResolvedComplaints() {
        return resolvedComplaints;
    }

    public void setResolvedComplaints(int resolvedComplaints) {
        this.resolvedComplaints = resolvedComplaints;
    }

    public int getTotalComplaints() {
        return totalComplaints;
    }

    public void setTotalComplaints(int totalComplaints) {
        this.totalComplaints = totalComplaints;
    }

    public double getAvgFoodQuality() {
        return avgFoodQuality;
    }

    public void setAvgFoodQuality(double avgFoodQuality) {
        this.avgFoodQuality = avgFoodQuality;
    }

    public double getAvgTaste() {
        return avgTaste;
    }

    public void setAvgTaste(double avgTaste) {
        this.avgTaste = avgTaste;
    }

    public double getAvgCleanliness() {
        return avgCleanliness;
    }

    public void setAvgCleanliness(double avgCleanliness) {
        this.avgCleanliness = avgCleanliness;
    }

    public double getOverallRating() {
        return overallRating;
    }

    public void setOverallRating(double overallRating) {
        this.overallRating = overallRating;
    }

    public double getTotalFoodPrepared() {
        return totalFoodPrepared;
    }

    public void setTotalFoodPrepared(double totalFoodPrepared) {
        this.totalFoodPrepared = totalFoodPrepared;
    }

    public double getTotalFoodServed() {
        return totalFoodServed;
    }

    public void setTotalFoodServed(double totalFoodServed) {
        this.totalFoodServed = totalFoodServed;
    }

    public double getTotalFoodWasted() {
        return totalFoodWasted;
    }

    public void setTotalFoodWasted(double totalFoodWasted) {
        this.totalFoodWasted = totalFoodWasted;
    }

    public double getWastagePercentage() {
        return wastagePercentage;
    }

    public void setWastagePercentage(double wastagePercentage) {
        this.wastagePercentage = wastagePercentage;
    }
}
