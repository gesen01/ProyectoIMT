IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='dbo.spCFDINominaRecibo')
DROP PROCEDURE dbo.spCFDINominaRecibo
GO
CREATE PROC dbo.spCFDINominaRecibo
			@Estacion					int,
			@ID							int,
			@Personal					varchar(10),
			--BUG21598
			@Empresa					varchar(5),
		    @TotalPercepciones			float		OUTPUT,
		    @TotalDeducciones			float		OUTPUT,
		    @PercepcionesTotalGravado	float		OUTPUT,
		    @PercepcionesTotalExcento	float		OUTPUT,
		    @DeduccionesTotalGravado	float		OUTPUT,
		    @DeduccionesTotalExcento	float		OUTPUT,
            @TotalDescuento				float		OUTPUT,
            @Importe					float		OUTPUT,
            --BUG21333
            @TotalDeduccionesSinISR		float		OUTPUT,
            @Ok							int			OUTPUT,
            @OkRef						varchar(255)OUTPUT
AS
BEGIN
  DECLARE @NumDiasPagados			float,
		  @Hoy						datetime,
		  @SDI						float,
		  --BUG21598
		  @SucursalTrabajo			int, 
		  @Categoria				varchar(50), 
		  @Puesto					varchar(50),
		  @ClaveRiesgo				varchar(50),
		  @NominaEditarFechaPago	bit,
		  @Mov						varchar(20),
		  @SueldoDiarioIntegrado	MONEY

  SELECT @Mov = Mov FROM Nomina WHERE ID = @ID 
  SELECT @NominaEditarFechaPago = NominaEditarFechaPago FROM EmpresaCFD WHERE Empresa = @Empresa
  IF ISNULL(@NominaEditarFechaPago,0) = 0
     SELECT @NominaEditarFechaPago = EditarFechaPago FROM CFDINominaMov WHERE Mov = @Mov 
  
  SELECT @SucursalTrabajo = SucursalTrabajo, @Categoria = Categoria, @Puesto = Puesto FROM Personal WHERE Personal = @Personal
  SELECT @Hoy = GETDATE()

  --BUG22367
  SELECT @NumDiasPagados = ROUND(ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0), 2)  
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     AND ISNULL(CfgDiasPagados, 0) = 1
     
  SELECT @SDI = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     AND ISNULL(CfgSDI, 0) = 1     

  SELECT @PercepcionesTotalGravado = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     --AND n.Movimiento = 'Percepcion'     
     AND ISNULL(CfgPercepcionesGravadas, 0) = 1

     
  SELECT @PercepcionesTotalExcento = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     --AND n.Movimiento = 'Percepcion'     
     AND ISNULL(CfgPercepcionesExcentas, 0) = 1

     
  SELECT @DeduccionesTotalGravado = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     --AND n.Movimiento = 'Deduccion'
     AND ISNULL(CfgDeduccionesGravadas, 0) = 1

     
  SELECT @DeduccionesTotalExcento = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     --AND n.Movimiento = 'Deduccion'
     AND ISNULL(CfgDeduccionesExcentas, 0) = 1 

  SELECT @TotalDescuento = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     AND ISNULL(CfgDescuento, 0) = 1
    
  --BUG21333
  SELECT @TotalDeduccionesSinISR = ISNULL(SUM(CASE co.CampoTotalizar WHEN 'Importe' THEN ISNULL(Importe, 0) WHEN 'Cantidad' THEN ISNULL(Cantidad, 0) END), 0)
    FROM NominaD n
    JOIN CFDINominaConcepto co ON n.Concepto = co.Concepto 
   WHERE n.ID = @ID 
     AND n.Personal = @Personal
     --AND n.Movimiento = 'Deduccion'
     AND (ISNULL(CfgDeduccionesGravadas, 0) = 1 OR ISNULL(CfgDeduccionesExcentas, 0) = 1)
     AND ISNULL(CfgDescuento, 0) = 0
     
   SELECT @SueldoDiarioIntegrado=SUM(ISNULL(NominaD.Importe, 0))
	FROM NominaD 
	WHERE NominaD.ID=@ID 
	AND NominaD.Personal=@Personal 
	AND NominaD.Movimiento='Estadistica' 
	AND NominaD.Concepto='Salario Diario Integrado'

  SELECT @TotalDeducciones  = ISNULL(@DeduccionesTotalExcento, 0)  + ISNULL(@DeduccionesTotalGravado, 0),
         @TotalPercepciones = ISNULL(@PercepcionesTotalExcento, 0) + ISNULL(@PercepcionesTotalGravado, 0)

  SELECT @Importe = @TotalPercepciones - @TotalDeducciones

  --BUG21598
  EXEC spCFDIPersonalPropValor @Empresa, @SucursalTrabajo, @Categoria, @Puesto, @Personal, 'CLAVE RIESGO', @ClaveRiesgo OUTPUT

  --BUG21333 BUG21416 BUG21432 BUG21457 BUG21419 BUG21598 BUG22059
  INSERT INTO CFDINominaRecibo(
          ID,   Moneda,   Personal,   Version,    RegistroPatronal,   CURP,        RFCEmisor,   RFC,          tipoRegimen,   NumSeguridadSocial,   FechaPago,    FechaInicialPago,                                              FechaFinalPago,  NumDiasPagados,    Departamento, CLABE,                                              Banco,                                           FechainicioRelLaboral, Antiguedad,                                 Puesto,    TipoContrato,    TipoJornada,   PeriodicidadPago,  SalarioBaseCotApor, RiesgoPuesto,                               SalarioDiarioIntegrado,  TotalPercepciones,  PercepcionesTotalGravado,  PercepcionesTotalExcento,  TotalDeducciones,  DeduccionesTotalGravado,  DeduccionesTotalExcento,  TotalDescuento,   TipoComprobante,  Importe,  TotalDeduccionesSinISR,    FormaPago)
  SELECT @ID, n.Moneda, p.Personal, m.Version, np.RegistroPatronal, p.Registro, em.RFC,       p.Registro2, tr.Clave,       p.Registro3,          n.FechaEmision, CASE mt.Clave WHEN 'NOM.NA' THEN d.FechaD ELSE n.FechaD END, n.FechaA,         @NumDiasPagados, np.Departamento, p.PersonalCuenta, dbo.fnRellenarCerosIzquierda(ins.ClaveSAT, 3), p.FechaAntiguedad,       DATEDIFF(Week, p.FechaAntiguedad, @Hoy), np.Puesto, np.TipoContrato, np.Jornada,     p.PeriodoTipo,      @SDI,                ISNULL(@ClaveRiesgo, e.CFDIClaveRiesgo),	 @SueldoDiarioIntegrado,
                                     --np.SDIEstaNomina,
            @TotalPercepciones, @PercepcionesTotalGravado, @PercepcionesTotalExcento, @TotalDeducciones, @DeduccionesTotalGravado, @DeduccionesTotalExcento, @TotalDescuento, m.TipoComprobante, @Importe, @TotalDeduccionesSinISR, np.FormaPago
    FROM Personal p
    JOIN NominaPersonal np ON p.Personal = np.Personal AND np.ID = @ID
    JOIN Nomina n ON np.ID = n.ID
    --BUG21432
    JOIN NominaD d ON n.ID = d.ID AND d.Personal = p.Personal AND d.Personal = np.Personal AND d.ID = @ID
    JOIN MovTipo mt ON n.Mov = mt.Mov AND mt.Modulo = 'NOM'
    JOIN Empresa em ON n.Empresa = em.Empresa
    LEFT OUTER JOIN EmpresaCFD e ON n.Empresa = e.Empresa
    JOIN CFDINominaMov m ON n.Mov = m.Mov
    --BUG21457
    --LEFT OUTER JOIN CtaDinero cta ON p.CtaDinero = cta.CtaDinero
    LEFT OUTER JOIN CFDINominaInstitucionFin ins ON p.PersonalSucursal = ins.Institucion
    LEFT OUTER JOIN CFDINominaSATTipoRegimenV12 tr ON m.tipoRegimen = tr.Nombre
   WHERE P.Personal = @Personal
     AND n.ID = @ID
     --BUG21457 BUG21740
  GROUP BY n.Moneda, p.Personal, m.Version, np.RegistroPatronal, p.Registro, em.RFC, p.Registro2, tr.Clave, p.Registro3, n.FechaEmision, 
		   mt.Clave, d.FechaD, n.FechaD, n.FechaA, np.Departamento, p.PersonalCuenta, ins.ClaveSAT, p.FechaAntiguedad, np.Puesto, 
		   np.TipoContrato, np.Jornada, p.PeriodoTipo, e.CFDIClaveRiesgo, np.SDIEstaNomina, m.TipoComprobante, np.FormaPago


  IF @NominaEditarFechaPago = 1
  BEGIN
    IF EXISTS(SELECT ID FROM CFDINominaDatosMov WHERE Estacion  = @Estacion AND ID = @ID AND NULLIF(FechaPago,'') IS NOT NULL)
      UPDATE CFDINominaREcibo SET FechaPago = m.FechaPago FROM CFDINominaREcibo r
        JOIN CFDINominaDatosMov m ON r.ID = m.ID 
       WHERE m.Estacion = @Estacion AND m.ID = @ID
  END

  RETURN
END
GO