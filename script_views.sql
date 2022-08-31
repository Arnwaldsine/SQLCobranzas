ALTER VIEW [vw_facturas]
AS 

SELECT 
		A.Id,
		A.NRO,
		B.Nombre AS [ObraSocial],
		A.ObraSocialId,
		A.PuntoVentaId,
		D.Nombre AS [PuntoVenta],
		FORMAT(A.FechaEmision,'dd/MM/yyyy') AS [FechaEmision],
		COALESCE(FORMAT(A.FechaUltimoPago,'dd/MM/yyyy'),'Nunca Pago') AS [FechaUltimoPago],
		A.Importe,
		A.Cobrado,
		A.Debe,
		A.EstadoId,
		C.Estado,
		A.Observaciones,
		(SELECT SUM(F.Debe) FROM [Facturas] F WHERE ObraSocialId = A.Id) AS TotalDeuda
	FROM 
		[Facturas] A
	INNER JOIN
		[ObrasSociales] B
	ON
		B.Id  = A.ObraSocialId
	INNER JOIN 
		[Estados] C
	ON
		C.Id = A.EstadoId
	INNER JOIN
		[PuntosVenta] D
	ON
		D.Id = A.PuntoVentaId
 GO

 CREATE VIEW [vw_bancos]
 AS 
	SELECT
	Id,
	Nombre
	FROM [Bancos] A
GO

CREATE VIEW [vw_puntos_venta]
AS
	SELECT 
	[Id],
	CONCAT([Nro],' | ',[Nombre]) AS Punto
	FROM [PuntosVenta] A
GO

CREATE VIEW [vw_formas_pago]
AS 
	SELECT * FROM [FormasPago]
GO


CREATE VIEW [vw_tipos_prestador]
AS 
	SELECT * FROM [TiposPrestador]
GO


CREATE VIEW [vw_estados]
AS 
	SELECT * FROM [Estados]
GO

CREATE VIEW [vw_respuestas]
AS 
	SELECT * FROM [Respuestas]
GO

CREATE VIEW [vw_contactos]
AS
	SELECT 
	A.ObraSocialId,
	A.Id,
	B.Nombre AS [ObraSocial],
	A.Contacto AS [Contacto],
	A.Horario AS [Horario],
	A.Mail AS [Mail],
	A.Telefono AS [Telefono],
	A.Sector AS [Sector],
	A.Observaciones
	FROM Contactos A
	INNER JOIN ObrasSociales B
	ON B.Id = A.Id
GO

CREATE VIEW [vw_notas_credito]
AS
	SELECT 
	A.ObraSocialId,
	A.Id,
	A.Nro,
	A.Total,
	FORMAT(A.FechaEmision,'dd/MM/yyyy') AS [FechaEmision],
	B.Nombre AS [ObraSocial]
	FROM [NotasCredito] A
	INNER JOIN
	[ObrasSociales] B
	ON B.Id = A.ObraSocialId
GO

alter VIEW [vw_gestiones]
AS
	SELECT
	A.UsuarioId,
	E.Nombre+' '+E.Apellido AS [Usuario],
	A.ObraSocialId,
	B.Nombre AS [ObraSocial],
	FORMAT(A.FechaContacto,'dd/MM/yyyy') AS [FechaContacto],
	A.RespuestaId,
	D.Respuesta,
	FORMAT(A.FechaProxContacto,'dd/MM/yyyy') AS [FechaProxContacto],
	A.ContactoId,
	C.Contacto,
	A.Observaciones
	FROM [Gestiones] A
	INNER JOIN [ObrasSociales] B
	ON B.Id = A.ObraSocialId
	INNER JOIN [Contactos] C
	ON C.Id = A.ContactoId
	INNER JOIN [Respuestas] D
	ON D.Id = A.RespuestaId
	INNER JOIN [Usuarios] E
	ON E.Id = A.UsuarioId
GO

CREATE VIEW [vw_deudas]
AS
	SELECT 
		B.Id,
		B.Nombre,
		SUM(A.Debe) AS [TotalDeuda],
		SUM(A.Cobrado) AS [TotalCobrado]
	FROM [Facturas] A
	INNER JOIN [ObrasSociales] B
	ON B.Id = A.ObraSocialId
	GROUP BY B.Nombre, B.Id
GO

CREATE VIEW [vw_recibos]
AS
	SELECT 
	A.Id,
	A.Nro,
	A.ObraSocialId,
	B.Nombre,
	FORMAT(A.Fecha,'dd/MM/yyyy')  AS [Fecha],
	A.Total,
	A.Observaciones
	FROM [Recibos] A
	INNER JOIN [ObrasSociales] B
	ON B.Id = A.ObraSocialId
GO


CREATE VIEW [vw_notas_credito_detalle]
AS 
	SELECT 
	A.NotaCreditoId,
	A.FacturaId,
	B.NRO,
	A.Monto,
	B.FechaEmision AS [FechaFactura]
	FROM [Facturas_NotasCredito] A
	INNER JOIN [Facturas] B
	ON B.Id = A.FacturaId
	INNER JOIN [NotasCredito] C
	ON C.Id = A.FacturaId
	
GO

