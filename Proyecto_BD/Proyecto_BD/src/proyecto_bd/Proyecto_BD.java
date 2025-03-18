/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package proyecto_bd;
import VISTA.InicioSesion;
import proyecto_bd.OracleConnection;

/**
 *
 * @author USUARIO
 */
public class Proyecto_BD {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        InicioSesion inicio = new InicioSesion();
        inicio.setVisible(true);
        
        OracleConnection conn = new OracleConnection();
        
    }
    
}
