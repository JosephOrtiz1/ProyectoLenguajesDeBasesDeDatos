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
public class Usuarios {
    private Connection connection;

    public Usuarios(Connection connection) {
        this.connection = connection;
    }
    
    //Crear Usuario
public void crearUsuario(int idUsuario, String nombre, String email, String contrasenna, java.sql.Date fechaRegistro) {
    String sql = "INSERT INTO USUARIOS (id_usuario, nombre, email, contrasenna, fecha_registro) VALUES (?, ?, ?, ?, ?)";

    try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
       
        stmt.setInt(1, idUsuario);
        stmt.setString(2, nombre);
        stmt.setString(3, email);
        stmt.setString(4, contrasenna); 
        stmt.setDate(5, fechaRegistro); 

        stmt.executeUpdate();  

        System.out.println("Usuario creado exitosamente");
    } catch (SQLException e) {
        System.out.println("Error al crear el usuario: " + e.getMessage());
    }
}

    
     public void leerUsuario() {
        String sql = "SELECT * FROM USUARIOS";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idUsuario = rs.getInt("id_usuario");
                String nombre = rs.getString("nombre");
                String email = rs.getString("email");
                String contrasenna = rs.getString("contrasenna");  
                String fechaRegistro = rs.getString("fecha_registro");  

                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID: " + idUsuario + ", Nombre: " + nombre + ", Email: " + email +", Contraseña:" +contrasenna + 
               ", Fecha registro:"+ fechaRegistro);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    //Actulizar usuarios
    public void actualizarUsuarios(int idUsuario, String nombre, String email, String contrasenna, java.sql.Date fechaRegistro) { 
    String sql = "UPDATE usuarios SET nombre = ?, email = ?, contrasenna = ?, fecha_registro = ? WHERE id_usuario = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setString(1, nombre); 
        stmt.setString(2, email); 
        stmt.setString(3, contrasenna); 
        stmt.setDate(4, fechaRegistro); 
        stmt.setInt(5, idUsuario); 

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

    
    //Eliminar Usuarios
    public void eliminarUsuarios(int idUsuario) {
    String sql = "DELETE FROM usuarios WHERE id_usuario = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idUsuario);
        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Usuario eliminado exitosamente.");
        } else {
            System.out.println("No se encontró el usuario con ese ID.");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
   
}
