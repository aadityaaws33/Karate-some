package KarateLearningLunch.utils;

import java.sql.*;

public class DbUtils {
    String dbName = "ilextest";
    String userName = "ilextestuser";
    String password = "[$LUISYL6&ZZVaQ&";
    String hostname = "ilex-test-db.cx1qnvkee43t.ap-southeast-1.rds.amazonaws.com";
    String port = "5432";

    public String DeleteDataTestDB() throws Throwable {

        System.out.println("*************Hostname******" + hostname);
        System.out.println("*************Post******" + port);
        System.out.println("*************Databasename******" + dbName);
        String jdbcUrl = "jdbc:postgresql://" + hostname + ":" + port + "/" + dbName;
        try {
            System.out.println("Loading driver...");
            Class.forName("org.postgresql.Driver");
            System.out.println("Driver loaded!");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Cannot find the driver in the classpath!", e);
        }

        Connection conn = null;
        Statement readStatement1 = null;
        try {
            // conn = DriverManager.getConnection(jdbcUrl);
            conn = DriverManager.getConnection(jdbcUrl, userName, password);

            readStatement1 = conn.createStatement();
            readStatement1.executeUpdate("TRUNCATE table negotiation CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table primary_negotiation CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table invitation CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table buy_interest CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table sell_order CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table \"order\" CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table tranche CASCADE;");
            readStatement1.executeUpdate("TRUNCATE table listing CASCADE;");
            conn.commit();
            conn.close();

        } catch (SQLException ex) {
            // Handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        } finally {
            System.out.println("Closing the connection.");
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException ignore) {
                }
        }
        return "DB Cleared";
    }


    public int GetTableCount() throws Throwable {

        System.out.println("*************Hostname******" + hostname);
        System.out.println("*************Post******" + port);
        System.out.println("*************Databasename******" + dbName);
        String jdbcUrl = "jdbc:postgresql://" + hostname + ":" + port + "/" + dbName;
        try {
            System.out.println("Loading driver...");
            Class.forName("org.postgresql.Driver");
            System.out.println("Driver loaded!");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Cannot find the driver in the classpath!", e);
        }

        Connection conn = null;
        Statement readStatement1 = null;
        ResultSet rs = null;
        int count = 0;
        try {
            // conn = DriverManager.getConnection(jdbcUrl);
            conn = DriverManager.getConnection(jdbcUrl, userName, password);
            readStatement1 = conn.createStatement();
            rs =  readStatement1.executeQuery("select count(*) from buy_interest;");
            rs.next();
            count = rs.getInt(1);
            conn.commit();
            conn.close();
        } catch (SQLException ex) {
            // Handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        } finally {
            System.out.println("Closing the connection.");
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException ignore) {
                }
        }
        return count;
    }
}
