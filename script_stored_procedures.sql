USE CobranzasSalud

CREATE PROCEDURE sp_crear_recibo (

	@observaciones AS VARCHAR(200),
	-- Items del recibo
	@FacturasList AS dbo.DetalleRecibosFacturasList READONLY
) AS
BEGIN 

	-- Total del recibo
	DECLARE @Total AS DECIMAL(10,2);
	SELECT @Total = SUM([Subtotal]) FROM @FacturasList;
	DECLARE @ReciboId AS INT;
	
	SET NOCOUNT ON
	INSERT INTO [Recibos](
		Total,
		Fecha,
		ANULADO,
		Observaciones
	) VALUES (
		@Total,
		GETDATE(),
		0,
		@observaciones
	)

	SELECT @ReciboId = SCOPE_IDENTITY()

	INSERT INTO Facturas_Recibos
	SELECT @ReciboId, Id, FormaPagoId, NroChequeTransf, NroReciboTes, BancoId, Subtotal from @FacturasList
END

-------

CREATE PROCEDURE sp_crear_nota_credito(
	@Observaciones AS VARCHAR(200),
	@FacturasList  AS DetalleNotaFacturasList READONLY
)
AS
BEGIN
	--Monto total de la nota
	DECLARE @Total AS DECIMAL(10,2);
	SELECT @Total = SUM([Monto]) FROM @FacturasList;
	DECLARE @NotaCreditoId AS INT;

	SET NOCOUNT ON;

	INSERT INTO [NotasCredito](
		Total,
		Observaciones
	) VALUES(
		@Total,
		@Observaciones
	)
	SELECT @NotaCreditoId = SCOPE_IDENTITY()

	INSERT INTO Facturas_NotasCredito
	SELECT @NotaCreditoId, [Id], Monto from @FacturasList
END
GO

------

CREATE PROCEDURE sp_crear_nota_debito(
	@Observaciones AS VARCHAR(200),
	@FacturasList  AS DetalleNotaFacturasList READONLY
)
AS
BEGIN
	--Monto total de la nota
	DECLARE @Total AS DECIMAL(10,2);
	SELECT @Total = SUM([Monto]) FROM @FacturasList;
	DECLARE @NotaDebitoId AS INT;

	SET NOCOUNT ON;

	INSERT INTO [NotasDebito](
		Total,
		Observaciones
	) VALUES(
		@Total,
		@Observaciones
	)
	SELECT @NotaDebitoId = SCOPE_IDENTITY()

	INSERT INTO Facturas_NotasDebito
	SELECT @NotaDebitoId, [Id], Monto from @FacturasList
END
GO

CREATE PROCEDURE [sp_crear_factura](
	@ObraSocialId AS INT,
	@PuntoVentaId AS INT,
	@Importe AS DECIMAL(10,2),
	@Observaciones AS VARCHAR(MAX)
)
AS
BEGIN
	INSERT INTO [Facturas](
		ObraSocialId,
		PuntoVentaId,
		Importe,
		Observaciones
	) VALUES
	(
		@ObraSocialId,
		@PuntoVentaId,
		@Importe,
		@Observaciones
	)
END
GO


CREATE PROCEDURE [sp_anular_factura](
	@FacturaId AS INT,
	@Observaciones AS VARCHAR(180)
)
AS
BEGIN

	--- El Monto a especificar en la nota de credito
	DECLARE @Monto as DECIMAL(10,2)
	Select @Monto = (SELECT [Importe]  FROM [Facturas] WHERE [Id] = @FacturaId)


	IF (@Monto != NULL )
		DECLARE @Factura AS DetalleNotaFacturasList

		INSERT INTO @Factura VALUES (@FacturaId,@Monto)

		UPDATE [Facturas]
		SET [EstadoId] = 4
		WHERE [Id] = @FacturaId
		exec sp_crear_nota_credito @Observaciones , @Factura;
END
GO

CREATE PROCEDURE [sp_select_factura] 
	@FacturaId AS INT
AS
BEGIN
	SELECT *
	FROM [vw_facturas] A
	WHERE A.Id = @FacturaId
END
GO
---------

CREATE PROCEDURE [sp_select_facturas] 
AS
BEGIN
	SELECT  * FROM [vw_facturas] A
	ORDER BY A.FechaEmision DESC
END
GO

--------

CREATE PROCEDURE [sp_select_facturas_obra_social]
	@ObraSocialId INT
AS
BEGIN 
	SELECT * FROM [vw_facturas] A
	WHERE ObraSocialId = @ObraSocialId
	ORDER BY A.FechaEmision DESC
END
GO

---------

CREATE PROCEDURE [sp_select_facturas_puntos_venta]
	@PuntoVentaId INT
AS
BEGIN
	SELECT * FROM [vw_facturas]
	WHERE PuntoVentaId= @PuntoVentaId
	ORDER BY FechaEmision DESC
END
GO
---------

CREATE PROCEDURE [sp_select_puntos_venta]
AS 
BEGIN 
	SELECT * FROM [vw_puntos_venta_all] A
	ORDER BY A.Punto ASC
END 
GO

--------

CREATE PROCEDURE [sp_select_bancos]
AS 
BEGIN
	SELECT * FROM [BancosAll] A 
	ORDER BY A.Nombre ASC
END 
GO

--------

CREATE PROCEDURE [sp_select_formas_pago]
AS 
BEGIN 
	SELECT * FROM [FormasPago] A
	ORDER BY A.Forma
END
GO

--------

CREATE PROCEDURE [sp_select_contactos_obra_social]
	@ObraSocialId INT
AS
BEGIN
	SELECT  *	
	FROM [vw_contactos]
	WHERE obrasocial = @ObraSocialId
END
GO

--------------

CREATE PROCEDURE [sp_select_notas_credito]
AS
BEGIN 
	SELECT * 
	FROM vw_notas_credito
	ORDER BY FechaEmision DESC
END
GO

---------

CREATE PROCEDURE [sp_select_notas_credito_obra_social]
	@ObraSocialId INT
AS
BEGIN
	SELECT *
	FROM vw_notas_credito A
	WHERE A.ObraSocialId = @ObraSocialId
END
GO

-------------

CREATE PROCEDURE [sp_select_facturas_estado]
	@EstadoId INT
AS 
BEGIN
	SELECT * 
	FROM vw_facturas A
	WHERE A.EstadoId = @EstadoId
	ORDER BY FechaEmision DESC
END
GO

-------------

CREATE PROCEDURE [sp_select_gestiones_obra_social]
	@ObraSocialId AS INT
AS
BEGIN
	SELECT * 
	FROM [vw_gestiones] A
	WHERE A.ObraSocialId = @ObraSocialId
	ORDER BY A.FechaContacto DESC
END
GO

------------

CREATE PROCEDURE [sp_select_recibos]
AS
BEGIN
	SELECT *
	FROM [vw_recibos]
	ORDER BY [Fecha] DESC
END
GO

---------

CREATE PROCEDURE [sp_select_recibos_obra_social]
	@ObraSocialId AS INT
AS
BEGIN
	SELECT * from [vw_recibos] 
	WHERE ObraSocialId = @ObraSocialId
	ORDER BY Fecha DESC
END
GO

------------

CREATE PROCEDURE [sp_select_facturas_entre_fechas]
	  @Desde AS DATE,
	  @Hasta AS DATE
AS
BEGIN
	SELECT * FROM [vw_facturas]
	WHERE FechaEmision BETWEEN @Desde AND @Hasta
	ORDER BY FechaEmision DESC
END
GO

CREATE PROCEDURE [sp_delete_gestion]
	@GestionId INT
AS
BEGIN
	DELETE FROM Gestiones
	WHERE Id = @GestionId
END
GO

CREATE PROCEDURE [sp_select_gestion]
	@GestionId INT
AS
BEGIN
	SELECT * FROM Gestiones
	WHERE Id = @GestionId
END
GO

CREATE PROCEDURE [sp_select_nota_credito_detalle]
	@NotaCreditoId AS INT
AS
	BEGIN
	SELECT * FROM
	[vw_notas_credito_detalle]
	WHERE NotaCreditoId = @NotaCreditoId
	ORDER BY FechaFactura DESC
	END
GO


CREATE PROCEDURE [sp_select_notas_credito_factura]
	@FacturaId AS INT
AS
	BEGIN
	SELECT * FROM
	[vw_notas_credito_detalle]
	WHERE @FacturaId = @FacturaId
	ORDER BY NotaCreditoId DESC
	END
GO


CREATE PROCEDURE [sp_select_gestiones_usuario]
	@UsuarioId AS INT
AS 
	BEGIN
	SELECT * FROM
	vw_gestiones A
	WHERE A.UsuarioId = @UsuarioId
END
GO

CREATE PROCEDURE [sp_insert_usuario]
	@PuntoVentaId INT,
	@Nombre VARCHAR(120),
	@Apellido VARCHAR(120),
	@Email VARCHAR(200),
	@PasswordHash Varchar(MAX)
AS
	BEGIN
		INSERT INTO [Usuarios] 
		(
			PuntoVentaId,
			Nombre,
			Apellido,
			Email,
			PasswordHash
		)
		VALUES(
			@PuntoVentaId,
			@Nombre,
			@Apellido,
			@Email,
			@PasswordHash
		)
	END
GO

CREATE PROCEDURE [sp_verificar_usuario_existente]
	@Email VARCHAR (200)
	AS
		BEGIN
			SELECT [Email] FROM Usuarios WHERE  LOWER(Email) =LOWER(@Email)
		END
	GO

CREATE PROCEDURE [sp_delete_usuario]
	@UsuarioId INT
	AS
		BEGIN
			DELETE FROM [Usuarios] WHERE Id = @UsuarioId
		END
	GO

CREATE PROCEDURE [sp_select_usuario]
	@Email VARCHAR(200),
	@PasswordHash VARCHAR(max)
	AS
		BEGIN
			SELECT 
				A.Id,
				A.PuntoVentaId,
				B.Nombre,
				A.Nombre AS [NombreUsuario],
				A.Apellido,
				A.Email
				FROM Usuarios A
				INNER JOIN PuntosVenta B
				ON B.Id = A.PuntoVentaId
			WHERE LOWER(A.Email) = LOWER(@Email) 
			AND A.PasswordHash = @PasswordHash
		END
	GO