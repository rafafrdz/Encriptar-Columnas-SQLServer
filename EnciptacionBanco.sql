--==========================================================================
--== Encriptar Columnas
--== Trabajo realizado por: Rafael Fernández Ortiz
--== Fecha: 10/12/2018
--== Documentacion: 
--== https://docs.microsoft.com/es-es/sql/relational-databases/security/encryption/encryption-hierarchy?view=sql-server-2017
--==========================================================================

--==========================================================================
-- Crearemos la tabla donde trataremos este tema.
--
-- En esta tabla simularemos el negocio de un banco, donde un cliente se registra,
-- hace su consulta de su cuenta bancaria, ingresa y retira dinero, y traspasa a otra cuenta
-- Se debe entender que una consulta normal no pueda mostrar dichos datos confidenciales
-- por ello que encriptaremos las columnas correspondientes a dichos datos sensibles
--==========================================================================

use EncriptarColumnas;
go
--drop table Banco;
create table Banco(
	DNI int primary key clustered,
	Nombre nvarchar(50) not null,
	PrimerApellido nvarchar(50) not null,
	SegundoApellido nvarchar(50) not null,
	NumTarjeta varbinary(max) not null,
	Clave varbinary(max) not null,
	Dinero varbinary(max) not null,
);
select * from Banco;

--==========================================================================
-- Debemos comprobar primero que tengamos creado SQL Server Services Master Key
-- Esto en teoria deberiamos tenerlo al haber creado la instancia
--==========================================================================

SELECT * 
	FROM master.sys.symmetric_keys AS SK 
		WHERE SK.name = '##MS_ServiceMasterKey##'
--==========================================================================
-- Crearemos la clave maestra, el certificado y el registro de claves simetricas
--==========================================================================

create master key encryption by password = 'masterkey'; 
create certificate CertificadoBanco with subject = 'certificado';

create symmetric key ClaveSimetrica
	with algorithm = AES_256
	encryption by certificate CertificadoBanco;

--==========================================================================
-- Creamos Trigger para añadir clientes en el banco
-- Observación: Como hemos hecho un drop de la tabla, el trigger se ha eliminado,
--				por tanto, se ha de crear de nuevo.
--==========================================================================

create trigger trClienteNuevo
	on Banco
	instead of insert
as
begin
	open symmetric key ClaveSimetrica
	decryption by certificate CertificadoBanco
	declare @clave nvarchar(100);
	select @clave = Clave from inserted;
	insert into Banco
		select
			DNI,
			Nombre,
			PrimerApellido,
			SegundoApellido,
			EncryptByKey (KEY_GUID('ClaveSimetrica'), NumTarjeta),
			EncryptByKey (KEY_GUID('ClaveSimetrica'), convert(varbinary(max),Clave)),
			EncryptByKey (KEY_GUID('ClaveSimetrica'), Convert(varbinary(max),Dinero))
		from inserted;
	close symmetric key ClaveSimetrica;
end

--==========================================================================
-- Añadimos valores a la tabla
--==========================================================================

select * from Banco;
insert into Banco
	values
	(771,'Rafael','Fernandez','Ortiz',0123,0000,174.22),
	(999, 'William John', 'Mac', 'Ilriach', 0456, 1111, 7.64);
select * from Banco;

--==========================================================================
-- Procedimiento para consultar el dinero en la cuenta (Clave numerica)
--==========================================================================

create procedure uspConsultaDinero
	@DNI int,
	@clave int
as begin
	open symmetric key ClaveSimetrica
	decryption by certificate CertificadoBanco
	select	Nombre,
			PrimerApellido,
			SegundoApellido,
			convert(numeric(7,2),DecryptByKey(Dinero)) as 'Dinero'
			from Banco
				where DNI = @dni and convert(int, DecryptByKey (Clave)) = @clave;
	close symmetric key ClaveSimetrica;
end

exec uspConsultaDinero 771, 0000; -- Consulta cuenta de Rafa
exec uspConsultaDinero 999, 1111; -- Consulta cuenta de Willi

--==========================================================================
--== Procedimiento para ingresar dinero en una cuenta
--== Se necesita el numero de tarjeta al que vaya a ingresar, la clave de la cuenta y la cantidad a ingresar
--==========================================================================

create procedure uspIngresa
	@NumTarjeta int,
	@Clave int,
	@Cantidad numeric(7,2)
as begin
	open symmetric key ClaveSimetrica
	decryption by certificate CertificadoBanco
	--conversion-----------------------------
	declare @DineroActualizado varbinary(max);
	select @DineroActualizado = convert(varbinary(max), @Cantidad + convert(numeric(7,2),DecryptByKey(Dinero)))
		from Banco
		where convert(int, DecryptByKey (NumTarjeta)) = @NumTarjeta and convert(int, DecryptByKey (Clave)) = @Clave;
	------------------------------------------
	update Banco
			set Dinero = EncryptByKey (KEY_GUID('ClaveSimetrica'), @DineroActualizado)
			from Banco
				where convert(int, DecryptByKey (NumTarjeta)) = @NumTarjeta and convert(int, DecryptByKey (Clave)) = @Clave;
	close symmetric key ClaveSimetrica;
end

exec uspConsultaDinero 771, 0000;
exec uspIngresa 0123,0000,1100; -- Llega final de mes y Rafa cobra el sueldo de M2C :D
exec uspConsultaDinero 771 ,0000;

--==========================================================================
--== Procedimiento para sacar dinero en una cuenta
--== Se necesita el numero de tarjeta al que vaya a sacar, la clave de la cuenta y la cantidad a retirar
--==========================================================================
create procedure uspSaca
	@NumTarjeta int,
	@Clave int,
	@Cantidad numeric(7,2)
as begin
	select @Cantidad = - @Cantidad
	exec uspIngresa @NumTarjeta, @Clave, @Cantidad;
end

exec uspConsultaDinero 771, 0000;
exec uspSaca 0123,0000,450; -- Rafa tiene que pagar el alquiler del piso :(
exec uspConsultaDinero 771 ,0000;

--==========================================================================
--== Procedimiento para traspasar dinero de una cuenta a otra cuenta
--== Se necesita el numero de tarjeta origen, la clave de dicha cuenta, la cantidad a traspasar y el numero de tarjeta origen del ingreso
--==========================================================================

create procedure uspTraspaso
	@NumTarjetaOrigen int,
	@ClaveOrigen int,
	@Cantidad numeric(7,2),
	@NumTarjetaDestino int
as begin
	
	open symmetric key ClaveSimetrica
	decryption by certificate CertificadoBanco

	declare @ClaveDestino int;
	select @ClaveDestino = convert(int, DecryptByKey (Clave))
		from Banco
		where convert(int, DecryptByKey (NumTarjeta)) = @NumTarjetaDestino;
	
	close symmetric key ClaveSimetrica;

	exec uspSaca @NumTarjetaOrigen, @ClaveOrigen, @Cantidad;
	exec uspIngresa @NumTarjetaDestino, @ClaveDestino, @Cantidad;
end

-- Willi quiere ir a un concierto, pero le falta dinero
exec uspConsultaDinero 771, 0000;
exec uspConsultaDinero 999, 1111;
exec uspTraspaso 0123,0000, 20, 0456; -- Rafa le pasa 20 euros a a cuenta de Willi
exec uspConsultaDinero 771, 0000;
exec uspConsultaDinero 999, 1111;
