USE IMT3500
GO
IF EXISTS(SELECT 1 FROM sysobjects WHERE TYPE='p' AND NAME='fixRepRUSP')
DROP PROCEDURE fixRepRUSP
GO
CREATE PROCEDURE fixRepRUSP
AS
BEGIN


DECLARE @Dato AS TABLE (Orden INT NULL, Dato VARCHAR(MAX) NULL)

SET CONCAT_NULL_YIELDS_NULL OFF

INSERT INTO @Dato(Orden, Dato)
SELECT a.Plaza,
LTRIM(RTRIM(b.RUSPRamo))+'|'+
LTRIM(RTRIM(b.RUSPUnidad))+'|'+
LTRIM(RTRIM(a.Plaza))+'|'+
LTRIM(RTRIM(b.PuestoReporta))+'|'+
LTRIM(RTRIM(b.Descripcion))+'|'+
LTRIM(RTRIM(b.RUSPCodigoPresup))+'|'+
LTRIM(RTRIM(b.RUSPNivelTabular))+'|'+
LTRIM(RTRIM(b.RUSPZonaEconomica))+'|'+
LTRIM(RTRIM(CAST(ISNULL(c.SDI, b.RUSPSueldoBase) AS CHAR)))+'|'+
ISNULL(NULLIF(LTRIM(RTRIM(CAST(b.RUSPCompensacion AS CHAR))), '0.00'),'0')+'|'+
LTRIM(RTRIM(b.RUSPCatDelegacion))+'|'+
LTRIM(RTRIM(b.RUSPPais))+'|'+
LTRIM(RTRIM(b.RUSPTipoPlaza))+'|'+
LTRIM(RTRIM(b.RUSPTipoPuesto))+'|'+
LTRIM(RTRIM(b.RUSPTipoFuncion))+'|'+
LTRIM(RTRIM(b.RUSPTipoPersonal))+'|'+
LTRIM(RTRIM(b.RUSPCodigoRHNet))+'|'+
LTRIM(RTRIM(CASE WHEN c.Personal IS NULL THEN '2' ELSE '1' END))+'|'+

RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.Registro2)),'') AS CHAR(30)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.Registro)),'') AS CHAR(30)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.Nombre)),'') AS CHAR(30)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.ApellidoPaterno)),'') AS CHAR(30)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.ApellidoMaterno)),'') AS CHAR(30)), 'NULL'))+'|'+
ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, c.FechaNacimiento,103))),'NULL')+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPCatSexo)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPEntFederativaN)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPPaisNacimiento)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.email)),'') AS CHAR(50)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPInstitutoSS)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.Registro3)),'') AS CHAR(30)), 'NULL'))+'|'+
'NULL'+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPTipoDiscapacidad)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(c.NivelPuestoIMT)),'') AS CHAR(20)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPTipoContratacion)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(LEFT(d.RUSPDebeDeclararPatrimonio,1))),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPDecPatrimonial)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(CAST(c.Credencial AS INT))),'') AS CHAR(4)), 'NULL'))+'|'+

ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, ISNULL(c.FechaIMT, c.FechaAlta),103))),'NULL')+'|'+  --Ingreso a la APF
ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, c.IMTFechaSPC,103))),'NULL')+'|'+  --Ingreso al SPC
ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, c.FechaIngresoIMT,103))),'NULL')+'|'+  --Ingreso a la Institución
ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, dbo.fnFechaSinHora(ISNULL(c.UltimaModificacion, c.FechaAntiguedad)),103))),'NULL')+'|'+  --Alta al Último Puesto
ISNULL(LTRIM(RTRIM(CONVERT(VARCHAR, c.IMTFechaDeclaraPatrimonio,103))),'NULL')+'|'+  --Obligacion de Presentar Declaracion Patrimonial

RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPArea)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPNRespContPub)),'') AS CHAR(15)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPNRespConcLicPer)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPNRespEnaBienes)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPNRespAsignaEmision)),'') AS CHAR(4)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(b.RUSPCatInmuebles)),'') AS CHAR(15)), 'NULL'))+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.RUSPTipoServidorPublico)),'') AS CHAR(5)), 'NULL'))+'|'+
dbo.fnNivelAcademicoRUSP(c.Personal)+'|'+
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.Conyugal)),'') AS CHAR(5)), 'NULL'))+'|'+ 
RTRIM(ISNULL(CAST(NULLIF(LTRIM(RTRIM(d.Idioma)),'') AS CHAR(5)), 'NULL'))+'|'+ 
ISNULL(dbo.fnCURPHijo(c.Personal),'NULL') AS Dato
FROM Plaza a
JOIN Puesto b ON a.Puesto=b.Puesto
LEFT JOIN Personal c ON a.Plaza=c.Plaza AND c.Estatus='ALTA'
LEFT JOIN RUSPPersonal d ON c.Personal=d.Personal
ORDER BY CAST(a.Plaza AS INT)

SELECT Dato FROM @Dato
ORDER BY Orden

END