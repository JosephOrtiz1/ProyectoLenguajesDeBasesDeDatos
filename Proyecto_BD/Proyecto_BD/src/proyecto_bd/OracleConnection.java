/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package proyecto_bd;
import java.sql.Connection;
import java.sql.DriverManager; 
import java.sql.SQLException;  

/**
 *
 * @author JOSEFU
 */
public class OracleConnection {
    private Connection conn = null;
    private String url, user, pass;
    
    public OracleConnection() { 
        conectar();
    }
    
     public static Connection conectar() {
        try {
            Class.forName("oracle.jdbc.OracleDriver");  // Cargar el driver
            String url = "jdbc:oracle:thin:@192.168.56.105:1521:orcl";
            String user = "AdminProyecto";
            String pass = "12345678";
            Connection conn = DriverManager.getConnection(url, user, pass);
            System.out.println("Conectado!");
            return conn;
        } catch (Exception e) {
            System.out.println("Error al conectar: " + e.getMessage());
            return null;  
        }
    }
    
    public void desconectar() {
         try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                System.out.println("Desconectado!");
            }
        } catch (SQLException e) {
            System.out.println("Error, no se pudo desconectar: " + e.getMessage());
        }
    
    }

    public Connection getConnection() {
       return conn;
    }
}
 
