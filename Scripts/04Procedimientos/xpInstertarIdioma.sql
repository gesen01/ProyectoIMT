IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='xpInstertarIdioma')
DROP PROCEDURE xpInstertarIdioma
GO
CREATE PROCEDURE xpInstertarIdioma
@Personal		VARCHAR(30),
@estacion		INT
AS
BEGIN
	
	DELETE FROM RUSPIdiomaPersonal WHERE Personal=@Personal
	
	INSERT INTO RUSPIdiomaPersonal(Personal,Clave)
	SELECT @Personal
		   ,Clave
	FROM ListaSt AS ls
	WHERE ls.Estacion=@estacion
	
	RETURN
END