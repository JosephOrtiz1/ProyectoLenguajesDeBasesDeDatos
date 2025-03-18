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
public class Presupuestos {
    private Connection connection;

    public Presupuestos(Connection connection) {
        this.connection = connection;
    }
    
    //Crear Presupuestos 
    public void crearTransaccion(int idPresupuesto, int idUsuario, double montoLimite, java.sql.Date fechaInicio, java.sql.Date fechaFin,
    String nombrePresupuesto,  String tipo  ) {
        
   
    String sql = "INSERT INTO presupuestos (id_presupuesto, id_usuario, monto_limite, fecha_inicio, fecha_fin ,nombre_presupuesto, tipo) VALUES (?, ?, ?, ?, ?, ?,?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idPresupuesto);
        stmt.setInt(2, idUsuario);
        stmt.setDouble(3, montoLimite);
        stmt.setDate(4, fechaInicio); 
        stmt.setDate(5, fechaFin);
        stmt.setString(6, nombrePresupuesto); 
        stmt.setString(7, tipo); 


        stmt.executeUpdate();  

        System.out.println("Presupuesto creado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al crear el presupuesto: " + e.getMessage());
    }
}
    
     //Leer presupuesto
     public void leerTransaccion() {
        String sql = "SELECT * FROM presupuestos";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idPresupuesto = rs.getInt("id_presupuesto");
                int idUsuario = rs.getInt("id_usuario");
                double montoLimite = rs.getInt("monto_limite");
                java.sql.Date fechaInicio = rs.getDate("fecha_inicio");
                java.sql.Date fechaFin= rs.getDate("fecha_fin");
                String nombrePresupuesto = rs.getString("nombre_presupuesto");  
                String tipo = rs.getString("tipo");  

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID del presupuesto: " + idPresupuesto + ", Realizado por: " + idUsuario + ", con un monto limite de:"
                 + montoLimite + "Con una fecha de inicio de : " + fechaInicio +"y una fecha de fin:" +fechaFin+ ", nombre del presupuesto:"+
                nombrePresupuesto+ ", tipo del presupuesto"+ tipo);
                
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     
    //Actulizar presupuesto
    public void actualizarPresupuesto(int idPresupuesto, int idUsuario, double montoLimite, java.sql.Date fechaInicio , java.sql.Date fechaFin ,String nombrePresupuesto, String tipo) { 
    String sql = "UPDATE presupuestos SET id_usuario = ?, monto_limite= ?, fecha_inicio = ?, fecha_fin = ?, nombre_presupuesto =? , tipo =? WHERE id_presupuesto = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idUsuario); 
        stmt.setDouble(2, montoLimite); 
        stmt.setDate(3, fechaInicio); 
        stmt.setDate(4, fechaFin); 
        stmt.setString(5, nombrePresupuesto); 
        stmt.setString(6, tipo);
        stmt.setInt(7, idPresupuesto); 

        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Presupuesto actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el presupuesto con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el presupuesto: " + e.getMessage());
    }
}
    
    //Eliminar presupuestos   
    public void eliminarPresupuestos(int idPresupuesto) {
        String sql = "DELETE FROM presupuestos WHERE id_presupuesto= ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idPresupuesto);
            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Presupuesto eliminado exitosamente.");
            } else {
                System.out.println("No se encontró el presupuesto con ese ID.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
}
    
}
