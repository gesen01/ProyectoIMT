USE IMT3500
GO
IF EXISTS(SELECT 1 FROM sysobjects WHERE TYPE='fn' AND NAME='fnNivelAcademicoRUSP')
DROP FUNCTION fnNivelAcademicoRUSP
GO
CREATE FUNCTION fnNivelAcademicoRUSP(@personal VARCHAR(30))
RETURNS CHAR(5)
AS
BEGIN
	DECLARE @UltimaFecha	DATETIME
	       ,@NivelAcademico CHAR(5)
	   
	
	SELECT @UltimaFecha =MAX(kai.FechaTermino)
	FROM KardexAcademicosIMT AS kai
	WHERE kai.Personal=@personal

	SELECT @NivelAcademico=IIF(RTRIM(LTRIM(kai.NivelAcademicoIMT)) IS NULL,'NULL',RTRIM(LTRIM(kai.NivelAcademicoIMT)))
	FROM KardexAcademicosIMT AS kai
	WHERE kai.FechaTermino=@UltimaFecha
	
	RETURN @NivelAcademico
END

--SELECT ISNULL(dbo.fnNivelAcademicoRUSP(P.Personal),'NULL')
--FROM Personal AS p


