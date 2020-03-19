USE tempdb;

IF(db_id('ExampleDB') IS NOT NULL)
EXEC('
ALTER DATABASE ExampleDB SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;
USE ExampleDB;
ALTER DATABASE ExampleDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
USE tempdb;
DROP DATABASE ExampleDB;
');

CREATE DATABASE ExampleDB;
GO
USE ExampleDB
GO

CREATE TABLE PostalCodes(
	PostalCodeId int NOT NULL PRIMARY KEY,
	PostDisctrict nvarchar(100)
)

CREATE TABLE Persons(
	CPRId int NOT NULL PRIMARY KEY,
	[Name] nvarchar(100) NOT NULL,
	Title nvarchar(100) NOT NULL,
	Salary money NOT NULL,
	PostalCodeId int NOT NULL FOREIGN KEY REFERENCES dbo.PostalCodes(PostalCodeId)
)

CREATE TABLE Firms(
	FirmNrId int NOT NULL PRIMARY KEY IDENTITY(1,1),
	FirmName nvarchar(100) NOT NULL,
	PostalCodeId int NOT NULL FOREIGN KEY REFERENCES dbo.PostalCodes(PostalCodeId)
)

CREATE TABLE Employees(
	CPRId int NOT NULL FOREIGN KEY REFERENCES dbo.Persons(CPRId),
	FirmNrId int NOT NULL FOREIGN KEY REFERENCES dbo.Firms(FirmNrId)
	CONSTRAINT PK_Employee PRIMARY KEY(CPRId, FirmNrId)
)

IF OBJECT_ID('CreatePostalCode') IS NOT NULL
BEGIN
	DROP PROCEDURE CreatePostalCode
END
GO
CREATE PROCEDURE CreatePostalCode
	(
		@PostalCodeId int,
		@PostDisctrict [nvarchar](100)
	)
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN

	INSERT INTO dbo.PostalCodes
	(
		PostalCodeId,
		PostDisctrict
	)
	VALUES
	(
		@PostalCodeId,
		@PostDisctrict
	)

	END
GO

IF OBJECT_ID('CreatePerson') IS NOT NULL
BEGIN
	DROP PROCEDURE CreatePerson
END
GO
CREATE PROCEDURE CreatePerson
	(
		@CPRId int,
		@Name [nvarchar](100),
		@Title [nvarchar](100),
		@Salary [money],
		@PostalCodeId [int]
	)
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN

	INSERT INTO dbo.Persons
	(
		CPRId, [Name], Title, Salary, PostalCodeId
	)
	VALUES
	(
		@CPRId,
		@Name,
		@Title,
		@Salary,
		@PostalCodeId
	)

	END
GO

IF OBJECT_ID('CreateFirm') IS NOT NULL
BEGIN
	DROP PROCEDURE CreateFirm
END
GO
CREATE PROCEDURE CreateFirm
	(
		@FirmName [nvarchar](100),
		@PostalCodeId [int]
	)
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN

	INSERT INTO dbo.Firms
	(
		FirmName, PostalCodeId
	)
	VALUES
	(
		@FirmName,
		@PostalCodeId
	)

	END
GO

IF OBJECT_ID('CreateEmployee') IS NOT NULL
BEGIN
	DROP PROCEDURE CreateEmployee
END
GO
CREATE PROCEDURE CreateEmployee
	(
		@CPRId int,
		@FirmNrId int
	)
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN

	INSERT INTO dbo.Employees
	(
		CPRId,
		FirmNrId
	)
	VALUES
	(
		@CPRId,
		@FirmNrId
	)

	END
GO



EXEC CreatePostalCode @PostalCodeId = 8000, @PostDisctrict = 'Århus C';

EXEC CreatePostalCode @PostalCodeId = 8200, @PostDisctrict = 'Århus N.';

EXEC CreatePostalCode @PostalCodeId = 8210, @PostDisctrict = 'Århus V.';

EXEC CreatePostalCode @PostalCodeId = 8220, @PostDisctrict = 'Brabrand';

EXEC CreatePostalCode @PostalCodeId = 8240, @PostDisctrict = 'Risskov';

EXEC CreatePostalCode @PostalCodeId = 8310, @PostDisctrict = 'Tranbjerg J.';

EXEC CreatePostalCode @PostalCodeId = 8270, @PostDisctrict = 'Højbjerg';

EXEC CreatePostalCode @PostalCodeId = 8250, @PostDisctrict = 'Egå';



EXEC CreatePerson @CPRId = 1212121212, @Name = 'Ib Hansen', @Title = 'Systemudvikler', @Salary = 250000, @PostalCodeId = 8000;

EXEC CreatePerson @CPRId = 1313131313, @Name = 'Poul Ibsen', @Title = 'Projektleder', @Salary = 500000, @PostalCodeId = 8310;

EXEC CreatePerson @CPRId = 1414141414, @Name = 'Anna Poulsen', @Title = 'IT-chef', @Salary = 870000, @PostalCodeId = 8250;

EXEC CreatePerson @CPRId = 1515151515, @Name = 'Jette Olsen', @Title = 'Systemudvikler', @Salary = 200000, @PostalCodeId = 8000;

EXEC CreatePerson @CPRId = 1616161616, @Name = 'Roy Hurtigkoder', @Title = 'Programmør', @Salary = 500000, @PostalCodeId = 8210;



EXEC CreateFirm @FirmName = 'Danske Data', @PostalCodeId = 8220;

EXEC CreateFirm @FirmName = 'Kommunedata', @PostalCodeId = 8000;

EXEC CreateFirm @FirmName = 'LEC', @PostalCodeId = 8240;

EXEC CreateFirm @FirmName = 'Dansk Supermarked', @PostalCodeId = 8270;


EXEC CreateEmployee	@CPRId = 1212121212, @FirmNrId = 2;

EXEC CreateEmployee	@CPRId = 1313131313, @FirmNrId = 4;

EXEC CreateEmployee	@CPRId = 1414141414, @FirmNrId = 4;

EXEC CreateEmployee	@CPRId = 1616161616, @FirmNrId = 2;




IF OBJECT_ID('SelectPostalCodesWherePersonsLive') IS NOT NULL
BEGIN
	DROP PROCEDURE SelectPostalCodesWherePersonsLive
END
GO
CREATE PROCEDURE SelectPostalCodesWherePersonsLive
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN	

	SELECT pc.* 
	FROM dbo.PostalCodes pc 
	JOIN dbo.Persons p ON pc.PostalCodeId = p.PostalCodeId

	END
GO

EXEC SelectPostalCodesWherePersonsLive;



IF OBJECT_ID('SelectNamesWhereSalaryIsOver400000') IS NOT NULL
BEGIN
	DROP PROCEDURE SelectNamesWhereSalaryIsOver400000
END
GO
CREATE PROCEDURE SelectNamesWhereSalaryIsOver400000
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN	

	SELECT p.Name
	--, p.Salary 
	FROM dbo.Persons p 
	WHERE p.Salary > 400000

	END
GO

EXEC SelectNamesWhereSalaryIsOver400000;



IF OBJECT_ID('SelectNamesForPeopleWhoLiveInAarhusC') IS NOT NULL
BEGIN
	DROP PROCEDURE SelectNamesForPeopleWhoLiveInAarhusC
END
GO
CREATE PROCEDURE SelectNamesForPeopleWhoLiveInAarhusC		
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN	

	SELECT p.Name
	--, pc.PostDisctrict 
	FROM dbo.Persons p 
	JOIN dbo.PostalCodes pc ON p.PostalCodeId = pc.PostalCodeId 
	--WHERE p.PostalCodeId = 8000
	WHERE pc.PostDisctrict = 'Århus C'

	END
GO

EXEC SelectNamesForPeopleWhoLiveInAarhusC;



IF OBJECT_ID('SelectPostalDistrictWherePersonsSalaryIsOver400000') IS NOT NULL
BEGIN
	DROP PROCEDURE SelectPostalDistrictWherePersonsSalaryIsOver400000
END
GO
CREATE PROCEDURE SelectPostalDistrictWherePersonsSalaryIsOver400000
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN	

	SELECT pc.PostDisctrict
	--, p.* 
	FROM dbo.PostalCodes pc 
	JOIN dbo.Persons p ON pc.PostalCodeId = p.PostalCodeId
	WHERE p.Salary > 400000

	END
GO

EXEC SelectPostalDistrictWherePersonsSalaryIsOver400000;

