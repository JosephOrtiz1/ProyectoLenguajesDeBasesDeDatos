-- VISTAS

-- Resumen de Gastos Mensuales
CREATE VIEW vw_resumen_gastos_mensuales AS
SELECT 
    c.nombre AS categoria, 
    SUM(t.monto) AS total_gastado, 
    EXTRACT(MONTH FROM t.fecha) AS mes, 
    EXTRACT(YEAR FROM t.fecha) AS año
FROM Transacciones t
JOIN Categorias c ON t.id_categoria = c.id_categoria
WHERE t.tipo = 'egreso' 
AND EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY c.nombre, EXTRACT(MONTH FROM t.fecha), EXTRACT(YEAR FROM t.fecha);


-- Balance Financiero Mensual
CREATE VIEW vw_balance_mensual AS
SELECT 
    COALESCE(SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END), 0) AS total_ingresos,
    COALESCE(SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END), 0) AS total_gastos,
    COALESCE(SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END), 0) 
    - COALESCE(SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END), 0) AS balance
FROM Transacciones t
WHERE EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM CURRENT_DATE);


-- Detalle de Gastos por Usuario

CREATE OR REPLACE VIEW vw_detalle_gastos_usuario AS
SELECT 
    u.nombre AS usuario,
    c.nombre AS categoria,
    t.monto,
    t.descripcion,
    t.fecha
FROM Transacciones t
JOIN Usuarios u ON t.id_usuario = u.id_usuario
JOIN Categorias c ON t.id_categoria = c.id_categoria
WHERE t.tipo = 'egreso';  


-- Resumen de Ingresos por Usuario

CREATE OR REPLACE VIEW vw_resumen_ingresos_usuario AS
SELECT 
    u.nombre AS usuario,
    SUM(t.monto) AS total_ingresos
FROM Transacciones t
JOIN Usuarios u ON t.id_usuario = u.id_usuario
WHERE t.tipo = 'ingreso'  
GROUP BY u.nombre;

-- Categorías con Más Gastos

CREATE OR REPLACE VIEW vw_top_categorias_gastos AS
SELECT 
    c.nombre AS categoria,
    SUM(t.monto) AS total_gastado
FROM Transacciones t
JOIN Categorias c ON t.id_categoria = c.id_categoria
WHERE t.tipo = 'egreso'  
GROUP BY c.nombre
ORDER BY total_gastado DESC;


-- Ingresos y Gastos por Día

CREATE OR REPLACE VIEW vw_ingresos_gastos_diarios AS
SELECT 
    t.fecha,
    SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END) AS total_ingresos,
    SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END) AS total_gastos
FROM Transacciones t
GROUP BY t.fecha
ORDER BY t.fecha;


-- Usuarios con Presupuesto Insuficiente

CREATE OR REPLACE VIEW vw_usuarios_presupuesto_insuficiente AS
SELECT 
    u.nombre AS usuario,
    p.monto_limite AS presupuesto_mensual,
    COALESCE(SUM(t.monto), 0) AS total_gastos,
    p.monto_limite - COALESCE(SUM(t.monto), 0) AS saldo_restante
FROM Usuarios u
JOIN Presupuestos p ON u.id_usuario = p.id_usuario  
LEFT JOIN Transacciones t ON u.id_usuario = t.id_usuario 
    AND t.tipo = 'egreso' 
    AND EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM SYSDATE)
    AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY u.nombre, p.monto_limite
HAVING p.monto_limite < COALESCE(SUM(t.monto), 0);  

-- Gastos anuales por usuario

CREATE OR REPLACE VIEW vw_gastos_anuales_usuario AS
SELECT 
    u.nombre AS usuario,
    EXTRACT(YEAR FROM t.fecha) AS año,
    SUM(t.monto) AS total_gastos
FROM Transacciones t
JOIN Usuarios u ON t.id_usuario = u.id_usuario
WHERE t.tipo = 'egreso'
GROUP BY u.nombre, EXTRACT(YEAR FROM t.fecha)
ORDER BY usuario, año;

-- Usuarios con ingresos superiores a gastos

CREATE OR REPLACE VIEW vw_usuarios_ingresos_superiores_a_gastos AS
SELECT 
    u.nombre AS usuario,
    COALESCE(SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END), 0) AS total_ingresos,
    COALESCE(SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END), 0) AS total_gastos
FROM Usuarios u
LEFT JOIN Transacciones t ON u.id_usuario = t.id_usuario
    AND EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM SYSDATE)
    AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY u.nombre
HAVING SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END) > SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END);

-- Promedio gastos mensuales

CREATE OR REPLACE VIEW vw_promedio_gastos_mensuales_usuario AS
SELECT 
    u.nombre AS usuario,
    AVG(gastos_mes.total_gastos_mes) AS promedio_gastos_mensuales
FROM (
    SELECT 
        t.id_usuario,
        EXTRACT(MONTH FROM t.fecha) AS mes,
        EXTRACT(YEAR FROM t.fecha) AS año,
        SUM(t.monto) AS total_gastos_mes
    FROM Transacciones t
    WHERE t.tipo = 'egreso'
    AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM SYSDATE)  -- Año actual
    GROUP BY t.id_usuario, EXTRACT(MONTH FROM t.fecha), EXTRACT(YEAR FROM t.fecha)
) gastos_mes
JOIN Usuarios u ON gastos_mes.id_usuario = u.id_usuario
GROUP BY u.nombre;



-- FUNCIONES ALMACENADAS

CREATE OR REPLACE FUNCTION fn_total_gastado(
    usuario_id IN NUMBER, 
    mes IN NUMBER, 
    año IN NUMBER
) RETURN NUMBER IS
    total NUMBER(10,2);
BEGIN
    SELECT COALESCE(SUM(t.monto), 0) 
    INTO total
    FROM Transacciones t
    WHERE t.id_usuario = usuario_id
    AND t.tipo = 'egreso'  
    AND EXTRACT(MONTH FROM t.fecha) = mes
    AND EXTRACT(YEAR FROM t.fecha) = año;

    RETURN total;
END;


-- Obtener Presupuesto Restante

CREATE OR REPLACE FUNCTION fn_presupuesto_restante(
    usuario_id IN NUMBER
) RETURN NUMBER IS
    presupuesto NUMBER(10,2);
    total_gastos NUMBER(10,2);
    restante NUMBER(10,2);
BEGIN
   
    SELECT COALESCE(SUM(t.monto), 0) INTO total_gastos
    FROM Transacciones t
    WHERE t.id_usuario = usuario_id
    AND t.tipo = 'egreso'  -- Solo los gastos
    AND EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM SYSDATE)
    AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM SYSDATE);
    
   
    SELECT COALESCE(p.monto_limite, 0) INTO presupuesto
    FROM Presupuestos p
    WHERE p.id_usuario = usuario_id;
    
    
    restante := presupuesto - total_gastos;
    
    RETURN restante;
END;


-- Calcular Gasto Promedio Diario en un Mes

CREATE OR REPLACE FUNCTION fn_gasto_promedio_diario(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER IS
    v_total_gasto NUMBER(10,2);
    v_dias NUMBER;
    v_gasto_promedio NUMBER(10,2);
BEGIN
    SELECT COALESCE(SUM(t.monto), 0) INTO v_total_gasto
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso'  
    AND EXTRACT(MONTH FROM t.fecha) = p_mes
    AND EXTRACT(YEAR FROM t.fecha) = p_anio;

   
    SELECT COUNT(DISTINCT EXTRACT(DAY FROM t.fecha)) INTO v_dias
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso'
    AND EXTRACT(MONTH FROM t.fecha) = p_mes
    AND EXTRACT(YEAR FROM t.fecha) = p_anio;

    
    IF v_dias = 0 THEN
        v_gasto_promedio := 0;
    ELSE
        
        v_gasto_promedio := v_total_gasto / v_dias;
    END IF;

    RETURN v_gasto_promedio;

END fn_gasto_promedio_diario;



-- Categoría con Mayor Gasto

CREATE OR REPLACE FUNCTION fn_categoria_mayor_gasto(
    p_usuario_id IN NUMBER
) RETURN VARCHAR2 IS
    v_categoria VARCHAR2(100);
BEGIN
    
    SELECT c.nombre
    INTO v_categoria
    FROM (
        SELECT c.nombre, SUM(t.monto) AS total_gasto
        FROM Transacciones t
        JOIN Categorias c ON t.id_categoria = c.id_categoria
        WHERE t.id_usuario = p_usuario_id
        AND t.tipo = 'egreso' 
        GROUP BY c.nombre
        ORDER BY total_gasto DESC
    ) 
    WHERE ROWNUM = 1;  
    
    RETURN v_categoria;
END;


-- Porcentaje de Gasto en una Categoría

CREATE OR REPLACE FUNCTION fn_porcentaje_gasto_categoria(
    p_usuario_id IN NUMBER,
    p_categoria_id IN NUMBER
) RETURN NUMBER IS
    v_total_gasto NUMBER(10,2);
    v_gasto_categoria NUMBER(10,2);
    v_porcentaje NUMBER(5,2);
BEGIN
    
    SELECT COALESCE(SUM(t.monto), 0) INTO v_total_gasto
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso';  

    SELECT COALESCE(SUM(t.monto), 0) INTO v_gasto_categoria
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.id_categoria = p_categoria_id
    AND t.tipo = 'egreso'; 

    IF v_total_gasto > 0 THEN
        v_porcentaje := (v_gasto_categoria / v_total_gasto) * 100;
    ELSE
        v_porcentaje := 0;
    END IF;

    RETURN v_porcentaje;
END;


-- Día con Mayor Gasto en un Mes

CREATE OR REPLACE FUNCTION fn_dia_mayor_gasto(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN DATE IS
    v_dia DATE;
BEGIN

    SELECT t.fecha
    INTO v_dia
    FROM (
        SELECT t.fecha, SUM(t.monto) AS total_gasto,
               ROW_NUMBER() OVER (ORDER BY SUM(t.monto) DESC) AS rn
        FROM Transacciones t
        WHERE t.id_usuario = p_usuario_id
        AND t.tipo = 'egreso'  
        AND EXTRACT(MONTH FROM t.fecha) = p_mes
        AND EXTRACT(YEAR FROM t.fecha) = p_anio
        GROUP BY t.fecha
    )
    WHERE rn = 1; 

    RETURN v_dia;
END;


-- Diferencia Entre Ingresos y Gastos En Un Mes

CREATE OR REPLACE FUNCTION fn_ahorro_mensual(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER IS
    v_total_ingresos NUMBER(10,2);
    v_total_gastos NUMBER(10,2);
    v_ahorro NUMBER(10,2);
BEGIN
   
    SELECT 
        COALESCE(SUM(CASE WHEN t.tipo = 'ingreso' THEN t.monto ELSE 0 END), 0) INTO v_total_ingresos,
        COALESCE(SUM(CASE WHEN t.tipo = 'egreso' THEN t.monto ELSE 0 END), 0) INTO v_total_gastos
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM t.fecha) = p_mes
    AND EXTRACT(YEAR FROM t.fecha) = p_anio;

    v_ahorro := v_total_ingresos - v_total_gastos;
    
    RETURN v_ahorro;
END;

-- Fecha del Último Gasto

CREATE OR REPLACE FUNCTION fn_ultima_fecha_gasto(
    p_usuario_id IN NUMBER
) RETURN DATE IS
    v_fecha DATE;
BEGIN
    SELECT MAX(t.fecha) INTO v_fecha
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso';  

    RETURN v_fecha;
END;



CREATE OR REPLACE FUNCTION fn_usuario_en_deficit(
    p_usuario_id IN NUMBER
) RETURN VARCHAR2 IS
    v_presupuesto NUMBER(10,2);
    v_gastos NUMBER(10,2);
BEGIN
   
    SELECT monto_limite INTO v_presupuesto
    FROM Presupuestos 
    WHERE id_usuario = p_usuario_id;

    
    SELECT COALESCE(SUM(t.monto), 0) INTO v_gastos
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso' 
    AND EXTRACT(MONTH FROM t.fecha) = EXTRACT(MONTH FROM SYSDATE)
    AND EXTRACT(YEAR FROM t.fecha) = EXTRACT(YEAR FROM SYSDATE);

   
    RETURN CASE WHEN v_gastos > v_presupuesto THEN 'Sí' ELSE 'No' END;
END;


-- Número de Gastos en un Mes

CREATE OR REPLACE FUNCTION fn_contar_gastos_mes(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER IS
    v_cantidad NUMBER;
BEGIN
   
    SELECT COUNT(*) INTO v_cantidad
    FROM Transacciones t
    WHERE t.id_usuario = p_usuario_id
    AND t.tipo = 'egreso' 
    AND EXTRACT(MONTH FROM t.fecha) = p_mes
    AND EXTRACT(YEAR FROM t.fecha) = p_anio;

    RETURN v_cantidad;
END;



-- PROCEDIMIENTOS ALMACENADOS



-- Registrar Gasto con validaciones
CREATE OR REPLACE PROCEDURE sp_registrar_gasto(
    p_usuario_id IN NUMBER,
    p_categoria_id IN NUMBER,
    p_monto IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_fecha IN DATE
)
IS
    v_existe_usuario NUMBER;
    v_existe_categoria NUMBER;
BEGIN
   
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto del gasto debe ser mayor que 0.');
    END IF;

   
    SELECT COUNT(*) INTO v_existe_usuario FROM Usuarios WHERE id_usuario = p_usuario_id;
    IF v_existe_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El usuario no existe.');
    END IF;

   
    SELECT COUNT(*) INTO v_existe_categoria FROM Categorias WHERE id_categoria = p_categoria_id;
    IF v_existe_categoria = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'La categoría no existe.');
    END IF;

  
    INSERT INTO Transacciones (id_usuario, id_categoria, monto, descripcion, fecha, tipo)
    VALUES (p_usuario_id, p_categoria_id, p_monto, p_descripcion, p_fecha, 'egreso');
    
    COMMIT;
END;


-- Registrar un nuevo ingreso con validaciones

CREATE OR REPLACE PROCEDURE sp_registrar_ingreso(
    p_usuario_id IN NUMBER,
    p_monto IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_fecha IN DATE
)
IS
    v_existe_usuario NUMBER;
BEGIN
   
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El monto del ingreso debe ser mayor que 0.');
    END IF;

    
    SELECT COUNT(*) INTO v_existe_usuario FROM Usuarios WHERE id_usuario = p_usuario_id;
    IF v_existe_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'El usuario no existe.');
    END IF;

  
    INSERT INTO Transacciones (id_usuario, id_categoria, monto, descripcion, fecha, tipo)
    VALUES (p_usuario_id, NULL, p_monto, p_descripcion, p_fecha, 'ingreso');
    
    COMMIT;
END;


-- Eliminar Ingresos de un Usuario

CREATE OR REPLACE PROCEDURE sp_eliminar_ingresos_usuario(
    p_usuario_id IN NUMBER
)
IS
BEGIN
   
    DELETE FROM Transacciones 
    WHERE id_usuario = p_usuario_id 
    AND tipo = 'ingreso';
    
    COMMIT;
END;
/

-- Ajustar Presupuesto de un Usuario

CREATE OR REPLACE PROCEDURE sp_ajustar_presupuesto(
    p_usuario_id IN NUMBER,
    p_nuevo_presupuesto IN NUMBER
)
IS
BEGIN
   
    UPDATE Presupuestos
    SET monto_limite = p_nuevo_presupuesto
    WHERE id_usuario = p_usuario_id;
    
    COMMIT;
END;
/


-- Transferir Presupuesto Entre Usuarios
CREATE OR REPLACE PROCEDURE sp_transferir_presupuesto(
    p_usuario_origen IN NUMBER,
    p_usuario_destino IN NUMBER,
    p_monto IN NUMBER
)
IS
    v_presupuesto_origen NUMBER;
    v_presupuesto_destino NUMBER;
BEGIN
   
    SELECT monto_limite INTO v_presupuesto_origen
    FROM Presupuestos
    WHERE id_usuario = p_usuario_origen;

    IF v_presupuesto_origen < p_monto THEN
        RAISE_APPLICATION_ERROR(-20010, 'Fondos insuficientes.');
    END IF;

   
    SELECT monto_limite INTO v_presupuesto_destino
    FROM Presupuestos
    WHERE id_usuario = p_usuario_destino;

    UPDATE Presupuestos
    SET monto_limite = monto_limite - p_monto
    WHERE id_usuario = p_usuario_origen;

    UPDATE Presupuestos
    SET monto_limite = monto_limite + p_monto
    WHERE id_usuario = p_usuario_destino;

    COMMIT;
END;
/

-- Eliminar Gastos Antiguos

CREATE OR REPLACE PROCEDURE sp_eliminar_gastos_antiguos
IS
BEGIN
    DELETE FROM Transacciones
    WHERE tipo = 'egreso'  
    AND fecha < ADD_MONTHS(SYSDATE, -24); 
    
    COMMIT;
END;
/


-- Modificar un Gasto
CREATE OR REPLACE PROCEDURE sp_modificar_gasto(
    p_gasto_id IN NUMBER,
    p_nuevo_monto IN NUMBER,
    p_nueva_descripcion IN VARCHAR2,
    p_nueva_fecha IN DATE
)
IS
BEGIN
    UPDATE Transacciones
    SET monto = p_nuevo_monto,
        descripcion = p_nueva_descripcion,
        fecha = p_nueva_fecha
    WHERE id_transaccion = p_gasto_id
    AND tipo = 'egreso';  

    COMMIT;
END;
/


-- Eliminar un Gasto 

CREATE OR REPLACE PROCEDURE sp_eliminar_gasto(
    p_gasto_id IN NUMBER
)
IS
BEGIN
    DELETE FROM Transacciones
    WHERE id_transaccion = p_gasto_id
    AND tipo = 'egreso';  
    COMMIT;
END;
/

-- Modificar un Ingreso

CREATE OR REPLACE PROCEDURE sp_modificar_ingreso(
    p_ingreso_id IN NUMBER,
    p_nuevo_monto IN NUMBER,
    p_nueva_descripcion IN VARCHAR2,
    p_nueva_fecha IN DATE
)
IS
BEGIN
    UPDATE Transacciones
    SET monto = p_nuevo_monto,
        descripcion = p_nueva_descripcion,
        fecha = p_nueva_fecha
    WHERE id_transaccion = p_ingreso_id
    AND tipo = 'ingreso'; 

    COMMIT;
END;
/


-- Transferir Dinero Entre Categorías de Gasto 

CREATE OR REPLACE PROCEDURE sp_transferir_gasto_categoria(
    p_usuario_id IN NUMBER,
    p_categoria_origen IN NUMBER,
    p_categoria_destino IN NUMBER,
    p_monto IN NUMBER
)
IS
    v_existe_categoria_origen NUMBER;
    v_existe_categoria_destino NUMBER;
    v_total_gasto_origen NUMBER;
BEGIN
    -- Validar si la categoría de origen existe
    SELECT COUNT(*) INTO v_existe_categoria_origen
    FROM Categorias
    WHERE id_categoria = p_categoria_origen;

    IF v_existe_categoria_origen = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La categoría de origen no existe.');
    END IF;

    -- Validar si la categoría de destino existe
    SELECT COUNT(*) INTO v_existe_categoria_destino
    FROM Categorias
    WHERE id_categoria = p_categoria_destino;

    IF v_existe_categoria_destino = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'La categoría de destino no existe.');
    END IF;

    
    SELECT SUM(monto) INTO v_total_gasto_origen
    FROM Transacciones
    WHERE id_usuario = p_usuario_id
    AND id_categoria = p_categoria_origen
    AND tipo = 'egreso';  

    IF v_total_gasto_origen < p_monto THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monto de gasto en la categoría de origen es insuficiente.');
    END IF;

    UPDATE Transacciones
    SET id_categoria = p_categoria_destino
    WHERE id_usuario = p_usuario_id
    AND id_categoria = p_categoria_origen
    AND tipo = 'egreso'
    AND monto = p_monto;

    COMMIT;
END;
/


-- Reporte de Gastos en un Rango de Fechas 


CREATE OR REPLACE PROCEDURE sp_reporte_gastos(
    p_usuario_id IN NUMBER,
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE
)
IS
BEGIN
    FOR gasto_rec IN (
        SELECT id_transaccion, monto, descripcion, fecha
        FROM Transacciones
        WHERE id_usuario = p_usuario_id
        AND tipo = 'egreso'  
        AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || gasto_rec.id_transaccion || 
                             ', Monto: ' || gasto_rec.monto || 
                             ', Descripción: ' || gasto_rec.descripcion || 
                             ', Fecha: ' || gasto_rec.fecha);
    END LOOP;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron gastos en el rango de fechas proporcionado.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/

