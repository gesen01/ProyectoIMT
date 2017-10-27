IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='spCFDINominaXMLComplemento')
DROP PROCEDURE spCFDINominaXMLComplemento
GO
CREATE PROC spCFDINominaXMLComplemento  
 @Estacion     int,  
 @ID       int,  
 @Personal     varchar(10),  
 @TotalPercepciones   float,   
 @TotalDeducciones   float,   
 @PercepcionesTotalGravado float,   
 @PercepcionesTotalExcento float,   
 @DeduccionesTotalGravado float,   
 @DeduccionesTotalExcento float,  
 @XMLComplemento    varchar(max) OUTPUT,  
 @XML      varchar(max) OUTPUT,  
 @Ok       int    OUTPUT,   
 @OkRef      varchar(255) OUTPUT  
AS  
BEGIN  
 DECLARE @TotalOtrosPagos                float,  
            @XMLNomina               varchar(max),  
   @XMLEmisor               varchar(max),  
   @EntidadSNCF              varchar(max),  
   @XMLReceptor              varchar(max),  
   @XMLSubContratacion             varchar(max),  
   --------------------            -----------  
   @XMLPercepciones             varchar(max),  
   @XMLPercepcion              varchar(max),  
   @XMLAccionesTitulos             varchar(max),  
   @XMLHorasExtra              varchar(max),  
   @XMLHorasExtraDoble    varchar(max),  
   @XMLHorasExtraTriple   varchar(max),  
   @XMLJubilacion              varchar(max),  
   @XMLSeparacion              varchar(max),  
   --------------------            ------------  
   @XMLDeducciones              varchar(max),  
            @XMLDeduccion              varchar(max),  
            @XMLOtrosPagos                  varchar(max),  
            @XMLOtroPago                    varchar(max),  
            @XMLSubsidioAlEmpleo            varchar(max),  
            @XMLCompensacionSaldosAFavor    varchar(max),  
            @XMLIncapacidad              varchar(max),  
   @XMLRetenciones              varchar(max),  
   @Ano       int,  
   @BanderaJubilación    bit,  
   @TotalUnaExhibicion    float,  
   @TotalParcialidad               float,  
   @TipoContrato     varchar(10),  
   @ClaveSAT      int,  
   @NumSeguridadSocial    varchar(255),  
   @FechaInicioRelLaboral   varchar(255),  
   @Antigüedad      varchar(255),  
   @RiesgoPuesto     varchar(255),  
   @SalarioDiarioIntegrado   varchar(255),  
   @RegistroPatronal    varchar(255),  
   @SaldoAFavor     varchar(255),  
   @RemanenteSalFav    varchar(255),  
   @OrigenRecurso     varchar(255),  
   @MontoRecursoPropio    float,  
   @TotalPercepciones1    float,  
   @NominaEditarFechaPago   bit,  
   @FechaPago      varchar(10),  
   @FechaA       varchar(10),  
   @SubContratacionPorcentajeTiem float,  
   @MontoDiario     float,  
   @UltimoSueldoMensOrd   float,  
   @ClaveSATB      varchar(3),  
   @CfgSubContratacion    bit,  
   @SubContratacionConteo   int,  
   @Ant       int,  
   @FechaIni      datetime,  
   @FechaFin      datetime,  
   @TotalDeduccionesc    varchar(max),  
   @TotalPercepcionc    varchar(max),  
   @Empresa      varchar(5),  
   @UsarTimbrarNomina    bit,  
   @TimbrarCFDIServidor   varchar(100),  
   @Mov       varchar(20)  
  
 -- Se necesita establecer este valor en ON  
 SET CONCAT_NULL_YIELDS_NULL ON  
  
 SELECT @Mov = Mov FROM Nomina WHERE ID = @ID   
  
 SELECT @BanderaJubilación = 0, @ClaveSAT = 0, @Ant = 0  
  
-- ********** Validaciónes **********  
 SELECT @TipoContrato           = CAST(REPLICATE('0',2-LEN(TC.ClaveSAT)) + CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)),  
     @ClaveSAT         = CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) NOT IN ('09','10','99') THEN 1 ELSE 0 END,  
     @NumSeguridadSocial     = CONVERT(varchar(255),ISNULL(RTRIM(A.NumSeguridadSocial),'')),  
     @FechaInicioRelLaboral  = CONVERT(varchar(10), A.FechaInicioRelLaboral, 120),  
     @Antigüedad      = CONVERT(varchar(255), FLOOR(DATEDIFF(DAY, p.FechaAntiguedad, A.FechaFinalPago)/7)),  
     @RiesgoPuesto     = RTRIM(A.RiesgoPuesto),  
     @SalarioDiarioIntegrado = CONVERT(varchar(max), CONVERT(DECIMAL(16,2), A.SalarioDiarioIntegrado)),  
    
     --@SalarioDiarioIntegrado = CONVERT(varchar(max), CONVERT(money, ISNULL((SELECT SUM(ISNULL(NominaD.Importe, 0)) FROM NominaD WHERE NominaD.ID=A.ID AND NominaD.Personal=A.Personal AND NominaD.Movimiento='Estadistica' AND NominaD.Concepto='Salario Diario Integrado'), 0))),  


     @RegistroPatronal    = CONVERT(varchar(255),RTRIM(A.RegistroPatronal)),  
     @FechaIni      = p.FechaAntiguedad,  
     @FechaFin      = A.FechaFinalPago  
   FROM CFDINominaRecibo A                 
   JOIN Personal P ON A.Personal = P.Personal  
   JOIN ContratoTipo TC ON P.TipoContrato = TC.Tipo AND TC.Modulo = 'NOM'  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
  
 SELECT @Empresa = Empresa FROM Nomina WHERE ID = @ID  
 SELECT @UsarTimbrarNomina = UsarTimbrarNomina FROM EmpresaCFD WHERE Empresa = @Empresa  
   
 IF ISNULL(@UsarTimbrarNomina,0) = 1  
  SELECT @TimbrarCFDIServidor = TimbrarCFDIServidor FROM EmpresaCFDNomina WHERE Empresa = @Empresa  
 IF ISNULL(@UsarTimbrarNomina,0) = 0  
  SELECT @TimbrarCFDIServidor = TimbrarCFDIServidor FROM EmpresaCFD WHERE Empresa = @Empresa  
  
 SELECT @Ant = Convert(int,@Antigüedad)  
   
 IF @Ant = 0 /* Formato en Días*/  
    IF @Ant = 0 /* Formato en Días*/  
      BEGIN   
        IF LTRIM(RTRIM(@TimbrarCFDIServidor))='LEVICOM'  
            SELECT @Antigüedad = CONVERT(varchar(255), DATEDIFF(DAY, @FechaIni, @FechaFin)) + 'D'     
        ELSE        
            SELECT @Antigüedad = CONVERT(varchar(255), DATEDIFF(DAY, @FechaIni, @FechaFin)+1) + 'D'  
      END  
  
  
  
 IF @Ant > 0 --AND @Ant <= 52 /* Formato en Semanas*/  
 BEGIN  
     -- IF LTRIM(RTRIM(@TimbrarCFDIServidor)) In ( 'FACTURAINTELIGENTE', 'FEL')   
   BEGIN  
     IF DATEDIFF(DAY, @FechaIni, @FechaFin) % 7 > 5  
          SELECT @Antigüedad = CONVERT(varchar(255), (DATEDIFF(DAY, @FechaIni, @FechaFin)/7)+1) + 'W'  
        ELSE   
          SELECT @Antigüedad = CONVERT(varchar(255), (DATEDIFF(DAY, @FechaIni, @FechaFin)/7)) + 'W'  
      END/*  
   ELSE   
   BEGIN  
     IF DATEDIFF(DAY, @FechaIni, @FechaFin) % 7 > 1  
          SELECT @Antigüedad = CONVERT(varchar(255), (DATEDIFF(DAY, @FechaIni, @FechaFin)/7)+1) + 'W'  
        ELSE   
          SELECT @Antigüedad = CONVERT(varchar(255), (DATEDIFF(DAY, @FechaIni, @FechaFin)/7)) + 'W'  
      END  
   */  
 END  
/*  
  
 IF @Ant > 52 /* Formato en Año Mes Día*/  
  SELECT @Antigüedad = dbo.fnAntiguedadAMD(@FechaIni,@FechaFin, 0)   
  */  
 IF @Antigüedad LIKE '%0M%'  
  SELECT @Antigüedad = CONVERT(varchar(255), FLOOR(DATEDIFF(DAY, @FechaIni, @FechaFin)/7)) + 'W'  
  
 --IF LTRIM(RTRIM(@TimbrarCFDIServidor)) = 'FEL'  
 -- SELECT @Antigüedad = CONVERT(varchar(255), DATEDIFF(DAY, @FechaIni, @FechaFin)/7) + 'W'  
 -- SELECT @Antigüedad = dbo.fnAntiguedadAMD(@FechaIni,@FechaFin, 1)   
  
 --IF EXISTS (SELECT * FROM CFDINOMINARECIBO WHERE ID = @ID AND Personal = @Personal AND OKREF LIKE '%Antigüedad%')  
 -- SELECT @Antigüedad = dbo.fnAntiguedadAMD(@FechaIni,@FechaFin, 1)   
  
 IF ISNULL(@RegistroPatronal,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar el Registro Patronal por el Tipo de Contrato Configurado. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar el Registro Patronal por el Tipo de Contrato Configurado. Personal: ' + @Personal   
  RETURN  
 END  
      
 IF ISNULL(@NumSeguridadSocial,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar el Número de Seguro Social, ya que Existe Registro Patronal. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar el Número de Seguro Social, ya que Existe Registro Patronal. Personal: ' + @Personal  
  RETURN  
 END  
  
 IF ISNULL(@FechaInicioRelLaboral,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar la Fecha de Inicio Relacion Laboral, ya que Existe Registro Patronal. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar la Fecha de Inicio Relacion Laboral, ya que Existe Registro Patronal. Personal: ' + @Personal  
  RETURN  
 END  
  
 IF ISNULL(@Antigüedad,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar la Antiguedad del Personal, ya que Existe Registro Patronal. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar la Antiguedad del Personal, ya que Existe Registro Patronal. Personal: ' + @Personal  
  RETURN  
 END  
  
 IF ISNULL(@RiesgoPuesto,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar el Riesgo de Trabajo, ya que Existe Registro Patronal. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar el Riesgo de Trabajo, ya que Existe Registro Patronal. Personal: ' + @Personal  
  RETURN  
 END  
  
 IF ISNULL(@SalarioDiarioIntegrado,'') = '' AND @ClaveSAT = 1  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Configurar el Salario Diario Integrago, ya que Existe Registro Patronal. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Configurar el Salario Diario Integrago, ya que Existe Registro Patronal. Personal: ' + @Personal  
  RETURN  
 END  
  
 IF ISNULL(@TipoContrato,'') = ''  
 BEGIN  
  SELECT @Ok = 10060, @OkRef = 'Falta Mapear el Tipo Contrato de Acuerdo al Catálogo SAT. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'Falta Mapear el Tipo Contrato de Acuerdo al Catálogo SAT. Personal: ' + @Personal  
  RETURN  
 END  
    
    SELECT @Ano = Cantidad    
      FROM NominaD n  
      JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto   
     WHERE n.ID = @ID   
    AND n.Personal = @Personal          
    AND ISNULL(AñoSaldoFavor,0) = 1  
  
  
    SELECT @SaldoAFavor      = NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgSaldoAFavor,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))),'0.00'),          
           @RemanenteSalFav  = NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgRemanenteSalFav,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))),'0.00')  
      FROM CFDINominaPercepcionDeduccion OtroPago  
      JOIN CFDINominaConcepto C ON OtroPago.Concepto = C.Concepto  
     WHERE OtroPago.ID = @ID  
       AND OtroPago.Personal = @Personal  
       AND OtroPago.Movimiento = 'Estadisticos'  
  
 IF ISNULL(@SaldoAFavor,'') = ''   
  SELECT @Ano = NULL  
   
 IF ISNULL(@SaldoAFavor,'') <> '' AND ISNULL(@RemanenteSalFav,'') = ''  
    BEGIN  
  SELECT @Ok = 10060, @OkRef = 'El importe Remanente Saldo a Favor es obligatorio si tienes el importe Saldo a Favor. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
  SELECT 'El importe Remanente Saldo a Favor es obligatorio si tienes el importe Saldo a Favor. Personal: ' + @Personal   
  RETURN  
 END  
  
 SELECT @OrigenRecurso      = D.OrigenRecurso,  
     @MontoRecursoPropio = ISNULL(C.MontoRecursoPropio,0)  
   FROM CFDINominaRecibo A  
   JOIN Nomina B ON A.ID = B.ID  
   JOIN EmpresaCFD C ON B.Empresa = C.Empresa  
      LEFT JOIN CFDINominaTipoOrigenRecurso D ON C.OrigenRecurso = D.Descripcion  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
  
 SELECT @TotalPercepciones1 = ISNULL(Nomina.TotalPercepciones, 0)  
   FROM CFDINominaRecibo Nomina  
   JOIN Nomina B ON Nomina.ID = B.ID  
   JOIN CFDINominaMov C ON B.Mov = C.Mov  
   LEFT JOIN CFDINominaSATTipoNomina D ON C.TipoNomina = D.Descripcion  
  WHERE Nomina.ID = @ID  
    AND Nomina.Personal = @Personal  
  
 SELECT @TotalOtrosPagos = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0.00) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0.00) END), 0.00)  
      FROM NominaD n  
      JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto   
     WHERE n.ID = @ID 
    AND n.Personal = @Personal          
    AND ISNULL(CfgOtroPago,0) = 1  
  
 IF @OrigenRecurso = 'IM'  
    BEGIN  
  IF @MontoRecursoPropio >= (@TotalPercepciones1 + @TotalOtrosPagos)  
  BEGIN  
   SELECT @Ok = 10060, @OkRef = 'El importe Monto Recurso Propio debe ser menor a la suma del Importe Total Persepciones con Importe Otros Pagos. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
   SELECT 'El importe Monto Recurso Propio debe ser menor a la suma del Importe Total Persepciones con Importe Otros Pagos. Personal: ' + @Personal   
   RETURN  
  END  
 END   
  
 SELECT @NominaEditarFechaPago = ISNULL(E.NominaEditarFechaPago,0),  
     @FechaPago     = ISNULL(CONVERT(varchar(10), NM.FechaPago, 120),''),  
     @FechaA      = CONVERT(varchar(10), B.FechaA, 120)  
   FROM CFDINominaRecibo Nomina  
   JOIN Nomina B ON Nomina.ID = B.ID  
   JOIN EmpresaCFD E ON B.Empresa = E.Empresa  
   LEFT JOIN CFDINominaDatosMov NM ON B.ID = NM.ID     
  WHERE Nomina.ID = @ID  
    AND Nomina.Personal = @Personal  
  
     IF ISNULL(@NominaEditarFechaPago,0) = 0  
       SELECT @NominaEditarFechaPago = EditarFechaPago FROM CFDINominaMov WHERE Mov = @Mov  
  
 IF @NominaEditarFechaPago = 1  
 BEGIN  
  IF @FechaPago = ''  
  BEGIN   
   SELECT @Ok = 10060, @OkRef = 'Es necesario configurar la Fecha de Pago al timbrar, ya que tienes activada esta configuración. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
   SELECT 'Es necesario configurar la Fecha de Pago al timbrar, ya que tienes activada esta configuración. Personal: ' + @Personal   
   RETURN  
  END  
 END  
  
    DECLARE @SubContratacionTabla TABLE  
    (  
        RFC                varchar(255),  
        PorcentajeTiempo   float  
    )  
  
 INSERT @SubContratacionTabla (RFC, PorcentajeTiempo)  
    SELECT P.SubContratacionRfcLabora AS 'RfcLabora',  
     ROUND(P.SubContratacionPorcentajeTiem,3) AS 'PorcentajeTiempo'  
   FROM Personal P   
  WHERE P.Personal = @Personal  
       AND ISNULL(P.SubContratacionRfcLabora,'') <> ''  
       AND ISNULL(P.SubContratacionPorcentajeTiem,0) <> 0  
  
    INSERT @SubContratacionTabla (RFC, PorcentajeTiempo)  
 SELECT P.SubContratacionRfcLabora2 AS 'RfcLabora',  
     ROUND(P.SubContratacionPorcentajeTiem2,3) AS 'PorcentajeTiempo'  
   FROM Personal P   
  WHERE P.Personal = @Personal  
       AND ISNULL(P.SubContratacionRfcLabora2,'') <> ''  
       AND ISNULL(P.SubContratacionPorcentajeTiem2,0) <> 0  
  
    INSERT @SubContratacionTabla (RFC, PorcentajeTiempo)  
 SELECT P.SubContratacionRfcLabora3 AS 'RfcLabora',  
     ROUND(P.SubContratacionPorcentajeTiem3,3) AS 'PorcentajeTiempo'  
   FROM Personal P  
  WHERE P.Personal = @Personal  
       AND ISNULL(P.SubContratacionRfcLabora3,'') <> ''  
       AND ISNULL(P.SubContratacionPorcentajeTiem3,0) <> 0  
  
  SELECT @SubContratacionPorcentajeTiem = SUM(PorcentajeTiempo)   
    FROM @SubContratacionTabla  
  
  IF ISNULL(@SubContratacionPorcentajeTiem,0) <> 0  
  BEGIN   
  IF @SubContratacionPorcentajeTiem < 100  
  BEGIN   
   SELECT @Ok = 10060, @OkRef = 'La Suma de tu porcentaje para la Subcontratación no es igual a 100. Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
   SELECT 'La Suma de tu porcentaje para la Subcontratación no es igual a 100. Personal: ' + @Personal   
   RETURN  
  END  
 END  
/*  
 SELECT @CfgSubContratacion = CfgSubContratacion  
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto D ON A.Concepto = D.Concepto  
      JOIN NOMINAD N ON D.Concepto = N.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
       AND ISNULL(D.CfgSubContratacion,0) = 1  
     GROUP BY CfgSubContratacion  
  
 SELECT @SubContratacionConteo = COUNT(*)   
   FROM @SubContratacionTabla  
   */  
   --  IF @CfgSubContratacion  = 1 AND @SubContratacionConteo = 0  
   --  BEGIN  
   --SELECT @Ok = 10060, @OkRef = 'Tienes configurado tu check de SubContratacion, algunos de estos datos no esta (RFC o Pordentaje). Personal: ' + @Personal FROM Personal WHERE Personal = @Personal  
   --SELECT 'Tienes configurado tu check de SubContratacion, algunos de estos datos no esta (RFC o Pordentaje): ' + @Personal   
   --RETURN  
   --  END  
  
    SELECT @TotalDeduccionesc = CONVERT(varchar(max), SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT NOT IN ('2') THEN ISNULL(A.ImporteGravado,0) + ISNULL(A.ImporteExcento,0) ELSE 0.00 END)) + SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT IN ('2') AND ISN
ULL(ImporteExcento,0) + ISNULL(ImporteGravado,0) <> 0 THEN ISNULL(A.ImporteGravado,0) + ISNULL(A.ImporteExcento,0) ELSE 0.00 END)))   
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND A.Movimiento = 'Deduccion'   
  
    SELECT @TotalPercepcionc = CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.Movimiento = 'Percepcion' THEN ISNULL(A.ImporteGravado,0.00) ELSE 0.00 END)) + SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.Movimiento = 'Percepcion' THEN ISNULL(A.ImporteE
xcento,0.00) ELSE 0.00 END)))  
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND A.Movimiento = 'Percepcion'  
  
 -- ********** Nomina **********  
 SELECT @XMLNomina = (   
 SELECT --'http://www.sat.gob.mx/nomina12' 'xmlns:nomina',  
     --'http://www.w3.org/2001/XMLSchema-instance' 'xmlns:xsi',  
     --'http://www.sat.gob.mx/nomina http://www.sat.gob.mx/sitio_internet/cfd/nomina/nomina12.xsd' 'xsi:schemaLocation',  
     '1.2' 'Version',  
     D.Clave 'TipoNomina',    
     CASE WHEN (ISNULL(E.NominaEditarFechaPago,0) = 1) OR (ISNULL(c.EditarFechaPago,0) = 1) THEN CONVERT(varchar(10),  NM.FechaPago, 120) ELSE CONVERT(varchar(10), B.FechaA, 120) END 'FechaPago',  
     CONVERT(varchar(10), Nomina.FechaInicialPago, 120) 'FechaInicialPago',  
     CONVERT(varchar(10), Nomina.FechaFinalPago, 120) 'FechaFinalPago',       
     CONVERT(varchar(max), CASE WHEN (Nomina.NumDiasPagados = 0 OR Nomina.NumDiasPagados < 0) THEN CONVERT(DECIMAL(10,3),1) ELSE CONVERT(DECIMAL(10,3),Nomina.NumDiasPagados) END) 'NumDiasPagados',  
     @TotalPercepcionc /*CONVERT(varchar(max), CONVERT(DECIMAL(16,2), CASE WHEN Nomina.TotalPercepciones = 0 THEN NULL ELSE ISNULL(Nomina.TotalPercepciones, NULL) END ))*/ 'TotalPercepciones',           
     @TotalDeduccionesc /* CONVERT(varchar(max), CONVERT(DECIMAL(16,2), CASE WHEN Nomina.TotalDeducciones = 0 THEN NULL ELSE ISNULL(Nomina.TotalDeducciones, NULL) END ))*/  'TotalDeducciones',  
     CONVERT(varchar(max),  CONVERT(decimal(16,2),CASE WHEN @TotalOtrosPagos = 0 THEN NULL ELSE ISNULL(@TotalOtrosPagos, NULL) END )) 'TotalOtrosPagos'  
   FROM CFDINominaRecibo Nomina  
   JOIN Nomina B ON Nomina.ID = B.ID  
   JOIN CFDINominaMov C ON B.Mov = C.Mov  
   JOIN EmpresaCFD E ON B.Empresa = E.Empresa  
   LEFT JOIN CFDINominaDatosMov NM ON B.ID = NM.ID and NM.Estacion = @Estacion    
   LEFT JOIN CFDINominaSATTipoNomina D ON C.TipoNomina = D.Descripcion  
  WHERE Nomina.ID = @ID  
    AND Nomina.Personal = @Personal  
  GROUP BY D.Clave , CASE WHEN (ISNULL(E.NominaEditarFechaPago,0) = 1) OR (ISNULL(c.EditarFechaPago,0) = 1) THEN CONVERT(varchar(10), NM.FechaPago, 120) ELSE CONVERT(varchar(10), B.FechaA, 120) END,  
     CONVERT(varchar(10), Nomina.FechaInicialPago, 120), CONVERT(varchar(10), Nomina.FechaFinalPago, 120),       
     CONVERT(varchar(max), CASE WHEN (Nomina.NumDiasPagados = 0 OR Nomina.NumDiasPagados < 0) THEN CONVERT(DECIMAL(10,3),1) ELSE CONVERT(DECIMAL(10,3),Nomina.NumDiasPagados) END)--,  
     --CONVERT(varchar(max), CONVERT(DECIMAL(16,2), CASE WHEN Nomina.TotalPercepciones = 0 THEN NULL ELSE ISNULL(Nomina.TotalPercepciones, NULL) END )),  
     --CONVERT(varchar(max), CONVERT(DECIMAL(16,2), CASE WHEN Nomina.TotalDeducciones = 0 THEN NULL ELSE ISNULL(Nomina.TotalDeducciones, NULL) END ))   
   FOR XML RAW('Nomina')  
 )  
 SELECT @XMLNomina = REPLACE(REPLACE(@XMLNomina, '/>', '>'), '<Nomina', '<nomina12:Nomina')  
  
 -- ********** EntidadSNCF **********   
 SELECT @EntidadSNCF = (  
 SELECT D.OrigenRecurso AS 'OrigenRecurso',  
     CASE WHEN D.OrigenRecurso = 'IM' THEN  
     CONVERT(varchar(max), CONVERT(DECIMAL(16,2), C.MontoRecursoPropio))  
     ELSE NULL END AS 'MontoRecursoPropio'  
   FROM CFDINominaRecibo A  
   JOIN Nomina B ON A.ID = B.ID  
   JOIN EmpresaCFD C ON B.Empresa = C.Empresa  
   LEFT JOIN CFDINominaTipoOrigenRecurso D ON C.OrigenRecurso = D.Descripcion  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
   FOR XML RAW('EntidadSNCF')  
   )   
  
 IF @EntidadSNCF = '<EntidadSNCF/>'  
  SELECT @EntidadSNCF = NULL  
  
 -- ********** Emisor **********   
 SELECT @XMLEmisor = (  
 SELECT CASE WHEN LEN(C.RFC) = 12 THEN NULL ELSE ISNULL(REPLACE(UPPER(RTRIM(C.RepresentanteCURP)),'Ñ','X'),'') END 'Curp',  
     CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) IN ('09','10','99') THEN NULL ELSE RTRIM(A.RegistroPatronal) END 'RegistroPatronal',  
     CASE WHEN ISNULL(@EntidadSNCF,'') = '' THEN NULL ELSE ISNULL(C.RFC,'') END 'RfcPatronOrigen',  
     CONVERT(XML, @EntidadSNCF)  
   FROM CFDINominaRecibo A  
   JOIN Nomina B ON A.ID = B.ID  
   JOIN Empresa C ON B.Empresa = C.Empresa  
   JOIN Personal P ON A.Personal = P.Personal  
   JOIN ContratoTipo TC ON P.TipoContrato = TC.Tipo AND TC.Modulo = 'NOM'     
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
   FOR XML RAW('Emisor')  
   )   
   
 SELECT @XMLEmisor = REPLACE(@XMLEmisor, '<EntidadSNCF', '<nomina12:EntidadSNCF')  
 SELECT @XMLEmisor = REPLACE(@XMLEmisor, '<Emisor', '<nomina12:Emisor')  
 SELECT @XMLEmisor = REPLACE(@XMLEmisor, '/EntidadSNCF>', '/nomina12:EntidadSNCF>')  
 SELECT @XMLEmisor = REPLACE(@XMLEmisor, '</Emisor>', '</nomina12:Emisor>')  
  
 IF @XMLEmisor = '<nomina12:Emisor"/>'  
  SELECT @XMLEmisor = NULL  
  
 -- ********** Receptor **********   
  
 SELECT @ClaveSATB = dbo.fnRellenarCerosIzquierda(CONVERT(int, I.ClaveSAT), 3)  
   FROM CFDINominaRecibo A  
   JOIN CFDINominaInstitucionFin I   
     ON ABS(CONVERT(INT,A.Banco)) = I.ClaveSAT  
     WHERE A.ID = @ID  
    AND A.Personal = @Personal  
  
 SELECT @XMLReceptor = (  
  SELECT REPLACE(UPPER(RTRIM(A.CURP)),'Ñ','X') AS 'Curp',  
      CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) NOT IN ('09','10','99') THEN ISNULL(RTRIM(A.NumSeguridadSocial),'') ELSE NULL END AS 'NumSeguridadSocial',  
      CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) NOT IN ('09','10','99') THEN CONVERT(varchar(10), A.FechaInicioRelLaboral, 120) ELSE NULL END AS 'FechaInicioRelLaboral',                 
      CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) NOT IN ('09','10','99') THEN 'P' + @Antigüedad ELSE NULL END AS 'Antigüedad',  
      CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) AS 'TipoContrato',        
      CASE WHEN ISNULL(P.Sindicato,'') NOT IN ('', '(Confianza)') THEN 'Sí' ELSE 'No' END AS 'Sindicalizado',  
      CASE WHEN SATTipoREgimen.Clave IN ('05', '06','07','08','09','10','11') THEN '' ELSE RTRIM(F.TipoJornada) END AS 'TipoJornada',  
      CAST(REPLICATE('0',2-LEN(A.TipoRegimen))+CAST(A.TipoRegimen AS VARCHAR(2)) AS VARCHAR(2)) AS 'TipoRegimen',  
      A.Personal AS 'NumEmpleado',  
      ISNULL(RTRIM(dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(A.Departamento))), '') AS 'Departamento',        
      ISNULL(RTRIM(dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(A.Puesto))), '') AS 'Puesto',  
      CASE WHEN TC.ClaveSAT NOT IN ('09','10','99') THEN ISNULL(RTRIM(A.RiesgoPuesto), '') ELSE NULL END AS 'RiesgoPuesto',  
      CASE WHEN B2.TipoNomina = 'Nómina Extraordinaria'  
      THEN '99'  
      ELSE CAST(REPLICATE('0',2-LEN(G.PeriodicidadPago))+CAST(G.PeriodicidadPago AS VARCHAR(2)) AS VARCHAR(2))   
      END AS 'PeriodicidadPago',  
      NULLIF(CASE WHEN ISNULL(@ClaveSATB,'') <> '' THEN CASE WHEN LEN(A.CLABE) < 18 THEN @ClaveSATB ELSE NULL END ELSE '0' END, '0') AS 'Banco',  
      NULLIF(CASE WHEN ISNULL(@ClaveSATB,'') <> '' THEN A.CLABE ELSE '' END, '') AS 'CuentaBancaria',  
      CASE WHEN A.SalarioBaseCotApor = '0' THEN NULL ELSE ISNULL(CONVERT(varchar(max), CONVERT(DECIMAL(16,2), ISNULL(A.SalarioBaseCotApor, 0))),NULL) END AS 'SalarioBaseCotApor',  
      --CASE WHEN CAST(REPLICATE('0',2-LEN(TC.ClaveSAT))+CAST(TC.ClaveSAT AS VARCHAR(2)) AS VARCHAR(2)) NOT IN ('09','10','99') THEN ISNULL(CONVERT(varchar(max), CONVERT(DECIMAL(16,2), ISNULL(A.SalarioDiarioIntegrado, 0))),NULL) ELSE NULL END AS 'SalarioDiarioIntegrado',  
    CONVERT(varchar(max), CONVERT(money, ISNULL((SELECT SUM(ISNULL(NominaD.Importe, 0)) FROM NominaD WHERE NominaD.ID=A.ID AND NominaD.Personal=A.Personal AND NominaD.Movimiento='Estadistica' AND NominaD.Concepto='Salario Diario Integrado'), 0)))'SalarioD
iarioIntegrado',   
   E.ClaveEstado AS 'ClaveEntFed'  
    FROM CFDINominaRecibo A  
    JOIN Nomina B ON A.ID = B.ID  
    JOIN CFDINominaMov B2 ON B.Mov = B2.Mov  
    JOIN CFDINominaSATTipoRegimenV12 SATTipoRegimen ON B2.TipoRegimen = SATTipoRegimen.Nombre  
    JOIN NominaPersonal D ON A.ID = D.ID AND A.Personal = D.Personal  
    JOIN Empresa C ON B.Empresa = C.Empresa  
    JOIN Personal P ON A.Personal = P.Personal  
    JOIN Sucursal S ON P.SucursalTrabajo = S.Sucursal  
    JOIN ContratoTipo TC ON P.TipoContrato = TC.Tipo AND TC.Modulo = 'NOM'  
  LEFT JOIN SATEstado E ON S.Estado = E.Descripcion  
  LEFT JOIN Jornada F ON A.TipoJornada = F.Jornada  
  LEFT JOIN PeriodoTipo G ON A.PeriodicidadPago = G.PeriodoTipo  
  LEFT JOIN FormaPago H ON A.FormaPago = H.FormaPago AND H.ClaveSAT = '03'  
  --LEFT JOIN CFDINominaInstitucionFin I ON ABS(CONVERT(INT,A.Banco)) = I.ClaveSAT  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
   FOR XML RAW('Receptor')  
     )  
     
 SELECT @XMLReceptor = REPLACE(@XMLReceptor, '<Receptor', '<nomina12:Receptor')  
   
 -- ********** SubContratacion **********  
 SELECT @XMLSubContratacion = (  
 SELECT RFC AS 'RfcLabora',  
      CONVERT(varchar(max), CONVERT(DECIMAL(16,3), PorcentajeTiempo)) AS 'PorcentajeTiempo'  
   FROM @SubContratacionTabla  
   FOR XML RAW('SubContratacion')  
   )  
   SELECT @XMLSubContratacion = ISNULL(NULLIF(@XMLSubContratacion,'<SubContratacion/>'),'')  
   SELECT @XMLSubContratacion = REPLACE(@XMLSubContratacion, '<SubContratacion', '<nomina12:SubContratacion')  
     
   IF ISNULL(@XMLSubContratacion,'') <> ''  
  BEGIN  
   SELECT @XMLReceptor = REPLACE(@XMLReceptor,'/>', '>')  
   SELECT @XMLReceptor = @XMLReceptor + @XMLSubContratacion + '</nomina12:Receptor>'  
  END   
     
 -- ********** Percepciones **********      
    SELECT @XMLPercepciones = (  
    SELECT CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT NOT IN (/*7,8,17,18,*/'22','23','25','39',/*40,41,42,43,*/'44') /*AND ISNULL(CfgOtroPago,0) = 0*/ THEN ISNULL(A.ImporteGravado,0.00) + ISNULL(A.ImporteExcento,0.00) ELSE NULL EN
D))) AS 'TotalSueldos',  
     CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT IN ('22','23','25') /*AND ISNULL(CfgOtroPago,0) = 0*/ THEN ISNULL(A.ImporteGravado,0.00) + ISNULL(A.ImporteExcento,0.00) ELSE NULL END))) AS 'TotalSeparacionIndemnizacion',  
     CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT IN ('39','44') /*AND ISNULL(CfgOtroPago,0) = 0*/ THEN ISNULL(A.ImporteGravado,0.00) + ISNULL(A.ImporteExcento,0.00) ELSE NULL END))) AS 'TotalJubilacionPensionRetiro',  
     CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.Movimiento = 'Percepcion' THEN ISNULL(A.ImporteGravado,0.00) ELSE '0.00' END))) AS 'TotalGravado',  
     CONVERT(varchar(max),SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.Movimiento = 'Percepcion' THEN ISNULL(A.ImporteExcento,0.00) ELSE '0.00' END))) AS 'TotalExento'  
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND A.Movimiento = 'Percepcion'  
   FOR XML RAW('Percepciones')  
 )  
 SELECT @XMLPercepciones = ISNULL(NULLIF(@XMLPercepciones,'<Percepciones/>'),'')  
 SELECT @XMLPercepciones = REPLACE(@XMLPercepciones, '<Percepciones', '<nomina12:Percepciones')  
  
-- ********** AccionesOTitulos **********  
    SELECT @XMLAccionesTitulos = (  
    SELECT NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgValorMercado,0) = 1 THEN A.Estadisticos ELSE 0 END))),'0.00') AS '@ValorMercado',  
     NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgPrecioAlOtorgarse,0) = 1 THEN A.Estadisticos ELSE 0 END))),'0.00') AS '@PrecioAlOtorgarse'  
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto c ON A.Concepto = c.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND Movimiento = 'Estadisticos'  
   FOR XML PATH('AccionesOTitulos')  
 )  
 SELECT @XMLAccionesTitulos = ISNULL(NULLIF(@XMLAccionesTitulos,'<AccionesOTitulos/>'),'')  
   
 -- ********** Horas Extra **********    
 IF NOT EXISTS(SELECT * FROM CFDINominaHoraExtra WHERE ID = @ID AND Personal = @Personal)  
  SELECT @XMLHorasExtra = ''  
 ELSE  
  BEGIN            
   SELECT @XMLHorasExtra = (    
   SELECT Dias AS '@Dias',   
          CAST(REPLICATE('0',2-LEN(B.TipoHoras))+CAST(B.TipoHoras AS VARCHAR(2)) AS VARCHAR(2)) AS '@TipoHoras',   
       CONVERT(varchar(max), ISNULL(HorasExtra, 0)) AS '@HorasExtra',   
       CONVERT(varchar(max), CONVERT(DECIMAL(16,2), ISNULL(ImportePagado, 0.00))) AS '@ImportePagado'  
     FROM CFDINominaHoraExtra HorasExtra  
     JOIN CFDINominaTipoHorasExtra B ON HorasExtra.tipohoras = B.Descripcion  
    WHERE ID = @ID  
      AND Personal = @Personal  
      AND B.TipoHoras = 3  
   FOR XML PATH('HorasExtra')  
   )  
  END  
    SELECT @XMLHorasExtra = ISNULL(NULLIF(@XMLHorasExtra,'<HorasExtra/>'),'')  
  
 IF NOT EXISTS(SELECT * FROM CFDINominaHoraExtra WHERE ID = @ID AND Personal = @Personal)  
  SELECT @XMLHorasExtra = ''  
 ELSE  
  BEGIN            
   SELECT @XMLHorasExtraDoble = (    
   SELECT Dias AS '@Dias',   
          CAST(REPLICATE('0',2-LEN(B.TipoHoras))+CAST(B.TipoHoras AS VARCHAR(2)) AS VARCHAR(2)) AS '@TipoHoras',   
       CONVERT(varchar(max), ISNULL(HorasExtra, 0)) AS '@HorasExtra',   
       CONVERT(varchar(max), CONVERT(DECIMAL(16,2), ISNULL(ImportePagado, 0.00))) AS '@ImportePagado'  
     FROM CFDINominaHoraExtra HorasExtra  
     JOIN CFDINominaTipoHorasExtra B ON HorasExtra.tipohoras = B.Descripcion  
    WHERE ID = @ID  
      AND Personal = @Personal  
      AND B.TipoHoras = 1  
   FOR XML PATH('HorasExtra')  
   )  
  END  
    SELECT @XMLHorasExtra = ISNULL(NULLIF(@XMLHorasExtra,'<HorasExtra/>'),'')  
  
 IF NOT EXISTS(SELECT * FROM CFDINominaHoraExtra WHERE ID = @ID AND Personal = @Personal)  
  SELECT @XMLHorasExtra = ''  
 ELSE  
  BEGIN            
   SELECT @XMLHorasExtraTriple = (    
   SELECT Dias AS '@Dias',   
          CAST(REPLICATE('0',2-LEN(B.TipoHoras))+CAST(B.TipoHoras AS VARCHAR(2)) AS VARCHAR(2)) AS '@TipoHoras',   
       CONVERT(varchar(max), ISNULL(HorasExtra, 0)) AS '@HorasExtra',   
       CONVERT(varchar(max), CONVERT(DECIMAL(16,2), ISNULL(ImportePagado, 0.00))) AS '@ImportePagado'  
     FROM CFDINominaHoraExtra HorasExtra  
     JOIN CFDINominaTipoHorasExtra B ON HorasExtra.tipohoras = B.Descripcion  
    WHERE ID = @ID  
      AND Personal = @Personal  
      AND B.TipoHoras = 2  
   FOR XML PATH('HorasExtra')  
   )  
  END  
    SELECT @XMLHorasExtra = ISNULL(NULLIF(@XMLHorasExtra,'<HorasExtra/>'),'')  
  
  
  
 -- ********** Percepcion **********  
    SELECT @XMLPercepcion = (  
    SELECT CAST(REPLICATE('0',3-LEN(A.TipoSAT))+CAST(A.TipoSAT AS VARCHAR(3)) AS VARCHAR(3)) AS '@TipoPercepcion',  
     CONVERT(varchar(5), ISNULL(A.ClaveSAT, NULL)) AS '@Clave',  
     CASE WHEN A.TipoSAT = '19' THEN 'Horas extra' ELSE CONVERT(varchar(255), ISNULL(dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(A.Concepto)), NULL)) END AS '@Concepto',  
     CONVERT(varchar(max), CONVERT(DECIMAL(16,2), SUM(ISNULL(A.ImporteGravado, 0.00)))) AS '@ImporteGravado',  
     CONVERT(varchar(max), CONVERT(DECIMAL(16,2), SUM(ISNULL(A.ImporteExcento, 0.00)))) AS '@ImporteExento',  
           CASE WHEN  A.TipoSAT = '45' THEN CONVERT(XML, @XMLAccionesTitulos) ELSE NULL END,  
     CASE WHEN  A.TipoSAT = '19' AND RTRIM(LTRIM(B.CfgTipoHoraExtra)) = 'Simples' THEN CONVERT(XML, @XMLHorasExtra) ELSE NULL END,       
     CASE WHEN  A.TipoSAT = '19' AND RTRIM(LTRIM(B.CfgTipoHoraExtra)) = 'Dobles' THEN CONVERT(XML, @XMLHorasExtraDoble) ELSE NULL END,  
     CASE WHEN  A.TipoSAT = '19' AND RTRIM(LTRIM(B.CfgTipoHoraExtra)) = 'Triples' THEN CONVERT(XML, @XMLHorasExtraTriple) ELSE NULL END  
   FROM CFDINominaPercepcionDeduccion A  
      LEFT JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND Movimiento = 'Percepcion'  
    AND (ISNULL(A.ImporteExcento,0) + ISNULL(A.ImporteGravado,0)) <> 0  
  GROUP BY A.TipoSAT, A.ClaveSAT, A.Concepto, B.CfgTipoHoraExtra  
   FOR XML PATH('Percepcion')  
 )  
  
    SELECT @XMLPercepcion = REPLACE(@XMLPercepcion, '<Percepcion', '<nomina12:Percepcion')  
 SELECT @XMLPercepcion = REPLACE(@XMLPercepcion, '<AccionesOTitulos', '<nomina12:AccionesOTitulos')   
 SELECT @XMLPercepcion = REPLACE(@XMLPercepcion, '<HorasExtra', '<nomina12:HorasExtra')  
 SELECT @XMLPercepcion = REPLACE(@XMLPercepcion, '</Percepcion>','</nomina12:Percepcion>')  
  
 /* Estadistico */  
   IF EXISTS   
      (  
  SELECT 1  
    FROM CFDINominaPercepcionDeduccion A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
     AND A.Movimiento = 'Percepcion'  
     AND ISNULL(CfgPercepcionesExcentas,0) = 1  
     AND  ISNULL(CfgJubilacionPensionRetiro,0) = 1  
    )  
  SELECT @BanderaJubilación = 1  
  
 IF @BanderaJubilación = 1  
 BEGIN  
  SELECT @TotalUnaExhibicion  = NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.CfgTotalUnaExhibicion,0) = 1 THEN A.ImporteGravado + A.ImporteExcento ELSE 0 END))),'0.00'),  
      @TotalParcialidad    = NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.CfgTotalParcialidad,0) = 1 THEN A.ImporteGravado + A.ImporteExcento  ELSE 0 END))),'0.00')  
    FROM CFDINominaPercepcionDeduccion A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
     AND A.TipoSAT IN ('39','44')  
     AND A.Movimiento = 'Percepcion'  
  
  IF ISNULL(@TotalUnaExhibicion,0) <> 0  
  BEGIN  
   SELECT @TotalParcialidad = NULL  
  END  
  
  SELECT @MontoDiario = A.Importe    
    FROM NominaD A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
     AND ISNULL(B.MontoDiario,0) = 1  
     AND ISNULL(CfgPercepcionesGravadas,0) = 0  
     AND ISNULL(CfgPercepcionesExcentas,0) = 0  
  
  
  -- ********** Jubilación Pensión Retiro **********  
  SELECT @XMLJubilacion = (  
  SELECT NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),@TotalUnaExhibicion)),'0.00') AS '@TotalUnaExhibicion',  
      NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),@TotalParcialidad)),'0.00') AS '@TotalParcialidad',  
      NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2), CASE WHEN ISNULL(@TotalUnaExhibicion,0) = 0 THEN @MontoDiario ELSE '0.00' END)),'0.00') AS '@MontoDiario',  
      CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.IngresoAcumulable,0) = 1  /*AND B.TipoSAT IN ('39','44')*/ THEN ISNULL(A.Importe,0.00) ELSE NULL END))) AS '@IngresoAcumulable',  
      CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.IngresoNoAcumulable,0) = 1 /*AND B.TipoSAT IN ('39','44')*/ THEN ISNULL(A.Importe,0.00) ELSE NULL END))) AS '@IngresoNoAcumulable'  
    FROM NominaD A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
    FOR XML PATH('JubilacionPensionRetiro')  
  )  
  
  SELECT @XMLJubilacion = ISNULL(NULLIF(@XMLJubilacion,'<JubilacionPensionRetiro/>'),'')  
  SELECT @XMLJubilacion = REPLACE(@XMLJubilacion, '<JubilacionPensionRetiro', '<nomina12:JubilacionPensionRetiro')   
 END  
  
 -- ********** Separación e Indemnización **********  
 IF @BanderaJubilación <> 1 /* No puede existir en el mismo XML los nodos de SeparacionIndemnizacion y JubilacionPensionRetiro debe ser uno o el otro*/  
 BEGIN  
     SELECT @UltimoSueldoMensOrd = SUM(CASE WHEN ISNULL(B.UltSdoMensOrd,0) = 1 THEN A.Estadisticos ELSE 0 END)  
    FROM CFDINominaPercepcionDeduccion A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal       
     AND A.Movimiento = 'Estadisticos'  
  
  
        IF EXISTS( SELECT a.ID   FROM NominaD A  JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto WHERE A.ID = @ID  AND A.Personal = @Personal AND ISNULL(B.CfgSeparacionIndemnizacion,0) = 1)  
  SELECT @XMLSeparacion = (      
  SELECT NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.CfgSeparacionIndemnizacion,0) = 1 THEN A.Importe ELSE 0 END))),'0.00') AS '@TotalPagado',  
      ISNULL(CONVERT(VARCHAR(max),CONVERT(INT,SUM(CASE WHEN ISNULL(B.CfgNumeroAniosServicio,0) = 1 THEN A.Cantidad ELSE NULL END))),'1')                       AS '@NumAñosServicio',  
      NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2), @UltimoSueldoMensOrd)),'0.00')   AS '@UltimoSueldoMensOrd',  
      CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.IngresoAcumulable,0) = 1 /*AND B.TipoSAT IN ('22','23','25')*/ THEN ISNULL(A.Importe,0.00) ELSE '0.00' END)))   AS '@IngresoAcumulable',  
      CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(B.IngresoNoAcumulable,0) = 1 /*AND B.TipoSAT IN ('22','23','25')*/ THEN ISNULL(A.Importe,0.00) ELSE '0.00' END)))  AS '@IngresoNoAcumulable'    
    FROM NominaD A  
    JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
   WHERE A.ID = @ID  
     AND A.Personal = @Personal  
    FOR XML PATH('SeparacionIndemnizacion')  
  )  
  
  SELECT @XMLSeparacion = ISNULL(NULLIF(@XMLSeparacion,'<SeparacionIndemnizacion/>'),'')  
  SELECT @XMLSeparacion = REPLACE(@XMLSeparacion, '<SeparacionIndemnizacion', '<nomina12:SeparacionIndemnizacion')   
 END  
  
   IF ISNULL(@XMLPercepcion,'') <> '' OR ISNULL(@XMLJubilacion,'') <> '' OR ISNULL(@XMLSeparacion,'') <> ''  
  BEGIN  
   SELECT @XMLPercepciones = REPLACE(@XMLPercepciones,'/>', '>')  
   SELECT @XMLPercepciones = ISNULL(@XMLPercepciones,'') +   
           ISNULL(@XMLPercepcion,'') +           
           ISNULL(@XMLJubilacion,'') +   
           ISNULL(@XMLSeparacion,'') + '</nomina12:Percepciones>'  
  END  
  
 -- ********** Deducciones **********      
    SELECT @XMLDeducciones = (  
    SELECT CONVERT(varchar(max), SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT NOT IN ('2') THEN ISNULL(A.ImporteGravado,0) + ISNULL(A.ImporteExcento,0) ELSE NULL END))) AS 'TotalOtrasDeducciones',  
     CONVERT(varchar(max), SUM(CONVERT(DECIMAL(16,2),CASE WHEN A.TipoSAT IN ('2') AND ISNULL(ImporteExcento,0) + ISNULL(ImporteGravado,0) <> 0 THEN ISNULL(A.ImporteGravado,0) + ISNULL(A.ImporteExcento,0) ELSE NULL END))) AS 'TotalImpuestosRetenidos'  
   FROM CFDINominaPercepcionDeduccion A  
      JOIN CFDINominaConcepto B ON A.Concepto = B.Concepto  
  WHERE A.ID = @ID  
    AND A.Personal = @Personal  
    AND A.Movimiento = 'Deduccion'       
   FOR XML RAW('Deducciones')  
 )  
 SELECT @XMLDeducciones = ISNULL(NULLIF(@XMLDeducciones,'<Deducciones/>'),'')  
 SELECT @XMLDeducciones = REPLACE(@XMLDeducciones, '<Deducciones', '<nomina12:Deducciones')  
  
  -- ********** Deduccion **********  
  IF NOT EXISTS(SELECT * FROM CFDINominaPercepcionDeduccion WHERE ID = @ID AND Personal = @Personal AND Movimiento = 'Deduccion')  
    SELECT @XMLDeduccion = ''  
  ELSE  
  BEGIN          
    SELECT @XMLDeduccion =  (  
    SELECT dbo.fnRellenarCerosIzquierda(ISNULL(TipoSAT, ''), 3) AS '@TipoDeduccion',   
           ClaveSAT AS '@Clave',   
           CASE WHEN Deduccion.TipoSAT = '6' THEN 'Descuento por incapacidad' ELSE CONVERT(varchar(255), ISNULL(dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(Deduccion.Concepto)), NULL)) END AS '@Concepto',  
           --dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(Concepto)) AS '@Concepto',   
           /*CONVERT(varchar(max), CONVERT(money, ISNULL(ImporteGravado, 0))) 'ImporteGravado', */  
           CONVERT(varchar(max), (CONVERT(DECIMAL(16,2),ISNULL(ImporteExcento,0)) + CONVERT(DECIMAL(16,2), ISNULL(ImporteGravado,0)))) AS '@Importe'  
      FROM CFDINominaPercepcionDeduccion Deduccion  
     WHERE ID = @ID  
       AND Personal = @Personal  
       AND Movimiento = 'Deduccion'  
    AND (ISNULL(ImporteExcento,0) + ISNULL(ImporteGravado,0)) <> 0  
      FOR XML PATH('Deduccion')  
    )  
 SELECT @XMLDeduccion = ISNULL(NULLIF(@XMLDeduccion,'<Deduccion/>'),'')  
 SELECT @XMLDeduccion = REPLACE(@XMLDeduccion, '<Deduccion', '<nomina12:Deduccion')  
  END  
    
   IF ISNULL(@XMLDeduccion,'') <> ''  
  BEGIN  
   SELECT @XMLDeducciones = REPLACE(@XMLDeducciones,'/>', '>')  
   SELECT @XMLDeducciones = ISNULL(@XMLDeducciones,'') +   
          ISNULL(@XMLDeduccion,'') + '</nomina12:Deducciones>'  
  END  
  
  -- ********** Otros Pagos **********  
    SELECT @XMLOtrosPagos = '<nomina12:OtrosPagos/>'  
  
    -- ********** Subsidio Al Empleo **********      
    SELECT @XMLSubsidioAlEmpleo = (  
    SELECT CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgSubsidioCausado,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))) AS '@SubsidioCausado'    
      FROM CFDINominaPercepcionDeduccion OtroPago  
      JOIN CFDINominaConcepto C ON OtroPago.Concepto = C.Concepto      
     WHERE OtroPago.ID = @ID  
       AND OtroPago.Personal = @Personal         
    AND OtroPago.Movimiento = 'Estadisticos'          
      FOR XML PATH('SubsidioAlEmpleo')  
    )       
 SELECT @XMLSubsidioAlEmpleo = ISNULL(NULLIF(@XMLSubsidioAlEmpleo,'<SubsidioAlEmpleo/>'),'')   
  
    -- ********** Compensacion Saldos A Favor **********  
    SELECT @XMLCompensacionSaldosAFavor = (  
    SELECT NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgSaldoAFavor,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))),'0.00') AS '@SaldoAFavor',          
           CONVERT(VARCHAR(25), @Ano) AS '@Año',  
           NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgRemanenteSalFav,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))),'0.00') AS '@RemanenteSalFav'  
      FROM CFDINominaPercepcionDeduccion OtroPago  
      JOIN CFDINominaConcepto C ON OtroPago.Concepto = C.Concepto     
     WHERE OtroPago.ID = @ID  
       AND OtroPago.Personal = @Personal  
       AND OtroPago.Movimiento = 'Estadisticos'      
      FOR XML PATH('CompensacionSaldosAFavor')  
    )      
 SELECT @XMLCompensacionSaldosAFavor = ISNULL(NULLIF(@XMLCompensacionSaldosAFavor,'<CompensacionSaldosAFavor/>'),'')   
 SELECT @XMLCompensacionSaldosAFavor = ISNULL(NULLIF(@XMLCompensacionSaldosAFavor,'<CompensacionSaldosAFavor Año=""/>'),'')  
  
  
  -- ********** Otro Pago ********** 
    SELECT @XMLOtroPago = (  
    SELECT O.TipoOtroPago AS '@TipoOtroPago',  
           C.ClaveSAT AS '@Clave',  
           dbo.fnQuitarCaracterEspecial(dbo.fnQuitarAcentos(C.Concepto)) AS '@Concepto',  
     NULLIF(CONVERT(VARCHAR(max),CONVERT(DECIMAL(16,2),SUM(CASE WHEN ISNULL(C.CfgOtroPago,0) = 1 THEN OtroPago.Estadisticos ELSE 0 END))),'0.00') AS '@Importe',  
     CASE WHEN O.TipoOtroPago = '002' THEN CONVERT(XML, @XMLSubsidioAlEmpleo) ELSE NULL END,  
     CASE WHEN O.TipoOtroPago = '004' THEN CONVERT(XML, @XMLCompensacionSaldosAFavor) ELSE NULL END  
      FROM CFDINominaPercepcionDeduccion OtroPago  
      JOIN CFDINominaConcepto C ON OtroPago.Concepto = C.Concepto  
      JOIN CFDINominaTipoOtrosPagos O ON C.CfgTipoOtroPago = O.Descripcion  
     WHERE OtroPago.ID = @ID  
       AND OtroPago.Personal = @Personal  
       AND OtroPago.Movimiento = 'Estadisticos'   
    AND ISNULL(C.CfgOtroPago,0) = 1  
     GROUP BY O.TipoOtroPago, C.ClaveSAT, C.Concepto        
      FOR XML PATH('OtroPago')  
    )  
   
 SELECT @XMLOtroPago = REPLACE(@XMLOtroPago, '<OtroPago', '<nomina12:OtroPago')  
 SELECT @XMLOtroPago = REPLACE(@XMLOtroPago, '<SubsidioAlEmpleo', '<nomina12:SubsidioAlEmpleo')   
 SELECT @XMLOtroPago = REPLACE(@XMLOtroPago, '<CompensacionSaldosAFavor', '<nomina12:CompensacionSaldosAFavor')  
 SELECT @XMLOtroPago = REPLACE(@XMLOtroPago, '</OtroPago>','</nomina12:OtroPago>')  
      
   IF ISNULL(@XMLOtroPago,'') <> ''  
  BEGIN  
   SELECT @XMLOtrosPagos = REPLACE(@XMLOtrosPagos,'/>', '>')  
   SELECT @XMLOtrosPagos = ISNULL(@XMLOtrosPagos,'') +   
         ISNULL(@XMLOtroPago,'') +            
                                    '</nomina12:OtrosPagos>'  
  END  
  
 IF ISNULL(@XMLOtrosPagos,'') = '<nomina12:OtrosPagos/>'   
 BEGIN  
  SELECT @XMLOtrosPagos = ''  
 END  
   
 IF ISNULL(@XMLOtroPago,'') = ''  
 BEGIN    
  SELECT @XMLOtrosPagos = ''  
 END  
  
  -- ********** Incapacidad **********     
  IF NOT EXISTS(SELECT * FROM CFDINominaIncapacidad WHERE ID = @ID AND Personal = @Personal)  
    SELECT @XMLIncapacidad = ''  
  ELSE  
  BEGIN   
    SELECT @XMLIncapacidad = '<nomina12:Incapacidades>' + (  
    SELECT Dias AS '@DiasIncapacidad',  
           CAST(REPLICATE('0',2-LEN(TipoIncapacidad))+CAST(TipoIncapacidad AS VARCHAR(2)) AS VARCHAR(2)) AS '@TipoIncapacidad',  
           CONVERT(varchar(max), CONVERT(DECIMAL(16,2), Descuento)) AS '@ImporteMonetario'  
      FROM CFDINominaIncapacidad Incapacidad        
     WHERE ID = @ID  
       AND Personal = @Personal  
      FOR XML PATH('Incapacidad')  
    )      
    SELECT @XMLIncapacidad = ISNULL(NULLIF(@XMLIncapacidad,'<Incapacidad/>'),'')   
 SELECT @XMLIncapacidad =  REPLACE(@XMLIncapacidad, '<Incapacidad', '<nomina12:Incapacidad')  
    SELECT @XMLIncapacidad =  ISNULL(@XMLIncapacidad, '') + '</nomina12:Incapacidades>'  
   
  END  
--    SELECT ISNULL(@XMLNomina, ''), ISNULL(@XMLEmisor, '') , ISNULL(@XMLReceptor, '') , ISNULL(@XMLPercepciones,''), ISNULL(@XMLDeducciones, '') , ISNULL(@XMLOtrosPagos, ''), ISNULL(@XMLIncapacidad, '')  
  
  /********************************************************************************************************/     
  SELECT @XMLComplemento = ISNULL(@XMLNomina, '') + ISNULL(@XMLEmisor, '') + ISNULL(@XMLReceptor, '') + ISNULL(@XMLPercepciones,'') + ISNULL(@XMLDeducciones, '') + ISNULL(@XMLOtrosPagos, '') + ISNULL(@XMLIncapacidad, '') + '</nomina12:Nomina>'  
  
  SELECT @XML = REPLACE(@XML, '@Complemento', ISNULL(@XMLComplemento, ''))  
  SELECT @XML = REPLACE(@XML, '@Retenciones', ISNULL(@XMLRetenciones, ''))  
  
  IF ISNULL(@XMLRetenciones, '') = ''  
  BEGIN  
    SELECT @XML = REPLACE(@XML, '<cfdi:Retenciones>', '')  
    SELECT @XML = REPLACE(@XML, '</cfdi:Retenciones>', '')  
  END  
  --SELECT @XML  
  SELECT @XML = dbo.fneDocLimpiarXML(@XML,'')       
  --SELECT CAST(@XML AS XML)  
      
  RETURN  
END 
