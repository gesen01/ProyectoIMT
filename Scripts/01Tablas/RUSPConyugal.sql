IF NOT EXISTS (SELECT 1 FROM sysobjects AS s WHERE s.[type]='U' AND s.name='RUSPConyugal')
CREATE TABLE RUSPConyugal (
		Clave			INT				NOT NULL,
		Descripcion		VARCHAR(50)		NULL
)