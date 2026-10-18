package com.smartmess.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility class for hashing and verifying passwords using BCrypt.
 * Second-year DBMS / Java concept: Never store plain text passwords in databases.
 */
public class PasswordUtil {

    /**
     * Hashes a plain text password with a secure salt.
     *
     * @param plainPassword the plain text password
     * @return the BCrypt hash string
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));
    }

    /**
     * Checks if a plain text password matches a stored BCrypt hash.
     *
     * @param plainPassword  the raw password entered by the user
     * @param hashedPassword the BCrypt hash from Oracle USERS table
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * Helper main method to generate known hashes for SQL seeding.
     */
    public static void main(String[] args) {
        String adminHash = hashPassword("admin123");
        String staffHash = hashPassword("staff123");
        String studentHash = hashPassword("student123");

        System.out.println("admin123: " + adminHash);
        System.out.println("staff123: " + staffHash);
        System.out.println("student123: " + studentHash);
    }
}
