package com.smartmess.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Reusable database connection utility for Oracle Database.
 * Demonstrates JDBC best practices:
 * - Credentials externalized to properties file
 * - Explicit driver loading
 * - Connection factory method
 * - Safe resource cleanup
 */
public class DBConnection {

    private static String jdbcUrl;
    private static String dbUser;
    private static String dbPassword;
    private static String dbDriver;
    private static boolean initialized = false;

    static {
        loadConfiguration();
    }

    private static synchronized void loadConfiguration() {
        if (initialized) {
            return;
        }

        Properties props = new Properties();
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
                jdbcUrl = props.getProperty("db.url", "jdbc:oracle:thin:@//localhost:1521/XEPDB1");
                dbUser = props.getProperty("db.username", "smartmess");
                dbPassword = props.getProperty("db.password", "smartmess123");
                dbDriver = props.getProperty("db.driver", "oracle.jdbc.OracleDriver");
            } else {
                // Fallback to system environment variables or standard defaults
                jdbcUrl = System.getenv().getOrDefault("SMARTMESS_DB_URL", "jdbc:oracle:thin:@//localhost:1521/XEPDB1");
                dbUser = System.getenv().getOrDefault("SMARTMESS_DB_USER", "smartmess");
                dbPassword = System.getenv().getOrDefault("SMARTMESS_DB_PASSWORD", "smartmess123");
                dbDriver = "oracle.jdbc.OracleDriver";
            }

            Class.forName(dbDriver);
            initialized = true;
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection ERROR] Oracle JDBC Driver class not found: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("[DBConnection ERROR] Failed to load db.properties: " + e.getMessage());
        }
    }

    /**
     * Obtains a fresh connection to the Oracle Database.
     *
     * @return active java.sql.Connection
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        if (!initialized) {
            loadConfiguration();
        }
        return DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
    }

    /**
     * Tests whether the database connection is active and healthy.
     *
     * @return true if connection can be opened and validated, false otherwise
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[DBConnection Test Failed] " + e.getMessage());
            return false;
        }
    }

    /**
     * Safely closes one or more database resources without throwing exceptions.
     */
    public static void closeQuietly(AutoCloseable... resources) {
        if (resources == null) return;
        for (AutoCloseable r : resources) {
            if (r != null) {
                try {
                    r.close();
                } catch (Exception ignored) {
                }
            }
        }
    }

    /**
     * Main method to test connectivity directly from command line.
     */
    public static void main(String[] args) {
        System.out.println("Testing Oracle DB Connection...");
        boolean ok = testConnection();
        if (ok) {
            System.out.println("SUCCESS: Connected to Oracle Database (" + jdbcUrl + ") as " + dbUser);
        } else {
            System.err.println("FAILURE: Could not connect to Oracle Database.");
        }
    }
}
