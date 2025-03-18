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
public class Reportes {
    private Connection connection;

    public Reportes(Connection connection) {
        this.connection = connection;
    }
    
    //Crear reportes
    public void crearReporte(int idReporte, int idUsuario,  java.sql.Date fechaInicio, java.sql.Date fechaFin, java.sql.Date generadoEn, String tipoReporte) {
    String sql = "INSERT INTO Reportes (id_reporte, id_usuario, fecha_inicio, fecha_fin, generado_en ,tipo_reporte) VALUES (?, ?, ?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idReporte);
        stmt.setInt(2, idUsuario);
        stmt.setDate(3, fechaInicio);
        stmt.setDate(4, fechaFin); 
        stmt.setDate(5, generadoEn);
        stmt.setString(6, tipoReporte); 


        stmt.executeUpdate();  

        System.out.println("Reporte creado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al crear el reporte: " + e.getMessage());
    }
}
    
    
    //Leer reporte
     public void leerReporte() {
        String sql = "SELECT * FROM reportes";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idReporte = rs.getInt("id_reporte");
                int idUsuario = rs.getInt("id_usuario");
                java.sql.Date fechaInicio = rs.getDate("fecha_inicio");
                java.sql.Date fechaFin = rs.getDate("fecha_fin");
                java.sql.Date generadoEn= rs.getDate("generadoEn");
                String tipoReporte = rs.getString("tipo_reporte");  
                  

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID de reporte: " + idReporte + ", Realizado por: " + idUsuario + ",con de Fecha inicio: "
                 + fechaInicio + ", Con fecha de fin:" + fechaFin +", reporte generado el dia:  " +generadoEn+ ", tipo de reporte:"+ tipoReporte);
                
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }}
        
        //Actualizar reporte
        public void actualizarReportes(int idReporte, int idUsuario, java.sql.Date fechaInicio, java.sql.Date fechaFin, java.sql.Date generadoEn , String tipoReporte) { 
            String sql = "UPDATE reportes SET  id_usuario = ?, fecha_inicio = ?, fecha_fin = ?, generado_en=? , tipo_reporte =? WHERE id_reporte = ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario); 
            stmt.setDate(2, fechaInicio); 
            stmt.setDate(3, fechaFin); 
            stmt.setDate(4, generadoEn);
            stmt.setString(5, tipoReporte );
            stmt.setInt(6, idReporte); 



            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Reporte actualizado exitosamente.");
            } else {
                System.out.println("No se encontró el reporte con ese ID.");
            }
        } catch (SQLException e) {
        
            System.out.println("Error al actualizar el reporte: " + e.getMessage());
            }
        }   

        //Eliminar reportes   
    public void eliminarReportes(int idReporte) {
        String sql = "DELETE FROM reportes WHERE id_reporte = ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idReporte);
            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Transacción eliminada exitosamente.");
            } else {
                System.out.println("No se encontró la transacción con ese ID.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
        
        
}
     
    


