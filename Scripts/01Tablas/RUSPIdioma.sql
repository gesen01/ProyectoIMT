IF NOT EXISTS (SELECT 1 FROM sysobjects AS s WHERE s.[type]='U' AND s.name='RUSPIdioma')
CREATE TABLE RUSPIdioma (
		Clave			INT				NOT NULL,
		ClaveCNDH		VARCHAR(10)		NULL,
		Descripcion		VARCHAR(50)		NULL
)

