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
public class PagosRecurrentes {
    private Connection connection;

    public PagosRecurrentes(Connection connection) {
        this.connection = connection;
    }
    
    
    //Crear pagos recurrentes
     public void crearPagosRecurrentes(int idPago, int idUsuario, String nombrePago ,double monto, java.sql.Date fechaPago, String estado ) {
        
   
    String sql = "INSERT INTO PagosRecurrentes (id_pago, id_usuario, nombre_pago, monto, fecha_pago, estado) VALUES (?, ?, ?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idPago);
        stmt.setInt(2, idUsuario);
        stmt.setString(3, nombrePago);
        stmt.setDate(4, fechaPago);
        stmt.setString(5, estado);
        

        stmt.executeUpdate();  

        System.out.println("Pago recurrente registrado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al registrar el pago recurrente: " + e.getMessage());
    }
}
     
    //Leer pago recurrente
     public void leerPagoRecurrente() {
        String sql = "SELECT * FROM PagosRecurrentes";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idPago= rs.getInt("id_pago");
                int idUsuario = rs.getInt("id_usuario");
                String nombrePago = rs.getString("nombre_pago");
                double monto = rs.getDouble("monto"); 
                java.sql.Date fechaPago = rs.getDate("fecha_pago");
                String estado = rs.getString("estado");

                 

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID del pago recurrente: " + idPago + ", Realizado por: " + idUsuario + ", con un nombre de:"
                 + nombrePago + "Con una monto de: " + monto +" con el estado de:"+ estado);      
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     
    //Actulizar pago recurrente
    public void actualizarPagoRecurrente(int idPagoRecurrente, int idUsuario, String nombrePago,double monto ,java.sql.Date fechaPago, String estado) { 
    String sql = "UPDATE presupuestos SET id_usuario = ?, nombre_pago= ?, monto= ?, fecha_pago=? , estado=? WHERE id_pago = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idUsuario); 
        stmt.setString(2, nombrePago); 
        stmt.setDouble(3, monto ); 
        stmt.setDate(4, fechaPago);        
        stmt.setString(5, estado);
        stmt.setInt(6, idPagoRecurrente); 

        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Pago recurrente actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el pago recurrente con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el pago: " + e.getMessage());
    }
} 
    
    //Eliminar el pago recurrente   
    public void eliminarPagoRecurrente(int idPago) {
        String sql = "DELETE FROM PagosRecurrentes WHERE id_pago= ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idPago);
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
