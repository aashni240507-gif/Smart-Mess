package com.smartmess.util;

import java.util.regex.Pattern;

/**
 * Utility class for server-side input validation and security sanitization.
 * Demonstrates:
 * - Email regex verification
 * - XSS prevention by HTML character escaping
 * - Safe numeric parsing
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    public static boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        if (isEmpty(email)) return false;
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidRating(int rating) {
        return rating >= 1 && rating <= 5;
    }

    public static boolean isValidRole(String role) {
        if (isEmpty(role)) return false;
        String r = role.trim().toUpperCase();
        return "STUDENT".equals(r) || "STAFF".equals(r) || "ADMIN".equals(r);
    }

    /**
     * Escapes critical HTML characters to prevent Cross-Site Scripting (XSS).
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }

    public static int parseInt(String val, int defaultValue) {
        if (isEmpty(val)) return defaultValue;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static double parseDouble(String val, double defaultValue) {
        if (isEmpty(val)) return defaultValue;
        try {
            return Double.parseDouble(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
