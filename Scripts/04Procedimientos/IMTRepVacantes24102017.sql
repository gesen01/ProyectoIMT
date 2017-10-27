IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='IMTRepVacantes')
DROP PROCEDURE IMTRepVacantes
GO
CREATE PROCEDURE dbo.IMTRepVacantes
AS
BEGIN

DECLARE @PlazaOcupadas AS TABLE(Descripcion VARCHAR(255) NULL, Cuantos INT NULL)

DECLARE @PlazaAutorizadas AS TABLE(Descripcion VARCHAR(255) NULL, Autorizadas INT NULL, Ocupada INT NULL, Vacante INT NULL)

DECLARE @PlazaVacantes AS TABLE(Descripcion VARCHAR(255) NULL, Cuantos INT NULL)


INSERT INTO @PlazaAutorizadas(Descripcion, Autorizadas)
SELECT Descripcion, COUNT(Plaza)
FROM Plaza
GROUP BY Descripcion


INSERT INTO @PlazaOcupadas
SELECT p.Descripcion, COUNT(p2.Personal)
FROM Plaza p
LEFT JOIN Personal p2 ON p2.Plaza=p.Plaza
WHERE p2.Estatus='ALTA'
GROUP BY Descripcion

--SELECT Descripcion, COUNT(Descripcion)
--FROM Plaza
--JOIN Personal ON Plaza.Plaza=Personal.Plaza
--GROUP BY Descripcion

INSERT INTO @PlazaVacantes
SELECT p.Descripcion,COUNT(p.Plaza)
FROM Plaza AS p
LEFT JOIN Personal AS p2 ON p2.Plaza = p.Plaza
WHERE p2.Personal IS  NULL
GROUP BY p.Descripcion

--SELECT Descripcion, COUNT(Descripcion)
--FROM Plaza
--LEFT JOIN Personal ON Plaza.Plaza=Personal.Plaza
--WHERE Personal.Personal IS NULL
--GROUP BY Descripcion


UPDATE a SET a.Ocupada = b.Cuantos
FROM @PlazaAutorizadas a
JOIN  @PlazaOcupadas b ON a.Descripcion =  b.Descripcion


UPDATE a SET a.Vacante = b.Cuantos
FROM @PlazaAutorizadas a
JOIN  @PlazaVacantes b ON a.Descripcion =  b.Descripcion



SELECT Descripcion,Autorizadas
	  ,ISNULL(Ocupada,0) AS 'Ocupada'
	  ,isnull(Vacante,0) AS 'Vacante' FROM @PlazaAutorizadas


END

--EXEC IMTRepVacantes

