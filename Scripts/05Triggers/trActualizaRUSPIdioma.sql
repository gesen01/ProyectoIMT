IF EXISTS(SELECT 1 FROM sysobjects WHERE TYPE='tr' AND NAME='trActualizaRUSPIdioma')
DROP TRIGGER trActualizaRUSPIdioma
GO
CREATE TRIGGER trActualizaRUSPIdioma
ON RUSPIdiomaPersonal FOR UPDATE
AS
BEGIN
	DECLARE @Personal VARCHAR(30)
	       ,@Cadena	  VARCHAR(255)
	       
	SET @Cadena=''
	
	SELECT @Personal = Personal FROM INSERTED
	
	SELECT @Cadena=@Cadena+','+cast(Clave AS VARCHAR(10))+'-'+Tipo
	FROM RUSPIdiomaPersonal
	WHERE Personal=@Personal
	
	UPDATE RUSPPersonal SET Idioma = ltrim(STUFF(@Cadena,1,1,''))
	WHERE Personal=@Personal
	
	RETURN
END


UPDATE RUSPIdiomaPersonal
SET
  Personal = 'AUTG',
  Clave = 107,
  Tipo = 'M'
WHERE
  Personal = 'AUTG' AND Clave = 107

UPDATE RUSPIdiomaPersonal
SET
  Personal = 'AUTG',
  Clave = 110,
  Tipo = 'A'
WHERE
  Personal = 'AUTG' AND Clave = 110


SELECT *
FROM RUSPIdiomaPersonal AS rp


SELECT Idioma,*
FROM RUSPPersonal AS r
WHERE r.Personal='AOOA'