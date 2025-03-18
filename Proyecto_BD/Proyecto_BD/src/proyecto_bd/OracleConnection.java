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
    
    private void conectar() {
        try {
            Class.forName("oracle.jdbc.OracleDriver"); // Driver 
            url = "jdbc:oracle:thin:@192.168.56.105:1521:orcl";
            user = "AdminProyecto";
            pass = "12345678";
            conn = DriverManager.getConnection(url, user, pass);
            System.out.println("Conectado!");
        } catch (Exception e) {
            System.out.println("Error, no se pudo conectar: " + e.getMessage());
        }
    }
    
    public void desconectar() {
        try {
            if (conn != null && !conn.isClosed()) { 
                conn.close();
                System.out.println("Desconectado!");
            }
        } catch (SQLException e) { // Captura SQLException en vez de Exception
            System.out.println("Error, no se pudo desconectar: " + e.getMessage());
        }
    }
}
