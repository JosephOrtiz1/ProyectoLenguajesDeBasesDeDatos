/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package CRUD;
import java.sql.*;

/**
 *
 * @author JOSEFU
 */
public class Graficos {
    private Connection connection;

    public Graficos(Connection connection) {
        this.connection = connection;
    }
    
    //Crear Graficos 
    public void crearTransaccion(int idGrafico, int idReporte, String tipoGrafico, String datos  ) {
    String sql = "INSERT INTO Graficos (id_grafico, id_reporte, tipo_grafico, datos) VALUES (?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idGrafico);
        stmt.setInt(2, idReporte);
        stmt.setString(3, tipoGrafico);
        stmt.setString(4, datos); 
        stmt.executeUpdate();  

        System.out.println("Transaccion creado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al crear la transacción: " + e.getMessage());
    }
}
    
        //Leer Graficos
     public void leerGraficos() {
        String sql = "SELECT * FROM Graficos";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idGrafico = rs.getInt("id_grafico");
                int idReporte = rs.getInt("id_reporte");
                String tipoGrafico = rs.getString("tipo_grafico");  
                String datos= rs.getString("datos_json"); 
                 
                //Opcional para imprimir los datos en la consola
                System.out.println("ID grafico: " + idGrafico + "ID del reporte: " +idReporte + "Tipo del grafico: "+tipoGrafico + "Datos: " + datos);
                
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     
    //Actulizar graficos
    public void actualizarTransacciones(int idGrafico, int idReporte, String tipoGrafico, String datos ) { 
    String sql = "UPDATE Graficos SET id_reporte = ?, tipo_grafico = ?, datos_json = ? WHERE id_grafico = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idReporte); 
        stmt.setString(2, tipoGrafico);  
        stmt.setString(3, datos);
        stmt.setInt(4, idGrafico); 

        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Grafico actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el grafico con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el grafico: " + e.getMessage());
    }
} 
    
     //Eliminar graficos  
    public void eliminarGraficos(int idGrafico) {
        String sql = "DELETE FROM Graficos WHERE id_grafico = ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idGrafico);
            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Grafico eliminado exitosamente.");
            } else {
                System.out.println("No se encontró el grafico con ese ID.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
} 
    
}
