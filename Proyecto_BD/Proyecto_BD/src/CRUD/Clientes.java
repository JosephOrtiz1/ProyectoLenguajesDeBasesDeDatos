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
public class Clientes {
    private Connection connection;

    public Clientes(Connection connection) {
        this.connection = connection;
    }
    
    //Crear cliente
     public void crearCliente(int idCliente, int nombreCliente, String emailCliente ,int numeroCliente ) {
        
   
    String sql = "INSERT INTO Clientes (id_cliente, nombre_cliente, email_cliente, numero_cliente) VALUES (?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idCliente);
        stmt.setInt(2, nombreCliente);
        stmt.setString(3, emailCliente);
        stmt.setInt(4, numeroCliente);
        
        stmt.executeUpdate();  

        System.out.println("Cliente recurrente registrado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al registrar el cliente nuevo: " + e.getMessage());
    }
}
     
     
     //Leer cliente
     public void leerCliente() {
        String sql = "SELECT * FROM Clientes";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idCliente= rs.getInt("id_cliente");
                String nombreCliente = rs.getString("nombre_cliente");
                String email= rs.getString("email");
                int numeroCliente = rs.getInt("numeroCliente");
                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID del cliente: " + idCliente + ", nombre cliente: " + nombreCliente + ", email del cliente:"
                 + email + ", numero del cliente " + numeroCliente);      
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     
      //Actulizar cliente
    public void actualizarCliente(int idCliente, String nombreCliente, String email,int numeroCliente) { 
    String sql = "UPDATE Clientes SET  nombre_cliente= ?, email= ?, numero_cliente=? WHERE id_cliente = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setString(1, nombreCliente); 
        stmt.setString(2, email ); 
        stmt.setInt(3, numeroCliente);
        stmt.setInt(4, idCliente);        
        
       

        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Cliente actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el client con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el cliente: " + e.getMessage());
    }
}
     
     
    //Eliminar el cliente
    public void eliminarCliente(int idCliente) {
        String sql = "DELETE FROM Clientes WHERE id_cliente= ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idCliente);
            int filasAfectadas = stmt.executeUpdate();
        
            if (filasAfectadas > 0) {
                System.out.println("Cliente eliminado exitosamente.");
            } else {
                System.out.println("No se encontró el cliente con ese ID.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
}
     
}
