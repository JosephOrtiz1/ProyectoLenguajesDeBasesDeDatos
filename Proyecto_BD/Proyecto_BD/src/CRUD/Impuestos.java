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
public class Impuestos {
    
    private Connection connection;

    public Impuestos(Connection connection) {
        this.connection = connection;
    }
    
    public void crearImpuestos(int idImpuesto, int idUsuario, double monto, java.sql.Date fechaRegistro, String descripcion ) {
        
   
    String sql = "INSERT INTO Impuestos (id_impuesto, id_usuario, monto, fecha_registro, descripcion) VALUES (?, ?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idImpuesto);
        stmt.setInt(2, idUsuario);
        stmt.setDouble(3, monto);
        stmt.setDate(4, fechaRegistro); 
        stmt.setString(5, descripcion);
       

        stmt.executeUpdate();  

        System.out.println("Impuestro registrado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al registrar el impuesto: " + e.getMessage());
    }
}
    
    //Leer impuesto
     public void leerImpuesto() {
        String sql = "SELECT * FROM impuesto";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idImpuesto= rs.getInt("id_impuesto");
                int idUsuario = rs.getInt("id_usuario");
                double monto = rs.getInt("monto");
                java.sql.Date fechaRegistro = rs.getDate("fecha_registro");   
                String descripcion = rs.getString("descripcion");  
                 

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID del impuesto: " + idImpuesto + ", Realizado por: " + idUsuario + ", con un monto de:"
                 + monto + "Con una fecha: " + fechaRegistro +" con la siguiente descripcion:"+ descripcion);      
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     
    //Actulizar impuesto
    public void actualizarPresupuesto(int idImpuesto, int idUsuario, double monto, java.sql.Date fechaRegistro ,  String descripcion) { 
    String sql = "UPDATE presupuestos SET id_usuario = ?, monto = ?, fecha_registro= ?, descripcion =? WHERE id_impuesto = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idUsuario); 
        stmt.setDouble(2, monto); 
        stmt.setDate(3, fechaRegistro); 
        stmt.setString(4, descripcion);
        stmt.setInt(5, idImpuesto); 



        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Impuesto actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el impuesto con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el impuesto: " + e.getMessage());
    }
} 
    
    
     //Eliminar impuestos   
    public void eliminarImpuesto(int idImpuesto) {
        String sql = "DELETE FROM impuestos WHERE id_impuesto= ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idImpuesto);
            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Impuesto eliminado exitosamente.");
            } else {
                System.out.println("No se encontró el impuesto con ese ID.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
}
     
}
