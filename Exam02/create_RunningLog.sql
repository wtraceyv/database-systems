/*
	Running Log Database Script
	Exam_02 - CSE 385 202030
	M. Stahr
*/

USE master;
GO

DROP DATABASE IF EXISTS RunningLog;
GO

CREATE DATABASE RunningLog;
GO

USE RunningLog;
GO

--============================== Tables
CREATE TABLE workoutTypes (
	workoutTypeId			int				not null	primary key		identity,
	[description]			varchar(100)	not null,
	sortOrder				int				not null	default(1000)
); 
GO

CREATE TABLE timeOfDay (
	timeOfDayId				int				not null	primary key		identity,
	[description]			varchar(100)	not null,
	sortOrder				int				not null	default(100),
	viewWorkoutSortOrder	int				not null	default(100),
	[default]				bit				not null	default(0)
); 
GO

CREATE TABLE shoeBrands (
	shoeBrandId		int				not null	primary key		identity,
	[description]	varchar(100)	not null,
	sortOrder		int				not null	default(500),
	isDeleted		bit				not null	default(0)
); 
GO

CREATE TABLE users (
	userId			int		not null	primary key		identity,
	email			varchar(100)	not null,
	[password]		varbinary(64)	not null,
	userName		varchar(100)	not null,
	firstName		varchar(50)		not null,
	lastName		varchar(50)		not null,
	gender			char(1)			not null,
	usesMetric		bit				not null	default(0),
	goodLoginCount	int				not null	default(0),
	badLoginCount	int				not null	default(0),
	isDeleted		bit				not null	default(0)
); 
GO

CREATE TABLE shoes (
	shoeId		int				not null	primary key		identity,
	userId		int				not null	foreign key	references users(userId),
	shoeBrandId	int				not null	foreign key	references shoeBrands(shoeBrandId),
	model		varchar(100)	not null	default(''),
	totalMiles	int				not null	default(0),
	isDeleted	bit				not null	default(0)
); 
GO

CREATE TABLE workouts (
	workoutId		int				not null	primary key		identity,
	userId			int				not null	foreign key		references users(userId),
	workoutTypeId	int				not null	foreign key		references workoutTypes(workoutTypeId),
	timeOfDayId		int				not null	foreign key		references timeOfDay(timeOfDayId),
	shoeId			int				null		foreign key		references shoes(shoeId),
	workoutDate		datetime		not null,
	totalMiles		float			not null	default(0),
	totalSeconds	int				not null	default(0),
	comments		varchar(MAX)	not null	default('')
); 
GO

CREATE TABLE [dbo].[errors](
	[errorId] 			int	IDENTITY(1,1)	NOT NULL PRIMARY KEY,
	[ERROR_NUMBER] 		int					NOT NULL,
	[ERROR_SEVERITY] 	int					NOT NULL,
	[ERROR_STATE] 		int					NOT NULL,
	[ERROR_PROCEDURE] 	varchar(50)			NOT NULL,
	[ERROR_LINE] 		int					NOT NULL,
	[ERROR_MESSAGE] 	varchar(500)		NOT NULL,
	[errorDate] 		datetime			NOT NULL DEFAULT(getdate()),
	[resolvedOn]		datetime			NULL,
	[comments]			varchar(8000)		NOT NULL DEFAULT(''),
	[userName]			varchar(100)		NOT NULL DEFAULT(''),
	[params]			varchar(MAX)		NOT NULL DEFAULT('')
);

GO
/**************************************************************************************************             
												FUNCTIONS
 **************************************************************************************************/
CREATE FUNCTION fnEncrypt (@str	AS	nvarchar(4000)) RETURNS varbinary(64) AS BEGIN	
	RETURN HASHBYTES('SHA2_512', @str)	
END
GO

/**************************************************************************************************             
												STORED PROCEDURES
 **************************************************************************************************/

-- =============================================
-- Author:		M. Stahr
-- Create date: 2/19/20
-- Description:	Saves current error
-- =============================================
CREATE PROCEDURE [dbo].[spSAVE_Error]
	@params varchar(MAX) = ''
AS
BEGIN
     SET NOCOUNT ON;
     BEGIN TRY
    	INSERT INTO errors (ERROR_NUMBER,   ERROR_SEVERITY,   ERROR_STATE,   ERROR_PROCEDURE,   ERROR_LINE,   ERROR_MESSAGE, userName, params)
		SELECT				ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), SUSER_NAME(), @params;
     END TRY BEGIN CATCH END CATCH
END
GO

/* =====================================================================

	Name:           spValidateLogin
	Author:         M. Stahr
	Written:        2/12/20
	Purpose:        Validates a user based on userName and password
	Returns:

	Edit History:   2/12/20 - M. Stahr
						+ Initial creation.			          

======================================================================== */
CREATE PROCEDURE spValidateLogin 
	@userName	varchar(100),
	@password	nvarchar(4000)
AS	BEGIN
	IF EXISTS(SELECT NULL FROM users WHERE (userName = @userName) AND (password = dbo.fnEncrypt(@password))) BEGIN
		UPDATE users SET goodLoginCount = goodLoginCount + 1 WHERE userName = @userName
		SELECT CAST(1 AS bit) AS success
	END ELSE BEGIN
		UPDATE users SET badLoginCount = badLoginCount + 1 WHERE userName = @userName
		SELECT CAST(0 AS bit) AS success
	END
END
GO


--===================================================================================================================================================================
--==================================================================================================================================================== Insert Data ==
--===================================================================================================================================================================
/*-------------------------------------------------------------------------------- 
									SHOES BRANDS
  --------------------------------------------------------------------------------*/
INSERT INTO shoeBrands (description) VALUES
	 ('Adidas'),('Asics'),('Avia'),('Brooks'),('Diadora')
	,('Etonic'),('Fila'),('Mizuno'),('Montrail')
	,('New Balance'),('Nike'),('Pearl Izimi'),('Puma')
	,('Reebok'),('Ryka'),('Saucony'),('WalMart')
	,('Other'),('Merrell'),('Loco'),('Newton')
	,('Salomon'),('Spira'),('North Face'),('Bite')
	,('Ecco'),('Fusion'),('Inov8'),('K-Swiss')
	,('Kalenji'),('Karhu'),('Keen'),('Patagonia')
	,('Payless'),('Riddell'),('Under Armour'),('Vasque')
	,('Vibram'),('Vitruvian'),('Wilson'),('Skora')
	,('Hoka'),('Skechers'),('Altra')
INSERT INTO shoeBrands(description, sortOrder) VALUES ('None',0)

/*-------------------------------------------------------------------------------- 
									TIME OF DAY 
  --------------------------------------------------------------------------------*/
INSERT INTO timeOfDay ([description],sortOrder,ViewWorkoutSortOrder,[default]) VALUES
	 ('Morning',	2,	1,	0)
	,('Afternoon',	1,	2,	1)
	,('Evening',	3,	3,	0)
	,('None (off)',	5,	5,	0)
	,('Night',  	4,	4,	0)


/*-------------------------------------------------------------------------------- 
									USERS 
  --------------------------------------------------------------------------------*/
INSERT INTO users (email, [password], userName, firstName, lastName, gender, usesMetric, goodLoginCount, badLoginCount, isDeleted) values 
	 ('tgoggan0@woothemes.com',dbo.fnEncrypt(CAST('8wZKebfRp' AS VARCHAR(4000))), 'tgoggan0', 'Thebault', 'Goggan', 'M',0,476,16, 0)
	,('talfonsini1@vk.com',dbo.fnEncrypt(CAST( 'gGu3HDop0a3f' AS VARCHAR(4000))), 'talfonsini1', 'Terrel', 'Alfonsini', 'M',1,943,3, 0)
	,('sizakson2@nps.gov',dbo.fnEncrypt(CAST( '0tibW8ahjiYr' AS VARCHAR(4000))), 'sizakson2', 'Shelia', 'Izakson', 'F',1,4,17, 0)
	,('hhuriche3@spiegel.de',dbo.fnEncrypt(CAST( 'eygvJzmbzM' AS VARCHAR(4000))), 'hhuriche3', 'Hildegarde', 'Huriche', 'F',1,448,16, 0)
	,('callder4@github.io',dbo.fnEncrypt(CAST( 'QM0V6oa' AS VARCHAR(4000))), 'callder4', 'Clemmy', 'Allder', 'F',0,380,20, 0)
	,('ggowthorpe5@businessinsider.com',dbo.fnEncrypt(CAST( 'm8B70lS' AS VARCHAR(4000))), 'ggowthorpe5', 'Gregoire', 'Gowthorpe', 'M',1,551,14, 0)
	,('dwretham6@twitter.com',dbo.fnEncrypt(CAST( 'fXQGl1uLD' AS VARCHAR(4000))), 'dwretham6', 'Donnie', 'Wretham', 'M',1,782,16, 0)
	,('destick7@altervista.org',dbo.fnEncrypt(CAST( '9HSIFmoZBmx' AS VARCHAR(4000))), 'destick7', 'Darin', 'Estick', 'M',1,521,1, 0)
	,('anotman8@ning.com',dbo.fnEncrypt(CAST( 'zVN2KUzTYYA' AS VARCHAR(4000))), 'anotman8', 'Andriette', 'Notman', 'F',0,696,4, 0)
	,('cjeduch9@amazon.de',dbo.fnEncrypt(CAST( '4JvHLX6' AS VARCHAR(4000))), 'cjeduch9', 'Corney', 'Jeduch', 'M',1,935,1, 0)
	,('ghaseleya@businessweek.com',dbo.fnEncrypt(CAST( 'CJ55cR' AS VARCHAR(4000))), 'ghaseleya', 'Gelya', 'Haseley', 'F',0,227,15, 0)
	,('krobbieb@blinklist.com',dbo.fnEncrypt(CAST( 'hIEcqc' AS VARCHAR(4000))), 'krobbieb', 'Katti', 'Robbie', 'F',0,932,9, 0)
	,('eovertonc@drupal.org',dbo.fnEncrypt(CAST( 'nSjT3BONi7J' AS VARCHAR(4000))), 'eovertonc', 'Esme', 'Overton', 'F',0,685,11, 0)
	,('kbraunleind@msu.edu',dbo.fnEncrypt(CAST( 'roTjah' AS VARCHAR(4000))), 'kbraunleind', 'Kiel', 'Braunlein', 'M',1,535,1, 0)
	,('aieldene@netscape.com',dbo.fnEncrypt(CAST( '5NXzFHan9m' AS VARCHAR(4000))), 'aieldene', 'Annie', 'Ielden', 'F',0,681,17, 0)
	,('mchantreef@blinklist.com',dbo.fnEncrypt(CAST( 'vgmxXfHX' AS VARCHAR(4000))), 'mchantreef', 'Morey', 'Chantree', 'M',1,430,16, 0)
	,('ewhottong@archive.org',dbo.fnEncrypt(CAST( 'Eb1txKhyjB2X' AS VARCHAR(4000))), 'ewhottong', 'Earvin', 'Whotton', 'M',0,919,8, 0)
	,('tmapowderh@ezinearticles.com',dbo.fnEncrypt(CAST( 'Wbks6VkdouEJ' AS VARCHAR(4000))), 'tmapowderh', 'Tillie', 'Mapowder', 'F',1,264,9, 0)
	,('cwagoni@wikispaces.com',dbo.fnEncrypt(CAST( '5SEZpZZb' AS VARCHAR(4000))), 'cwagoni', 'Charley', 'Wagon', 'M',1,146,17, 0)
	,('eheislerj@canalblog.com',dbo.fnEncrypt(CAST( 'XGZxMDFNA2VA' AS VARCHAR(4000))), 'eheislerj', 'Eilis', 'Heisler', 'F',0,219,16, 0)
	,('mgynnik@chicagotribune.com',dbo.fnEncrypt(CAST( 'dPpaVyBICH' AS VARCHAR(4000))), 'mgynnik', 'Malchy', 'Gynni', 'M',0,588,11, 0)
	,('chorderl@tinyurl.com',dbo.fnEncrypt(CAST( 'Zy6f8uJR' AS VARCHAR(4000))), 'chorderl', 'Christy', 'Horder', 'M',1,382,16, 0)
	,('okleinhandlerm@wikispaces.com',dbo.fnEncrypt(CAST( 'VJtDpGUzeY' AS VARCHAR(4000))), 'okleinhandlerm', 'Obediah', 'Kleinhandler', 'M',0,394,13, 0)
	,('ahenriquen@networkadvertising.org',dbo.fnEncrypt(CAST( 'ldGMHYp' AS VARCHAR(4000))), 'ahenriquen', 'Augie', 'Henrique', 'M',1,969,0, 0)
	,('gjuzao@oracle.com',dbo.fnEncrypt(CAST( 'YxfjytaC' AS VARCHAR(4000))), 'gjuzao', 'Gibb', 'Juza', 'M',0,225,4, 0)
	,('scurrellp@berkeley.edu',dbo.fnEncrypt(CAST( 'NqJbjpRLOMls' AS VARCHAR(4000))), 'scurrellp', 'Selle', 'Currell', 'F',1,666,17, 0)
	,('nsalleq@odnoklassniki.ru',dbo.fnEncrypt(CAST( 'cbOAtFwJ1v' AS VARCHAR(4000))), 'nsalleq', 'Niko', 'Salle', 'M',0,827,0, 0)
	,('mnieassr@shutterfly.com',dbo.fnEncrypt(CAST( 'CmFUvYXhGM' AS VARCHAR(4000))), 'mnieassr', 'Mohandas', 'Nieass', 'M',0,355,11, 0)
	,('wshaws@nytimes.com',dbo.fnEncrypt(CAST( 'RjgR0ULpfm7' AS VARCHAR(4000))), 'wshaws', 'Willi', 'Shaw', 'M',1,752,16, 0)
	,('bkalderont@ucsd.edu',dbo.fnEncrypt(CAST( 'qdiCdjuz3rC' AS VARCHAR(4000))), 'bkalderont', 'Batsheva', 'Kalderon', 'F',1,649,6, 0)
	,('lhanu@is.gd',dbo.fnEncrypt(CAST( 'eRDgknb4' AS VARCHAR(4000))), 'lhanu', 'Lorri', 'Han', 'F',1,638,16, 0)
	,('ishoardv@google.com.hk',dbo.fnEncrypt(CAST( '4PiXMKAnCSgR' AS VARCHAR(4000))), 'ishoardv', 'Iseabal', 'Shoard', 'F',1,970,14, 0)
	,('hrentelllw@quantcast.com',dbo.fnEncrypt(CAST( 'IF9jGe' AS VARCHAR(4000))), 'hrentelllw', 'Horton', 'Rentelll', 'M',0,11,5, 0)
	,('hfinnesx@nymag.com',dbo.fnEncrypt(CAST( '1TDLmWuPC' AS VARCHAR(4000))), 'hfinnesx', 'Hernando', 'Finnes', 'M',0,817,15, 0)
	,('bcoppledikey@dell.com',dbo.fnEncrypt(CAST( '078jNeVisC' AS VARCHAR(4000))), 'bcoppledikey', 'Benedick', 'Coppledike', 'M',0,404,0, 0)
	,('bmcreynoldz@chicagotribune.com',dbo.fnEncrypt(CAST( '0z6GgchIz' AS VARCHAR(4000))), 'bmcreynoldz', 'Benedicta', 'McReynold', 'F',1,88,7, 0)
	,('miban10@oracle.com',dbo.fnEncrypt(CAST( 'AEDQZWEfANrs' AS VARCHAR(4000))), 'miban10', 'Maire', 'Iban', 'F',1,829,19, 0)
	,('dhenningham11@icio.us',dbo.fnEncrypt(CAST( 'PXV3HwO0LPek' AS VARCHAR(4000))), 'dhenningham11', 'Deck', 'Henningham', 'M',1,26,19, 0)
	,('gstanman12@wired.com',dbo.fnEncrypt(CAST( 'MYv2tOnz' AS VARCHAR(4000))), 'gstanman12', 'Gwenneth', 'Stanman', 'F',0,181,14, 0)
	,('lwordington13@dot.gov',dbo.fnEncrypt(CAST( 'kQBxZ94y' AS VARCHAR(4000))), 'lwordington13', 'Lexie', 'Wordington', 'F',1,209,2, 0)
	,('nmaffy14@arizona.edu',dbo.fnEncrypt(CAST( '0wPj48jT07wy' AS VARCHAR(4000))), 'nmaffy14', 'Nial', 'Maffy', 'M',1,545,16, 0)
	,('ccutajar15@g.co',dbo.fnEncrypt(CAST( 'WZ35DFM' AS VARCHAR(4000))), 'ccutajar15', 'Charlean', 'Cutajar', 'F',0,318,15, 0)
	,('dgodmer16@apache.org',dbo.fnEncrypt(CAST( '0laynq' AS VARCHAR(4000))), 'dgodmer16', 'Dyanne', 'Godmer', 'F',1,374,6, 0)
	,('aocoskerry17@icq.com',dbo.fnEncrypt(CAST( 'vRcXWVdlKs' AS VARCHAR(4000))), 'aocoskerry17', 'Annamaria', 'O''Coskerry', 'F',0,732,4, 0)
	,('lcurrall18@nationalgeographic.com',dbo.fnEncrypt(CAST( 'cYcfjO9' AS VARCHAR(4000))), 'lcurrall18', 'Lannie', 'Currall', 'M',0,445,18, 0)
	,('ddagworthy19@ucsd.edu',dbo.fnEncrypt(CAST( 'JtQWU0' AS VARCHAR(4000))), 'ddagworthy19', 'Davidson', 'Dagworthy', 'M',1,911,9, 0)
	,('vmullan1a@chronoengine.com',dbo.fnEncrypt(CAST( 'vo00S3JOrme' AS VARCHAR(4000))), 'vmullan1a', 'Valencia', 'Mullan', 'F',0,48,19, 0)
	,('mkeggins1b@1und1.de',dbo.fnEncrypt(CAST( 'xtjRwsSSefi' AS VARCHAR(4000))), 'mkeggins1b', 'Mickey', 'Keggins', 'M',1,336,8, 0)
	,('cfordyce1c@spiegel.de',dbo.fnEncrypt(CAST( 'NfEaGy4hMzfA' AS VARCHAR(4000))), 'cfordyce1c', 'Carlin', 'Fordyce', 'M',1,917,11, 0)
	,('lfeavearyear1d@china.com.cn',dbo.fnEncrypt(CAST( 'Sjuwj7Pn8' AS VARCHAR(4000))), 'lfeavearyear1d', 'Lily', 'Feavearyear', 'F',0,583,14, 0)
	,('gdepport1e@bravesites.com',dbo.fnEncrypt(CAST( '7oULJpL11q' AS VARCHAR(4000))), 'gdepport1e', 'Giselle', 'Depport', 'F',1,133,0, 0)
	,('mpopworth1f@sourceforge.net',dbo.fnEncrypt(CAST( 'afmJxk3' AS VARCHAR(4000))), 'mpopworth1f', 'Manolo', 'Popworth', 'M',1,802,1, 0)
	,('jroyste1g@w3.org',dbo.fnEncrypt(CAST( 'T4wKaRs' AS VARCHAR(4000))), 'jroyste1g', 'Jens', 'Royste', 'M',0,757,17, 0)
	,('ngoult1h@i2i.jp',dbo.fnEncrypt(CAST( 'IxsREq' AS VARCHAR(4000))), 'ngoult1h', 'Nickolaus', 'Goult', 'M',0,918,15, 0)
	,('fslaght1i@ftc.gov',dbo.fnEncrypt(CAST( 'qiOTOl' AS VARCHAR(4000))), 'fslaght1i', 'Fernando', 'Slaght', 'M',1,539,6, 0)
	,('cshackel1j@last.fm',dbo.fnEncrypt(CAST( 'wtIDhu' AS VARCHAR(4000))), 'cshackel1j', 'Corbett', 'Shackel', 'M',0,165,12, 0)
	,('vbowick1k@loc.gov',dbo.fnEncrypt(CAST( 'GuUBkkunLs' AS VARCHAR(4000))), 'vbowick1k', 'Virge', 'Bowick', 'M',1,45,9, 0)
	,('fdwight1l@nasa.gov',dbo.fnEncrypt(CAST( 'TmeMkGysa' AS VARCHAR(4000))), 'fdwight1l', 'Fonzie', 'Dwight', 'M',0,436,15, 0)
	,('rletertre1m@woothemes.com',dbo.fnEncrypt(CAST( 'HKhYMCpKO3M' AS VARCHAR(4000))), 'rletertre1m', 'Ritchie', 'Letertre', 'M',0,439,2, 0)
	,('kkitchingman1n@furl.net',dbo.fnEncrypt(CAST( 'DGZYyCSO' AS VARCHAR(4000))), 'kkitchingman1n', 'Kelci', 'Kitchingman', 'F',1,707,12, 0)
	,('cgonzales1o@tripadvisor.com',dbo.fnEncrypt(CAST( 'IAWrs7t0TLms' AS VARCHAR(4000))), 'cgonzales1o', 'Case', 'Gonzales', 'M',1,181,2, 0)
	,('tweatherdon1p@t-online.de',dbo.fnEncrypt(CAST( '8n85ZQ1GuQk' AS VARCHAR(4000))), 'tweatherdon1p', 'Thaine', 'Weatherdon', 'M',0,588,0, 0)
	,('edalgleish1q@linkedin.com',dbo.fnEncrypt(CAST( 'V3cSb0fCyZkm' AS VARCHAR(4000))), 'edalgleish1q', 'Effie', 'Dalgleish', 'F',1,850,3, 0)
	,('acrowch1r@skype.com',dbo.fnEncrypt(CAST( 'JZ8Cqux' AS VARCHAR(4000))), 'acrowch1r', 'Amby', 'Crowch', 'M',1,482,3, 0)
	,('efewless1s@github.com',dbo.fnEncrypt(CAST( '8Rd2I8d' AS VARCHAR(4000))), 'efewless1s', 'Elizabeth', 'Fewless', 'F',0,902,8, 0)
	,('eblois1t@samsung.com',dbo.fnEncrypt(CAST( 'aR33D1wXuP' AS VARCHAR(4000))), 'eblois1t', 'Edvard', 'Blois', 'M',0,730,11, 0)
	,('dwaadenburg1u@sciencedirect.com',dbo.fnEncrypt(CAST( 'R7Jht9vI' AS VARCHAR(4000))), 'dwaadenburg1u', 'Demetria', 'Waadenburg', 'F',1,686,1, 0)
	,('caltham1v@free.fr',dbo.fnEncrypt(CAST( 'BEwlM8FHFwYH' AS VARCHAR(4000))), 'caltham1v', 'Cece', 'Altham', 'M',1,639,4, 0)
	,('rdeners1w@meetup.com',dbo.fnEncrypt(CAST( '9s6yHDmXMx' AS VARCHAR(4000))), 'rdeners1w', 'Rip', 'Deners', 'M',0,288,2, 0)
	,('tpyner1x@icq.com',dbo.fnEncrypt(CAST( '0gqBZftk9ncY' AS VARCHAR(4000))), 'tpyner1x', 'Trula', 'Pyner', 'F',0,94,13, 0)
	,('nmacavaddy1y@statcounter.com',dbo.fnEncrypt(CAST( 'h1OMD2' AS VARCHAR(4000))), 'nmacavaddy1y', 'Nat', 'MacAvaddy', 'M',1,845,17, 0)
	,('cdewbury1z@springer.com',dbo.fnEncrypt(CAST( 'o84rYjL' AS VARCHAR(4000))), 'cdewbury1z', 'Carine', 'Dewbury', 'F',0,450,11, 0)
	,('eshevlane20@nature.com',dbo.fnEncrypt(CAST( 'rcu7bigbAogu' AS VARCHAR(4000))), 'eshevlane20', 'Edyth', 'Shevlane', 'F',0,659,19, 0)
	,('anuttall21@wisc.edu',dbo.fnEncrypt(CAST( 'Z67zMEJAZrW' AS VARCHAR(4000))), 'anuttall21', 'Agretha', 'Nuttall', 'F',0,99,12, 0)
	,('xsymms22@ed.gov',dbo.fnEncrypt(CAST( 'KMgKCTIJic' AS VARCHAR(4000))), 'xsymms22', 'Ximenez', 'Symms', 'M',1,101,3, 0)
	,('jvanyushin23@usnews.com',dbo.fnEncrypt(CAST( 'xRt1wUNbRq' AS VARCHAR(4000))), 'jvanyushin23', 'Justinn', 'Vanyushin', 'F',0,799,15, 0)
	,('ileworthy24@php.net',dbo.fnEncrypt(CAST( 'A1945u' AS VARCHAR(4000))), 'ileworthy24', 'Igor', 'Leworthy', 'M',0,979,2, 0)
	,('tortega25@house.gov',dbo.fnEncrypt(CAST( 'ajI7gGpPzB7k' AS VARCHAR(4000))), 'tortega25', 'Torry', 'Ortega', 'M',0,736,14, 0)
	,('cabson26@washingtonpost.com',dbo.fnEncrypt(CAST( 'wjAkhm' AS VARCHAR(4000))), 'cabson26', 'Cullan', 'Abson', 'M',1,337,13, 0)
	,('lbeedon27@nsw.gov.au',dbo.fnEncrypt(CAST( 'QEhzjNdWhv28' AS VARCHAR(4000))), 'lbeedon27', 'Lauren', 'Beedon', 'M',0,908,10, 0)
	,('thellens28@msn.com',dbo.fnEncrypt(CAST( 'CzQtTtloZ' AS VARCHAR(4000))), 'thellens28', 'Thane', 'Hellens', 'M',1,668,8, 0)
	,('dstanton29@discovery.com',dbo.fnEncrypt(CAST( '8iQjPWD89' AS VARCHAR(4000))), 'dstanton29', 'Denise', 'Stanton', 'F',0,225,17, 0)
	,('hskingley2a@oracle.com',dbo.fnEncrypt(CAST( 'AUqiVHkQ4ZWE' AS VARCHAR(4000))), 'hskingley2a', 'Haleigh', 'Skingley', 'M',1,749,14, 0)
	,('ccamelli2b@edublogs.org',dbo.fnEncrypt(CAST( 'H5pCJcRs7w' AS VARCHAR(4000))), 'ccamelli2b', 'Celinka', 'Camelli', 'F',0,896,0, 0)
	,('rmcgoldrick2c@google.pl',dbo.fnEncrypt(CAST( 'taWjshNRJkxj' AS VARCHAR(4000))), 'rmcgoldrick2c', 'Reynold', 'McGoldrick', 'M',1,649,15, 0)
	,('twinsborrow2d@nytimes.com',dbo.fnEncrypt(CAST( '0s8UcqlsoO' AS VARCHAR(4000))), 'twinsborrow2d', 'Tiebold', 'Winsborrow', 'M',0,149,17, 0)
	,('bandrejevic2e@soup.io',dbo.fnEncrypt(CAST( 'nIh4GL01' AS VARCHAR(4000))), 'bandrejevic2e', 'Britney', 'Andrejevic', 'F',1,308,7, 0)
	,('sdungay2f@phpbb.com',dbo.fnEncrypt(CAST( '8TI3ln' AS VARCHAR(4000))), 'sdungay2f', 'Seth', 'Dungay', 'M',0,828,12, 0)
	,('awederell2g@answers.com',dbo.fnEncrypt(CAST( 'yK3fQN2vvm' AS VARCHAR(4000))), 'awederell2g', 'Akim', 'Wederell', 'M',0,361,10, 0)
	,('aessery2h@ucoz.ru',dbo.fnEncrypt(CAST( '2a1H8xPM8' AS VARCHAR(4000))), 'aessery2h', 'Aldous', 'Essery', 'M',1,525,19, 0)
	,('fburr2i@japanpost.jp',dbo.fnEncrypt(CAST( 'M8YZpWPzJA15' AS VARCHAR(4000))), 'fburr2i', 'Freddy', 'Burr', 'M',0,17,4, 0)
	,('ahendrick2j@huffingtonpost.com',dbo.fnEncrypt(CAST( 'vewQMLrNgg' AS VARCHAR(4000))), 'ahendrick2j', 'Alameda', 'Hendrick', 'F',1,905,2, 0)
	,('rgaven2k@homestead.com',dbo.fnEncrypt(CAST( 'W9uJjJ4' AS VARCHAR(4000))), 'rgaven2k', 'Ruby', 'Gaven', 'F',1,478,14, 0)
	,('ocayle2l@marriott.com',dbo.fnEncrypt(CAST( 'xUYQJalZKB' AS VARCHAR(4000))), 'ocayle2l', 'Ozzy', 'Cayle', 'M',0,9,10, 0)
	,('dskyrm2m@whitehouse.gov',dbo.fnEncrypt(CAST( 'h1NmdIrXpb' AS VARCHAR(4000))), 'dskyrm2m', 'Devonna', 'Skyrm', 'F',0,170,11, 0)
	,('tsmees2n@unicef.org',dbo.fnEncrypt(CAST( 'cCcvFuw2oJr' AS VARCHAR(4000))), 'tsmees2n', 'Tessy', 'Smees', 'F',0,80,8, 0)
	,('sdurtnel2o@nifty.com',dbo.fnEncrypt(CAST( 'hMbAO8mBoa' AS VARCHAR(4000))), 'sdurtnel2o', 'Skye', 'Durtnel', 'M',0,921,6000, 0)
	,('pdeatta2p@nhs.uk',dbo.fnEncrypt(CAST( 'zsEjgFUygp' AS VARCHAR(4000))), 'pdeatta2p', 'Portia', 'De Atta', 'F',0,974,13, 0)
	,('aabramamov2q@github.com',dbo.fnEncrypt(CAST( 'drH7GZ7ModP' AS VARCHAR(4000))), 'aabramamov2q', 'Abdel', 'Abramamov', 'M',0,562,18, 0)
	,('redden2r@fda.gov',dbo.fnEncrypt(CAST( 'e7M140' AS VARCHAR(4000))), 'redden2r', 'Raleigh', 'Edden', 'M',1,456,4, 0)
	,('tdearlove2s@webs.com',dbo.fnEncrypt(CAST( 'H7t2mkcouK8' AS VARCHAR(4000))), 'tdearlove2s', 'Talbot', 'Dearlove', 'M',1,660,1, 0)
	,('cpretorius2t@tinypic.com',dbo.fnEncrypt(CAST( 'aqJCuH' AS VARCHAR(4000))), 'cpretorius2t', 'Corina', 'Pretorius', 'F',1,187,1000, 0)
	,('tchadbourne2u@tripadvisor.com',dbo.fnEncrypt(CAST( 'pxKPGATsof' AS VARCHAR(4000))), 'tchadbourne2u', 'Thorstein', 'Chadbourne', 'M',0,718,4, 0)
	,('scapel2v@nymag.com',dbo.fnEncrypt(CAST( 'cvqmmMUBFNR9' AS VARCHAR(4000))), 'scapel2v', 'Saree', 'Capel', 'F',0,112,3, 0)
	,('agoney2w@topsy.com',dbo.fnEncrypt(CAST( 'pPhwuY' AS VARCHAR(4000))), 'agoney2w', 'Ardelia', 'Goney', 'F',1,752,14, 0)
	,('fclotworthy2x@creativecommons.org',dbo.fnEncrypt(CAST( '8I9zKGM4RTd' AS VARCHAR(4000))), 'fclotworthy2x', 'Felike', 'Clotworthy', 'M',1,400,8, 0)
	,('barrighi2y@reddit.com',dbo.fnEncrypt(CAST( 'EclV2PU' AS VARCHAR(4000))), 'barrighi2y', 'Berri', 'Arrighi', 'F',1,295,16, 0)
	,('hfullbrook2z@amazon.co.jp',dbo.fnEncrypt(CAST( 'bT6EQshbv' AS VARCHAR(4000))), 'hfullbrook2z', 'Hilliary', 'Fullbrook', 'F',0,179,3, 0)
	,('ghodge30@furl.net',dbo.fnEncrypt(CAST( 'InUmyb' AS VARCHAR(4000))), 'ghodge30', 'Gloriane', 'Hodge', 'F',1,564,0, 0)
	,('roheaney31@dmoz.org',dbo.fnEncrypt(CAST( 'x8678B' AS VARCHAR(4000))), 'roheaney31', 'Rip', 'O''Heaney', 'M',1,767,4, 0)
	,('lpfeffer32@typepad.com',dbo.fnEncrypt(CAST( 'YV7E80rk' AS VARCHAR(4000))), 'lpfeffer32', 'Lewie', 'Pfeffer', 'M',1,884,7, 0)
	,('cstainer33@columbia.edu',dbo.fnEncrypt(CAST( 'wKWSBOtuaYJB' AS VARCHAR(4000))), 'cstainer33', 'Chelsie', 'Stainer', 'F',1,801,10, 0)
	,('tmanna34@ibm.com',dbo.fnEncrypt(CAST( '636iKHaU' AS VARCHAR(4000))), 'tmanna34', 'Travus', 'Manna', 'M',1,972,13, 0)
	,('hbudgett35@multiply.com',dbo.fnEncrypt(CAST( 'tKstQB70' AS VARCHAR(4000))), 'hbudgett35', 'Hinda', 'Budgett', 'F',1,59,7, 0)
	,('eerrowe36@webnode.com',dbo.fnEncrypt(CAST( 'kLmjn6yMRt' AS VARCHAR(4000))), 'eerrowe36', 'Ellynn', 'Errowe', 'F',1,340,2, 0)
	,('wdrover37@disqus.com',dbo.fnEncrypt(CAST( 'mBVPZ26' AS VARCHAR(4000))), 'wdrover37', 'Wilton', 'Drover', 'M',1,909,0, 0)
	,('lcaudray38@mayoclinic.com',dbo.fnEncrypt(CAST( 'f0zJH3Kp9j' AS VARCHAR(4000))), 'lcaudray38', 'Lenard', 'Caudray', 'M',1,225,2, 0)
	,('rlacoste39@washingtonpost.com',dbo.fnEncrypt(CAST( 'kMjYCSP' AS VARCHAR(4000))), 'rlacoste39', 'Reece', 'Lacoste', 'M',1,907,16, 0)
	,('msmee3a@nba.com',dbo.fnEncrypt(CAST( 'x90sjMzCQiy' AS VARCHAR(4000))), 'msmee3a', 'Myles', 'Smee', 'M',1,836,14, 0)
	,('gmcphillimey3b@creativecommons.org',dbo.fnEncrypt(CAST( 'FvzMbRIyf' AS VARCHAR(4000))), 'gmcphillimey3b', 'Godiva', 'McPhillimey', 'F',0,193,14, 0)
	,('cmartygin3c@dmoz.org',dbo.fnEncrypt(CAST( 'ov4y3TXDe9yx' AS VARCHAR(4000))), 'cmartygin3c', 'Chandra', 'Martygin', 'F',0,505,18, 0)
	,('rkeeffe3d@google.ca',dbo.fnEncrypt(CAST( 'KZBfScvqDhQW' AS VARCHAR(4000))), 'rkeeffe3d', 'Rudolf', 'Keeffe', 'M',1,130,16, 0)
	,('sthorpe3e@bing.com',dbo.fnEncrypt(CAST( 'K49mkS' AS VARCHAR(4000))), 'sthorpe3e', 'Shannah', 'Thorpe', 'F',0,724,13, 0)
	,('dchupin3f@nifty.com',dbo.fnEncrypt(CAST( 'eQLE27c' AS VARCHAR(4000))), 'dchupin3f', 'Dianne', 'Chupin', 'F',1,982,10, 0)
	,('cguise3g@guardian.co.uk',dbo.fnEncrypt(CAST( 'd455Jc5aT5' AS VARCHAR(4000))), 'cguise3g', 'Carmel', 'Guise', 'F',1,913,3, 0)
	,('ndashwood3h@salon.com',dbo.fnEncrypt(CAST( '8J7GPtAAL' AS VARCHAR(4000))), 'ndashwood3h', 'Norri', 'Dashwood', 'F',1,856,16, 0)
	,('nkonerding3i@wix.com',dbo.fnEncrypt(CAST( 'wq58ubD' AS VARCHAR(4000))), 'nkonerding3i', 'Norton', 'Konerding', 'M',1,239,9, 0)
	,('ccopestake3j@microsoft.com',dbo.fnEncrypt(CAST( 'o2zDKo853' AS VARCHAR(4000))), 'ccopestake3j', 'Constantin', 'Copestake', 'M',1,746,14, 0)
	,('gbleier3k@deliciousdays.com',dbo.fnEncrypt(CAST( 'um4duy' AS VARCHAR(4000))), 'gbleier3k', 'Glendon', 'Bleier', 'M',0,116,5, 0)
	,('gabercrombie3l@newyorker.com',dbo.fnEncrypt(CAST( '3WQhzDiy' AS VARCHAR(4000))), 'gabercrombie3l', 'Granny', 'Abercrombie', 'M',1,961,1, 0)
	,('sewan3m@purevolume.com',dbo.fnEncrypt(CAST( 'hZkp458fe' AS VARCHAR(4000))), 'sewan3m', 'Stanford', 'Ewan', 'M',0,12,14, 0)
	,('pdittson3n@behance.net',dbo.fnEncrypt(CAST( 'p2foJoZfcZJo' AS VARCHAR(4000))), 'pdittson3n', 'Pyotr', 'Dittson', 'M',1,925,7, 0)
	,('fcargen3o@un.org',dbo.fnEncrypt(CAST( 'EhuVCI2o' AS VARCHAR(4000))), 'fcargen3o', 'Felic', 'Cargen', 'M',0,227,20000, 0)
	,('kdenidge3p@slideshare.net',dbo.fnEncrypt(CAST( 'bhKj3ngXa' AS VARCHAR(4000))), 'kdenidge3p', 'Kippy', 'Denidge', 'M',1,737,11, 0)
	,('bgalliver3q@blog.com',dbo.fnEncrypt(CAST( 'kGZbx3a' AS VARCHAR(4000))), 'bgalliver3q', 'Brendis', 'Galliver', 'M',0,308,13, 0)
	,('mwyburn3r@smugmug.com',dbo.fnEncrypt(CAST( 'B82YfQLg9H' AS VARCHAR(4000))), 'mwyburn3r', 'Mavra', 'Wyburn', 'F',1,701,2, 0)
	,('aruoss3s@zimbio.com',dbo.fnEncrypt(CAST( 'iDJeEfC' AS VARCHAR(4000))), 'aruoss3s', 'Anders', 'Ruoss', 'M',1,253,15, 0)
	,('ejankin3t@dot.gov',dbo.fnEncrypt(CAST( 'zv78VE' AS VARCHAR(4000))), 'ejankin3t', 'Elise', 'Jankin', 'F',0,886,16, 0)
	,('jlaight3u@accuweather.com',dbo.fnEncrypt(CAST( 'Od1yOEOwvz' AS VARCHAR(4000))), 'jlaight3u', 'Jean', 'Laight', 'M',0,110,14, 0)
	,('ccopley3v@dedecms.com',dbo.fnEncrypt(CAST( 'bQFy4KOD9' AS VARCHAR(4000))), 'ccopley3v', 'Cleve', 'Copley', 'M',0,664,7, 0)
	,('hbeevors3w@senate.gov',dbo.fnEncrypt(CAST( 'TLaXzZi3' AS VARCHAR(4000))), 'hbeevors3w', 'Heinrick', 'Beevors', 'M',0,769,19, 0)
	,('gshillingford3x@free.fr',dbo.fnEncrypt(CAST( 'poa0bOw' AS VARCHAR(4000))), 'gshillingford3x', 'Gibby', 'Shillingford', 'M',0,293,19, 0)
	,('mlucio3y@bloglovin.com',dbo.fnEncrypt(CAST( 'CZpxygLzr' AS VARCHAR(4000))), 'mlucio3y', 'Madalena', 'Lucio', 'F',0,319,16, 0)
	,('cmebius3z@comsenz.com',dbo.fnEncrypt(CAST( 'E1DTrJ4lex' AS VARCHAR(4000))), 'cmebius3z', 'Corney', 'Mebius', 'M',1,367,14, 0)
	,('nbrauner40@simplemachines.org',dbo.fnEncrypt(CAST( 'sA1H5ad' AS VARCHAR(4000))), 'nbrauner40', 'Nicolis', 'Brauner', 'M',1,131,6, 0)
	,('bupcraft41@themeforest.net',dbo.fnEncrypt(CAST( 'Qau6LC8U2VH' AS VARCHAR(4000))), 'bupcraft41', 'Berny', 'Upcraft', 'M',1,944,14, 0)
	,('ppeotz42@shop-pro.jp',dbo.fnEncrypt(CAST( 'vNtI00Hpl' AS VARCHAR(4000))), 'ppeotz42', 'Padraic', 'Peotz', 'M',0,534,0, 0)
	,('cbungey43@ucoz.ru',dbo.fnEncrypt(CAST( 'nU8d010sIy4' AS VARCHAR(4000))), 'cbungey43', 'Cully', 'Bungey', 'M',1,840,16, 0)
	,('azumbusch44@scientificamerican.com',dbo.fnEncrypt(CAST( 'rQlNm0dK8Xkv' AS VARCHAR(4000))), 'azumbusch44', 'Anet', 'Zumbusch', 'F',1,563,7, 0)
	,('ehedge45@latimes.com',dbo.fnEncrypt(CAST( 'ZuDgaqm' AS VARCHAR(4000))), 'ehedge45', 'Evelin', 'Hedge', 'M',1,605,13, 0)
	,('jconnock46@privacy.gov.au',dbo.fnEncrypt(CAST( 'EEzwdpVOS' AS VARCHAR(4000))), 'jconnock46', 'Joni', 'Connock', 'F',0,367,13, 0)
	,('mnorville47@ucla.edu',dbo.fnEncrypt(CAST( 'r3JeQmZUZ' AS VARCHAR(4000))), 'mnorville47', 'Matthieu', 'Norville', 'M',1,40,17, 0)
	,('adargie48@vkontakte.ru',dbo.fnEncrypt(CAST( 'KZUeK5' AS VARCHAR(4000))), 'adargie48', 'Ariadne', 'Dargie', 'F',0,698,20, 0)
	,('hmannock49@kickstarter.com',dbo.fnEncrypt(CAST( 'YcUHmSIPbVWC' AS VARCHAR(4000))), 'hmannock49', 'Hilarius', 'Mannock', 'M',0,445,2, 0)
	,('aick4a@tripod.com',dbo.fnEncrypt(CAST( 'cCsHnPCYX' AS VARCHAR(4000))), 'aick4a', 'Annnora', 'Ick', 'F',0,779,15, 0)
	,('pmccerery4b@umn.edu',dbo.fnEncrypt(CAST( 'uHefVV8c' AS VARCHAR(4000))), 'pmccerery4b', 'Patti', 'McCerery', 'F',0,529,6, 0)
	,('lhandforth4c@1und1.de',dbo.fnEncrypt(CAST( 's5NLCB' AS VARCHAR(4000))), 'lhandforth4c', 'Lucho', 'Handforth', 'M',0,800,15, 0)
	,('mcomerford4d@naver.com',dbo.fnEncrypt(CAST( 'Y1C0su' AS VARCHAR(4000))), 'mcomerford4d', 'Mavra', 'Comerford', 'F',1,342,1, 0)
	,('vmyall4e@wisc.edu',dbo.fnEncrypt(CAST( 'lnNm5F' AS VARCHAR(4000))), 'vmyall4e', 'Vincents', 'Myall', 'M',0,147,18, 0)
	,('pgarvey4f@hubpages.com',dbo.fnEncrypt(CAST( 'o9AKkHrq' AS VARCHAR(4000))), 'pgarvey4f', 'Pippa', 'Garvey', 'F',1,583,18, 0)
	,('smarrion4g@jugem.jp',dbo.fnEncrypt(CAST( 'fy5X0oZM2' AS VARCHAR(4000))), 'smarrion4g', 'Shir', 'Marrion', 'F',1,195,6, 0)
	,('sgostage4h@wunderground.com',dbo.fnEncrypt(CAST( 'ehPeMPJ4o' AS VARCHAR(4000))), 'sgostage4h', 'Simone', 'Gostage', 'F',0,678,16, 0)
	,('ahebblewaite4i@columbia.edu',dbo.fnEncrypt(CAST( 'vaRgAwher' AS VARCHAR(4000))), 'ahebblewaite4i', 'Annabal', 'Hebblewaite', 'F',0,948,4, 0)
	,('dkrates4j@foxnews.com',dbo.fnEncrypt(CAST( 'TeksU9rM' AS VARCHAR(4000))), 'dkrates4j', 'Dyna', 'Krates', 'F',1,287,4, 0)
	,('dgladebeck4k@ehow.com',dbo.fnEncrypt(CAST( 'hC9pkj05' AS VARCHAR(4000))), 'dgladebeck4k', 'Doe', 'Gladebeck', 'F',0,776,16, 0)
	,('cbrownsea4l@vistaprint.com',dbo.fnEncrypt(CAST( 'ml4zRSD4Xf' AS VARCHAR(4000))), 'cbrownsea4l', 'Cynthea', 'Brownsea', 'F',1,371,14, 0)
	,('ngunner4m@drupal.org',dbo.fnEncrypt(CAST( 'APnpZqkFot' AS VARCHAR(4000))), 'ngunner4m', 'Nestor', 'Gunner', 'M',0,876,10, 0)
	,('twimbury4n@jalbum.net',dbo.fnEncrypt(CAST( 'g0FbvxUNNr' AS VARCHAR(4000))), 'twimbury4n', 'Trudey', 'Wimbury', 'F',0,840,20, 0)
	,('jkenwrick4o@army.mil',dbo.fnEncrypt(CAST( 'rnjXh1O1FJHL' AS VARCHAR(4000))), 'jkenwrick4o', 'Jock', 'Kenwrick', 'M',1,400,1, 0)
	,('mboissier4p@webeden.co.uk',dbo.fnEncrypt(CAST( 'bpruOl5LIlgi' AS VARCHAR(4000))), 'mboissier4p', 'Monah', 'Boissier', 'F',0,338,3, 0)
	,('ccarruthers4q@meetup.com',dbo.fnEncrypt(CAST( 'E01v1pLq3z' AS VARCHAR(4000))), 'ccarruthers4q', 'Chaunce', 'Carruthers', 'M',0,130,13, 0)
	,('mtillerton4r@netvibes.com',dbo.fnEncrypt(CAST( '6hBhlX1bMmN' AS VARCHAR(4000))), 'mtillerton4r', 'Martino', 'Tillerton', 'M',0,19,1, 0)
	,('omourton4s@amazon.co.uk',dbo.fnEncrypt(CAST( '8Y72WSE' AS VARCHAR(4000))), 'omourton4s', 'Ortensia', 'Mourton', 'F',1,898,14, 0)
	,('ecroome4t@about.com',dbo.fnEncrypt(CAST( 'nCu69lg3W' AS VARCHAR(4000))), 'ecroome4t', 'Elbert', 'Croome', 'M',0,985,15, 0)
	,('acrier4u@exblog.jp',dbo.fnEncrypt(CAST( 'hIeSEDn' AS VARCHAR(4000))), 'acrier4u', 'Artemas', 'Crier', 'M',1,937,18, 0)
	,('jcarrell4v@columbia.edu',dbo.fnEncrypt(CAST( 'C7coec8PM6S' AS VARCHAR(4000))), 'jcarrell4v', 'Jaynell', 'Carrell', 'F',0,731,13, 0)
	,('rmajury4w@canalblog.com',dbo.fnEncrypt(CAST( 'oliyj2OKJ' AS VARCHAR(4000))), 'rmajury4w', 'Rustie', 'Majury', 'M',1,746,9, 0)
	,('khuot4x@posterous.com',dbo.fnEncrypt(CAST( '0mUhOALGcJgR' AS VARCHAR(4000))), 'khuot4x', 'Korella', 'Huot', 'F',0,688,14, 0)
	,('rmaharey4y@hc360.com',dbo.fnEncrypt(CAST( 'EQiqwgnLE' AS VARCHAR(4000))), 'rmaharey4y', 'Ron', 'Maharey', 'M',0,790,9, 0)
	,('ebradman4z@scientificamerican.com',dbo.fnEncrypt(CAST( 'ArM3FUj0msC' AS VARCHAR(4000))), 'ebradman4z', 'Eric', 'Bradman', 'M',0,71,6, 0)
	,('ebernardoni50@biblegateway.com',dbo.fnEncrypt(CAST( '2ZkQXWwz0H3' AS VARCHAR(4000))), 'ebernardoni50', 'Elliott', 'Bernardoni', 'M',1,568,11, 0)
	,('ldowda51@biglobe.ne.jp',dbo.fnEncrypt(CAST( 'fakuRk7inAVQ' AS VARCHAR(4000))), 'ldowda51', 'Lowrance', 'Dowda', 'M',1,285,19, 0)
	,('oscyone52@example.com',dbo.fnEncrypt(CAST( '5ZC2ZH' AS VARCHAR(4000))), 'oscyone52', 'Osmund', 'Scyone', 'M',0,621,5, 0)
	,('gmatusson53@bbc.co.uk',dbo.fnEncrypt(CAST( 'xk874Yd' AS VARCHAR(4000))), 'gmatusson53', 'Genevieve', 'Matusson', 'F',1,424,10, 0)
	,('asummerhayes54@fema.gov',dbo.fnEncrypt(CAST( '5ZPPLm3fjw7d' AS VARCHAR(4000))), 'asummerhayes54', 'Annie', 'Summerhayes', 'F',0,614,11, 0)
	,('amarkushkin55@jigsy.com',dbo.fnEncrypt(CAST( 'OgtTCoy' AS VARCHAR(4000))), 'amarkushkin55', 'Alan', 'Markushkin', 'M',0,540,2, 0)
	,('jhearfield56@tripod.com',dbo.fnEncrypt(CAST( 'igsX1BoQWK' AS VARCHAR(4000))), 'jhearfield56', 'Jorrie', 'Hearfield', 'F',0,407,16, 0)
	,('aphettiplace57@webnode.com',dbo.fnEncrypt(CAST( 'Jrr51pWHfUlb' AS VARCHAR(4000))), 'aphettiplace57', 'Aleen', 'Phettiplace', 'F',0,496,6, 0)
	,('qbool58@barnesandnoble.com',dbo.fnEncrypt(CAST( 'EJHKOhLgS9xn' AS VARCHAR(4000))), 'qbool58', 'Quinn', 'Bool', 'F',1,119,6, 0)
	,('rmcelvogue59@hao123.com',dbo.fnEncrypt(CAST( 'biOYzTvhO' AS VARCHAR(4000))), 'rmcelvogue59', 'Regan', 'McElvogue', 'F',0,839,1, 1)
	,('dricca5a@xing.com',dbo.fnEncrypt(CAST( 'ouFidG3N26' AS VARCHAR(4000))), 'dricca5a', 'Denyse', 'Ricca', 'F',0,616,18, 0)
	,('imulbry5b@spiegel.de',dbo.fnEncrypt(CAST( 'ONUIv8InOu' AS VARCHAR(4000))), 'imulbry5b', 'Isadora', 'Mulbry', 'F',0,30,7, 0)
	,('dbertie5c@discuz.net',dbo.fnEncrypt(CAST( 'mIGbkK5' AS VARCHAR(4000))), 'dbertie5c', 'Dimitri', 'Bertie', 'M',1,507,12, 0)
	,('wseamarke5d@instagram.com',dbo.fnEncrypt(CAST( 'Cg6hdnVtif9' AS VARCHAR(4000))), 'wseamarke5d', 'Wylma', 'Seamarke', 'F',0,517,4, 0)
	,('smckerley5e@engadget.com',dbo.fnEncrypt(CAST( 'BxYF7q' AS VARCHAR(4000))), 'smckerley5e', 'Sidonia', 'McKerley', 'F',0,969,1, 0)
	,('cglencrosche5f@devhub.com',dbo.fnEncrypt(CAST( 'IDIDtPc' AS VARCHAR(4000))), 'cglencrosche5f', 'Caz', 'Glencrosche', 'M',0,971,5, 0)
	,('aspelman5g@theguardian.com',dbo.fnEncrypt(CAST( 'Uq0rzwdy9e' AS VARCHAR(4000))), 'aspelman5g', 'Alaine', 'Spelman', 'F',0,706,7, 0)
	,('bmuglestone5h@mac.com',dbo.fnEncrypt(CAST( '5EsdafTm' AS VARCHAR(4000))), 'bmuglestone5h', 'Bonnie', 'Muglestone', 'F',0,903,17, 0)
	,('qlampett5i@bigcartel.com',dbo.fnEncrypt(CAST( 'cHeOx2c' AS VARCHAR(4000))), 'qlampett5i', 'Quinn', 'Lampett', 'M',0,644,8, 0)
	,('hmargrett5j@princeton.edu',dbo.fnEncrypt(CAST( 'pNSbxb' AS VARCHAR(4000))), 'hmargrett5j', 'Halie', 'Margrett', 'F',0,448,2, 0)
	,('sparlour5k@imageshack.us',dbo.fnEncrypt(CAST( 'ylyORk' AS VARCHAR(4000))), 'sparlour5k', 'Siffre', 'Parlour', 'M',0,669,7, 0)
	,('sstuehmeyer5l@jiathis.com',dbo.fnEncrypt(CAST( 'HGFORu0' AS VARCHAR(4000))), 'sstuehmeyer5l', 'Stephan', 'Stuehmeyer', 'M',1,150,13, 0)
	,('sblakden5m@wordpress.com',dbo.fnEncrypt(CAST( 'oWo2G0X6' AS VARCHAR(4000))), 'sblakden5m', 'Stanislaus', 'Blakden', 'M',1,687,14, 0)
	,('kscadding5n@reference.com',dbo.fnEncrypt(CAST( 'cBq3rr3N1i' AS VARCHAR(4000))), 'kscadding5n', 'Karlotta', 'Scadding', 'F',0,857,2, 0)
	,('swyett5o@unesco.org',dbo.fnEncrypt(CAST( 'tWcu1NUhZbO' AS VARCHAR(4000))), 'swyett5o', 'Shell', 'Wyett', 'M',1,794,10, 0)
	,('amalmar5p@merriam-webster.com',dbo.fnEncrypt(CAST( 'VePBLw' AS VARCHAR(4000))), 'amalmar5p', 'Ariadne', 'Malmar', 'F',0,389,19, 0)
	,('cgalway5q@wp.com',dbo.fnEncrypt(CAST( 'UUmDeNT3aIXt' AS VARCHAR(4000))), 'cgalway5q', 'Cathyleen', 'Galway', 'F',0,26,16, 0)
	,('tmarler5r@discuz.net',dbo.fnEncrypt(CAST( 'ALo4v0keEI' AS VARCHAR(4000))), 'tmarler5r', 'Temple', 'Marler', 'M',1,967,11, 0)
	,('cworman5s@tinypic.com',dbo.fnEncrypt(CAST( 'hrctNg' AS VARCHAR(4000))), 'cworman5s', 'Cassie', 'Worman', 'M',1,27,14, 0)
	,('sreadshaw5t@bbc.co.uk',dbo.fnEncrypt(CAST( 'zx5MDwSlvkn' AS VARCHAR(4000))), 'sreadshaw5t', 'Shelton', 'Readshaw', 'M',0,144,8, 0)
	,('mmasse5u@techcrunch.com',dbo.fnEncrypt(CAST( 'pkPhId1pC' AS VARCHAR(4000))), 'mmasse5u', 'Minna', 'Masse', 'F',1,812,14, 0)
	,('eissitt5v@bravesites.com',dbo.fnEncrypt(CAST( 'llyLB4hmBP' AS VARCHAR(4000))), 'eissitt5v', 'Ernesta', 'Issitt', 'F',0,212,5, 0)
	,('jwickey5w@imageshack.us',dbo.fnEncrypt(CAST( 'WrXV19a' AS VARCHAR(4000))), 'jwickey5w', 'Jason', 'Wickey', 'M',1,478,5, 0)
	,('reastmond5x@nps.gov',dbo.fnEncrypt(CAST( 'Calcwq3Ips5' AS VARCHAR(4000))), 'reastmond5x', 'Rozamond', 'Eastmond', 'F',1,600,17, 0)
	,('hmacsween5y@wix.com',dbo.fnEncrypt(CAST( 'CFGd3A' AS VARCHAR(4000))), 'hmacsween5y', 'Hewett', 'MacSween', 'M',0,228,10, 0)
	,('gcavy5z@oakley.com',dbo.fnEncrypt(CAST( 'TB7N28' AS VARCHAR(4000))), 'gcavy5z', 'Gavra', 'Cavy', 'F',0,103,14, 0)
	,('cdubarry60@ucoz.ru',dbo.fnEncrypt(CAST( 'BTDJWZOKbca' AS VARCHAR(4000))), 'cdubarry60', 'Craggy', 'Du Barry', 'M',1,300,18, 0)
	,('gcadogan61@altervista.org',dbo.fnEncrypt(CAST( 'UdG6u6xmK9Tv' AS VARCHAR(4000))), 'gcadogan61', 'Gaspard', 'Cadogan', 'M',0,726,0, 0)
	,('cgammie62@who.int',dbo.fnEncrypt(CAST( 'ahIzXXL' AS VARCHAR(4000))), 'cgammie62', 'Curtice', 'Gammie', 'M',1,172,13, 0)
	,('gdallender63@ezinearticles.com',dbo.fnEncrypt(CAST( 'BAhSzm' AS VARCHAR(4000))), 'gdallender63', 'Guillaume', 'Dallender', 'M',1,328,9, 0)
	,('dmichelmore64@usgs.gov',dbo.fnEncrypt(CAST( 'WD09GtOU4' AS VARCHAR(4000))), 'dmichelmore64', 'Dagny', 'Michelmore', 'M',0,556,18, 0)
	,('garnley65@stanford.edu',dbo.fnEncrypt(CAST( 'kNweZYJf96zI' AS VARCHAR(4000))), 'garnley65', 'Gibbie', 'Arnley', 'M',0,469,8, 0)
	,('mvernall66@patch.com',dbo.fnEncrypt(CAST( 'RKr5fHH' AS VARCHAR(4000))), 'mvernall66', 'Milly', 'Vernall', 'F',0,967,17, 0)
	,('mpothbury67@constantcontact.com',dbo.fnEncrypt(CAST( 'UcgaIvEucml' AS VARCHAR(4000))), 'mpothbury67', 'Mose', 'Pothbury', 'M',1,54,7, 1)
	,('sewins68@wordpress.com',dbo.fnEncrypt(CAST( 'EHMItZRLM' AS VARCHAR(4000))), 'sewins68', 'Symon', 'Ewins', 'M',0,909,3, 1)
	,('tbelton69@aboutads.info',dbo.fnEncrypt(CAST( '5MjpMF8' AS VARCHAR(4000))), 'tbelton69', 'Trevar', 'Belton', 'M',0,827,17, 1)
	,('jcarding6a@fda.gov',dbo.fnEncrypt(CAST( 'mDFBUTzE86' AS VARCHAR(4000))), 'jcarding6a', 'Jodie', 'Carding', 'M',1,187,5, 0)
	,('jmilan6b@yale.edu',dbo.fnEncrypt(CAST( 'X1bKgPIJvgv' AS VARCHAR(4000))), 'jmilan6b', 'Johnette', 'Milan', 'F',0,390,17, 0)
	,('edyka6c@google.co.uk',dbo.fnEncrypt(CAST( 'S1XefJS' AS VARCHAR(4000))), 'edyka6c', 'Eric', 'Dyka', 'M',0,333,50000, 0)
	,('kspender6d@mapy.cz',dbo.fnEncrypt(CAST( 'uZnMkMK3n' AS VARCHAR(4000))), 'kspender6d', 'Kaitlynn', 'Spender', 'F',0,235,1, 0)
	,('cfagge6e@furl.net',dbo.fnEncrypt(CAST( 'kKHpCDlA' AS VARCHAR(4000))), 'cfagge6e', 'Claudianus', 'Fagge', 'M',0,411,4, 0)
	,('bleborgne6f@zimbio.com',dbo.fnEncrypt(CAST( 'IbxiFcaZg' AS VARCHAR(4000))), 'bleborgne6f', 'Bethanne', 'Le Borgne', 'F',1,654,14, 0)
	,('pmccrorie6g@hugedomains.com',dbo.fnEncrypt(CAST( 'iKWqYFK' AS VARCHAR(4000))), 'pmccrorie6g', 'Piper', 'McCrorie', 'F',1,621,18, 0)
	,('ltalby6h@wikia.com',dbo.fnEncrypt(CAST( 'PH946p' AS VARCHAR(4000))), 'ltalby6h', 'Loren', 'Talby', 'F',1,806,2, 0)
	,('gniesel6i@imdb.com',dbo.fnEncrypt(CAST( 'f9iVHGR' AS VARCHAR(4000))), 'gniesel6i', 'Garik', 'Niesel', 'M',1,391,20, 0)
	,('mcrab6j@yellowpages.com',dbo.fnEncrypt(CAST( 'LOoqEIQbGlXB' AS VARCHAR(4000))), 'mcrab6j', 'Moll', 'Crab', 'F',1,649,7, 0)
	,('isuermeier6k@google.nl',dbo.fnEncrypt(CAST( 'IrB8gfezzt' AS VARCHAR(4000))), 'isuermeier6k', 'Ilyssa', 'Suermeier', 'F',1,686,20, 0)
	,('fdominguez6l@addthis.com',dbo.fnEncrypt(CAST( 'I3kocUZ3' AS VARCHAR(4000))), 'fdominguez6l', 'Francisco', 'Dominguez', 'M',1,726,11, 0)
	,('ocanning6m@oracle.com',dbo.fnEncrypt(CAST( '8b7GaBb2xefy' AS VARCHAR(4000))), 'ocanning6m', 'Otto', 'Canning', 'M',0,850,15, 0)
	,('fmorritt6n@exblog.jp',dbo.fnEncrypt(CAST( 'tk7njV' AS VARCHAR(4000))), 'fmorritt6n', 'Ferdinande', 'Morritt', 'F',1,509,4, 0)
	,('zbowkett6o@biglobe.ne.jp',dbo.fnEncrypt(CAST( 'BBSay4jK2f7s' AS VARCHAR(4000))), 'zbowkett6o', 'Zaria', 'Bowkett', 'F',0,887,5, 0)
	,('amenezes6p@zdnet.com',dbo.fnEncrypt(CAST( 's0ZOGgJZlhBE' AS VARCHAR(4000))), 'amenezes6p', 'Augustus', 'Menezes', 'M',0,111,5, 0)
	,('sjudkins6q@linkedin.com',dbo.fnEncrypt(CAST( 'DitXiaVaN' AS VARCHAR(4000))), 'sjudkins6q', 'Steffie', 'Judkins', 'F',1,248,20, 0)
	,('sbeamiss6r@businessweek.com',dbo.fnEncrypt(CAST( 'hQxL5UtIzCl' AS VARCHAR(4000))), 'sbeamiss6r', 'Sasha', 'Beamiss', 'M',1,400,1, 0)
	,('renglish6s@vk.com',dbo.fnEncrypt(CAST( 'MoPnvAk' AS VARCHAR(4000))), 'renglish6s', 'Ralina', 'English', 'F',0,751,4, 0)
	,('dbonham6t@yolasite.com',dbo.fnEncrypt(CAST( 'c8VG6d4BW' AS VARCHAR(4000))), 'dbonham6t', 'Dino', 'Bonham', 'M',0,664,15, 0)
	,('sdeangelo6u@zimbio.com',dbo.fnEncrypt(CAST( 'mGyae2lIkxK' AS VARCHAR(4000))), 'sdeangelo6u', 'Shelden', 'De Angelo', 'M',0,960,2, 0)
	,('wmcgeagh6v@godaddy.com',dbo.fnEncrypt(CAST( 'lV4AVpbW' AS VARCHAR(4000))), 'wmcgeagh6v', 'Webb', 'McGeagh', 'M',1,275,3, 0)
	,('csheers6w@hexun.com',dbo.fnEncrypt(CAST( 'D3CsW4rpnhV' AS VARCHAR(4000))), 'csheers6w', 'Cece', 'Sheers', 'M',1,4,13, 0)
	,('wcurrum6x@youku.com',dbo.fnEncrypt(CAST( 'G6Brx2VWam1' AS VARCHAR(4000))), 'wcurrum6x', 'Webster', 'Currum', 'M',0,787,13, 0)
	,('kyuryshev6y@marriott.com',dbo.fnEncrypt(CAST( 'vfVXm2oh' AS VARCHAR(4000))), 'kyuryshev6y', 'Kele', 'Yuryshev', 'M',0,415,14, 0)
	,('mtreweela6z@umich.edu',dbo.fnEncrypt(CAST( 'ppTmOgNvGA4' AS VARCHAR(4000))), 'mtreweela6z', 'Mandi', 'Treweela', 'F',0,313,3, 0)
	,('schettle70@twitter.com',dbo.fnEncrypt(CAST( 'Ikpc04HrY0B' AS VARCHAR(4000))), 'schettle70', 'Staffard', 'Chettle', 'M',0,930,14, 0)
	,('wimlach71@geocities.com',dbo.fnEncrypt(CAST( '2D9OkT' AS VARCHAR(4000))), 'wimlach71', 'Wilhelm', 'Imlach', 'M',0,91,18, 0)
	,('ebrood72@adobe.com',dbo.fnEncrypt(CAST( 'IeLBWdOs4PK' AS VARCHAR(4000))), 'ebrood72', 'Eleanora', 'Brood', 'F',0,244,10, 0)
	,('ichaffin73@springer.com',dbo.fnEncrypt(CAST( 'e8qJozT36' AS VARCHAR(4000))), 'ichaffin73', 'Ivonne', 'Chaffin', 'F',0,230,2, 0)
	,('ysquibe74@opensource.org',dbo.fnEncrypt(CAST( 'kGKhVRwx' AS VARCHAR(4000))), 'ysquibe74', 'Yurik', 'Squibe', 'M',1,686,3, 0)
	,('jmaes75@webs.com',dbo.fnEncrypt(CAST( 'a44mQo4CCo67' AS VARCHAR(4000))), 'jmaes75', 'Jarret', 'Maes', 'M',1,516,8, 0)
	,('osimmings76@baidu.com',dbo.fnEncrypt(CAST( '8oIENugGy4Z' AS VARCHAR(4000))), 'osimmings76', 'Osgood', 'Simmings', 'M',1,319,3, 0)
	,('bsecretan77@google.it',dbo.fnEncrypt(CAST( '4T2txDQo6t' AS VARCHAR(4000))), 'bsecretan77', 'Babb', 'Secretan', 'F',1,989,14, 0)
	,('lmowsdill78@npr.org',dbo.fnEncrypt(CAST( '1djAM8OP' AS VARCHAR(4000))), 'lmowsdill78', 'Lotte', 'Mowsdill', 'F',1,524,13, 0)
	,('abuyers79@youtu.be',dbo.fnEncrypt(CAST( 'AmT2kpQm94S' AS VARCHAR(4000))), 'abuyers79', 'Alf', 'Buyers', 'M',1,421,5, 0)
	,('ccadogan7a@tripadvisor.com',dbo.fnEncrypt(CAST( '3tP6A6fR' AS VARCHAR(4000))), 'ccadogan7a', 'Charin', 'Cadogan', 'F',1,554,1, 0)
	,('jokeaveny7b@hexun.com',dbo.fnEncrypt(CAST( 'twsA4p5R' AS VARCHAR(4000))), 'jokeaveny7b', 'Jerrold', 'O''Keaveny', 'M',0,335,2, 0)
	,('epotten7c@livejournal.com',dbo.fnEncrypt(CAST( 'VDU9biJA0P' AS VARCHAR(4000))), 'epotten7c', 'Evelyn', 'Potten', 'M',1,958,10, 0)
	,('dlanfere7d@ftc.gov',dbo.fnEncrypt(CAST( '4y5TKzW6Dw3P' AS VARCHAR(4000))), 'dlanfere7d', 'Delila', 'Lanfere', 'F',0,133,11, 0)
	,('prycraft7e@tmall.com',dbo.fnEncrypt(CAST( '9cqSEIjzo' AS VARCHAR(4000))), 'prycraft7e', 'Pincus', 'Rycraft', 'M',1,107,2, 0)
	,('dtorrese7f@princeton.edu',dbo.fnEncrypt(CAST( 'POMEL8E' AS VARCHAR(4000))), 'dtorrese7f', 'Delainey', 'Torrese', 'M',1,57,3, 0)
	,('dbiffin7g@alexa.com',dbo.fnEncrypt(CAST( 'Ht6X0MH2' AS VARCHAR(4000))), 'dbiffin7g', 'Drusy', 'Biffin', 'F',1,699,3, 0)
	,('clankester7h@narod.ru',dbo.fnEncrypt(CAST( 'T4uGG5n' AS VARCHAR(4000))), 'clankester7h', 'Cort', 'Lankester', 'M',0,833,18, 0)
	,('chattigan7i@globo.com',dbo.fnEncrypt(CAST( '6JlLDH9v' AS VARCHAR(4000))), 'chattigan7i', 'Cassey', 'Hattigan', 'F',1,730,10, 0)
	,('rworsalls7j@google.com',dbo.fnEncrypt(CAST( 'PbJG1Ff' AS VARCHAR(4000))), 'rworsalls7j', 'Ruddy', 'Worsalls', 'M',1,48,19, 0)
	,('lgaymar7k@wikia.com',dbo.fnEncrypt(CAST( '1peqTPqDL3S' AS VARCHAR(4000))), 'lgaymar7k', 'Leola', 'Gaymar', 'F',0,96,2, 0)
	,('pbarsham7l@tinyurl.com',dbo.fnEncrypt(CAST( 'OkUcagabXGbb' AS VARCHAR(4000))), 'pbarsham7l', 'Phillipe', 'Barsham', 'M',1,244,11, 0)
	,('bgartshore7m@issuu.com',dbo.fnEncrypt(CAST( 'uAwHrRqYPvb' AS VARCHAR(4000))), 'bgartshore7m', 'Blithe', 'Gartshore', 'F',0,522,13, 0)
	,('shartell7n@cocolog-nifty.com',dbo.fnEncrypt(CAST( '8zMFDgEH' AS VARCHAR(4000))), 'shartell7n', 'Spence', 'Hartell', 'M',1,524,13, 0)
	,('gmcvittie7o@imageshack.us',dbo.fnEncrypt(CAST( 'Oq72FA9Y' AS VARCHAR(4000))), 'gmcvittie7o', 'Gerick', 'McVittie', 'M',0,461,19, 0)
	,('tniesing7p@blog.com',dbo.fnEncrypt(CAST( 'aA2rnM' AS VARCHAR(4000))), 'tniesing7p', 'Thomasine', 'Niesing', 'F',1,334,15, 0)
	,('llamperti7q@g.co',dbo.fnEncrypt(CAST( 'VYQrY5jJ9P' AS VARCHAR(4000))), 'llamperti7q', 'Leo', 'Lamperti', 'M',1,513,10, 0)
	,('bhulson7r@yahoo.co.jp',dbo.fnEncrypt(CAST( '8axOsa8' AS VARCHAR(4000))), 'bhulson7r', 'Bradan', 'Hulson', 'M',0,121,8, 0)
	,('ckrale7s@disqus.com',dbo.fnEncrypt(CAST( 'AraBpfYvSZcI' AS VARCHAR(4000))), 'ckrale7s', 'Carolyn', 'Krale', 'F',1,178,2, 0)
	,('ceaken7t@bloomberg.com',dbo.fnEncrypt(CAST( 'SgIhcrSOJfZ' AS VARCHAR(4000))), 'ceaken7t', 'Carilyn', 'Eaken', 'F',0,660,8, 0)
	,('jsalvatore7u@wordpress.org',dbo.fnEncrypt(CAST( 'oXZHIVL' AS VARCHAR(4000))), 'jsalvatore7u', 'Juli', 'Salvatore', 'F',0,716,17, 0)
	,('rchat7v@jiathis.com',dbo.fnEncrypt(CAST( 'GgKH2vQh' AS VARCHAR(4000))), 'rchat7v', 'Rosalynd', 'Chat', 'F',0,208,1, 0)
	,('kchavey7w@sakura.ne.jp',dbo.fnEncrypt(CAST( 'Uurc1X7vd8lG' AS VARCHAR(4000))), 'kchavey7w', 'Keelby', 'Chavey', 'M',1,627,11, 0)
	,('gbrigden7x@drupal.org',dbo.fnEncrypt(CAST( 'vzzJ5Sw' AS VARCHAR(4000))), 'gbrigden7x', 'Garrard', 'Brigden', 'M',0,908,3, 0)
	,('emckerley7y@google.cn',dbo.fnEncrypt(CAST( 'zjxhTF3pPjj' AS VARCHAR(4000))), 'emckerley7y', 'Ellerey', 'Mc-Kerley', 'M',0,244,6, 0)
	,('hdurham7z@dropbox.com',dbo.fnEncrypt(CAST( 'cmQTbBs' AS VARCHAR(4000))), 'hdurham7z', 'Helga', 'Durham', 'F',0,472,2, 0)
	,('mgerrill80@answers.com',dbo.fnEncrypt(CAST( 'gn2ukkJgXI' AS VARCHAR(4000))), 'mgerrill80', 'Mel', 'Gerrill', 'F',0,142,9, 0)
	,('atayloe81@fema.gov',dbo.fnEncrypt(CAST( '7H7DFqq' AS VARCHAR(4000))), 'atayloe81', 'Addia', 'Tayloe', 'F',1,469,8, 0)
	,('wbabst82@whitehouse.gov',dbo.fnEncrypt(CAST( 'PB4Rm9' AS VARCHAR(4000))), 'wbabst82', 'Wallie', 'Babst', 'F',1,227,4, 0)
	,('splease83@hud.gov',dbo.fnEncrypt(CAST( 'twu7UiJmdvM4' AS VARCHAR(4000))), 'splease83', 'Sallee', 'Please', 'F',1,13,16, 0)
	,('bbeetham84@hhs.gov',dbo.fnEncrypt(CAST( 'RN8COP7I3h' AS VARCHAR(4000))), 'bbeetham84', 'Burnaby', 'Beetham', 'M',1,842,10, 0)
	,('bcuxon85@mysql.com',dbo.fnEncrypt(CAST( 'PEzaxC0K' AS VARCHAR(4000))), 'bcuxon85', 'Buddy', 'Cuxon', 'M',0,142,5, 0)
	,('etunnicliffe86@chronoengine.com',dbo.fnEncrypt(CAST( 'q0BNG3x62' AS VARCHAR(4000))), 'etunnicliffe86', 'Emili', 'Tunnicliffe', 'F',0,560,11, 0)
	,('sdayes87@slashdot.org',dbo.fnEncrypt(CAST( 'uVUhEUmhOQYp' AS VARCHAR(4000))), 'sdayes87', 'Simmonds', 'Dayes', 'M',1,502,2, 0)
	,('ztumber88@redcross.org',dbo.fnEncrypt(CAST( 'GQTa4KR' AS VARCHAR(4000))), 'ztumber88', 'Zorah', 'Tumber', 'F',0,134,16, 0)
	,('fmacconnell89@apache.org',dbo.fnEncrypt(CAST( 'zEDbY9iZHPt' AS VARCHAR(4000))), 'fmacconnell89', 'Frederico', 'MacConnell', 'M',1,788,2, 0)
	,('pteffrey8a@un.org',dbo.fnEncrypt(CAST( 'YAmZEQAfIAg' AS VARCHAR(4000))), 'pteffrey8a', 'Pyotr', 'Teffrey', 'M',1,304,2, 0)
	,('gtidmarsh8b@google.cn',dbo.fnEncrypt(CAST( 'k5dE3pw0JT' AS VARCHAR(4000))), 'gtidmarsh8b', 'Greggory', 'Tidmarsh', 'M',0,92,0, 0)
	,('cdillway8c@typepad.com',dbo.fnEncrypt(CAST( '0XDKf5t8P59' AS VARCHAR(4000))), 'cdillway8c', 'Cos', 'Dillway', 'M',1,712,18, 0)
	,('sdutchburn8d@ed.gov',dbo.fnEncrypt(CAST( 'o7vhtR6iF' AS VARCHAR(4000))), 'sdutchburn8d', 'Saunders', 'Dutchburn', 'M',1,400,17, 0)
	,('psambrok8e@delicious.com',dbo.fnEncrypt(CAST( 'rbvrfHXYj' AS VARCHAR(4000))), 'psambrok8e', 'Peggie', 'Sambrok', 'F',1,29,20, 0)
	,('acollin8f@mediafire.com',dbo.fnEncrypt(CAST( '3iWIBzN' AS VARCHAR(4000))), 'acollin8f', 'Allison', 'Collin', 'F',1,690,8, 0)
	,('mmcgloughlin8g@yellowbook.com',dbo.fnEncrypt(CAST( 'r1g0hg1YQ' AS VARCHAR(4000))), 'mmcgloughlin8g', 'Manolo', 'McGloughlin', 'M',1,182,6, 0)
	,('kserraillier8h@dot.gov',dbo.fnEncrypt(CAST( 'BdpZjpxA' AS VARCHAR(4000))), 'kserraillier8h', 'Kim', 'Serraillier', 'M',1,800,13, 0)
	,('bpenvarden8i@google.com',dbo.fnEncrypt(CAST( '5iz7aJ4Q2' AS VARCHAR(4000))), 'bpenvarden8i', 'Barbaraanne', 'Penvarden', 'F',0,91,0, 0)
	,('lduesberry8j@amazon.co.uk',dbo.fnEncrypt(CAST( 'yjN094D7X' AS VARCHAR(4000))), 'lduesberry8j', 'Linc', 'Duesberry', 'M',0,602,14, 0)
	,('ldickman8k@printfriendly.com',dbo.fnEncrypt(CAST( 'qjgFSM' AS VARCHAR(4000))), 'ldickman8k', 'Luci', 'Dickman', 'F',0,911,5, 0)
	,('astronach8l@opera.com',dbo.fnEncrypt(CAST( 'P4JvD7jlBu' AS VARCHAR(4000))), 'astronach8l', 'Aloin', 'Stronach', 'M',0,529,5, 0)
	,('bfelder8m@disqus.com',dbo.fnEncrypt(CAST( 'CnBtfOCmJ' AS VARCHAR(4000))), 'bfelder8m', 'Brandyn', 'Felder', 'M',1,712,6, 0)
	,('mbenbough8n@google.nl',dbo.fnEncrypt(CAST( 'tTGC2dM' AS VARCHAR(4000))), 'mbenbough8n', 'Maureene', 'Benbough', 'F',0,960,7, 0)
	,('acissen8o@pagesperso-orange.fr',dbo.fnEncrypt(CAST( 'l3EmpLjtfx' AS VARCHAR(4000))), 'acissen8o', 'Alphonse', 'Cissen', 'M',0,819,20, 0)
	,('marboine8p@google.cn',dbo.fnEncrypt(CAST( '6QfPcGMz' AS VARCHAR(4000))), 'marboine8p', 'Micheline', 'Arboine', 'F',0,784,1, 0)
	,('cmartineau8q@tumblr.com',dbo.fnEncrypt(CAST( 'wUaTFu' AS VARCHAR(4000))), 'cmartineau8q', 'Chucho', 'Martineau', 'M',0,318,19, 0)
	,('dhuckerbe8r@prnewswire.com',dbo.fnEncrypt(CAST( 'fm4BHqlES' AS VARCHAR(4000))), 'dhuckerbe8r', 'Dorine', 'Huckerbe', 'F',0,165,4, 0)
	,('fskelton8s@epa.gov',dbo.fnEncrypt(CAST( 'o8i3Jkx96H3f' AS VARCHAR(4000))), 'fskelton8s', 'Florencia', 'Skelton', 'F',0,563,16, 0)
	,('yschiementz8t@tmall.com',dbo.fnEncrypt(CAST( 'Gyro2cF1WUqO' AS VARCHAR(4000))), 'yschiementz8t', 'Yolande', 'Schiementz', 'F',1,273,16, 0)
	,('lgregoletti8u@patch.com',dbo.fnEncrypt(CAST( 'E1fszG' AS VARCHAR(4000))), 'lgregoletti8u', 'Lotti', 'Gregoletti', 'F',0,673,1, 0)
	,('ravraam8v@stanford.edu',dbo.fnEncrypt(CAST( '462qXA' AS VARCHAR(4000))), 'ravraam8v', 'Reuven', 'Avraam', 'M',0,355,4, 0)
	,('yschutze8w@qq.com',dbo.fnEncrypt(CAST( 'P6dsaXf8W' AS VARCHAR(4000))), 'yschutze8w', 'Yvor', 'Schutze', 'M',0,909,4, 0)
	,('rramelot8x@upenn.edu',dbo.fnEncrypt(CAST( 'x36WCirR' AS VARCHAR(4000))), 'rramelot8x', 'Rollo', 'Ramelot', 'M',1,299,13, 0)
	,('lgoldsworthy8y@webnode.com',dbo.fnEncrypt(CAST( '8420QZX' AS VARCHAR(4000))), 'lgoldsworthy8y', 'Lewes', 'Goldsworthy', 'M',1,208,9, 0)
	,('slethley8z@friendfeed.com',dbo.fnEncrypt(CAST( 'ngGgNlPTWk' AS VARCHAR(4000))), 'slethley8z', 'Silvie', 'Lethley', 'F',1,864,19, 0)
	,('vgauchier90@twitter.com',dbo.fnEncrypt(CAST( 'DAVLvYb' AS VARCHAR(4000))), 'vgauchier90', 'Verena', 'Gauchier', 'F',1,244,15, 0)
	,('gvaadeland91@flickr.com',dbo.fnEncrypt(CAST( 'UABMaxk' AS VARCHAR(4000))), 'gvaadeland91', 'Giuditta', 'Vaadeland', 'F',1,583,9, 0)
	,('ccauley92@cafepress.com',dbo.fnEncrypt(CAST( '7HWOPvI' AS VARCHAR(4000))), 'ccauley92', 'Cass', 'Cauley', 'F',0,687,15, 0)
	,('kfife93@merriam-webster.com',dbo.fnEncrypt(CAST( 'C2Quzs' AS VARCHAR(4000))), 'kfife93', 'Kippy', 'Fife', 'M',0,998,11, 0)
	,('fodevey94@diigo.com',dbo.fnEncrypt(CAST( 'ZKMrP72OKHS' AS VARCHAR(4000))), 'fodevey94', 'Frederico', 'O''Devey', 'M',0,963,6, 0)
	,('lacey95@symantec.com',dbo.fnEncrypt(CAST( 'WHq5KlS' AS VARCHAR(4000))), 'lacey95', 'Lucina', 'Acey', 'F',1,15,13, 0)
	,('sferryn96@delicious.com',dbo.fnEncrypt(CAST( 'QbcsdNV4bO' AS VARCHAR(4000))), 'sferryn96', 'Siffre', 'Ferryn', 'M',0,364,10, 0)
	,('fghelarducci97@wikispaces.com',dbo.fnEncrypt(CAST( 'vj0MSEtz' AS VARCHAR(4000))), 'fghelarducci97', 'Faber', 'Ghelarducci', 'M',0,683,12, 0)
	,('cmannooch98@linkedin.com',dbo.fnEncrypt(CAST( 'zX1X2xMJV' AS VARCHAR(4000))), 'cmannooch98', 'Connor', 'Mannooch', 'M',0,547,8, 0)
	,('nwellard99@tripod.com',dbo.fnEncrypt(CAST( '1mFJ6gEirecm' AS VARCHAR(4000))), 'nwellard99', 'Neron', 'Wellard', 'M',0,550,16, 0)
	,('lpeto9a@sogou.com',dbo.fnEncrypt(CAST( 'XGUD5ulaCT2d' AS VARCHAR(4000))), 'lpeto9a', 'Liuka', 'Peto', 'F',0,849,9, 0)
	,('rwright9b@cdbaby.com',dbo.fnEncrypt(CAST( 'NWaBFi' AS VARCHAR(4000))), 'rwright9b', 'Ruddy', 'Wright', 'M',1,663,16, 0)
	,('cgiocannoni9c@yahoo.co.jp',dbo.fnEncrypt(CAST( 'RIPAaff' AS VARCHAR(4000))), 'cgiocannoni9c', 'Cassi', 'Giocannoni', 'F',1,492,4, 0)
	,('jronayne9d@delicious.com',dbo.fnEncrypt(CAST( 'tLjjyj8wH' AS VARCHAR(4000))), 'jronayne9d', 'Jamison', 'Ronayne', 'M',1,200,3, 0)
	,('kchallenor9e@biblegateway.com',dbo.fnEncrypt(CAST( 'TbRc4Hr' AS VARCHAR(4000))), 'kchallenor9e', 'Knox', 'Challenor', 'M',1,844,12, 0)
	,('dtenant9f@ameblo.jp',dbo.fnEncrypt(CAST( 'KVLZ9HdNZHCY' AS VARCHAR(4000))), 'dtenant9f', 'Darrell', 'Tenant', 'M',0,198,2, 0)
	,('hbeadle9g@dedecms.com',dbo.fnEncrypt(CAST( '9DsXJB5k2wcR' AS VARCHAR(4000))), 'hbeadle9g', 'Hamilton', 'Beadle', 'M',1,841,10, 0)
	,('bbaudinot9h@indiegogo.com',dbo.fnEncrypt(CAST( 'H8mq7GbaaE' AS VARCHAR(4000))), 'bbaudinot9h', 'Bastian', 'Baudinot', 'M',0,232,15, 0)
	,('renrietto9i@un.org',dbo.fnEncrypt(CAST( 'uhYbLkKo' AS VARCHAR(4000))), 'renrietto9i', 'Robbert', 'Enrietto', 'M',0,824,15, 0)
	,('bmangin9j@sogou.com',dbo.fnEncrypt(CAST( 'TqLCcPoJ0CJ' AS VARCHAR(4000))), 'bmangin9j', 'Brod', 'Mangin', 'M',0,408,6, 0)
	,('bnewlove9k@cdbaby.com',dbo.fnEncrypt(CAST( 'l90pFZox6j' AS VARCHAR(4000))), 'bnewlove9k', 'Blair', 'Newlove', 'F',0,541,10, 0)
	,('echasney9l@rediff.com',dbo.fnEncrypt(CAST( 'UZreD00r0h' AS VARCHAR(4000))), 'echasney9l', 'Engelbert', 'Chasney', 'M',0,144,20, 0)
	,('ggallafant9m@wp.com',dbo.fnEncrypt(CAST( 'H2S0TMIHhp0T' AS VARCHAR(4000))), 'ggallafant9m', 'Gwennie', 'Gallafant', 'F',0,182,16, 0)
	,('mdunk9n@reuters.com',dbo.fnEncrypt(CAST( 'akni3Op7F1r' AS VARCHAR(4000))), 'mdunk9n', 'Martino', 'Dunk', 'M',0,84,2, 0)
	,('ljillett9o@odnoklassniki.ru',dbo.fnEncrypt(CAST( 'QLY7GZN6' AS VARCHAR(4000))), 'ljillett9o', 'Lanette', 'Jillett', 'F',0,828,9, 0)
	,('csemechik9p@elpais.com',dbo.fnEncrypt(CAST( 'mVtOrad1VI4T' AS VARCHAR(4000))), 'csemechik9p', 'Curr', 'Semechik', 'M',1,305,6, 0)
	,('dhollebon9q@blogs.com',dbo.fnEncrypt(CAST( 'KV6C9MUKJxU' AS VARCHAR(4000))), 'dhollebon9q', 'Doloritas', 'Hollebon', 'F',0,522,13, 0)
	,('wrottger9r@hostgator.com',dbo.fnEncrypt(CAST( 'xR8DSHv1z9Z' AS VARCHAR(4000))), 'wrottger9r', 'Wilbert', 'Rottger', 'M',1,756,12, 0)
	,('scroisier9s@hibu.com',dbo.fnEncrypt(CAST( 'nyHdj9v' AS VARCHAR(4000))), 'scroisier9s', 'Saundra', 'Croisier', 'F',0,726,12, 0)
	,('gpostin9t@weather.com',dbo.fnEncrypt(CAST( 'hFRQWo' AS VARCHAR(4000))), 'gpostin9t', 'Gwenni', 'Postin', 'F',0,207,16, 0)
	,('varch9u@yale.edu',dbo.fnEncrypt(CAST( 'KhwhZRN3S' AS VARCHAR(4000))), 'varch9u', 'Vivyanne', 'Arch', 'F',0,668,0, 0)
	,('mmasurel9v@un.org',dbo.fnEncrypt(CAST( 'DaVPKld' AS VARCHAR(4000))), 'mmasurel9v', 'Minor', 'Masurel', 'M',1,702,1, 0)
	,('jriguard9w@patch.com',dbo.fnEncrypt(CAST( 'r2sHoj6E' AS VARCHAR(4000))), 'jriguard9w', 'Jobyna', 'Riguard', 'F',0,841,0, 0)
	,('eszapiro9x@sitemeter.com',dbo.fnEncrypt(CAST( 'i7zVKGObpp' AS VARCHAR(4000))), 'eszapiro9x', 'Emmy', 'Szapiro', 'M',0,33,2, 0)
	,('cradloff9y@illinois.edu',dbo.fnEncrypt(CAST( 'h1fS8Y0' AS VARCHAR(4000))), 'cradloff9y', 'Cody', 'Radloff', 'M',0,322,6, 0)
	,('tasals9z@slideshare.net',dbo.fnEncrypt(CAST( 'bOCvuzurZc6' AS VARCHAR(4000))), 'tasals9z', 'Timofei', 'Asals', 'M',1,851,16, 0)
	,('smandrya0@histats.com',dbo.fnEncrypt(CAST( 'Kxd3hqah' AS VARCHAR(4000))), 'smandrya0', 'Samson', 'Mandry', 'M',0,232,0, 0)
	,('mmeiera1@zdnet.com',dbo.fnEncrypt(CAST( '0HIgZUCq' AS VARCHAR(4000))), 'mmeiera1', 'Markos', 'Meier', 'M',1,815,7, 0)
	,('dhoverta2@go.com',dbo.fnEncrypt(CAST( 'zjFOl4YqSmMO' AS VARCHAR(4000))), 'dhoverta2', 'Dean', 'Hovert', 'M',0,536,20, 0)
	,('rgasgartha3@soup.io',dbo.fnEncrypt(CAST( 'LLaC6hRBso' AS VARCHAR(4000))), 'rgasgartha3', 'Rina', 'Gasgarth', 'F',0,796,12, 0)
	,('npitrolloa4@ehow.com',dbo.fnEncrypt(CAST( 'yQEX3jhfWyE4' AS VARCHAR(4000))), 'npitrolloa4', 'Nichols', 'Pitrollo', 'M',1,823,19, 0)
	,('lnaiseya5@loc.gov',dbo.fnEncrypt(CAST( 'P5dmiHyzDLtK' AS VARCHAR(4000))), 'lnaiseya5', 'Lothaire', 'Naisey', 'M',1,170,13, 0)
	,('ppeartreea6@alibaba.com',dbo.fnEncrypt(CAST( 'v6FzYzjkQ' AS VARCHAR(4000))), 'ppeartreea6', 'Prentiss', 'Peartree', 'M',1,739,17, 0)
	,('cstringmana7@psu.edu',dbo.fnEncrypt(CAST( 'OVhpb3yo5Xq' AS VARCHAR(4000))), 'cstringmana7', 'Con', 'Stringman', 'M',1,107,5, 0)
	,('ddraudea8@edublogs.org',dbo.fnEncrypt(CAST( 'MmAa8QmzMY6' AS VARCHAR(4000))), 'ddraudea8', 'Damien', 'Draude', 'M',0,630,9, 0)
	,('dcasebornea9@sbwire.com',dbo.fnEncrypt(CAST( 'Of1p8Ulzjt' AS VARCHAR(4000))), 'dcasebornea9', 'Dalila', 'Caseborne', 'F',0,413,19, 0)
	,('amacsweeneyaa@sbwire.com',dbo.fnEncrypt(CAST( '5HwXwsv' AS VARCHAR(4000))), 'amacsweeneyaa', 'Amata', 'MacSweeney', 'F',1,994,15, 0)
	,('kewingab@google.com',dbo.fnEncrypt(CAST( 'EwaPRZHTK2fN' AS VARCHAR(4000))), 'kewingab', 'Katinka', 'Ewing', 'F',0,379,9, 0)
	,('hmclenaghanac@nhs.uk',dbo.fnEncrypt(CAST( 'oqk7PIu' AS VARCHAR(4000))), 'hmclenaghanac', 'Harlene', 'McLenaghan', 'F',0,790,7, 0)
	,('tbelliveauad@hugedomains.com',dbo.fnEncrypt(CAST( 'NXy8zlkvdZ' AS VARCHAR(4000))), 'tbelliveauad', 'Tim', 'Belliveau', 'F',1,867,9, 0)
	,('gcastrilloae@i2i.jp',dbo.fnEncrypt(CAST( 'usf89ELkS' AS VARCHAR(4000))), 'gcastrilloae', 'Giraud', 'Castrillo', 'M',1,384,14, 0)
	,('rjosephoffaf@diigo.com',dbo.fnEncrypt(CAST( '93ZiX4YICUsI' AS VARCHAR(4000))), 'rjosephoffaf', 'Reuben', 'Josephoff', 'M',1,570,8, 0)
	,('bpietruszkaag@domainmarket.com',dbo.fnEncrypt(CAST( 'sA3AmpZ93X' AS VARCHAR(4000))), 'bpietruszkaag', 'Birch', 'Pietruszka', 'M',1,433,9, 0)
	,('rgoveah@flickr.com',dbo.fnEncrypt(CAST( 'vxjHQ6KWn' AS VARCHAR(4000))), 'rgoveah', 'Rad', 'Gove', 'M',0,827,4, 0)
	,('mmanhoodai@goo.ne.jp',dbo.fnEncrypt(CAST( 'oIrIVSc7kfwl' AS VARCHAR(4000))), 'mmanhoodai', 'Maggy', 'Manhood', 'F',1,80,13, 0)
	,('hwestcottaj@ameblo.jp',dbo.fnEncrypt(CAST( 'Hm7XIGS' AS VARCHAR(4000))), 'hwestcottaj', 'Hillie', 'Westcott', 'M',0,732,7, 0)
	,('sschankelborgak@imdb.com',dbo.fnEncrypt(CAST( '59jtaPvLIpZU' AS VARCHAR(4000))), 'sschankelborgak', 'Shaine', 'Schankelborg', 'M',0,111,17, 0)
	,('lburgettal@cloudflare.com',dbo.fnEncrypt(CAST( 'EkduJFj2rJas' AS VARCHAR(4000))), 'lburgettal', 'Loutitia', 'Burgett', 'F',1,637,4, 0)
	,('fshepherdsonam@samsung.com',dbo.fnEncrypt(CAST( 's640wLWESfu3' AS VARCHAR(4000))), 'fshepherdsonam', 'Fairfax', 'Shepherdson', 'M',1,146,19, 0)
	,('slockneyan@craigslist.org',dbo.fnEncrypt(CAST( 'CnDZkjNr' AS VARCHAR(4000))), 'slockneyan', 'Sonny', 'Lockney', 'F',0,236,2, 0)
	,('mbrehautao@washington.edu',dbo.fnEncrypt(CAST( 'Ybvk6Nbc' AS VARCHAR(4000))), 'mbrehautao', 'Mari', 'Brehaut', 'F',0,999,14, 0)
	,('haharoniap@altervista.org',dbo.fnEncrypt(CAST( 'oqOQX7xLMHP' AS VARCHAR(4000))), 'haharoniap', 'Huey', 'Aharoni', 'M',0,145,8, 0)
	,('bgarfootaq@sbwire.com',dbo.fnEncrypt(CAST( 'XbQvs6' AS VARCHAR(4000))), 'bgarfootaq', 'Bruce', 'Garfoot', 'M',0,24,12, 0)
	,('htrevearar@ehow.com',dbo.fnEncrypt(CAST( 'aj1lr6vW' AS VARCHAR(4000))), 'htrevearar', 'Hall', 'Trevear', 'M',0,691,8, 0)
	,('bnewcomeas@cpanel.net',dbo.fnEncrypt(CAST( 'exF2VnW' AS VARCHAR(4000))), 'bnewcomeas', 'Bartolemo', 'Newcome', 'M',0,284,10, 0)
	,('fseysat@nsw.gov.au',dbo.fnEncrypt(CAST( 'Mw3JAmC' AS VARCHAR(4000))), 'fseysat', 'Felecia', 'Seys', 'F',1,135,4, 0)
	,('cofihillieau@newyorker.com',dbo.fnEncrypt(CAST( 'qMUVC0QY' AS VARCHAR(4000))), 'cofihillieau', 'Carny', 'O''Fihillie', 'M',0,203,3, 0)
	,('webornav@hhs.gov',dbo.fnEncrypt(CAST( 'RGDrwR' AS VARCHAR(4000))), 'webornav', 'Wolfie', 'Eborn', 'M',1,143,5, 0)
	,('jplentyaw@mail.ru',dbo.fnEncrypt(CAST( 'AuaI8Pqlxhbv' AS VARCHAR(4000))), 'jplentyaw', 'Jana', 'Plenty', 'F',1,507,17, 0)
	,('mbeardwellax@i2i.jp',dbo.fnEncrypt(CAST( 'YuRiqcDiD' AS VARCHAR(4000))), 'mbeardwellax', 'Mallorie', 'Beardwell', 'F',0,219,20, 0)
	,('sbevanay@usnews.com',dbo.fnEncrypt(CAST( '2kKBq7xKIReE' AS VARCHAR(4000))), 'sbevanay', 'Siana', 'Bevan', 'F',1,722,9, 0)
	,('ebloodwortheaz@nydailynews.com',dbo.fnEncrypt(CAST( '7z1BjHVN' AS VARCHAR(4000))), 'ebloodwortheaz', 'Elena', 'Bloodworthe', 'F',1,518,2, 0)
	,('gbielefeldb0@flickr.com',dbo.fnEncrypt(CAST( 'uM7Djq' AS VARCHAR(4000))), 'gbielefeldb0', 'Gael', 'Bielefeld', 'F',0,491,19, 0)
	,('fplettsb1@live.com',dbo.fnEncrypt(CAST( 'tKhmH2l' AS VARCHAR(4000))), 'fplettsb1', 'Fina', 'Pletts', 'F',1,788,6, 0)
	,('aroddellb2@hao123.com',dbo.fnEncrypt(CAST( 'lHBMYqM8h' AS VARCHAR(4000))), 'aroddellb2', 'Archaimbaud', 'Roddell', 'M',0,157,20, 0)
	,('skleinpeltzb3@multiply.com',dbo.fnEncrypt(CAST( '3xqKWAFd' AS VARCHAR(4000))), 'skleinpeltzb3', 'Saleem', 'Kleinpeltz', 'M',1,693,13, 0)
	,('efrearb4@salon.com',dbo.fnEncrypt(CAST( '31EAxclorAal' AS VARCHAR(4000))), 'efrearb4', 'Emili', 'Frear', 'F',0,728,12, 0)
	,('risworthb5@multiply.com',dbo.fnEncrypt(CAST( 'vdnpUcrh' AS VARCHAR(4000))), 'risworthb5', 'Randa', 'Isworth', 'F',1,725,20, 0)
	,('fantonuttib6@dmoz.org',dbo.fnEncrypt(CAST( 'zcJIhnd8K3c' AS VARCHAR(4000))), 'fantonuttib6', 'Felizio', 'Antonutti', 'M',0,426,7, 0)
	,('cemmanuelib7@mtv.com',dbo.fnEncrypt(CAST( 'RbQGUaU' AS VARCHAR(4000))), 'cemmanuelib7', 'Cal', 'Emmanueli', 'M',1,202,13, 0)
	,('kcolliardb8@wikimedia.org',dbo.fnEncrypt(CAST( 'uqAfnH1a' AS VARCHAR(4000))), 'kcolliardb8', 'Kelsy', 'Colliard', 'F',1,638,11, 0)
	,('pravensb9@artisteer.com',dbo.fnEncrypt(CAST( 'yds6r9' AS VARCHAR(4000))), 'pravensb9', 'Paloma', 'Ravens', 'F',1,765,13, 0)
	,('avialsba@psu.edu',dbo.fnEncrypt(CAST( 'IDlOHYyUfb' AS VARCHAR(4000))), 'avialsba', 'Abey', 'Vials', 'M',1,460,9, 0)
	,('hswiersbb@wisc.edu',dbo.fnEncrypt(CAST( '6DJCAFC' AS VARCHAR(4000))), 'hswiersbb', 'Hillary', 'Swiers', 'F',0,800,14, 0)
	,('mclevelandbc@live.com',dbo.fnEncrypt(CAST( 'ipshAJlBt' AS VARCHAR(4000))), 'mclevelandbc', 'Merle', 'Cleveland', 'F',0,821,19, 0)
	,('sdormandbd@csmonitor.com',dbo.fnEncrypt(CAST( 'ylYzJp' AS VARCHAR(4000))), 'sdormandbd', 'Stefanie', 'Dormand', 'F',1,320,6, 0)
	,('duppettbe@unblog.fr',dbo.fnEncrypt(CAST( 'v8yhvA' AS VARCHAR(4000))), 'duppettbe', 'De witt', 'Uppett', 'M',0,566,6, 0)
	,('mboogbf@examiner.com',dbo.fnEncrypt(CAST( 'NVeelu2Ky' AS VARCHAR(4000))), 'mboogbf', 'Matthias', 'Boog', 'M',1,667,10, 0)
	,('ssworderbg@noaa.gov',dbo.fnEncrypt(CAST( 'k1GF2q' AS VARCHAR(4000))), 'ssworderbg', 'Sherman', 'Sworder', 'M',1,143,1, 0)
	,('cjillardbh@shareasale.com',dbo.fnEncrypt(CAST( 'rGPCsz' AS VARCHAR(4000))), 'cjillardbh', 'Chancey', 'Jillard', 'M',1,964,10, 0)
	,('ntaschbi@craigslist.org',dbo.fnEncrypt(CAST( 'wyngCafElL' AS VARCHAR(4000))), 'ntaschbi', 'Natalee', 'Tasch', 'F',0,982,8, 0)
	,('rquenellbj@tamu.edu',dbo.fnEncrypt(CAST( '3e3h0ydAz' AS VARCHAR(4000))), 'rquenellbj', 'Rutledge', 'Quenell', 'M',0,123,18, 0)
	,('kparkeybk@msn.com',dbo.fnEncrypt(CAST( 'pCW2jBLZyf6' AS VARCHAR(4000))), 'kparkeybk', 'Kareem', 'Parkey', 'M',0,286,13, 0)
	,('aolneybl@yale.edu',dbo.fnEncrypt(CAST( 'e26j87r' AS VARCHAR(4000))), 'aolneybl', 'Annissa', 'Olney', 'F',1,26,12, 0)
	,('dkabischbm@t.co',dbo.fnEncrypt(CAST( '0HYHvTDBJX7' AS VARCHAR(4000))), 'dkabischbm', 'Drugi', 'Kabisch', 'M',0,306,17, 0)
	,('dzealebn@blogtalkradio.com',dbo.fnEncrypt(CAST( '1p4qUwnGF4' AS VARCHAR(4000))), 'dzealebn', 'Debbie', 'Zeale', 'F',0,810,14, 0)
	,('ocullneanbo@alibaba.com',dbo.fnEncrypt(CAST( 'tbNHkxm4db' AS VARCHAR(4000))), 'ocullneanbo', 'Orsa', 'Cullnean', 'F',1,891,15, 0)
	,('lapfelbp@paginegialle.it',dbo.fnEncrypt(CAST( 'pgLbTqA' AS VARCHAR(4000))), 'lapfelbp', 'Lindi', 'Apfel', 'F',1,658,20, 0)
	,('blambertibq@wikispaces.com',dbo.fnEncrypt(CAST( 'QDFTUDBGLLcn' AS VARCHAR(4000))), 'blambertibq', 'Budd', 'Lamberti', 'M',0,572,3, 0)
	,('esimonsbr@bloglines.com',dbo.fnEncrypt(CAST( 'XKBLLPlzc7z' AS VARCHAR(4000))), 'esimonsbr', 'Elfie', 'Simons', 'F',1,375,11, 0)
	,('kmacgillivraybs@earthlink.net',dbo.fnEncrypt(CAST( 'o7fmUWf6zhY' AS VARCHAR(4000))), 'kmacgillivraybs', 'Kahlil', 'MacGillivray', 'M',1,711,5, 0)
	,('cmixbt@nsw.gov.au',dbo.fnEncrypt(CAST( 'SSCnnffXIrn' AS VARCHAR(4000))), 'cmixbt', 'Cletis', 'Mix', 'M',1,834,11, 0)
	,('lbierlingbu@fema.gov',dbo.fnEncrypt(CAST( 'IBwdOrDB' AS VARCHAR(4000))), 'lbierlingbu', 'Lyman', 'Bierling', 'M',0,386,15, 0)
	,('kdearlovebv@sfgate.com',dbo.fnEncrypt(CAST( '0VkOKC8ZZ' AS VARCHAR(4000))), 'kdearlovebv', 'Konstance', 'Dearlove', 'F',1,801,9, 0)
	,('gshipmanbw@state.gov',dbo.fnEncrypt(CAST( 'SInIwKSo' AS VARCHAR(4000))), 'gshipmanbw', 'Ginny', 'Shipman', 'F',1,629,7, 0)
	,('jsimonichbx@tripod.com',dbo.fnEncrypt(CAST( '2MlyswC' AS VARCHAR(4000))), 'jsimonichbx', 'Jard', 'Simonich', 'M',0,840,0, 0)
	,('cechelleby@wisc.edu',dbo.fnEncrypt(CAST( 'XaM5t4Vpq1s' AS VARCHAR(4000))), 'cechelleby', 'Carlo', 'Echelle', 'M',1,42,10, 0)
	,('agrimsditchbz@miibeian.gov.cn',dbo.fnEncrypt(CAST( 'krmR7K' AS VARCHAR(4000))), 'agrimsditchbz', 'Aldridge', 'Grimsditch', 'M',0,202,14, 0)
	,('lbogeyc0@fc2.com',dbo.fnEncrypt(CAST( 'AqZ7K2pEaVFw' AS VARCHAR(4000))), 'lbogeyc0', 'Lurline', 'Bogey', 'F',1,551,13, 0)
	,('mshouldersc1@meetup.com',dbo.fnEncrypt(CAST( 'zYhCX2' AS VARCHAR(4000))), 'mshouldersc1', 'Meredith', 'Shoulders', 'F',0,466,15, 0)
	,('rlilbournec2@people.com.cn',dbo.fnEncrypt(CAST( 'ipdCHirrUnfm' AS VARCHAR(4000))), 'rlilbournec2', 'Roseanne', 'Lilbourne', 'F',1,31,7, 0)
	,('rgarmansc3@hud.gov',dbo.fnEncrypt(CAST( '3YznOorTpK3' AS VARCHAR(4000))), 'rgarmansc3', 'Rosalinde', 'Garmans', 'F',0,808,11, 0)
	,('ldaidc4@rakuten.co.jp',dbo.fnEncrypt(CAST( 'py0Eqxss7BB' AS VARCHAR(4000))), 'ldaidc4', 'Leanora', 'Daid', 'F',1,191,1, 0)
	,('mgrimwadec5@mlb.com',dbo.fnEncrypt(CAST( '4QS31ED' AS VARCHAR(4000))), 'mgrimwadec5', 'Maritsa', 'Grimwade', 'F',1,94,5, 0)
	,('wheninghamc6@woothemes.com',dbo.fnEncrypt(CAST( '0oiCwimMGPs' AS VARCHAR(4000))), 'wheninghamc6', 'Walton', 'Heningham', 'M',0,918,14, 0)
	,('hbonhamc7@walmart.com',dbo.fnEncrypt(CAST( 'AhtoZ10bkGa' AS VARCHAR(4000))), 'hbonhamc7', 'Hadria', 'Bonham', 'F',0,695,5, 0)
	,('alarkinsc8@wp.com',dbo.fnEncrypt(CAST( 'YbotNU32oS' AS VARCHAR(4000))), 'alarkinsc8', 'Arnoldo', 'Larkins', 'M',0,845,8, 0)
	,('kcoggellc9@newsvine.com',dbo.fnEncrypt(CAST( 'c1TGqkMo' AS VARCHAR(4000))), 'kcoggellc9', 'Kailey', 'Coggell', 'F',1,679,2, 0)
	,('nstairsca@time.com',dbo.fnEncrypt(CAST( '8o1mpdi' AS VARCHAR(4000))), 'nstairsca', 'Noak', 'Stairs', 'M',1,586,20, 0)
	,('ahassurcb@behance.net',dbo.fnEncrypt(CAST( 'rGx2xbWyxj' AS VARCHAR(4000))), 'ahassurcb', 'Alejandrina', 'Hassur', 'F',0,918,6, 0)
	,('kmccutheoncc@microsoft.com',dbo.fnEncrypt(CAST( 'hrGyC5cl' AS VARCHAR(4000))), 'kmccutheoncc', 'Kaia', 'McCutheon', 'F',0,48,10, 0)
	,('apattlelcd@sciencedirect.com',dbo.fnEncrypt(CAST( 'OVDyN1Han' AS VARCHAR(4000))), 'apattlelcd', 'Alexina', 'Pattlel', 'F',1,486,18, 0)
	,('hlandce@eventbrite.com',dbo.fnEncrypt(CAST( 'AunfVnOX3Nt' AS VARCHAR(4000))), 'hlandce', 'Harriette', 'Land', 'F',1,914,9, 0)
	,('dhinrichscf@patch.com',dbo.fnEncrypt(CAST( 'XuvWHM' AS VARCHAR(4000))), 'dhinrichscf', 'Davidde', 'Hinrichs', 'M',1,66,11, 0)
	,('nmorrisseycg@ibm.com',dbo.fnEncrypt(CAST( '74V2E71Nht' AS VARCHAR(4000))), 'nmorrisseycg', 'Norrie', 'Morrissey', 'M',0,548,11, 0)
	,('fscreatonch@nhs.uk',dbo.fnEncrypt(CAST( 'HsJmbVNEDYy' AS VARCHAR(4000))), 'fscreatonch', 'Fletch', 'Screaton', 'M',1,391,5, 0)
	,('ascawtonci@gravatar.com',dbo.fnEncrypt(CAST( 'WtW8zpBwjI' AS VARCHAR(4000))), 'ascawtonci', 'Ado', 'Scawton', 'M',1,661,17, 0)
	,('bphytheancj@fotki.com',dbo.fnEncrypt(CAST( 'tdwxUTU68XT' AS VARCHAR(4000))), 'bphytheancj', 'Becca', 'Phythean', 'F',1,204,5, 0)
	,('smerryfieldck@livejournal.com',dbo.fnEncrypt(CAST( 'lnzaEl6' AS VARCHAR(4000))), 'smerryfieldck', 'Silvana', 'Merryfield', 'F',0,865,2, 0)
	,('mfairhurstcl@scientificamerican.com',dbo.fnEncrypt(CAST( '6rjIy3s' AS VARCHAR(4000))), 'mfairhurstcl', 'Muire', 'Fairhurst', 'F',0,91,8, 0)
	,('usilmoncm@mayoclinic.com',dbo.fnEncrypt(CAST( 'UR54Jk' AS VARCHAR(4000))), 'usilmoncm', 'Ulrica', 'Silmon', 'F',0,686,18, 0)
	,('mjegercn@vistaprint.com',dbo.fnEncrypt(CAST( 'ACllmm6tsG0' AS VARCHAR(4000))), 'mjegercn', 'Monica', 'Jeger', 'F',0,102,18, 0)
	,('nmurfettco@whitehouse.gov',dbo.fnEncrypt(CAST( 'UpXhsErLWBE3' AS VARCHAR(4000))), 'nmurfettco', 'Nixie', 'Murfett', 'F',0,388,5, 0)
	,('vgwatkinscp@disqus.com',dbo.fnEncrypt(CAST( 'isomnJWBE' AS VARCHAR(4000))), 'vgwatkinscp', 'Vikki', 'Gwatkins', 'F',1,551,7, 0)
	,('khunecq@ca.gov',dbo.fnEncrypt(CAST( '8Uf8cq30Q' AS VARCHAR(4000))), 'khunecq', 'Kelcey', 'Hune', 'F',1,102,14, 0)
	,('jpriestnercr@163.com',dbo.fnEncrypt(CAST( 'pzxiVL2jlC' AS VARCHAR(4000))), 'jpriestnercr', 'Joelly', 'Priestner', 'F',1,228,20, 0)
	,('tvasilikcs@godaddy.com',dbo.fnEncrypt(CAST( 'xgdTnw6nk' AS VARCHAR(4000))), 'tvasilikcs', 'Thom', 'Vasilik', 'M',1,707,17, 0)
	,('byukhtinct@alibaba.com',dbo.fnEncrypt(CAST( 'R97ykVdNgu6' AS VARCHAR(4000))), 'byukhtinct', 'Bryce', 'Yukhtin', 'M',1,469,20, 0)
	,('hdenningcu@delicious.com',dbo.fnEncrypt(CAST( 'kYBJq5XNdzG' AS VARCHAR(4000))), 'hdenningcu', 'Holly', 'Denning', 'M',0,314,18, 0)
	,('vbarwoodcv@sourceforge.net',dbo.fnEncrypt(CAST( 'Ljz08ONL4th' AS VARCHAR(4000))), 'vbarwoodcv', 'Vinny', 'Barwood', 'M',1,941,5, 0)
	,('wchristercw@unc.edu',dbo.fnEncrypt(CAST( 'z2qF4mPBvJ3G' AS VARCHAR(4000))), 'wchristercw', 'Worthington', 'Christer', 'M',1,1000,14, 0)
	,('tgonnelcx@tripadvisor.com',dbo.fnEncrypt(CAST( '1doMARtGb' AS VARCHAR(4000))), 'tgonnelcx', 'Terri-jo', 'Gonnel', 'F',1,891,0, 0)
	,('dbrimleycy@nature.com',dbo.fnEncrypt(CAST( 'BkvIAekUUabQ' AS VARCHAR(4000))), 'dbrimleycy', 'Drugi', 'Brimley', 'M',0,760,9, 0)
	,('acammockecz@tmall.com',dbo.fnEncrypt(CAST( 'z9YG5I' AS VARCHAR(4000))), 'acammockecz', 'Aubrey', 'Cammocke', 'M',0,53,20, 0)
	,('aborehamd0@google.co.uk',dbo.fnEncrypt(CAST( 'Lhoxv1fUncVm' AS VARCHAR(4000))), 'aborehamd0', 'Abigail', 'Boreham', 'F',0,969,6, 0)
	,('aramsdelld1@elpais.com',dbo.fnEncrypt(CAST( 'IWy9v0mr2G' AS VARCHAR(4000))), 'aramsdelld1', 'Auria', 'Ramsdell', 'F',0,213,12, 0)
	,('jmerwed2@soup.io',dbo.fnEncrypt(CAST( 'eLEXSa' AS VARCHAR(4000))), 'jmerwed2', 'Johnette', 'Merwe', 'F',1,360,3, 0)
	,('mumbersd3@skyrock.com',dbo.fnEncrypt(CAST( '5rBhqVjvuUq' AS VARCHAR(4000))), 'mumbersd3', 'Melisse', 'Umbers', 'F',1,305,0, 0)
	,('awristd4@icio.us',dbo.fnEncrypt(CAST( 'ZagWAbzRv1' AS VARCHAR(4000))), 'awristd4', 'Arabelle', 'Wrist', 'F',1,149,16, 0)
	,('tduttond5@desdev.cn',dbo.fnEncrypt(CAST( 'tJXJUTRJx' AS VARCHAR(4000))), 'tduttond5', 'Tadio', 'Dutton', 'M',0,699,1, 0)
	,('rarmatysd6@storify.com',dbo.fnEncrypt(CAST( 'QtUH0YsD1D' AS VARCHAR(4000))), 'rarmatysd6', 'Ray', 'Armatys', 'M',0,664,12, 0)
	,('pgraved7@timesonline.co.uk',dbo.fnEncrypt(CAST( 'JmipuUn' AS VARCHAR(4000))), 'pgraved7', 'Phaedra', 'Grave', 'F',1,125,6, 0)
	,('sellingfordd8@accuweather.com',dbo.fnEncrypt(CAST( 'BIk8lTPxs7v' AS VARCHAR(4000))), 'sellingfordd8', 'Sarajane', 'Ellingford', 'F',1,397,20, 0)
	,('mattled9@opera.com',dbo.fnEncrypt(CAST( 'F30lNiiLHII' AS VARCHAR(4000))), 'mattled9', 'Mella', 'Attle', 'F',1,31,1, 0)
	,('ayurinda@drupal.org',dbo.fnEncrypt(CAST( 'n0BvO61VEjD' AS VARCHAR(4000))), 'ayurinda', 'Ardelle', 'Yurin', 'F',0,88,19, 0)
	,('astilledb@nydailynews.com',dbo.fnEncrypt(CAST( 'TsWBsKF9dX' AS VARCHAR(4000))), 'astilledb', 'Alisha', 'Stille', 'F',1,925,3, 0)
	,('lelbournedc@yellowpages.com',dbo.fnEncrypt(CAST( 'JvIQ7QLj' AS VARCHAR(4000))), 'lelbournedc', 'Lisette', 'Elbourne', 'F',0,246,0, 0)
	,('bgonzalvodd@java.com',dbo.fnEncrypt(CAST( 'ZCiEKyKSQ' AS VARCHAR(4000))), 'bgonzalvodd', 'Bent', 'Gonzalvo', 'M',0,456,17, 0)
	,('kstledgerde@cdc.gov',dbo.fnEncrypt(CAST( 'HzDvvM1' AS VARCHAR(4000))), 'kstledgerde', 'Kareem', 'St. Ledger', 'M',1,91,12, 0)
	,('rdanielsendf@webeden.co.uk',dbo.fnEncrypt(CAST( 'AVvGYBzFF' AS VARCHAR(4000))), 'rdanielsendf', 'Reagen', 'Danielsen', 'M',0,403,17, 0)
	,('dmenendesdg@chicagotribune.com',dbo.fnEncrypt(CAST( 'vxFRu5giwn1' AS VARCHAR(4000))), 'dmenendesdg', 'Donnie', 'Menendes', 'M',0,339,7, 0)
	,('bgeramdh@instagram.com',dbo.fnEncrypt(CAST( 'CjjmLRUWB' AS VARCHAR(4000))), 'bgeramdh', 'Brett', 'Geram', 'F',1,155,7, 0)
	,('cdehailesdi@miitbeian.gov.cn',dbo.fnEncrypt(CAST( 'jD51d3T' AS VARCHAR(4000))), 'cdehailesdi', 'Crysta', 'De Hailes', 'F',1,472,3, 0)
	,('gdastdj@goodreads.com',dbo.fnEncrypt(CAST( 'IJw6fxy' AS VARCHAR(4000))), 'gdastdj', 'Grover', 'Dast', 'M',1,246,19, 0)
	,('esparshottdk@xing.com',dbo.fnEncrypt(CAST( 'cv8Wae' AS VARCHAR(4000))), 'esparshottdk', 'Emmott', 'Sparshott', 'M',0,976,5, 0)
	,('pbuckhurstdl@nyu.edu',dbo.fnEncrypt(CAST( 'FeVlHMOk' AS VARCHAR(4000))), 'pbuckhurstdl', 'Parry', 'Buckhurst', 'M',1,896,3, 0)
	,('senriquedm@creativecommons.org',dbo.fnEncrypt(CAST( 'MVQiojrB' AS VARCHAR(4000))), 'senriquedm', 'Sabina', 'Enrique', 'F',1,323,1, 0)
	,('bfogdendn@discovery.com',dbo.fnEncrypt(CAST( 'D1wQw7rPJeR' AS VARCHAR(4000))), 'bfogdendn', 'Burnard', 'Fogden', 'M',1,13,12, 0)
	,('gcavillado@4shared.com',dbo.fnEncrypt(CAST( 'sk7tzM7xT' AS VARCHAR(4000))), 'gcavillado', 'Gabby', 'Cavilla', 'M',1,541,2, 0)
	,('agregorettidp@europa.eu',dbo.fnEncrypt(CAST( 'S4LRqah' AS VARCHAR(4000))), 'agregorettidp', 'Amalia', 'Gregoretti', 'F',0,738,5, 0)
	,('awintourdq@census.gov',dbo.fnEncrypt(CAST( 'EH7XcxiTyBS' AS VARCHAR(4000))), 'awintourdq', 'Avivah', 'Wintour', 'F',0,9,4, 0)
	,('gkingsdr@yolasite.com',dbo.fnEncrypt(CAST( 'Frw8OVTYD81B' AS VARCHAR(4000))), 'gkingsdr', 'Goldia', 'Kings', 'F',0,908,20, 0)
	,('tdelgadods@twitpic.com',dbo.fnEncrypt(CAST( 'KY2s8yYZ0hH' AS VARCHAR(4000))), 'tdelgadods', 'Trev', 'Delgado', 'M',0,959,1, 0)
	,('bswiggdt@webmd.com',dbo.fnEncrypt(CAST( 'ZcPzL2s7' AS VARCHAR(4000))), 'bswiggdt', 'Bonnibelle', 'Swigg', 'F',0,349,9, 0)
	,('hcarbertdu@ehow.com',dbo.fnEncrypt(CAST( 'TZajxmA9Mdl' AS VARCHAR(4000))), 'hcarbertdu', 'Harris', 'Carbert', 'M',0,219,5, 0)
	,('tespasadv@hp.com',dbo.fnEncrypt(CAST( 'zm8VzZZFh53' AS VARCHAR(4000))), 'tespasadv', 'Tades', 'Espasa', 'M',1,501,9, 0)
	,('smchaledw@cbsnews.com',dbo.fnEncrypt(CAST( '11Bsp6OPy' AS VARCHAR(4000))), 'smchaledw', 'Sarine', 'McHale', 'F',0,457,5, 0)
	,('pandrejsdx@home.pl',dbo.fnEncrypt(CAST( 'Jrm0h0G6w' AS VARCHAR(4000))), 'pandrejsdx', 'Patricio', 'Andrejs', 'M',0,90,9, 0)
	,('gwybrowdy@theatlantic.com',dbo.fnEncrypt(CAST( 'ZejXbj' AS VARCHAR(4000))), 'gwybrowdy', 'Grantley', 'Wybrow', 'M',1,707,7, 0)
	,('rlindldz@jiathis.com',dbo.fnEncrypt(CAST( 'A1gDhmq' AS VARCHAR(4000))), 'rlindldz', 'Roma', 'Lindl', 'M',0,884,1, 0)
	,('dreye0@com.com',dbo.fnEncrypt(CAST( '4S7Kpq2' AS VARCHAR(4000))), 'dreye0', 'Darb', 'Rey', 'F',1,169,3, 0)
	,('tughettie1@auda.org.au',dbo.fnEncrypt(CAST( 'K9oUNuYhr' AS VARCHAR(4000))), 'tughettie1', 'Tildi', 'Ughetti', 'F',1,207,4, 0)
	,('gnijse2@dedecms.com',dbo.fnEncrypt(CAST( 'DkjakOpPMG' AS VARCHAR(4000))), 'gnijse2', 'Gerrie', 'Nijs', 'F',1,527,6, 0)
	,('bduere3@cbslocal.com',dbo.fnEncrypt(CAST( 'lUeYOPsv' AS VARCHAR(4000))), 'bduere3', 'Brewer', 'Duer', 'M',1,723,18, 0)
	,('cpaxfordee4@mayoclinic.com',dbo.fnEncrypt(CAST( 'GAi5TI5rkH' AS VARCHAR(4000))), 'cpaxfordee4', 'Culley', 'Paxforde', 'M',0,121,0, 0)
	,('eguerreaue5@spiegel.de',dbo.fnEncrypt(CAST( 'y0bn7yB7So9N' AS VARCHAR(4000))), 'eguerreaue5', 'Englebert', 'Guerreau', 'M',1,20,13, 0)
	,('mgenningse6@1und1.de',dbo.fnEncrypt(CAST( 'u7c9WmO' AS VARCHAR(4000))), 'mgenningse6', 'Michale', 'Gennings', 'M',0,160,15, 0)
	,('cfranzolinie7@nymag.com',dbo.fnEncrypt(CAST( 'kOLoLKRNBg7I' AS VARCHAR(4000))), 'cfranzolinie7', 'Cesare', 'Franzolini', 'M',1,770,11, 0)
	,('jiberte8@nationalgeographic.com',dbo.fnEncrypt(CAST( '7sWiqHlO' AS VARCHAR(4000))), 'jiberte8', 'Jinny', 'Ibert', 'F',1,455,8, 0)
	,('snollete9@xing.com',dbo.fnEncrypt(CAST( 'fvVAj8bp' AS VARCHAR(4000))), 'snollete9', 'Stepha', 'Nollet', 'F',1,373,7, 0)
	,('nkerinsea@google.co.uk',dbo.fnEncrypt(CAST( 'NGZSQfcdp' AS VARCHAR(4000))), 'nkerinsea', 'Nani', 'Kerins', 'F',0,960,6, 0)
	,('nlowndesbrougheb@home.pl',dbo.fnEncrypt(CAST( 'sCQ735R1QKXh' AS VARCHAR(4000))), 'nlowndesbrougheb', 'Netty', 'Lowndesbrough', 'F',1,458,15, 0)
	,('tmarfellec@wiley.com',dbo.fnEncrypt(CAST( 'tAqtxCbfwDi' AS VARCHAR(4000))), 'tmarfellec', 'Tiffani', 'Marfell', 'F',1,317,10, 0)
	,('tsmoothed@statcounter.com',dbo.fnEncrypt(CAST( 'UF5NP9' AS VARCHAR(4000))), 'tsmoothed', 'Trumann', 'Smooth', 'M',1,278,20, 0)
	,('ajakuboviczee@yahoo.co.jp',dbo.fnEncrypt(CAST( '9xXxGF' AS VARCHAR(4000))), 'ajakuboviczee', 'Angelika', 'Jakubovicz', 'F',0,139,15, 0)
	,('beagleshamef@pinterest.com',dbo.fnEncrypt(CAST( 'C9VGCffF' AS VARCHAR(4000))), 'beagleshamef', 'Boone', 'Eaglesham', 'M',1,247,15, 0)

/*-------------------------------------------------------------------------------- 
									SHOES 
  --------------------------------------------------------------------------------*/
  INSERT INTO shoes (userId, shoeBrandId, model, totalMiles) VALUES
	 (103, 11, 'Pegasus 1', 66)
	,(102, 11, 'Runner', 71)
	,(113, 4, 'Glycerin', 136)
	,(105, 4, 'Summer trainers', 5)
	,(115, 11, 'nike elite', 4)
	,(111, 1, 'Workout shoe', 43)
	,(116, 2, '7th grade cross', 43)
	,(111, 1, 'Training Shoe', 43)
	,(117, 1, 'Supernova Classic 1', 74)
	,(123, 1, 'Adiprene', 1)
	,(80, 11, 'Pegasus', 3)
	,(80, 11, 'Eldoret', 43)
	,(80, 11, 'Zoom Vapor', 25)
	,(102, 11, 'Pegasus', 4)
	,(113, 11, 'Vapor', 33)
	,(128, 1, 'Swisher', 12)
	,(113, 11, 'Eldoret', 23)
	,(112, 11, 'Pegesus', 64)
	,(137, 1, 'P.F. Flyers', 43)
	,(137, 1, 'asdf', 43)
	,(113, 4, 'Glycerin Gold', 145)
	,(1, 2, 'GBlank', 43)
	,(102, 1, 'Nova Cushion', 30)
	,(225, 11, 'Nike Air Tempest', 3)
	,(112, 11, 'OLD Pegasus', 138)
	,(117, 1, 'Supernova Cushion', 58)
	,(102, 4, 'Brooks Trance', 35)
	,(149, 11, 'vapors', 43)
	,(161, 8, 'About to be Retired', 163)
	,(161, 11, 'Pegasus Racer', 195)
	,(168, 1, 'Gel', 155)
	,(170, 2, 'Gel Landreth', 21)
	,(171, 4, 'Adrenaline GTS 4', 41)
	,(178, 2, '1090', 99)
	,(183, 2, 'Gel DS-lyte Trainers', 15)
	,(113, 4, 'WINTER', 108)
	,(105, 10, 'Winter', 25)
	,(161, 2, 'Gel-Landreth', 128)
	,(206, 8, 'winter training', 205)
	,(152, 1, 'GEL''N', 43)
	,(80, 11, 'Pegasus 1', 43)
	,(225, 8, 'Mizuno', 5)
	,(81, 11, 'Air Pegasus', 115)
	,(228, 1, 'Q''s Shoe', 43)
	,(228, 1, 'Zap''s Shoe', 43)
	,(102, 11, 'Pegasus 2', 37)
	,(225, 8, 'Mizuno', 7)
	,(205, 2, '2090s', 11)
	,(123, 1, 'Addidas - Red', 57)
	,(174, 2, '1090s', 102)
	,(175, 8, 'Riders VII Spring 1', 35)
	,(206, 8, 'maverick', 145)
	,(281, 2, '2080''s', 43)
	,(289, 4, 'trainer', 43)
	,(289, 16, 'indoor racing flats', 6)
	,(148, 2, 'Old Asics', 43)
	,(302, 11, 'Nike Free', 45)
	,(302, 1, 'Adidas Trail', 2)
	,(290, 1, 'Boston Classic', 43)
	,(303, 3, 'Sweet Running Shoes', 43)
	,(296, 1, 'adidas', 36)
	,(296, 4, 'Books', 25)
	,(81, 11, 'Air Pegasus', 21)
	,(305, 2, 'toast', 5)
	,(302, 11, 'Hero''s', 24)
	,(299, 8, 'Wave Rider 7', 15)
	,(309, 11, 'Green Elite 1', 7)
	,(279, 11, 'air structure', 44)
	,(279, 11, 'Nike Waflles', 29)
	,(299, 11, 'Zoom Elite', 44)
	,(311, 11, 'Nike', 48)
	,(313, 8, 'Wave Nirvana #1', 44)
	,(313, 8, 'Wave Nirvana #2', 56)
	,(318, 11, 'Nike', 35)
	,(319, 1, '1', 18)
	,(179, 8, 'wave precision', 53)
	,(324, 11, 'Favorite', 37)
	,(327, 4, 'Burn2', 21)
	,(327, 4, 'Trance', 43)
	,(1, 2, 'Gel - 1100', 43)
	,(178, 2, 'gt-2100', 69)
	,(314, 1, 'Tough', 20)
	,(314, 11, 'Blue Flash', 22)
	,(320, 18, 'shoe1', 11)
	,(112, 11, '05 Pegasus', 162)
	,(299, 8, 'Wave Rider 8', 5)
	,(293, 8, 'Wave Mustang', 43)
	,(302, 1, 'New Trail', 43)
	,(113, 4, 'Sping Glycerin', 98)
	,(333, 1, 'Cushion 2', 26)
	,(333, 8, 'Revolvers', 10)
	,(126, 8, '1', 43)
	,(126, 4, '2', 8)
	,(333, 11, 'Kennedy XC''s Camo', 15)
	,(333, 1, 'Adidas Spikes', 8)
	,(333, 1, 'Cushion 1', 27)
	,(313, 8, 'Wave Nirvana #3', 43)
	,(337, 2, 'Trainers', 10)
	,(337, 1, 'Adistars', 36)
	,(325, 2, 'Ace', 43)
	,(102, 11, 'Pegasus 3', 10)
	,(105, 10, 'NB kicks', 23)
	,(289, 18, 'Bare Feet', 13)
	,(289, 4, 'trainer 2', 9)
	,(1, 2, 'GT - 2100', 43)
	,(352, 2, 'shoe', 43)
	,(309, 12, 'Patti', 27)
	,(337, 2, 'Trainers2', 18)
	,(349, 11, 'T-Bomb', 43)
	,(340, 2, 'New Trainers', 43)
	,(289, 4, 'track spike', 12)
	,(349, 1, 'Old Skul', 12)
	,(351, 4, 'Radius', 5)
	,(358, 4, 'Brooks 1', 43)
	,(296, 11, 'solas', 44)
	,(333, 1, 'Cushion 3', 86)
	,(330, 11, 'Moto', 43)
	,(309, 11, 'green elite 2', 456)
	,(363, 8, 'Aero', 3)
	,(363, 8, 'Rider 8', 3)
	,(363, 8, 'Rider 8 (2)', 3)
	,(363, 8, 'Rider 8 (3)', 43)
	,(363, 8, 'Rider 8 (4)', 7)
	,(175, 8, 'Wave Rider VIII Spring', 63)
	,(374, 11, 'Pegasus', 43)
	,(375, 2, 'duomax', 43)
	,(375, 1, 'fbvfwevgfr', 43)
	,(299, 11, 'Zoom Ethiopia', 20)
	,(299, 1, 'Cosmos', 16)
	,(379, 2, 'april', 43)
	,(384, 2, '2080', 43)
	,(384, 2, 'Orange Spikes', 43)
	,(382, 11, 'Track Workout Shoe', 43)
	,(382, 8, 'Best Since Triax', 43)
	,(392, 4, 'training shoe', 43)
	,(309, 10, '900 #1', 12)
	,(392, 4, 'training shoe', 43)
	,(392, 4, 'track racing shoe', 43)
	,(399, 11, 'pegasus', 43)
	,(174, 8, 'Gorby', 74)
	,(313, 8, 'Wave Nirvana #4', 53)
	,(102, 11, 'Air Max Moto', 33)
	,(358, 4, 'Brooks 05(1)', 9)
	,(358, 11, 'Steeple Spikes', 43)
	,(396, 2, 'Bob', 43)
	,(384, 1, '2100', 43)
	,(384, 1, '2100', 43)
	,(337, 2, 'Trainers3', 8)
	,(402, 1, 'Supernova Control', 43)
	,(402, 1, 'Supernova Control(2)', 43)
	,(367, 11, 'Grey Pegasus', 43)
	,(337, 4, 'T3s', 10)
	,(367, 11, 'Streak Ekidens', 43)
	,(409, 1, 'Supernova classic', 43)
	,(409, 4, 'Adrenaline GTS 5', 43)
	,(409, 1, 'New Classics', 43)
	,(352, 2, 'ds trainer', 9)
	,(408, 4, 'Trance', 43)
	,(414, 11, 'Perseus', 43)
	,(415, 1, 'Cubato', 43)
	,(415, 11, 'Zoom Elite', 43)
	,(338, 2, 'Gel Nimbus', 43)
	,(383, 4, 'Spring 1', 43)
	,(353, 8, 'running shoes', 43)
	,(383, 11, 'Spring 2', 43)
	,(352, 1, 'rotterdam II', 30)
	,(205, 2, '2100s', 17)
	,(197, 2, 'asics 2100(1)', 43)
	,(434, 11, 'bob', 43)
	,(434, 1, 'bob', 43)
	,(192, 11, 'christine', 43)
	,(192, 11, 'Veronica', 43)
	,(431, 8, 'Mizuno Wave Maverick', 43)
	,(439, 2, 'Best shoe ever', 43)
	,(451, 2, 'Asics part 2', 43)
	,(458, 14, 'The Dawg', 43)
	,(458, 2, 'Steeple Spikes', 43)
	,(457, 11, 'blue and gold', 43)
	,(363, 8, 'Mustang', 43)
	,(460, 11, 'Trail Exposure II', 43)
	,(457, 11, 'blue and white', 43)
	,(398, 8, 'Summer Shoes', 43)
	,(178, 8, '1st mizuno', 83)
	,(445, 13, 'H52', 43)
	,(175, 8, 'Wave Rider VIII Summer', 33)
	,(112, 11, 'Summer Peg', 151)
	,(457, 11, 'red and white', 43)
	,(485, 11, 'Peg', 43)
	,(487, 2, 'Cumulus', 43)
	,(149, 1, 'Jet Streams', 43)
	,(175, 8, 'Mizuno Wave Rider VI Fall 1', 24)
	,(309, 8, 'Mavy', 22)
	,(500, 8, 'Inspire', 43)
	,(495, 11, 'Pegasus 1', 43)
	,(501, 8, 'Trainers 1', 43)
	,(445, 13, 'h55', 5)
	,(495, 11, 'Span 1', 5)
	,(445, 11, 'jasari', 5)
	,(471, 11, 'zoom air miler', 4)
	,(520, 10, 'NB 690', 5);

/*-------------------------------------------------------------------------------- 
							WORKOUT TYPES
  --------------------------------------------------------------------------------*/
INSERT INTO workoutTypes (description, sortOrder) VALUES
	 ('Easy Run', 10)
	,('Normal Run', 0)
	,('Hard Run', 30)
	,('Long Run', 40)
	,('Interval Workout', 5000)
	,('Cross Training/Other', 7000)
	,('Recovery', 100)
	,('Endurance', 50)
	,('Tempo', 70)
	,('Race', 6000)
	,('NO RUN - OFF', 500)
	,('Medium Run', 20)
	,('Hill Training', 60)
	,('Aqua Jogging', 90)
	,('Fartlek', 80)
	,('Threshold', 120)
	,('wu/cd', 130)
	,('Speed Training', 110)
	,('Progression Run', 45)
	,('Cycling', 200)
	,('Elliptical', 201)
	,('Hiking', 202)
	,('VO2 Max', 46)
	,('Steady State', 55)
	,('Other', 10000)

/*-------------------------------------------------------------------------------- 
									WORKOUTS 
  --------------------------------------------------------------------------------*/
INSERT INTO workouts (userid, workoutTypeid, timeOfDayId, shoeId, workoutDate, totalMiles, totalSeconds) VALUES
	(105,2,1,37,'8/21/2004',5,2400),
	(105,2,3,102,'8/16/2004',3,1500),
	(105,2,3,37,'8/23/2004',3,1500),
	(113,2,2,36,'8/24/2004',7,2940),
	(105,2,2,102,'8/28/2004',3,1500),
	(105,2,2,37,'8/29/2004',4,1800),
	(117,2,2,9,'8/31/2004',7,2867),
	(117,2,2,26,'9/1/2004',5,3300),
	(115,2,3,5,'9/1/2004',5,2008),
	(105,2,1,4,'9/4/2004',5,2700),
	(113,2,1,17,'9/5/2004',7,2980),
	(113,2,2,15,'9/3/2004',6,0),
	(113,2,2,15,'9/6/2004',9,3641),
	(117,2,1,26,'9/2/2004',7,0),
	(117,2,1,26,'9/3/2004',7,0),
	(80,2,2,13,'9/7/2004',9,0),
	(105,2,3,37,'9/7/2004',3,1500),
	(113,2,2,17,'9/7/2004',4,0),
	(117,2,2,9,'9/8/2004',9,3270),
	(102,2,2,2,'9/8/2004',9,3600),
	(128,2,1,16,'9/2/2004',7,2482),
	(102,2,2,46,'9/9/2004',8,3240),
	(113,2,2,17,'9/9/2004',8,3143),
	(113,2,2,3,'9/8/2004',7,3101),
	(117,2,1,26,'9/11/2004',2,0),
	(112,2,1,186,'9/12/2004',7,3081),
	(105,2,1,102,'9/11/2004',5,2100),
	(117,2,2,9,'9/15/2004',6,2520),
	(112,2,1,85,'9/15/2004',10,3696),
	(80,2,2,13,'9/15/2004',10,3569),
	(113,2,2,21,'9/15/2004',10,3597),
	(113,2,2,21,'9/13/2004',9,0),
	(117,2,2,26,'9/17/2004',7,0),
	(117,2,1,9,'9/18/2004',7,2940),
	(112,2,1,18,'9/19/2004',10,4142),
	(117,2,2,26,'9/21/2004',9,3321),
	(102,2,2,2,'9/21/2004',9,3660),
	(102,2,2,14,'9/23/2004',9,3600),
	(113,2,2,17,'9/23/2004',8,3266),
	(112,2,2,18,'9/23/2004',8,3274),
	(102,2,1,46,'9/25/2004',9,3600),
	(102,2,1,2,'9/26/2004',9,3605),
	(113,2,1,3,'9/26/2004',7,2989),
	(113,2,2,15,'9/28/2004',9,3631),
	(102,2,2,2,'9/28/2004',9,3600),
	(123,2,1,49,'9/24/2004',3,1680),
	(112,2,2,18,'9/29/2004',7,2982),
	(117,2,2,9,'9/29/2004',7,2940),
	(117,2,1,26,'9/30/2004',7.5,0),
	(112,2,3,18,'10/2/2004',7,2917),
	(113,2,2,21,'9/29/2004',7,2953),
	(105,2,3,102,'10/4/2004',3,1800),
	(105,2,2,37,'9/27/2004',3,1680),
	(113,2,2,15,'10/4/2004',8,3307),
	(117,2,2,9,'10/4/2004',9,0),
	(113,2,2,3,'10/5/2004',10,0),
	(112,2,2,18,'10/4/2004',8,3237),
	(112,2,1,85,'10/6/2004',8,3234),
	(113,2,1,36,'10/6/2004',8,3284),
	(112,2,1,85,'10/7/2004',8,3215),
	(112,2,1,186,'10/9/2004',7,2909),
	(102,2,2,14,'10/9/2004',9,3600),
	(112,2,1,18,'10/10/2004',8,3231),
	(113,2,2,17,'10/7/2004',6,2368),
	(102,2,1,142,'10/10/2004',9,3600),
	(113,2,3,17,'10/10/2004',5,2102),
	(117,2,2,9,'10/8/2004',7,0),
	(117,2,2,9,'10/6/2004',8,0),
	(112,2,1,25,'10/12/2004',8,3374),
	(123,2,1,10,'10/12/2004',3.7,1862),
	(113,2,2,3,'10/12/2004',8,3330),
	(128,2,1,16,'10/10/2004',5,2100),
	(117,2,3,9,'10/15/2004',7,2520),
	(113,2,2,15,'10/14/2004',7.5,3300),
	(117,2,2,26,'10/16/2004',9,0),
	(112,2,1,25,'10/15/2004',5,0),
	(112,2,1,85,'10/17/2004',9,3732),
	(113,2,1,36,'10/17/2004',7,2779),
	(102,2,2,23,'10/18/2004',9.5,3720),
	(112,2,1,85,'10/18/2004',10,4002),
	(113,2,2,89,'10/18/2004',9,3701),
	(112,2,1,186,'10/20/2004',7,2789),
	(113,2,2,15,'10/20/2004',6,2483),
	(113,2,2,17,'10/21/2004',8,3272),
	(112,2,1,85,'10/21/2004',8,0),
	(117,2,2,9,'10/22/2004',7,0),
	(117,2,2,26,'10/18/2004',5,0),
	(112,2,1,18,'10/23/2004',6,2633),
	(113,2,3,17,'10/23/2004',6.5,2623),
	(113,2,2,21,'10/24/2004',6,2492),
	(112,2,1,186,'10/24/2004',5,2128),
	(102,2,2,2,'10/24/2004',6,2400),
	(113,2,2,17,'10/26/2004',8,3360),
	(112,2,1,25,'10/26/2004',8,3372),
	(113,2,2,89,'10/28/2004',6,2482),
	(112,2,2,85,'10/28/2004',6,2547),
	(112,2,2,85,'10/29/2004',5,0),
	(112,2,1,186,'10/31/2004',7.5,0),
	(112,2,2,18,'11/1/2004',8,3262),
	(102,2,2,14,'11/2/2004',7,2880),
	(112,2,2,25,'11/2/2004',8,3273),
	(113,2,2,17,'10/31/2004',8,0),
	(113,2,2,36,'10/29/2004',5,0),
	(113,2,2,36,'11/4/2004',6,2437),
	(102,2,2,14,'11/4/2004',6,2400),
	(112,2,2,186,'11/4/2004',6,0),
	(105,2,3,102,'11/4/2004',3,1800),
	(105,2,3,4,'11/1/2004',3,1800),
	(105,2,3,4,'11/5/2004',3,1800),
	(112,2,2,18,'11/7/2004',6,2496),
	(102,2,2,14,'11/7/2004',7.5,3000),
	(105,2,2,37,'11/7/2004',4,1980),
	(112,2,2,186,'11/9/2004',6,2542),
	(123,2,3,10,'11/9/2004',4.5,2367),
	(123,2,2,10,'11/11/2004',3,1685),
	(112,2,2,186,'11/11/2004',6,2505),
	(112,2,2,85,'11/12/2004',5,0),
	(113,2,2,21,'11/12/2004',5,2160),
	(113,2,2,21,'11/9/2004',7,2880),
	(123,2,2,49,'11/16/2004',3,1770),
	(123,2,2,10,'11/18/2004',4.5,2338),
	(123,2,1,49,'11/20/2004',6.2,3180),
	(123,2,2,49,'11/21/2004',3,1440),
	(123,2,2,10,'11/23/2004',3,1742),
	(102,2,2,142,'11/25/2004',4,1680),
	(102,2,3,46,'11/26/2004',4,1680),
	(102,2,2,101,'11/27/2004',4,1498),
	(102,2,2,2,'11/28/2004',4,1680),
	(102,2,2,14,'11/29/2004',4,0),
	(123,2,1,49,'11/27/2004',3.6,1860),
	(112,2,2,25,'11/30/2004',5,0),
	(102,2,2,27,'11/30/2004',6,0),
	(113,2,2,21,'11/29/2004',6,2498),
	(102,2,2,27,'12/1/2004',4.5,1800),
	(113,2,1,36,'12/1/2004',5,2132),
	(102,2,2,101,'12/2/2004',4,0),
	(170,2,2,32,'12/1/2004',8,3480),
	(168,2,2,31,'8/19/2004',0,0),
	(112,2,2,186,'12/2/2004',7,2909),
	(112,2,2,18,'12/3/2004',6,2702),
	(168,2,2,31,'12/3/2004',6,2490),
	(178,2,2,34,'12/1/2004',4,1627),
	(178,2,2,183,'12/2/2004',4,1644),
	(178,2,2,183,'12/3/2004',4,1665),
	(178,2,2,34,'11/30/2004',3,0),
	(168,2,2,31,'9/2/2004',8,0),
	(171,2,2,33,'11/30/2004',4,1800),
	(171,2,2,33,'11/29/2004',3,1348),
	(123,2,2,10,'12/2/2004',3,1811),
	(161,2,1,30,'12/4/2004',6.5,2632),
	(102,2,2,142,'12/4/2004',6,0),
	(170,2,2,32,'12/4/2004',13,0),
	(183,2,1,35,'12/5/2004',11,4380),
	(112,2,1,186,'12/6/2004',6,2590),
	(183,2,1,35,'12/6/2004',4.5,1980),
	(178,2,2,183,'12/6/2004',4,1721),
	(113,2,2,89,'12/6/2004',6,2560),
	(113,2,2,36,'12/5/2004',6.5,3000),
	(113,2,2,36,'12/4/2004',6,0),
	(113,2,2,3,'12/2/2004',7,2904),
	(102,2,2,2,'12/6/2004',6,0),
	(178,2,2,183,'12/7/2004',3,1210),
	(102,2,2,27,'12/7/2004',5,0),
	(112,2,3,18,'12/7/2004',4,0),
	(178,2,2,81,'12/8/2004',4,1710),
	(161,2,2,30,'12/8/2004',7,2905),
	(102,2,2,2,'12/8/2004',6,0),
	(178,2,2,81,'12/9/2004',3,1298),
	(161,2,2,29,'12/9/2004',4.5,1865),
	(178,2,2,34,'12/10/2004',4,1693),
	(168,2,2,31,'12/10/2004',7,0),
	(171,2,2,33,'12/7/2004',4,1800),
	(171,2,2,33,'12/8/2004',1,507),
	(171,2,2,33,'12/11/2004',6,2400),
	(161,2,1,30,'12/12/2004',4.5,1860),
	(178,2,2,183,'12/12/2004',4,1703),
	(178,2,2,81,'12/13/2004',3,1315),
	(102,2,2,142,'12/13/2004',6,0),
	(178,2,2,34,'12/14/2004',3,1275),
	(102,2,2,27,'12/14/2004',6.5,0),
	(178,2,2,183,'12/15/2004',4,1680),
	(115,2,3,5,'12/13/2004',6,2520),
	(115,2,2,5,'12/15/2004',6,2400),
	(161,2,1,30,'12/16/2004',4,1620),
	(102,2,2,23,'12/15/2004',7,0),
	(178,2,2,34,'12/16/2004',4,1677),
	(178,2,2,34,'12/17/2004',4,1650),
	(115,2,3,5,'12/17/2004',7,3084),
	(178,2,2,81,'12/19/2004',4,1689),
	(161,2,1,30,'12/19/2004',6.5,2728),
	(178,2,2,34,'12/20/2004',4.6,2100),
	(115,2,2,5,'12/18/2004',6.2,2463),
	(161,2,1,30,'12/20/2004',5.5,2280),
	(161,2,1,30,'12/21/2004',3,1260),
	(161,2,2,29,'12/21/2004',4,1654),
	(178,2,2,34,'12/21/2004',4,1678),
	(115,2,3,5,'12/21/2004',6,2520),
	(168,2,2,31,'12/21/2004',7,2858),
	(178,2,2,183,'12/22/2004',4,1657),
	(161,2,1,38,'12/22/2004',5,2040),
	(102,2,2,27,'12/22/2004',6,2520),
	(206,2,2,39,'12/20/2004',8,2932),
	(115,2,2,5,'12/23/2004',0,0),
	(115,2,2,5,'12/23/2004',0,0),
	(115,2,2,5,'12/23/2004',0,0),
	(206,2,2,39,'12/23/2004',7,2820),
	(171,2,2,33,'12/23/2004',1,420),
	(102,2,2,14,'12/23/2004',5,0),
	(161,2,1,29,'12/24/2004',5,0),
	(178,2,2,81,'12/24/2004',4,1698),
	(102,2,2,142,'12/24/2004',8,3360),
	(105,2,1,102,'12/19/2004',3,1800),
	(115,2,2,5,'12/26/2004',10.5,4500),
	(161,2,2,29,'12/26/2004',6,2520),
	(178,2,2,81,'12/27/2004',4.6,0),
	(171,2,2,33,'12/26/2004',7,3049),
	(168,2,2,31,'12/27/2004',8.5,3244),
	(102,2,2,14,'12/27/2004',7,2940),
	(115,2,2,5,'12/27/2004',0,0),
	(161,2,1,30,'12/27/2004',4.5,0),
	(161,2,1,29,'12/28/2004',5.5,0),
	(178,2,2,34,'12/28/2004',4.4,1978),
	(115,2,2,5,'12/28/2004',5,2100),
	(161,2,1,38,'12/29/2004',6,0),
	(206,2,2,52,'12/29/2004',7,2683),
	(168,2,2,31,'12/29/2004',8,0),
	(178,2,2,34,'12/29/2004',4,1808),
	(161,2,1,29,'12/30/2004',6,0),
	(178,2,2,81,'12/30/2004',2.5,1208),
	(168,2,2,31,'12/30/2004',6,2393),
	(161,2,1,30,'12/31/2004',4,1555),
	(206,2,2,39,'12/31/2004',10,3859),
	(168,2,2,31,'12/31/2004',7,2828),
	(112,2,2,18,'12/31/2004',5,2106),
	(178,2,2,183,'1/1/2005',4,1718),
	(206,2,2,52,'1/1/2005',5,1963),
	(205,2,1,48,'1/2/2005',1.84,1212),
	(115,2,2,5,'1/2/2005',0,0),
	(113,2,2,15,'1/2/2005',8,3013),
	(113,2,2,3,'1/1/2005',6.5,2708),
	(161,2,1,38,'1/2/2005',8,3120),
	(178,2,2,183,'1/2/2005',4,1578),
	(161,2,1,29,'1/3/2005',7,0),
	(115,2,3,5,'1/3/2005',5,2100),
	(178,2,2,183,'1/3/2005',5,2178),
	(206,2,2,39,'1/3/2005',10,3914),
	(113,2,2,15,'1/3/2005',7,2788),
	(178,2,2,34,'1/4/2005',5,0),
	(80,2,2,13,'1/4/2005',6,0),
	(206,2,2,52,'1/4/2005',6,2384),
	(168,2,2,31,'1/5/2005',5,1935),
	(113,2,2,3,'1/5/2005',9,3631),
	(113,2,2,21,'1/4/2005',6.5,2605),
	(80,2,2,11,'1/5/2005',3,1184),
	(115,2,3,5,'1/5/2005',8,3360),
	(171,2,2,33,'1/5/2005',4.25,1800),
	(178,2,2,183,'1/5/2005',4,0),
	(178,2,2,34,'1/6/2005',4,1573),
	(178,2,2,34,'1/6/2005',1,0),
	(161,2,1,29,'1/5/2005',5,0),
	(161,2,2,29,'1/6/2005',5,0),
	(113,2,2,36,'1/6/2005',6,2422),
	(225,2,3,47,'1/6/2005',0,0),
	(161,2,1,30,'1/7/2005',6,0),
	(161,2,2,30,'1/7/2005',5,2068),
	(171,2,2,33,'1/7/2005',5.5,2400),
	(178,2,2,183,'1/7/2005',5,2074),
	(178,2,2,81,'1/7/2005',1,0),
	(178,2,2,183,'1/8/2005',4,1802),
	(115,2,2,5,'1/7/2005',0,0),
	(161,2,2,38,'1/9/2005',5.5,0),
	(178,2,1,81,'1/9/2005',7,2889),
	(81,2,2,43,'1/7/2005',7,2880),
	(113,2,2,3,'1/9/2005',5,2081),
	(113,2,2,36,'1/8/2005',7,2676),
	(113,2,2,15,'1/7/2005',7.5,3080),
	(102,2,1,46,'1/10/2005',8,3240),
	(168,2,2,31,'1/10/2005',8,3028),
	(178,2,2,34,'1/10/2005',2,788),
	(112,2,2,25,'1/10/2005',6,2222),
	(205,2,3,167,'1/10/2005',2.24,1200),
	(161,2,2,29,'1/10/2005',6,0),
	(178,2,3,81,'1/10/2005',3,0),
	(113,2,2,3,'1/10/2005',8,3160),
	(225,2,3,24,'1/10/2005',3,0),
	(178,2,2,34,'1/11/2005',3,1248),
	(178,2,2,183,'1/11/2005',1,0),
	(81,2,2,43,'1/11/2005',9,3720),
	(206,2,2,39,'1/11/2005',5.5,2253),
	(115,2,2,5,'1/11/2005',5,2080),
	(113,2,2,17,'1/11/2005',6,2485),
	(178,2,2,81,'1/12/2005',2,807),
	(113,2,2,89,'1/12/2005',8,3142),
	(112,2,2,85,'1/11/2005',6,2495),
	(112,2,2,25,'1/12/2005',8,3136),
	(178,2,3,34,'1/12/2005',5,0),
	(168,2,2,31,'1/8/2001',4.5,1800),
	(168,2,2,31,'1/9/2001',4.5,1800),
	(168,2,2,31,'1/12/2001',5,0),
	(168,2,2,31,'1/14/2001',6,0),
	(168,2,2,31,'1/15/2001',6,0),
	(168,2,2,31,'1/16/2001',6,0),
	(168,2,2,31,'1/17/2001',6.5,0),
	(168,2,2,31,'1/19/2001',3,0),
	(168,2,2,31,'1/21/2001',8,0),
	(168,2,2,31,'1/22/2001',6,0),
	(168,2,2,31,'1/23/2001',7,0),
	(168,2,2,31,'1/25/2001',7,0),
	(168,2,2,31,'1/28/2001',8,0),
	(168,2,2,31,'1/29/2001',7,0),
	(123,2,3,10,'1/12/2005',3,1623),
	(123,2,3,49,'1/9/2005',3,1800),
	(81,2,2,63,'1/12/2005',8,3000),
	(113,2,2,17,'1/13/2005',7,2916),
	(161,2,2,38,'1/12/2005',5,0),
	(161,2,1,38,'1/13/2005',6,0),
	(112,2,2,186,'1/13/2005',7,2927),
	(178,2,2,183,'1/14/2005',5,2207),
	(225,2,3,42,'1/13/2005',2,0),
	(161,2,2,38,'1/14/2005',6,0),
	(115,2,2,5,'1/14/2005',5.5,2213),
	(112,2,2,186,'1/14/2005',10,4140),
	(161,2,1,29,'1/15/2005',5.5,0),
	(206,2,2,39,'1/14/2005',0,2700),
	(174,2,2,50,'1/15/2005',1,480),
	(112,2,2,18,'1/15/2005',6,2500),
	(81,2,2,43,'1/15/2005',6,2460),
	(81,2,2,63,'1/15/2005',3,1260),
	(178,2,2,183,'1/15/2005',5.5,2278),
	(178,2,2,34,'1/15/2005',1,0),
	(161,2,1,30,'1/16/2005',6,0),
	(178,2,2,183,'1/16/2005',4,1768),
	(113,2,2,89,'1/16/2005',7,3439),
	(113,2,2,3,'1/14/2005',10,4128),
	(113,2,2,17,'1/15/2005',7,2928),
	(112,2,2,85,'1/16/2005',7,3439),
	(161,2,1,30,'1/17/2005',6,0),
	(112,2,2,18,'1/17/2005',8,3374),
	(174,2,2,140,'1/17/2005',3,1250),
	(113,2,2,3,'1/17/2005',8,3374),
	(171,2,2,33,'1/11/2005',6,2400),
	(178,2,2,183,'1/17/2005',5.5,0),
	(113,2,2,89,'1/18/2005',8,3317),
	(174,2,3,140,'1/18/2005',4,1660),
	(206,2,2,52,'1/18/2005',6,2470),
	(206,2,2,52,'1/19/2005',7,2891),
	(161,2,2,30,'1/18/2005',7,0),
	(161,2,2,29,'1/19/2005',7,0),
	(112,2,2,25,'1/18/2005',8,3174),
	(178,2,2,81,'1/18/2005',6,2703),
	(178,2,2,183,'1/18/2005',0.5,0),
	(178,2,2,34,'1/19/2005',3,1388),
	(178,2,2,81,'1/19/2005',4.5,0),
	(161,2,2,30,'1/20/2005',7,0),
	(174,2,2,50,'1/19/2005',3,1420),
	(174,2,3,50,'1/19/2005',5,0),
	(174,2,2,140,'1/20/2005',5,2311),
	(113,2,2,15,'1/20/2005',8,3314),
	(112,2,2,18,'1/20/2005',8,3299),
	(178,2,2,81,'1/20/2005',5,2314),
	(81,2,2,63,'1/20/2005',7,2880),
	(81,2,2,43,'1/21/2005',8,3169),
	(81,2,2,63,'1/17/2005',7,2700),
	(178,2,2,34,'1/21/2005',0.5,0),
	(206,2,2,52,'1/21/2005',8.5,3477),
	(161,2,2,38,'1/21/2005',6,0),
	(112,2,2,25,'1/21/2005',6,2326),
	(123,2,1,10,'1/16/2005',2.5,2040),
	(123,2,1,49,'1/17/2005',3.2,1890),
	(123,2,1,10,'1/18/2005',3.2,1890),
	(123,2,1,49,'1/20/2005',3.2,1830),
	(161,2,2,38,'1/22/2005',7,0),
	(174,2,2,50,'1/22/2005',3,1320),
	(206,2,2,39,'1/22/2005',9.5,3600),
	(178,2,2,183,'1/22/2005',4,1654),
	(115,2,2,5,'1/22/2005',0,0),
	(161,2,1,29,'1/23/2005',6,0),
	(174,2,2,50,'1/23/2005',4.5,0),
	(178,2,2,183,'1/23/2005',5,2296),
	(175,2,2,124,'1/23/2005',5.7,2416),
	(112,2,2,25,'1/23/2005',7,2669),
	(225,2,1,47,'1/22/2005',3,0),
	(225,2,2,47,'1/23/2005',4,0),
	(113,2,2,3,'1/22/2005',7,2751),
	(113,2,2,21,'1/21/2005',8,3353),
	(113,2,2,15,'1/23/2005',7,2669),
	(178,2,2,34,'1/24/2005',3,1284),
	(175,2,2,185,'1/24/2005',3,1287),
	(161,2,2,30,'1/24/2005',6,0),
	(115,2,2,5,'1/24/2005',5.5,2220),
	(175,2,2,191,'1/24/2005',4,0),
	(178,2,3,81,'1/24/2005',4,0),
	(225,2,3,42,'1/24/2005',3,0),
	(161,2,1,30,'1/25/2005',6.5,0),
	(178,2,2,81,'1/25/2005',5,0),
	(112,2,2,18,'1/25/2005',8,3174),
	(174,2,2,140,'1/24/2005',3,1290),
	(174,2,2,50,'1/24/2005',4,0),
	(175,2,2,51,'1/25/2005',5,0),
	(115,2,2,5,'1/25/2005',6,2460),
	(206,2,2,52,'1/25/2005',10.5,4208),
	(113,2,2,21,'1/25/2005',8,3174),
	(81,2,2,43,'1/25/2005',10,4020),
	(161,2,2,38,'1/26/2005',6.5,0),
	(115,2,2,5,'1/26/2005',7,2940),
	(174,2,2,50,'1/27/2005',5,2097),
	(112,2,2,18,'1/27/2005',7,2906),
	(161,2,2,29,'1/27/2005',7,0),
	(206,2,2,39,'1/27/2005',7.5,3010),
	(113,2,2,89,'1/27/2005',7,2888),
	(206,2,2,52,'1/28/2005',8,3117),
	(123,2,3,49,'1/27/2005',3.5,1891),
	(175,2,2,185,'1/28/2005',5,2078),
	(112,2,2,85,'1/28/2005',6,2532),
	(174,2,2,50,'1/28/2005',5,2080),
	(115,2,2,5,'1/28/2005',5,2004),
	(174,2,1,50,'1/29/2005',7,2927),
	(178,2,2,34,'1/28/2005',5,2082),
	(178,2,2,81,'1/29/2005',7,2951),
	(161,2,2,38,'1/29/2005',8.5,0),
	(115,2,2,5,'1/29/2005',7,2870),
	(175,2,2,51,'1/29/2005',7,2962),
	(102,2,1,2,'1/30/2005',13,5040),
	(279,2,2,68,'1/30/2005',5,0),
	(174,2,2,50,'1/30/2005',2,840),
	(279,2,2,68,'1/26/2005',3,0),
	(279,2,2,69,'1/28/2005',5,0),
	(174,2,2,140,'1/30/2005',4,1840),
	(115,2,2,5,'1/30/2005',10,4131),
	(113,2,1,15,'1/29/2005',5,2125),
	(113,2,2,3,'1/30/2005',7,2864),
	(161,2,1,29,'1/30/2005',6.5,0),
	(81,2,2,63,'1/30/2005',12,4800),
	(123,2,2,49,'1/30/2005',5,2400),
	(112,2,2,186,'1/30/2005',7,2864),
	(174,2,2,50,'1/31/2005',5,0),
	(115,2,2,5,'1/31/2005',7,2896),
	(161,2,1,30,'2/1/2005',6.5,0),
	(178,2,2,34,'2/1/2005',1,420),
	(174,2,2,50,'2/1/2005',5,1966),
	(174,2,2,140,'2/1/2005',1,0),
	(115,2,1,5,'2/1/2005',7,2879),
	(112,2,2,85,'2/1/2005',9,0),
	(206,2,2,52,'2/2/2005',6,2612),
	(161,2,1,29,'2/2/2005',6.5,0),
	(279,2,2,69,'2/2/2005',5,0),
	(113,2,2,21,'2/2/2005',9.5,3399),
	(113,2,2,17,'2/1/2005',7,2820),
	(115,2,2,5,'2/2/2005',8,3222),
	(105,2,2,37,'1/30/2005',3,1500),
	(161,2,2,29,'2/3/2005',6,0),
	(302,2,3,65,'2/3/2005',4,0),
	(178,2,2,34,'2/3/2005',7,2971),
	(175,2,2,124,'2/3/2005',7,2968),
	(296,2,3,61,'2/3/2005',4,0),
	(296,2,3,115,'2/2/2005',2,0),
	(174,2,2,50,'2/3/2005',7,2965),
	(81,2,2,63,'2/3/2005',7,2520),
	(279,2,2,68,'2/3/2005',4,0),
	(305,2,2,64,'2/4/2005',5.5,2400),
	(205,2,2,167,'2/4/2005',2,1038),
	(302,2,2,58,'2/4/2005',2.5,0),
	(161,2,2,30,'2/4/2005',7.5,0),
	(115,2,2,5,'2/4/2005',8,3137),
	(112,2,2,186,'2/3/2005',7,2913),
	(206,2,2,52,'2/4/2005',6,2388),
	(113,2,2,17,'2/3/2005',7,2903),
	(161,2,2,38,'2/5/2005',6,0),
	(279,2,2,68,'2/5/2005',4,0),
	(123,2,2,10,'2/3/2005',4.5,2072),
	(123,2,2,49,'2/5/2005',4,2028),
	(296,2,1,62,'2/5/2005',6,2490),
	(112,2,2,186,'2/5/2005',6.5,2724),
	(206,2,2,52,'2/5/2005',5,2040),
	(161,2,1,29,'2/6/2005',6.5,0),
	(279,2,2,69,'2/6/2005',5,0),
	(178,2,2,34,'2/7/2005',5,2400),
	(174,2,2,50,'2/6/2005',2,0),
	(175,2,2,191,'2/7/2005',5,0),
	(174,2,2,140,'2/6/2005',4,1860),
	(112,2,2,18,'2/6/2005',6,0),
	(113,2,2,3,'2/5/2005',8,3262),
	(113,2,2,21,'2/6/2005',6,2329),
	(299,2,2,128,'2/7/2005',6,2651),
	(115,2,3,5,'2/7/2005',8,3260),
	(206,2,2,39,'2/7/2005',7,2908),
	(205,2,1,167,'2/8/2005',2.5,1500),
	(309,2,2,118,'2/8/2005',6.5,2511),
	(206,2,2,52,'2/8/2005',8.5,3466),
	(115,2,2,5,'2/8/2005',6.25,2544),
	(311,2,1,71,'1/1/2005',4,2100),
	(311,2,2,71,'1/10/2005',2,1008),
	(311,2,2,71,'1/12/2005',2.5,1263),
	(161,2,1,30,'2/8/2005',6.5,0),
	(161,2,1,29,'2/9/2005',6.5,0),
	(174,2,2,140,'2/9/2005',6,2685),
	(81,2,2,43,'2/9/2005',6,2340),
	(115,2,3,5,'2/9/2005',8,3134),
	(313,2,3,72,'2/7/2005',3.2,1740),
	(313,2,3,141,'2/8/2005',2,1740),
	(112,2,2,18,'2/8/2005',10,0),
	(112,2,2,85,'2/9/2005',7,2941),
	(112,2,2,186,'2/10/2005',8,3314),
	(161,2,2,30,'2/10/2005',7.5,0),
	(289,2,2,111,'2/10/2005',7,3000),
	(81,2,2,43,'2/10/2005',9,3540),
	(115,2,3,5,'2/10/2005',7,2940),
	(206,2,2,39,'2/10/2005',8.5,3276),
	(289,2,1,111,'2/11/2005',3.5,1500),
	(296,2,2,115,'2/9/2005',6,0),
	(296,2,2,61,'2/10/2005',3.5,0),
	(161,2,2,30,'2/11/2005',7,0),
	(206,2,2,52,'2/11/2005',7,2696),
	(115,2,3,5,'2/11/2005',8,3194),
	(81,2,2,43,'2/11/2005',10,3900),
	(112,2,2,186,'2/12/2005',6,2530),
	(206,2,2,39,'2/12/2005',5,2012),
	(81,2,2,43,'2/12/2005',8,3060),
	(175,2,1,124,'2/13/2005',7,2937),
	(309,2,1,118,'2/13/2005',10,3960),
	(289,2,3,55,'2/12/2005',3.5,1500),
	(113,2,3,17,'2/13/2005',10,4040),
	(113,2,1,15,'2/12/2005',6,2529),
	(113,2,2,89,'2/10/2005',8,3374),
	(113,2,2,3,'2/9/2005',7,2933),
	(113,2,2,36,'2/8/2005',8,3214),
	(81,2,3,63,'2/13/2005',5,1980),
	(313,2,3,141,'2/2/2005',2.2,1800),
	(313,2,3,73,'2/3/2005',3.3,1800),
	(313,2,1,72,'2/5/2005',6.7,3600),
	(178,2,2,34,'2/14/2005',7.5,3137),
	(115,2,3,5,'2/13/2005',13,5400),
	(115,2,2,5,'2/12/2005',7,2880),
	(174,2,2,140,'2/14/2005',7,2880),
	(318,2,2,74,'2/14/2005',6,2687),
	(115,2,2,5,'2/14/2005',5,2062),
	(309,2,4,136,'2/14/2005',0,0),
	(175,2,2,185,'2/14/2005',7,2883),
	(161,2,1,38,'2/15/2005',7.5,0),
	(206,2,2,39,'2/15/2005',7,2671),
	(318,2,2,74,'2/15/2005',7,0),
	(103,2,2,1,'2/14/2005',9,0),
	(103,2,2,1,'2/13/2005',10,0),
	(103,2,2,1,'2/15/2005',6,2520),
	(112,2,2,85,'2/15/2005',10,0),
	(205,2,2,48,'2/15/2005',2.5,1500),
	(309,2,2,136,'2/16/2005',6,2250),
	(318,2,2,74,'2/16/2005',7,0),
	(115,2,2,5,'2/16/2005',8,3308),
	(311,2,2,71,'2/16/2005',2,1094),
	(311,2,2,71,'1/13/2005',2,1043),
	(311,2,2,71,'1/19/2005',4,1746),
	(311,2,2,71,'1/26/2005',2,1008),
	(311,2,2,71,'2/1/2005',3.5,1601),
	(311,2,2,71,'2/2/2005',4,1709),
	(311,2,2,71,'2/6/2005',5,2939),
	(311,2,2,71,'2/8/2005',2,912),
	(311,2,2,71,'2/10/2005',2,1102),
	(161,2,2,29,'2/16/2005',9,0),
	(81,2,2,63,'2/15/2005',8,2940),
	(81,2,2,43,'2/16/2005',10,3900),
	(289,2,1,111,'2/15/2005',2,840),
	(289,2,2,103,'2/15/2005',6.5,0),
	(103,2,2,1,'2/16/2005',6.5,0),
	(161,2,2,29,'2/17/2005',6.5,0),
	(112,2,2,186,'2/17/2005',6,2413),
	(206,2,2,39,'2/17/2005',7,2747),
	(289,2,1,104,'2/17/2005',2,0),
	(174,2,2,50,'2/17/2005',1.5,673),
	(174,2,2,140,'2/17/2005',1.5,0),
	(296,2,2,61,'2/17/2005',5.5,2334),
	(302,2,2,57,'2/17/2005',5.5,2334),
	(279,2,2,68,'2/17/2005',1.5,0),
	(115,2,3,5,'2/17/2005',2,840),
	(205,2,1,48,'2/18/2005',2.61,1500),
	(309,2,1,118,'2/18/2005',6,2268),
	(318,2,2,74,'2/18/2005',7,0),
	(174,2,2,50,'2/18/2005',7,2970),
	(175,2,2,124,'2/18/2005',7,0),
	(161,2,2,38,'2/18/2005',6.5,0),
	(115,2,2,5,'2/18/2005',8,3300),
	(179,2,2,76,'2/18/2005',7,0),
	(112,2,2,25,'2/19/2005',8,3278),
	(175,2,2,124,'2/19/2005',4.5,0),
	(206,2,2,52,'2/18/2005',6,2389),
	(279,2,2,69,'2/19/2005',2,0),
	(113,2,3,21,'2/19/2005',6,2598),
	(113,2,2,21,'2/17/2005',6,2415),
	(113,2,2,21,'2/15/2005',8,3240),
	(319,2,2,75,'2/19/2005',10,4380),
	(81,2,2,43,'2/19/2005',5,2040),
	(309,2,1,118,'2/20/2005',10,3756),
	(112,2,2,25,'2/20/2005',5,2058),
	(175,2,2,51,'2/20/2005',7,3030),
	(81,2,2,63,'2/20/2005',10,3900),
	(161,2,1,38,'2/20/2005',5,0),
	(161,2,2,30,'2/21/2005',7.5,0),
	(175,2,1,124,'2/21/2005',6,2646),
	(178,2,2,34,'2/21/2005',7,2958),
	(81,2,1,43,'2/21/2005',4.5,1800),
	(279,2,2,68,'2/21/2005',3,0),
	(324,2,1,77,'2/21/2005',7,2804),
	(324,2,1,77,'2/20/2005',6,2306),
	(311,2,2,71,'2/17/2005',7,3246),
	(311,2,3,71,'2/21/2005',4,1766),
	(112,2,2,25,'2/21/2005',9.5,3850),
	(309,2,4,136,'2/22/2005',0,0),
	(327,2,1,78,'2/22/2005',10,3910),
	(327,2,1,78,'2/21/2005',10.5,4140),
	(161,2,1,30,'2/22/2005',7.5,0),
	(296,2,2,62,'2/22/2005',6.5,2952),
	(206,2,2,39,'2/22/2005',8,3122),
	(103,2,2,1,'2/21/2005',6,0),
	(103,2,2,1,'2/17/2005',7,0),
	(103,2,2,1,'2/19/2005',7.5,3180),
	(324,2,1,77,'2/23/2005',6,2381),
	(314,2,2,82,'2/17/2005',5,0),
	(279,2,1,69,'2/23/2005',4,0),
	(113,2,2,17,'2/20/2005',9,3667),
	(113,2,2,3,'2/21/2005',9.5,3851),
	(311,2,3,71,'2/22/2005',2,1037),
	(102,2,2,23,'2/23/2005',8,3300),
	(112,2,2,25,'2/23/2005',7,2935),
	(115,2,4,5,'2/23/2005',7,2878),
	(161,2,2,38,'2/23/2005',6.5,0),
	(289,2,1,55,'2/23/2005',2.5,1200),
	(289,2,2,103,'2/18/2005',4,1800),
	(313,2,3,73,'2/23/2005',5,3037),
	(113,2,2,15,'2/23/2005',7,2931),
	(313,2,2,73,'1/1/2005',5,0),
	(313,2,2,73,'1/2/2005',2.1,0),
	(313,2,2,72,'1/3/2005',3.2,0),
	(313,2,2,73,'1/4/2005',2.1,0),
	(313,2,2,141,'1/5/2005',3,0),
	(313,2,2,141,'1/6/2005',2.1,0),
	(313,2,2,141,'1/8/2005',7.2,0),
	(313,2,2,141,'1/9/2005',2.1,0),
	(313,2,2,73,'1/10/2005',3.2,0),
	(313,2,2,141,'1/11/2005',2,0),
	(313,2,2,72,'1/13/2005',2.4,0),
	(313,2,2,97,'1/15/2005',14,0),
	(313,2,2,97,'1/16/2005',2.1,0),
	(313,2,2,141,'1/17/2005',3.1,0),
	(313,2,2,97,'1/18/2005',2.3,0),
	(313,2,2,72,'1/19/2005',3.1,0),
	(313,2,2,73,'1/20/2005',2.2,0),
	(313,2,2,141,'1/22/2005',7,0),
	(313,2,2,73,'1/23/2005',2.1,0),
	(313,2,2,141,'1/24/2005',3.3,0),
	(313,2,2,141,'1/25/2005',2,0),
	(313,2,2,97,'1/27/2005',3,0),
	(313,2,2,73,'1/30/2005',1.5,0),
	(313,2,2,72,'1/31/2005',3.2,0),
	(206,2,2,39,'2/24/2005',6,2301),
	(174,2,2,50,'2/24/2005',1.5,707),
	(174,2,2,140,'2/24/2005',1.5,0),
	(318,2,2,74,'2/22/2005',8,0),
	(179,2,2,76,'2/24/2005',4,1547),
	(179,2,2,76,'2/24/2005',3,0),
	(161,2,2,30,'2/24/2005',6.5,0),
	(115,2,3,5,'2/24/2005',5,2013),
	(309,2,1,118,'2/25/2005',5,1827),
	(279,2,1,69,'2/25/2005',3,0),
	(324,2,1,77,'2/25/2005',4,1602),
	(161,2,1,29,'2/25/2005',9,0),
	(206,2,2,52,'2/25/2005',8,3070),
	(319,2,2,75,'2/25/2005',8,3360),
	(179,2,2,76,'2/25/2005',6,0),
	(313,2,3,73,'2/25/2005',3.3,1800),
	(174,2,1,50,'2/26/2005',8,3462),
	(279,2,2,69,'2/26/2005',2,0),
	(115,2,3,5,'2/26/2005',8,3300),
	(206,2,2,39,'2/26/2005',7,2787),
	(175,2,2,185,'2/27/2005',7,2955),
	(179,2,2,76,'2/27/2005',6,0),
	(102,2,2,14,'2/27/2005',10,4200),
	(103,2,2,1,'2/27/2005',6,2340),
	(103,2,2,1,'2/23/2005',7,0),
	(103,2,2,1,'2/24/2005',4.5,1800),
	(161,2,1,29,'2/26/2005',5,0),
	(161,2,1,30,'2/27/2005',5,0),
	(309,2,1,192,'2/27/2005',6,2278),
	(102,2,2,46,'2/28/2005',8,3240),
	(102,2,2,14,'3/2/2005',4,1590),
	(102,2,1,101,'3/3/2005',2,820),
	(320,2,1,84,'2/28/2005',1,1080),
	(320,2,1,84,'2/27/2005',2,1800),
	(320,2,1,84,'2/25/2005',2,1800),
	(320,2,1,84,'2/26/2005',2,1800),
	(205,2,1,48,'2/28/2005',2,1200),
	(123,2,2,10,'2/27/2005',5.5,2783),
	(123,2,2,49,'2/26/2005',5,2469),
	(112,2,2,85,'2/26/2005',7,2903),
	(112,2,2,25,'2/27/2005',8,3276),
	(313,2,2,73,'2/28/2005',5,3360),
	(161,2,2,38,'2/28/2005',6,0),
	(81,2,2,43,'3/2/2005',9,3540),
	(81,2,2,63,'3/3/2005',8,3120),
	(81,2,2,43,'3/5/2005',7,2700),
	(174,2,2,140,'2/28/2005',7,2969),
	(175,2,2,51,'2/28/2005',7,2973),
	(299,2,2,66,'2/28/2005',7,2910),
	(299,2,2,129,'2/27/2005',6.5,2850),
	(299,2,2,70,'2/25/2005',5.25,2340),
	(299,2,2,129,'2/22/2005',4,1560),
	(206,2,2,39,'2/28/2005',6,2366),
	(309,2,4,67,'3/1/2005',0,0),
	(313,2,3,97,'3/1/2005',5.5,3360),
	(81,2,1,63,'3/1/2005',4,1620),
	(320,2,2,84,'3/1/2005',0,0),
	(320,2,1,84,'3/2/2005',2,1800),
	(296,2,2,61,'3/2/2005',6.5,2730),
	(309,2,4,192,'3/2/2005',0,0),
	(179,2,2,76,'3/2/2005',4,0),
	(161,2,2,30,'3/1/2005',5.5,0),
	(161,2,2,29,'3/2/2005',5.5,0),
	(112,2,2,186,'3/2/2005',9,3652),
	(115,2,4,5,'3/1/2005',0,0),
	(313,2,3,97,'3/2/2005',5.6,3314),
	(113,2,2,21,'3/2/2005',9,3652),
	(205,2,2,167,'3/2/2005',2.25,900),
	(206,2,2,52,'3/1/2005',8,3267),
	(206,2,2,39,'3/2/2005',6,2324),
	(174,2,2,140,'3/3/2005',1.5,690),
	(174,2,2,140,'3/3/2005',2.5,0),
	(179,2,2,76,'3/3/2005',6,0),
	(299,2,2,66,'3/1/2005',8.5,3390),
	(112,2,2,85,'3/3/2005',8,3360),
	(333,2,2,96,'3/3/2005',7,2820),
	(333,2,1,94,'3/3/2005',4,1620),
	(309,2,4,118,'3/3/2005',0,0),
	(113,2,2,36,'3/3/2005',8,3360),
	(113,2,2,3,'2/26/2005',6,2566),
	(113,2,2,15,'2/27/2005',8,3157),
	(113,2,2,15,'2/28/2005',8,2810),
	(320,2,1,84,'3/4/2005',2,1800),
	(103,2,2,1,'3/3/2005',6,2580),
	(103,2,2,1,'3/2/2005',6,2520),
	(103,2,2,1,'3/1/2005',6,0),
	(309,2,1,107,'3/4/2005',6,2304),
	(179,2,2,76,'3/4/2005',7,0),
	(333,2,2,91,'2/28/2005',10.5,4320),
	(205,2,3,167,'3/4/2005',4.38,2400),
	(333,2,2,90,'3/2/2005',8.5,3513),
	(296,2,2,61,'3/4/2005',7.5,3221),
	(313,2,2,72,'3/5/2005',5.5,3481),
	(179,2,2,76,'3/5/2005',7,0),
	(112,2,2,186,'3/5/2005',6,2504),
	(161,2,2,30,'3/3/2005',5.5,0),
	(161,2,2,38,'3/4/2005',5,0),
	(161,2,2,30,'3/5/2005',5.5,0),
	(161,2,2,30,'3/6/2005',5.5,0),
	(206,2,2,39,'3/3/2005',7,2700),
	(206,2,2,52,'3/5/2005',8,3089),
	(309,2,1,107,'3/6/2005',10,3783),
	(302,2,2,65,'3/6/2005',5,2133),
	(115,2,2,5,'3/6/2005',7.5,3300),
	(179,2,2,76,'3/6/2005',6,0),
	(337,2,2,108,'2/28/2005',8,3600),
	(337,2,2,99,'3/1/2005',8,3360),
	(112,2,2,25,'3/6/2005',10,4136),
	(175,2,2,51,'3/6/2005',2,0),
	(175,2,2,51,'3/6/2005',4,0),
	(175,2,1,191,'3/7/2005',5,2116),
	(279,2,2,69,'3/7/2005',3,0),
	(289,2,1,103,'3/7/2005',1,600),
	(289,2,2,104,'3/7/2005',3,1620),
	(333,2,3,95,'3/7/2005',8,3196),
	(179,2,2,76,'3/7/2005',6,0),
	(103,2,2,1,'3/7/2005',9.5,0),
	(103,2,2,1,'3/6/2005',2,0),
	(103,2,2,1,'3/5/2005',6,0),
	(112,2,2,25,'3/7/2005',9.5,0),
	(81,2,2,63,'3/7/2005',9.5,0),
	(309,2,2,192,'3/8/2005',6,2295),
	(206,2,2,52,'3/6/2005',6,2383),
	(81,2,2,63,'3/8/2005',8,3300),
	(337,2,2,99,'3/8/2005',10,4200),
	(112,2,2,18,'3/8/2005',8,3306),
	(179,2,2,76,'3/8/2005',2.25,900),
	(115,2,3,5,'3/8/2005',7.9,3300),
	(103,2,2,1,'3/8/2005',7.5,3180),
	(313,2,3,73,'3/8/2005',5.6,3264),
	(175,2,2,51,'3/8/2005',4.25,0),
	(179,2,2,76,'3/9/2005',1,0),
	(179,2,2,76,'3/9/2005',2,0),
	(333,2,1,94,'3/9/2005',7,2930),
	(333,2,3,94,'3/9/2005',4,1666),
	(309,2,4,118,'3/10/2005',0,0),
	(105,2,2,102,'3/4/2005',3,1500),
	(289,2,1,103,'3/10/2005',1.5,900),
	(175,2,2,124,'3/10/2005',5.5,0),
	(179,2,2,76,'3/10/2005',6,0),
	(337,2,2,108,'3/10/2005',10,4260),
	(313,2,3,97,'3/10/2005',5.5,3269),
	(103,2,2,1,'3/10/2005',6,0),
	(179,2,2,76,'3/11/2005',6,0),
	(175,2,2,51,'3/11/2005',1,0),
	(175,2,2,124,'3/11/2005',4.25,0),
	(299,2,2,128,'3/7/2005',7,2895),
	(299,2,2,129,'3/10/2005',6,2640),
	(333,2,1,116,'3/10/2005',6,2387),
	(333,2,2,96,'3/10/2005',6,2435),
	(179,2,2,76,'3/12/2005',5,0),
	(309,2,1,107,'3/11/2005',5,0),
	(206,2,2,52,'3/8/2005',7,2760),
	(206,2,2,39,'3/10/2005',8,3120),
	(206,2,2,39,'3/11/2005',10,3780),
	(206,2,2,52,'3/12/2005',7,2698),
	(313,2,1,141,'3/12/2005',5.6,3525),
	(337,2,2,98,'3/12/2005',10,4200),
	(296,2,3,62,'3/12/2005',6.5,2479),
	(299,2,2,70,'3/13/2005',5,2219),
	(175,2,2,185,'3/13/2005',6,0),
	(175,2,2,51,'3/12/2005',10,0),
	(296,2,2,115,'3/13/2005',9.5,4200),
	(179,2,2,76,'3/13/2005',7,0),
	(333,2,3,90,'3/12/2005',9.5,3853),
	(115,2,2,5,'3/13/2005',8.2,3300),
	(309,2,1,192,'3/13/2005',10,4052),
	(113,2,3,89,'3/13/2005',12,5040),
	(123,2,2,49,'3/13/2005',5,2822),
	(179,2,2,76,'3/14/2005',6,0),
	(313,2,3,72,'3/14/2005',5.4,3480),
	(175,2,2,124,'3/14/2005',1,418),
	(126,2,2,93,'3/10/2005',8,3170),
	(175,2,3,191,'3/14/2005',2.2,912),
	(112,2,2,25,'3/10/2005',6,0),
	(112,2,2,18,'3/13/2005',7,0),
	(112,2,2,186,'3/12/2005',3,0),
	(206,2,2,39,'3/14/2005',8.5,3303),
	(309,2,1,136,'3/15/2005',6,2330),
	(289,2,2,104,'3/15/2005',4,0),
	(302,2,3,65,'3/15/2005',5.5,0),
	(115,2,3,5,'3/15/2005',8,3300),
	(179,2,2,76,'3/15/2005',7,0),
	(337,2,2,99,'3/15/2005',10,4200),
	(112,2,2,85,'3/15/2005',10,4028),
	(313,2,3,72,'3/15/2005',3.5,2160),
	(123,2,2,49,'3/8/2005',4,2040),
	(123,2,2,10,'3/12/2005',4.5,2340),
	(352,2,2,157,'3/15/2005',9,3027),
	(179,2,2,76,'3/16/2005',6.5,0),
	(206,2,2,39,'3/16/2005',8,3064),
	(296,2,3,115,'3/16/2005',6.5,2712),
	(352,2,2,106,'3/16/2005',10,3242),
	(112,2,2,25,'3/17/2005',6,2334),
	(115,2,2,5,'3/17/2005',8.1,3300),
	(123,2,2,49,'3/17/2005',3,1674),
	(179,2,2,76,'3/17/2005',7,0),
	(337,2,2,148,'3/17/2005',8,3600),
	(296,2,2,115,'3/17/2005',7.5,3120),
	(175,2,2,185,'3/17/2005',1,403),
	(175,2,2,185,'3/16/2005',1,0),
	(175,2,2,191,'3/15/2005',1,0),
	(175,2,2,124,'3/15/2005',6.4,0),
	(333,2,2,90,'3/17/2005',8.25,3400),
	(349,2,2,112,'3/17/2005',4.5,1980),
	(313,2,3,141,'3/17/2005',7.5,4669),
	(174,2,2,50,'3/17/2005',1,403),
	(174,2,2,140,'3/17/2005',4,1832),
	(174,2,2,50,'3/16/2005',4,0),
	(174,2,2,50,'3/15/2005',3,0),
	(174,2,2,50,'3/14/2005',3,1391),
	(352,2,2,106,'3/17/2005',6,2302),
	(174,2,2,140,'3/18/2005',1,423),
	(174,2,2,140,'3/18/2005',4,1745),
	(296,2,2,61,'3/18/2005',2,0),
	(296,2,3,115,'3/18/2005',6,0),
	(175,2,2,51,'3/18/2005',1,0),
	(175,2,1,51,'3/19/2005',10.5,4601),
	(313,2,1,72,'3/19/2005',5.6,3434),
	(352,2,2,106,'3/18/2005',5,2042),
	(352,2,1,106,'3/19/2005',9,3784),
	(352,2,4,157,'3/20/2005',0,0),
	(112,2,2,18,'3/19/2005',7,2844),
	(296,2,3,115,'3/19/2005',6.5,2554),
	(333,2,2,96,'3/19/2005',8.5,3420),
	(296,2,2,61,'3/20/2005',7.25,3128),
	(179,2,2,76,'3/20/2005',7,0),
	(115,2,2,5,'3/20/2005',8,3300),
	(174,2,2,140,'3/20/2005',5,0),
	(337,2,2,99,'3/20/2005',8,3600),
	(103,2,2,1,'3/20/2005',7,0),
	(103,2,1,1,'3/19/2005',6,0),
	(103,2,2,1,'3/18/2005',6,0),
	(103,2,2,1,'3/11/2005',6,0),
	(103,2,2,1,'3/12/2005',6,0),
	(103,2,2,1,'3/13/2005',7,0),
	(113,2,2,17,'3/20/2005',8.5,3388),
	(113,2,2,21,'3/19/2005',7,2840),
	(113,2,2,36,'3/17/2005',6,2417),
	(113,2,2,21,'3/16/2005',9.5,3898),
	(113,2,2,89,'3/14/2005',7,2917),
	(113,2,2,36,'3/7/2005',9.5,0),
	(113,2,2,36,'3/8/2005',8,3180),
	(115,2,3,5,'3/21/2005',8,3310),
	(113,2,2,21,'3/6/2005',10,4138),
	(113,2,1,3,'3/5/2005',6,2504),
	(81,2,2,63,'3/21/2005',6,2400),
	(296,2,3,62,'3/21/2005',6.5,2676),
	(299,2,2,128,'3/17/2005',7.5,3120),
	(314,2,2,83,'3/20/2005',7,2645),
	(314,2,2,82,'3/18/2005',3.5,1355),
	(314,2,2,83,'3/16/2005',9,3855),
	(314,2,2,82,'3/14/2005',5,0),
	(314,2,2,83,'3/12/2005',3,1046),
	(314,2,2,82,'3/13/2005',6.5,2611),
	(313,2,3,73,'3/21/2005',6.5,4080),
	(179,2,2,76,'3/21/2005',6,0),
	(175,2,2,124,'3/21/2005',1,397),
	(175,2,2,185,'3/22/2005',1,0),
	(81,2,2,63,'3/22/2005',6,2400),
	(179,2,1,76,'3/22/2005',5,0),
	(112,2,2,85,'3/22/2005',7,2810),
	(349,2,2,112,'3/21/2005',8,3480),
	(313,2,3,73,'3/22/2005',4.8,2940),
	(179,2,1,76,'3/23/2005',8.2,0),
	(352,2,2,166,'3/22/2005',7,2777),
	(352,2,2,106,'3/21/2005',5,1946),
	(161,2,2,30,'3/21/2005',5.5,0),
	(161,2,2,38,'3/22/2005',5.5,0),
	(161,2,2,29,'3/23/2005',6.5,0),
	(174,2,2,140,'3/23/2005',1,435),
	(174,2,1,140,'3/22/2005',1.5,0),
	(358,2,2,143,'3/21/2005',9,3402),
	(302,2,2,65,'3/23/2005',5,0),
	(175,2,2,185,'3/23/2005',1,435),
	(313,2,3,141,'3/23/2005',4.5,3000),
	(337,2,2,152,'3/23/2005',10,4200),
	(81,2,2,63,'3/23/2005',6.5,2520),
	(352,2,2,166,'3/23/2005',7.6,3054),
	(179,2,2,76,'3/24/2005',5,0),
	(161,2,2,38,'3/24/2005',7,0),
	(175,2,2,185,'3/24/2005',1,425),
	(205,2,3,48,'3/24/2005',3,1297),
	(351,2,2,113,'3/24/2005',5.5,2105),
	(115,2,2,5,'3/24/2005',8.01,3300),
	(161,2,3,29,'3/24/2005',6.5,0),
	(174,2,1,50,'3/25/2005',6,0),
	(324,2,2,77,'3/23/2005',5,1977),
	(324,2,2,77,'3/24/2005',5,2008),
	(324,2,2,77,'3/25/2005',4.5,0),
	(81,2,2,43,'3/25/2005',7,2700),
	(175,2,2,124,'3/25/2005',7,2978),
	(313,2,3,73,'3/25/2005',5,3193),
	(352,2,2,106,'3/25/2005',8,3240),
	(179,2,2,76,'3/26/2005',6,0),
	(299,2,2,86,'3/25/2005',5.5,2666),
	(352,2,3,166,'3/26/2005',10,3960),
	(174,2,2,140,'3/27/2005',7,2940),
	(161,2,2,29,'3/25/2005',4,0),
	(161,2,1,30,'3/26/2005',7,0),
	(161,2,2,38,'3/26/2005',4,0),
	(161,2,2,30,'3/27/2005',4,0),
	(175,2,2,191,'3/27/2005',6,2611),
	(103,2,3,1,'3/27/2005',5,0),
	(103,2,2,1,'3/25/2005',6,0),
	(103,2,2,1,'3/24/2005',5,0),
	(103,2,2,1,'3/22/2005',6,0),
	(333,2,2,96,'3/24/2005',5.5,2168),
	(113,2,3,36,'3/27/2005',5,2261),
	(113,2,2,89,'3/25/2005',6,2491),
	(113,2,3,21,'3/24/2005',2,844),
	(113,2,1,89,'3/24/2005',6,2414),
	(113,2,2,17,'3/22/2005',7,2912),
	(112,2,2,85,'3/24/2005',8,3239),
	(112,2,2,186,'3/25/2005',6,2470),
	(112,2,2,186,'3/27/2005',5,2052),
	(302,2,2,65,'3/28/2005',5,1980),
	(313,2,3,72,'3/28/2005',3,1994),
	(179,2,2,76,'3/28/2005',8.5,0),
	(115,2,3,5,'3/28/2005',8.13,3300),
	(115,2,2,5,'3/25/2005',7,0),
	(175,2,2,191,'3/28/2005',1,409),
	(115,2,2,5,'3/26/2005',0,0),
	(115,2,2,5,'3/26/2005',0,0),
	(206,2,2,39,'3/21/2005',9,3447),
	(206,2,2,39,'3/22/2005',10,3921),
	(206,2,2,39,'3/24/2005',7,2700),
	(206,2,2,39,'3/18/2005',6,0),
	(206,2,2,52,'3/19/2005',5,0),
	(206,2,2,39,'3/20/2005',7,0),
	(112,2,2,85,'3/28/2005',8,3329),
	(363,2,3,123,'3/28/2005',7,2520),
	(205,2,1,167,'3/29/2005',3.75,1816),
	(352,2,2,166,'3/28/2005',5.4,2083),
	(314,2,2,83,'3/25/2005',3.5,1356),
	(113,2,2,89,'3/28/2005',8,3279),
	(102,2,1,23,'3/28/2005',6,2520),
	(102,2,2,27,'3/26/2005',7,2820),
	(309,2,1,107,'3/28/2005',6,2340),
	(175,2,2,124,'3/29/2005',1,415),
	(309,2,2,67,'3/26/2005',7,2880),
	(175,2,2,51,'3/29/2005',0.5,0),
	(309,2,2,118,'3/27/2005',3,0),
	(179,2,2,76,'3/29/2005',9,0),
	(174,2,2,50,'3/29/2005',7,2992),
	(174,2,2,50,'3/29/2005',1.5,0),
	(313,2,2,97,'3/29/2005',5,2903)
	GO
