IF EXISTS(SELECT 1 FROM sysobjects WHERE TYPE='fn' AND NAME='fnCURPHijo')
DROP FUNCTION fnCURPHijo
GO
CREATE FUNCTION fnCURPHijo(@personal VARCHAR(30))
RETURNS VARCHAR(100)
AS
BEGIN
	
	DECLARE @Cadena			VARCHAR(255)
	        ,@resultado		VARCHAR(255)
	
	SET @Cadena=''
	
	DECLARE @PersonalHijos TABLE (
			CURP			VARCHAR(40),
			FechaNacimiento	DATETIME	
	)
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijoIMT,p.HijoNacimientoIMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo1IMT,p.HijoNacimiento1IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo2IMT,p.HijoNacimiento2IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo3IMT,p.HijoNacimiento3IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo4IMT,p.HijoNacimiento4IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo5IMT,p.HijoNacimiento5IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo6IMT,p.HijoNacimiento6IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo7IMT,p.HijoNacimiento7IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo8IMT,p.HijoNacimiento8IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo9IMT,p.HijoNacimiento9IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo10IMT,p.HijoNacimiento10IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo11IMT,p.HijoNacimiento11IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	INSERT INTO @PersonalHijos(CURP,FechaNacimiento)
	SELECT p.CURPHijo12IMT,p.HijoNacimiento12IMT
	FROM Personal AS p
	WHERE p.Personal=@personal
	
	
	SELECT @Cadena=@Cadena+','+CURP 
	FROM @PersonalHijos
	WHERE CURP IS NOT NULL
	ORDER BY FechaNacimiento DESC
	
	SELECT @resultado = IIF(@Cadena IS NULL,'NULL',RTRIM(ltrim(STUFF(@Cadena,1,1,''))))
	
	RETURN @resultado
END


--SELECT ISNULL(dbo.fnCURPHijo(p.Personal),'NULL')
--FROM Personal AS p