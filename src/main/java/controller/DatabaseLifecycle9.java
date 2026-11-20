package controller;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import java.sql.*;
import java.util.Enumeration;
import javax.servlet.*;
import javax.servlet.annotation.WebListener;

/** Release only this webapp's JDBC driver and cleanup thread when Tomcat redeploys it. */
@WebListener
public class DatabaseLifecycle9 implements ServletContextListener {
    @Override
    public void contextDestroyed(ServletContextEvent event) {
        AbandonedConnectionCleanupThread.checkedShutdown();
        ClassLoader loader = getClass().getClassLoader();
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() == loader) {
                try {
                    DriverManager.deregisterDriver(driver);
                } catch (SQLException ex) {
                    event.getServletContext()
                            .log("Cannot release webapp JDBC driver (SQL state " + ex.getSQLState() + ")");
                }
            }
        }
    }
}
