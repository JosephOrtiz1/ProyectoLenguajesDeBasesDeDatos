--Creacion de tabla para usuarios
CREATE TABLE Usuarios (
id_usuario int PRIMARY KEY,
nombre VARCHAR2(20),
email VARCHAR2(100) UNIQUE,
contrasenna VARCHAR2(100),
fecha_registro DATE
);

-----------------------------------------------------------------------------------------

--Creacion de la tabla de transacciones 
CREATE TABLE Transacciones (
id_transaccion int PRIMARY KEY,
id_usuario int,
id_categoria int,
monto DECIMAL (10,2),
tipo VARCHAR2(10), CHECK(tipo IN ('Pendiente','Pagado')),
fecha DATE,
descripcion VARCHAR2(500)
);

--Foreing keys
ALTER TABLE Transacciones
ADD CONSTRAINT fk_usuario FOREIGN KEY(id_usuario)
REFERENCES Usuarios (id_usuario);

ALTER TABLE Transacciones
ADD CONSTRAINT fk_categoria FOREIGN KEY(id_categoria)
REFERENCES Categorias(id_categoria);

-------------------------------------------------------------------------------------------

--Creacion de tabla categorias

CREATE TABLE Categorias (
id_categoria int PRIMARY KEY,
nombre VARCHAR2(20),
tipo VARCHAR2(10) CHECK(tipo IN ('ingreso','egreso'))
);

------------------------------------------------------------------------------------------

--Creacion de la tabla graficos

CREATE TABLE Graficos (
id_grafico int PRIMARY KEY,
id_reporte int,
tipo_grafico VARCHAR2(100),
datos_json clob --Almacena datos tipo JSON como texto
);

--Foreing key
ALTER TABLE Graficos
ADD CONSTRAINT fk_reporte FOREIGN KEY(id_reporte)
references Reportes(id_reporte);

----------------------------------------------------------------------------------------
CREATE TABLE Reportes (
id_reporte int PRIMARY KEY,
id_usuario int,
fecha_inicio DATE,
fecha_fin DATE,
generado_en DATE,
tipo_reporte VARCHAR2(20), CHECK(tipo_reporte IN ('Mensual','Semanal', 'Personalizado'))
);

--Foreing key
ALTER TABLE Reportes
ADD CONSTRAINT fk_usuario FOREIGN KEY(id_usuario)
references Usuarios(id_usuario);

---------------------------------------------------------------------------------------------
--Creacion de tabla para presupuestos
CREATE TABLE Presupuestos(
id_presupuesto int PRIMARY KEY,
id_usuario int,
monto_limite DECIMAL (10,2),
Fecha_inicio DATE,
fecha_fin DATE,
nombre_presupuesto varchar(200),
tipo varchar2(50)
);

--Foreing key
ALTER TABLE Presupuestos
ADD CONSTRAINT fk_usuario FOREIGN KEY(id_usuario)
references Usuarios(id_usuario);

---------------------------------------------------------------------------------
--Creacion de tabla para impuestos
CREATE TABLE Impuestos(
id_impuesto int PRIMARY KEY,
id_usuario int,
monto DECIMAL (10,2),
fecha_registro DATE,
descripcion VARCHAR2(500)
);

--Foreing key
ALTER TABLE Impuestos
ADD CONSTRAINT fk_usuario FOREIGN KEY(id_usuario)
references Usuarios(id_usuario);

-----------------------------------------------------------------------------------
--Creacion de tabla para los pagos recurrentes
CREATE TABLE PagosRecurrentes (
id_pago int PRIMARY KEY,
id_usuario int,
nombre_pago VARCHAR2(200),
monto DECIMAL (10,2),
fecha_pago DATE,
estado VARCHAR2(10), CHECK(estado IN ('Pendiente','Pagado')));

--Foreing key
ALTER TABLE PagosRecurrentes
ADD CONSTRAINT fk_usuario FOREIGN KEY (id_usuario)
references Usuarios(id_usuario);

----------------------------------------------------------------------------------
--Creacion de tabla para clientes 

CREATE TABLE Clientes(
id_cliente int PRIMARY KEY,
nombre_cliente VARCHAR2(50),
email_cliente VARCHAR2 (200) UNIQUE,
numero_cliente NUMBER(10)
);
