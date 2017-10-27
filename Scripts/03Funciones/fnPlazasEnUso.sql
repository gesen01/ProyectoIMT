IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='fn' AND NAME='fnPlazasEnUso')
DROP FUNCTION fnPlazasEnUso
GO
CREATE FUNCTION fnPlazasEnUso(@Plaza VARCHAR(20),@Personal VARCHAR(30))
RETURNS INT
AS
BEGIN
	
	DECLARE @EnUso	INT
	
	SELECT @EnUso = COUNT(p2.Personal)
	FROM Plaza p
	LEFT JOIN Personal p2 ON p2.Plaza=p.Plaza
	WHERE p2.Estatus='ALTA'
	AND p2.Personal=@Personal
	AND p.Plaza=@Plaza
	GROUP BY Descripcion

	RETURN @EnUso
END