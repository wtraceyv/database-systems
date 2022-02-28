/*
	Name: Walter Tracey
	Date: 6 June 2020
	Description: CodingAssignment_01 Stored Procedure
*/

--=========================================================== 
-- DO NOT MODIFY THIS SECTION - start coding after line 50
--===========================================================
DROP TABLE IF EXISTS CodingAssignment;

CREATE TABLE CodingAssignment (
	studentID		INT			PRIMARY KEY		IDENTITY,
	miamiID			VARCHAR(10),
	fullName		VARCHAR(50),
	gpa				float
);

INSERT CodingAssignment VALUES
	 ('jephce','Elmer Jephcote',	3.5)
	,('plumtt','Troy Plumtree',	3.7)
	,('ennord','Dannel Ennor',	2.4)
	,('gaineh','Hammad Gaine',	3.7)
	,('holsal','Lolly Holsall',	1.8)
	,('davitg','Gradeigh Davitashvili',	2.3)
	,('feehaa','Agnese Feeham',	2.8)
	,('arnaut','Tynan Arnaudet',	3.4)
	,('piriew','Warde Pirie',	1.9)
	,('lealw','Weston Leal',	1.7)
	,('yosifs','Sallyanne Yosifov',	2.1)
	,('conyem','Mina Conyers',	2.1)
	,('scurrt','Thomasin Scurrer',	3.9)
	,('tremed','Dwain Tremellan',	3.1)
	,('hatlik','Kenyon Hatliff',	2.2)
	,('dagwea','Augustin Dagwell',	1.1)
	,('paalm','Maddalena Paal',	1.7)
	,('sidgwm','Moss Sidgwick',	3.3)
	,('batals','Shelbi Batalini',	2.3)
	,('wardlc','Cordelia Wardlow',	3.2)
	,('shyrec','Christen Shyre',	1.0)
--========================================================

/*
	Write a stored procedure to allow for adds, updates, 
	and deletes against the CodingAssignment table.

	Rules: 
		1. two students can not have the same username
		2. gpa must be between 0.0 AND 4.0
*/

