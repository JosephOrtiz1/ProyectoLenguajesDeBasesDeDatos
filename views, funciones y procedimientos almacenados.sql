-- VISTAS

-- Resumen de Gastos Mensuales
CREATE VIEW vw_resumen_gastos_mensuales AS
SELECT 
    c.nombre AS categoria, 
    SUM(g.monto) AS total_gastado, 
    EXTRACT(MONTH FROM g.fecha) AS mes, 
    EXTRACT(YEAR FROM g.fecha) AS año
FROM gastos g
JOIN categorias c ON g.id_categoria = c.id
WHERE EXTRACT(MONTH FROM g.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(YEAR FROM g.fecha) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY c.nombre, mes, año;

-- Balance Financiero Mensual
CREATE VIEW vw_balance_mensual AS
SELECT 
    COALESCE((SELECT SUM(i.monto) FROM ingresos i WHERE EXTRACT(MONTH FROM i.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)), 0) AS total_ingresos,
    COALESCE((SELECT SUM(g.monto) FROM gastos g WHERE EXTRACT(MONTH FROM g.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)), 0) AS total_gastos,
    (COALESCE((SELECT SUM(i.monto) FROM ingresos i WHERE EXTRACT(MONTH FROM i.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)), 0) 
     - COALESCE((SELECT SUM(g.monto) FROM gastos g WHERE EXTRACT(MONTH FROM g.fecha) = EXTRACT(MONTH FROM CURRENT_DATE)), 0)) AS balance

-- Detalle de Gastos por Usuario
CREATE OR REPLACE VIEW vw_detalle_gastos_usuario AS
SELECT 
    u.nombre AS usuario,
    c.nombre AS categoria,
    g.monto,
    g.descripcion,
    g.fecha
FROM gastos g
JOIN usuarios u ON g.id_usuario = u.id
JOIN categorias c ON g.id_categoria = c.id;

-- Resumen de Ingresos por Usuario
CREATE OR REPLACE VIEW vw_resumen_ingresos_usuario AS
SELECT 
    u.nombre AS usuario,
    SUM(i.monto) AS total_ingresos
FROM ingresos i
JOIN usuarios u ON i.id_usuario = u.id
GROUP BY u.nombre;

-- Categorías con Más Gastos
CREATE OR REPLACE VIEW vw_top_categorias_gastos AS
SELECT 
    c.nombre AS categoria,
    SUM(g.monto) AS total_gastado
FROM gastos g
JOIN categorias c ON g.id_categoria = c.id
GROUP BY c.nombre
ORDER BY total_gastado DESC;

-- Ingresos y Gastos por Día
CREATE OR REPLACE VIEW vw_ingresos_gastos_diarios AS
SELECT 
    fecha,
    SUM(CASE WHEN tipo = 'ingreso' THEN monto ELSE 0 END) AS total_ingresos,
    SUM(CASE WHEN tipo = 'gasto' THEN monto ELSE 0 END) AS total_gastos
FROM (
    SELECT fecha, monto, 'ingreso' AS tipo FROM ingresos
    UNION ALL
    SELECT fecha, monto, 'gasto' AS tipo FROM gastos
) t
GROUP BY fecha
ORDER BY fecha;

-- Usuarios con Presupuesto Insuficiente
CREATE OR REPLACE VIEW vw_usuarios_presupuesto_insuficiente AS
SELECT 
    u.nombre AS usuario,
    u.presupuesto_mensual,
    COALESCE(SUM(g.monto), 0) AS total_gastos,
    u.presupuesto_mensual - COALESCE(SUM(g.monto), 0) AS saldo_restante
FROM usuarios u
LEFT JOIN gastos g ON u.id = g.id_usuario
AND EXTRACT(MONTH FROM g.fecha) = EXTRACT(MONTH FROM SYSDATE)
AND EXTRACT(YEAR FROM g.fecha) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY u.nombre, u.presupuesto_mensual
HAVING u.presupuesto_mensual < COALESCE(SUM(g.monto), 0);





-- FUNCIONES ALMACENADAS

-- Obtener Total Gastado en un Mes Y Año
CREATE FUNCTION fn_total_gastado(usuario_id INT, mes INT, año INT) RETURNS DECIMAL(10,2) AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(monto), 0) INTO total
    FROM gastos
    WHERE id_usuario = usuario_id
    AND EXTRACT(MONTH FROM fecha) = mes
    AND EXTRACT(YEAR FROM fecha) = año;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Obtener Presupuesto Restante
CREATE FUNCTION fn_presupuesto_restante(usuario_id INT) RETURNS DECIMAL(10,2) AS $$
DECLARE
    presupuesto DECIMAL(10,2);
    total_gastos DECIMAL(10,2);
    restante DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(monto), 0) INTO total_gastos
    FROM gastos WHERE id_usuario = usuario_id
    AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM CURRENT_DATE);
    
    SELECT COALESCE(presupuesto_mensual, 0) INTO presupuesto
    FROM usuarios WHERE id = usuario_id;
    
    restante := presupuesto - total_gastos;
    RETURN restante;
END;
$$ LANGUAGE plpgsql;

-- Calcular Gasto Promedio Diario en un Mes
CREATE OR REPLACE FUNCTION fn_gasto_promedio_diario(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER
IS
    v_total_gasto NUMBER;
    v_dias NUMBER;
BEGIN
    SELECT NVL(SUM(monto), 0) INTO v_total_gasto
    FROM gastos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;

    SELECT COUNT(DISTINCT fecha) INTO v_dias
    FROM gastos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;

    RETURN CASE WHEN v_dias > 0 THEN v_total_gasto / v_dias ELSE 0 END;
END;
/

-- Categoría con Mayor Gasto
CREATE OR REPLACE FUNCTION fn_categoria_mayor_gasto(
    p_usuario_id IN NUMBER
) RETURN VARCHAR2
IS
    v_categoria VARCHAR2(100);
BEGIN
    SELECT c.nombre INTO v_categoria
    FROM gastos g
    JOIN categorias c ON g.id_categoria = c.id
    WHERE g.id_usuario = p_usuario_id
    GROUP BY c.nombre
    ORDER BY SUM(g.monto) DESC
    FETCH FIRST 1 ROWS ONLY;

    RETURN v_categoria;
END;
/

-- Porcentaje de Gasto en una Categoría
CREATE OR REPLACE FUNCTION fn_porcentaje_gasto_categoria(
    p_usuario_id IN NUMBER,
    p_categoria_id IN NUMBER
) RETURN NUMBER
IS
    v_total_gasto NUMBER;
    v_gasto_categoria NUMBER;
    v_porcentaje NUMBER;
BEGIN
    SELECT NVL(SUM(monto), 0) INTO v_total_gasto
    FROM gastos
    WHERE id_usuario = p_usuario_id;

    SELECT NVL(SUM(monto), 0) INTO v_gasto_categoria
    FROM gastos
    WHERE id_usuario = p_usuario_id AND id_categoria = p_categoria_id;

    IF v_total_gasto > 0 THEN
        v_porcentaje := (v_gasto_categoria / v_total_gasto) * 100;
    ELSE
        v_porcentaje := 0;
    END IF;

    RETURN v_porcentaje;
END;
/

-- Día con Mayor Gasto en un Mes
CREATE OR REPLACE FUNCTION fn_dia_mayor_gasto(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN DATE
IS
    v_dia DATE;
BEGIN
    SELECT fecha INTO v_dia
    FROM gastos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio
    GROUP BY fecha
    ORDER BY SUM(monto) DESC
    FETCH FIRST 1 ROWS ONLY;

    RETURN v_dia;
END;
/

-- Diferencia Entre Ingresos y Gastos En Un Mes
CREATE OR REPLACE FUNCTION fn_ahorro_mensual(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER
IS
    v_total_ingresos NUMBER;
    v_total_gastos NUMBER;
    v_ahorro NUMBER;
BEGIN
    SELECT NVL(SUM(monto), 0) INTO v_total_ingresos
    FROM ingresos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;

    SELECT NVL(SUM(monto), 0) INTO v_total_gastos
    FROM gastos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;

    v_ahorro := v_total_ingresos - v_total_gastos;
    RETURN v_ahorro;
END;
/

-- Fecha del Último Gasto
CREATE OR REPLACE FUNCTION fn_ultima_fecha_gasto(
    p_usuario_id IN NUMBER
) RETURN DATE
IS
    v_fecha DATE;
BEGIN
    SELECT MAX(fecha) INTO v_fecha
    FROM gastos
    WHERE id_usuario = p_usuario_id;

    RETURN v_fecha;
END;
/

-- Determinar si un Usuario Está en Déficit
CREATE OR REPLACE FUNCTION fn_usuario_en_deficit(
    p_usuario_id IN NUMBER
) RETURN VARCHAR2
IS
    v_presupuesto NUMBER;
    v_gastos NUMBER;
BEGIN
    SELECT presupuesto_mensual INTO v_presupuesto
    FROM usuarios WHERE id = p_usuario_id;

    SELECT NVL(SUM(monto), 0) INTO v_gastos
    FROM gastos WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM SYSDATE);

    RETURN CASE WHEN v_gastos > v_presupuesto THEN 'Sí' ELSE 'No' END;
END;
/

-- Número de Gastos en un Mes
CREATE OR REPLACE FUNCTION fn_contar_gastos_mes(
    p_usuario_id IN NUMBER,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER
IS
    v_cantidad NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cantidad
    FROM gastos
    WHERE id_usuario = p_usuario_id
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;

    RETURN v_cantidad;
END;
/





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
    -- Validar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto del gasto debe ser mayor que 0.');
    END IF;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_existe_usuario FROM usuarios WHERE id = p_usuario_id;
    IF v_existe_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El usuario no existe.');
    END IF;

    -- Verificar si la categoría existe
    SELECT COUNT(*) INTO v_existe_categoria FROM categorias WHERE id = p_categoria_id;
    IF v_existe_categoria = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'La categoría no existe.');
    END IF;

    -- Insertar el gasto si pasa todas las validaciones
    INSERT INTO gastos (id_usuario, id_categoria, monto, descripcion, fecha)
    VALUES (p_usuario_id, p_categoria_id, p_monto, p_descripcion, p_fecha);
    
    COMMIT;
END;
/
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
    -- Validar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El monto del ingreso debe ser mayor que 0.');
    END IF;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_existe_usuario FROM usuarios WHERE id = p_usuario_id;
    IF v_existe_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'El usuario no existe.');
    END IF;

    -- Insertar el ingreso si pasa las validaciones
    INSERT INTO ingresos (id_usuario, monto, descripcion, fecha)
    VALUES (p_usuario_id, p_monto, p_descripcion, p_fecha);
    
    COMMIT;
END;
/

-- Eliminar Ingresos de un Usuario
CREATE OR REPLACE PROCEDURE sp_eliminar_ingresos_usuario(
    p_usuario_id IN NUMBER
)
IS
BEGIN
    DELETE FROM ingresos WHERE id_usuario = p_usuario_id;
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
    UPDATE usuarios
    SET presupuesto_mensual = p_nuevo_presupuesto
    WHERE id = p_usuario_id;
    
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
BEGIN
    SELECT presupuesto_mensual INTO v_presupuesto_origen
    FROM usuarios WHERE id = p_usuario_origen;

    IF v_presupuesto_origen < p_monto THEN
        RAISE_APPLICATION_ERROR(-20010, 'Fondos insuficientes.');
    END IF;

    UPDATE usuarios
    SET presupuesto_mensual = presupuesto_mensual - p_monto
    WHERE id = p_usuario_origen;

    UPDATE usuarios
    SET presupuesto_mensual = presupuesto_mensual + p_monto
    WHERE id = p_usuario_destino;
    
    COMMIT;
END;
/

-- Eliminar Gastos Antiguos
CREATE PROCEDURE sp_eliminar_gastos_antiguos()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM gastos WHERE fecha < CURRENT_DATE - INTERVAL '2 years';
END;
$$;

-- Modificar un Gasto
CREATE OR REPLACE PROCEDURE sp_modificar_gasto(
    p_gasto_id IN NUMBER,
    p_nuevo_monto IN NUMBER,
    p_nueva_descripcion IN VARCHAR2,
    p_nueva_fecha IN DATE
)
IS
BEGIN
    UPDATE gastos
    SET monto = p_nuevo_monto,
        descripcion = p_nueva_descripcion,
        fecha = p_nueva_fecha
    WHERE id = p_gasto_id;

    COMMIT;
END;
/

-- Eliminar un Gasto
CREATE OR REPLACE PROCEDURE sp_eliminar_gasto(
    p_gasto_id IN NUMBER
)
IS
BEGIN
    DELETE FROM gastos WHERE id = p_gasto_id;
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
    UPDATE ingresos
    SET monto = p_nuevo_monto,
        descripcion = p_nueva_descripcion,
        fecha = p_nueva_fecha
    WHERE id = p_ingreso_id;

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
BEGIN
    UPDATE gastos
    SET id_categoria = p_categoria_destino
    WHERE id_usuario = p_usuario_id
    AND id_categoria = p_categoria_origen
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
    CURSOR c_gastos IS
        SELECT id, monto, descripcion, fecha
        FROM gastos
        WHERE id_usuario = p_usuario_id
        AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
BEGIN
    FOR gasto_rec IN c_gastos LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || gasto_rec.id || ', Monto: ' || gasto_rec.monto || ', Descripción: ' || gasto_rec.descripcion || ', Fecha: ' || gasto_rec.fecha);
    END LOOP;
END;
/


