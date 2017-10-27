IF NOT EXISTS (SELECT 1 FROM sysobjects AS s WHERE s.[type]='U' AND s.name='RUSPIdiomaPersonal')
CREATE TABLE RUSPIdiomaPersonal (
		Personal		VARCHAR(30)		NOT NULL,
		Clave			INT				NOT NULL,
		Tipo			VARCHAR(1)		NULL
)


