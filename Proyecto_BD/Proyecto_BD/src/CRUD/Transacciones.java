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
public class Transacciones {
    private Connection connection;

    public Transacciones(Connection connection) {
        this.connection = connection;
    }
    
    //Crear Transaccion 
    public void crearTransaccion(int idTransaccion, int idUsuario, int idCategoria, double monto, String tipo,  java.sql.Date fecha,  String descripcion  ) {
    String sql = "INSERT INTO transacciones (id_transaccion, id_usuario, id_categoria, monto, tipo ,fecha, descripcion) VALUES (?, ?, ?, ?, ?, ?,?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idTransaccion);
        stmt.setInt(2, idUsuario);
        stmt.setInt(3, idCategoria);
        stmt.setDouble(4, monto); 
        stmt.setString(5, tipo);
        stmt.setDate(6, fecha); 
        stmt.setString(7, descripcion); 


        stmt.executeUpdate();  

        System.out.println("Transaccion creado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al crear la transacción: " + e.getMessage());
    }
}
    
    
    //Leer transaccion
     public void leerTransaccion() {
        String sql = "SELECT * FROM transacciones";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idTransaccion = rs.getInt("id_transaccion");
                int idUsuario = rs.getInt("id_usuario");
                int idCategoria = rs.getInt("idCategoria");

                double monto = rs.getDouble("Monto");
                String tipo= rs.getString("tipo");
                Date fecha = rs.getDate("fecha");  
                String descripcion = rs.getString("Descripcion");  

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID transacción: " + idTransaccion + ", Realizado por: " + idUsuario + ", En la categoria"
                 + idCategoria + "Con el monto de: " + monto +", Tipo de transacción " +tipo+ ", Fecha :"+ fecha+ ", Descripcion de la transaccion: "+ descripcion);
                
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    //Actulizar transacciones
    public void actualizarTransacciones(int idTransaccion, int idUsuario, int idCategoria, double monto, String tipo ,java.sql.Date fecha, String descripcion ) { 
    String sql = "UPDATE transacciones SET id_usuario = ?, id_categoria = ?, monto = ?, tipo = ?, fecha =? , descripcion =? WHERE id_transaccion = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idUsuario); 
        stmt.setInt(2, idCategoria); 
        stmt.setDouble(3, monto); 
        stmt.setString(4, tipo); 
        stmt.setDate(5, fecha); 
        stmt.setString(6, descripcion );
        stmt.setInt(7, idTransaccion); 

        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Usuario actualizado exitosamente.");
        } else {
            System.out.println("No se encontró el usuario con ese ID.");
        }
    } catch (SQLException e) {
        
        System.out.println("Error al actualizar el usuario: " + e.getMessage());
    }
}   
    
    //Eliminar transacciones   
    public void eliminarTransacciones(int idTransaccion) {
        String sql = "DELETE FROM transacciones WHERE id_transaccion = ?";
    
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, idTransaccion);
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
