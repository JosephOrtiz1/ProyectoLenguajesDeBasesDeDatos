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
public class Categorias {

    private Connection connection;

    public Categorias(Connection connection) {
        this.connection = connection;
    }

    //Crud para crear Categorias
    public void crearCategoria(int idCategoria, String nombre, String tipo) {
        String sql = "INSERT INTO Categorias (Id_Categoria, Nombre, Tipo) VALUES (?, ?, ?)";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {  
            stmt.setInt(1, idCategoria);
            stmt.setString(2, nombre);
            stmt.setString(3, tipo);
            stmt.executeUpdate();  

            System.out.println("Categoria creada");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    //Crud para leer categorias
   public void leerCategoria() {
        String sql = "SELECT * FROM Categorias";

        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
             
            while (rs.next()) {
                int idCategoria = rs.getInt("id_categoria");
                String nombre = rs.getString("nombre");
                String tipo = rs.getString("tipo");  
                
                //Opcional para imprimir los datos en la consola
                System.out.println("ID: " + idCategoria + ", Nombre: " + nombre + ", Tipo: " + tipo);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
  
  //Crud para actualizar Categorias
  public void actualizarCategoria(int Id_Categoria, String Nombre, String Tipo) { 
    String sql = "UPDATE categorias SET nombre = ?, tipo = ? WHERE Id_Categoria = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setString(1, Nombre);
        stmt.setString(2, Tipo);
        stmt.setInt(3, Id_Categoria);
        
        int filasAfectadas = stmt.executeUpdate();
        
       
        if (filasAfectadas > 0) {
            System.out.println("Categoría actualizada exitosamente.");
        } else {
            System.out.println("No se encontró la categoría con ese ID.");
        }
    } catch (SQLException e) {
        
        e.printStackTrace();
    }
}

//Crud para eliminar Categorias   
public void eliminarCategoria(int idCategoria) {
    String sql = "DELETE FROM Categorias WHERE Id_Categoria = ?";
    
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, idCategoria);
        int filasAfectadas = stmt.executeUpdate();
        
        if (filasAfectadas > 0) {
            System.out.println("Categoria eliminado exitosamente.");
        } else {
            System.out.println("No se encontró la categoria con ese ID.");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
}   

   
    }


    
    
    

