--1. CREAR UNA BASE DE DATOS
CREATE DATABASE PruebaTecnica;

USE PruebaTecnica;

--2. CREAR LAS TABLAS
CREATE TABLE Clientes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(100) NOT NULL,
	Correo VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Productos (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(100) NOT NULL,
	Precio DECIMAL(10,2),
	Cantidad INT
);

CREATE TABLE Ordenes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ClienteId INT,
	Fecha DATE,
	CONSTRAINT FK_ClienteID FOREIGN KEY (ClienteId) REFERENCES Clientes(Id)
);

CREATE TABLE DetalleOrden (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	OrdenId INT,
	ProductoId INT,
	Cantidad INT,
	PrecioUnitario DECIMAL(10,2)
	CONSTRAINT FK_OrdenID FOREIGN KEY (OrdenId) REFERENCES Ordenes(Id),
	CONSTRAINT FK_ProductoID FOREIGN KEY (ProductoId) REFERENCES Productos(Id)
);

--3. OPERACIONES CRUD
-- INSERTAR UN PRODUCTO
DECLARE @NombreProducto VARCHAR(100);
DECLARE @Precio DECIMAL(10,2);
DECLARE @Cantidad INT;
SET @NombreProducto = 'CocaCola';
SET @Precio = 18.50;
SET @Cantidad = 100;

INSERT INTO Productos (Nombre, Precio, Cantidad)
VALUES (@NombreProducto, @Precio, @Cantidad);

--MODIFICAR EL PRECIO DE UN PRODUCTO
DECLARE @ProductoID INT;
DECLARE @NuevoPrecio DECIMAL(10,2);
SET @ProductoID = 1;
SET @NuevoPrecio = 19.20;
UPDATE Productos SET Precio = @NuevoPrecio WHERE Id = @ProductoID;

--ELIMINAR UN PRODUCTO
DELETE FROM Productos WHERE Id = @ProductoID;

--SELECCIONAR TODOS LOS PRODUCTOS DE LA TABLA PRODUCTOS
SELECT * FROM Productos;

--4. PROCEDIMIENTOS ALMACENADOS
GO
--4.1.
CREATE PROCEDURE sp_ObtenerProductoDetalles 
	@ProductoID INT 
AS
BEGIN
    -- Seleccionar los detalles del producto
    SELECT 
        Id,
        Nombre,
        Precio,
        Cantidad,
        (Precio * Cantidad) AS ValorTotalInventario
    FROM Productos
    WHERE Id = @ProductoID;
END;
GO
--EXEC sp_ObtenerProductoDetalles @ProductoID = 2;
--GO

--4.2
CREATE PROCEDURE sp_ObtenerOrdenesPorCliente 
	@ClienteID INT	
AS
BEGIN
    -- Seleccionar todas las órdenes del cliente especificado
    SELECT 
        o.Id AS OrdenID,
        o.Fecha AS FechaOrden,
        SUM(d.Cantidad * d.PrecioUnitario) AS TotalOrden
    FROM Ordenes o
    INNER JOIN DetalleOrden d ON o.Id = d.OrdenId
    WHERE o.ClienteId = @ClienteID
    GROUP BY o.Id, o.Fecha
    ORDER BY o.Id;
END;
GO
--EXEC sp_ObtenerOrdenesPorCliente @ClienteID = 1;
--GO

--4.3
CREATE PROCEDURE sp_ObtenerDetalleOrdenCompleto 
	@OrdenID INT 
AS
BEGIN
    -- Obtener los detalles de la orden, información del cliente y el total de la orden
    SELECT 
        o.Id AS OrdenID,
        o.Fecha AS FechaOrden,
        c.Id AS ClienteID,
        c.Nombre AS NombreCliente,
        c.Correo AS CorreoCliente,
        p.Id AS ProductoID,
        p.Nombre AS NombreProducto,
        d.Cantidad,
        d.PrecioUnitario,
        (d.Cantidad * d.PrecioUnitario) AS TotalProducto
    FROM Ordenes o
    INNER JOIN Clientes c ON o.ClienteId = c.Id
    INNER JOIN DetalleOrden d ON o.Id = d.OrdenId
    INNER JOIN Productos p ON d.ProductoId = p.Id
    WHERE o.Id = @OrdenID
    ORDER BY p.Nombre;

    -- Obtener el total de la orden
    SELECT 
        o.Id AS OrdenID,
        SUM(d.Cantidad * d.PrecioUnitario) AS TotalOrden
    FROM Ordenes o
    INNER JOIN DetalleOrden d ON o.Id = d.OrdenId
    WHERE o.Id = @OrdenID
    GROUP BY o.Id;
END;
GO
--EXEC sp_ObtenerDetalleOrdenCompleto @OrdenID = 1;
--GO

--4.4
CREATE PROCEDURE sp_ObtenerTotalVentas
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    -- Obtener el total de ventas de todos los productos en el periodo dado
    SELECT 
        SUM(d.Cantidad * d.PrecioUnitario) AS TotalVentas
    FROM DetalleOrden d
    INNER JOIN Ordenes o ON d.OrdenId = o.Id
    WHERE o.Fecha BETWEEN @FechaInicio AND @FechaFin;
END;
GO
--EXEC sp_ObtenerTotalVentas @FechaInicio = '2024-01-01', @FechaFin = '2024-12-31';
--GO

--5. TRIGGER
CREATE TABLE Historial (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID INT,
    CantidadAnterior INT,
    CantidadNueva INT,
    FechaCambio DATETIME DEFAULT GETDATE(),
    Usuario NVARCHAR(100) -- Opcional, para registrar el usuario que hizo el cambio
);
GO

CREATE TRIGGER trg_ActualizarCantidad
ON Productos
AFTER UPDATE
AS
BEGIN
    -- Insertar registros en la tabla Historial para cada cambio en la cantidad de productos
    INSERT INTO Historial (ProductoID, CantidadAnterior, CantidadNueva)
    SELECT 
        d.Id AS ProductoID,
        d.Cantidad AS CantidadAnterior,
        i.Cantidad AS CantidadNueva
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id
    WHERE i.Cantidad <> d.Cantidad;
END;
GO

--6. FUNCTION
CREATE FUNCTION fn_ObtenerPrecioPromedio()
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @PrecioPromedio DECIMAL(10, 2);

    -- Calcular el precio promedio de todos los productos
    SELECT @PrecioPromedio = AVG(Precio)
    FROM Productos;

    RETURN @PrecioPromedio;
END;
GO

--7. RELACION MASTER DETALLE Y CONSULTAS
--7.1
DECLARE @ClienteID INT = 1;
DECLARE @FechaOrden DATE = GETDATE();
DECLARE @OrdenID INT;

INSERT INTO Ordenes (ClienteId, Fecha)
VALUES (@ClienteID, @FechaOrden);

SET @OrdenID = SCOPE_IDENTITY();

INSERT INTO DetalleOrden (OrdenId, ProductoId, Cantidad, PrecioUnitario)
VALUES
    (@OrdenID, 1, 5, 20.00),
    (@OrdenID, 1, 3, 15.00);

SELECT 
    o.Id AS OrdenID,
    o.ClienteId,
    o.Fecha,
    d.ProductoId,
    d.Cantidad,
    d.PrecioUnitario
FROM Ordenes o
INNER JOIN DetalleOrden d ON o.Id = d.OrdenId
WHERE o.Id = @OrdenID;
GO

--7.2
SELECT 
    o.Id AS OrdenID,
    o.Fecha AS FechaOrden,
    c.Id AS ClienteID,
    c.Nombre AS NombreCliente,
    p.Id AS ProductoID,
    p.Nombre AS NombreProducto,
    p.Precio AS PrecioProducto,
    d.Cantidad AS CantidadProducto,
    d.PrecioUnitario AS PrecioUnitario,
    (d.Cantidad * d.PrecioUnitario) AS TotalProducto
FROM 
    Ordenes o
INNER JOIN 
    Clientes c ON o.ClienteId = c.Id
INNER JOIN 
    DetalleOrden d ON o.Id = d.OrdenId
INNER JOIN 
    Productos p ON d.ProductoId = p.Id
ORDER BY 
    o.Id, p.Id;
GO

--7.3
SELECT 
    o.Id AS OrdenID,
    o.Fecha AS FechaOrden,
    c.Id AS ClienteID,
    c.Nombre AS NombreCliente,
    p.Id AS ProductoID,
    p.Nombre AS NombreProducto,
    p.Precio AS PrecioProducto,
    d.Cantidad AS CantidadProducto,
    d.PrecioUnitario AS PrecioUnitario,
    (d.Cantidad * d.PrecioUnitario) AS TotalProducto
FROM 
    Ordenes o
LEFT JOIN 
    Clientes c ON o.ClienteId = c.Id
LEFT JOIN 
    DetalleOrden d ON o.Id = d.OrdenId
LEFT JOIN 
    Productos p ON d.ProductoId = p.Id
ORDER BY 
    o.Id, p.Id;
GO

--7.4
SELECT 
    p.Id AS ProductoID,
    p.Nombre AS NombreProducto,
    p.Precio AS PrecioProducto,
    o.Id AS OrdenID,
    o.Fecha AS FechaOrden,
    c.Id AS ClienteID,
    c.Nombre AS NombreCliente,
    d.Cantidad AS CantidadProducto,
    d.PrecioUnitario AS PrecioUnitario,
    (d.Cantidad * d.PrecioUnitario) AS TotalProducto
FROM 
    Productos p
LEFT JOIN 
    DetalleOrden d ON p.Id = d.ProductoId
LEFT JOIN 
    Ordenes o ON d.OrdenId = o.Id
LEFT JOIN 
    Clientes c ON o.ClienteId = c.Id
ORDER BY 
    p.Id, o.Id;
GO

--7.5
SELECT 
    o.Id AS OrdenID,
    o.Fecha AS FechaOrden,
    c.Id AS ClienteID,
    c.Nombre AS NombreCliente,
    c.Correo AS CorreoCliente,
    p.Id AS ProductoID,
    p.Nombre AS NombreProducto,
    p.Precio AS PrecioProducto,
    d.Cantidad AS CantidadProducto,
    d.PrecioUnitario AS PrecioUnitario,
    (d.Cantidad * d.PrecioUnitario) AS TotalProducto
FROM 
    Ordenes o
INNER JOIN 
    Clientes c ON o.ClienteId = c.Id
INNER JOIN 
    DetalleOrden d ON o.Id = d.OrdenId
INNER JOIN 
    Productos p ON d.ProductoId = p.Id
ORDER BY 
    o.Id, p.Id;
GO