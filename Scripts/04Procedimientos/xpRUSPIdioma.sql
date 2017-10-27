IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='xpRUSPIdioma')
DROP PROCEDURE xpRUSPIdioma
GO
CREATE PROCEDURE xpRUSPIdioma
@personal	VARCHAR(30)
AS
BEGIN
	DECLARE @Cadena	  VARCHAR(255)
	       
	SET @Cadena=''
	
	SELECT @Cadena=@Cadena+','+cast(Clave AS VARCHAR(10))+'-'+Tipo
	FROM RUSPIdiomaPersonal
	WHERE Personal=@Personal
	
	UPDATE RUSPPersonal SET Idioma = ltrim(STUFF(@Cadena,1,1,''))
	WHERE Personal=@Personal
	RETURN
END