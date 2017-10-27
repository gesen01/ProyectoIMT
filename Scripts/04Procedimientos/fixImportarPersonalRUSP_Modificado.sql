IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='fixImportarPersonalRUSP' AND NAME='fixImportarPersonalRUSP')
DROP PROCEDURE fixImportarPersonalRUSP
GO
CREATE PROCEDURE fixImportarPersonalRUSP
@Personal	VARCHAR(30)
AS 
BEGIN

DECLARE @RUSPPersonal AS TABLE(
Personal CHAR (10) NULL,
RUSPCatSexo CHAR (3) NULL,
RUSPEntFederativaN CHAR (3) NULL,
RUSPPaisNacimiento CHAR (3) NULL,
RUSPInstitutoSS CHAR (3) NULL,
RUSPTipoDiscapacidad CHAR (3) NULL,
RUSPNRespEnaBienes CHAR (3) NULL,
RUSPNRespAsignaEmision CHAR (3) NULL,
RUSPCatInmuebles CHAR (15) NULL,
RUSPTipoServidorPublico CHAR (5) NULL,
RUSPNivelEscolaridad CHAR (3) NULL,
RUSPTipoContratacion CHAR (3) NULL,
RUSPDebeDeclararPatrimonio CHAR (2) NULL,
RUSPDecPatrimonial CHAR (3) NULL,
RUSPArea CHAR (3) NULL,
RUSPNRespContPub CHAR (3) NULL,
RUSPNRespConcLicPer CHAR (3) NULL,
Conyugal	INT	NULL,
Idioma		VARCHAR(100)	NULL)

INSERT INTO @RUSPPersonal(Personal,	RUSPCatSexo,	RUSPEntFederativaN,	RUSPPaisNacimiento,	RUSPInstitutoSS,	RUSPTipoDiscapacidad,	RUSPTipoContratacion,	RUSPDebeDeclararPatrimonio,	RUSPDecPatrimonial,	RUSPArea,	RUSPNRespContPub,	RUSPNRespConcLicPer,	RUSPNRespEnaBienes,	RUSPNRespAsignaEmision,	RUSPCatInmuebles,	RUSPTipoServidorPublico,	RUSPNivelEscolaridad,Conyugal,Idioma)
SELECT Personal,	RUSPCatSexo,	RUSPEntFederativaN,	RUSPPaisNacimiento,	RUSPInstitutoSS,	RUSPTipoDiscapacidad,	RUSPTipoContratacion,	RUSPDebeDeclararPatrimonio,	RUSPDecPatrimonial,	RUSPArea,	RUSPNRespContPub,	RUSPNRespConcLicPer,	RUSPNRespEnaBienes,	RUSPNRespAsignaEmision,	RUSPCatInmuebles,	RUSPTipoServidorPublico,	RUSPNivelEscolaridad, Conyugal, Idioma 
FROM RUSPPersonal 
WHERE Personal=@Personal

--DELETE RUSPPersonal

--INSERT INTO RUSPPersonal(Personal)
--SELECT Personal FROM Personal WHERE Estatus='ALTA'

UPDATE a SET
a.RUSPCatSexo=b.RUSPCatSexo,
a.RUSPEntFederativaN=b.RUSPEntFederativaN,
a.RUSPPaisNacimiento=b.RUSPPaisNacimiento,
a.RUSPInstitutoSS=b.RUSPInstitutoSS,
a.RUSPTipoDiscapacidad=b.RUSPTipoDiscapacidad,
a.RUSPTipoContratacion=b.RUSPTipoContratacion,
a.RUSPDebeDeclararPatrimonio=b.RUSPDebeDeclararPatrimonio,
a.RUSPDecPatrimonial=b.RUSPDecPatrimonial,
a.RUSPArea=b.RUSPArea,
a.RUSPNRespContPub=b.RUSPNRespContPub,
a.RUSPNRespConcLicPer=b.RUSPNRespConcLicPer,
a.RUSPNRespEnaBienes=b.RUSPNRespEnaBienes,
a.RUSPNRespAsignaEmision=b.RUSPNRespAsignaEmision,
a.RUSPCatInmuebles=b.RUSPCatInmuebles,
a.RUSPTipoServidorPublico=b.RUSPTipoServidorPublico,
a.RUSPNivelEscolaridad=b.RUSPNivelEscolaridad
FROM RUSPPersonal a
JOIN @RUSPPersonal b ON a.Personal=b.Personal
WHERE a.Personal=@Personal

END