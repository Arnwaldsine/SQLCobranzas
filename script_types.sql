USE [CobranzasSalud]
GO

CREATE TYPE [DetalleRecibosFacturasList] AS TABLE(
	[Id] INT NULL,
	[FormaPagoId] INT NULL,
	[NroChequeTransf] VARCHAR(100) NULL,
	[NroReciboTes] VARCHAR(100) NULL,
	[BancoId] INT NULL,
	[Subtotal] DECIMAL(10, 2) NULL
)
GO

CREATE TYPE [DetalleNotaFacturasList] AS TABLE(
	[Id] INT NULL,
	[Monto] DECIMAL(10,2) NULL
)
GO

