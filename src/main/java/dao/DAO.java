package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.io.IOException;
import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import java.time.LocalDate;

/** Base DAO: one connection per database operation. */
public class DAO {
    public DAO() {
    }

    protected Connection getConnection() throws SQLException {
        // Connector/J is packaged in this web application's WEB-INF/lib.
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("MySQL JDBC driver is unavailable", ex);
        }
        Properties config = new Properties();
        String file = System.getProperty("restman.db.config", System.getenv("RESTMAN_DB_CONFIG"));
        if (file != null && !file.isBlank()) {
            try (Reader reader = Files.newBufferedReader(Path.of(file))) {
                config.load(reader);
            } catch (IOException ex) {
                throw new SQLException("Cannot read local database configuration", ex);
            }
        }
        String url = setting("RESTMAN_DB_URL", config, "url", "jdbc:mysql://localhost:3306/restman");
        String username = setting("RESTMAN_DB_USER", config, "username", "root");
        String password = setting("RESTMAN_DB_PASSWORD", config, "password", null);
        if (password == null)
            throw new SQLException("Database credentials are not configured");
        return DriverManager.getConnection(url, username, password);
    }

    private String setting(String env, Properties config, String key, String fallback) {
        String value = System.getenv(env);
        return value == null ? config.getProperty(key, fallback) : value;
    }

    public static void validateDateRange(LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException(
                    "Vui lòng chọn đầy đủ cả ngày bắt đầu và ngày kết thúc thống kê.");
        }
        if (startDate.getYear() < 1000 || endDate.getYear() >= 9999 || startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("Khoảng thời gian không hợp lệ.");
        }
        if (endDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Thời gian thống kê không được vượt quá ngày hiện tại.");
        }
    }
}
