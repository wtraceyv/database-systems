--======================================= prepare DB ===================
USE master
GO

DROP DATABASE IF EXISTS Lab01
GO

CREATE DATABASE Lab01
GO 

USE Lab01
GO

--======================================= TABLES ===================

CREATE TABLE Users(
	id			INT		PRIMARY KEY		IDENTITY,
	userName	VARCHAR(50),
	password	VARCHAR(50),
	first_name	VARCHAR(50),
	last_name	VARCHAR(50),
	email		VARCHAR(50),
	gender		VARCHAR(50),
	avatar		VARCHAR(150)
)
GO

--======================================= INSERTS ===================

BULK INSERT Users
FROM 'C:\temp\Users.txt'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n',
	KEEPIDENTITY,
	TABLOCK
)
GO