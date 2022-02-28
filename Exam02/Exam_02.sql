-- Name: Walter Tracey
-- Date: 12 June 2020

-- Download and run the create_RunningLog.sql database
-- Complete the following coding questions.

USE RunningLog

--================================================================================================= Q1:  
--	Create a JSON document with the following data:
--
--	Users userName
--	Users fullName (a combo of the firstName and lastName)
--	Users email
--	Users Workouts
--		Workout date
--		Workout totalMiles 
--		Workout totalSeconds
--		Workout time of day description (comes from the timeOfDay table)
--		Workout workoutType description (comes from the workoutTypes table)
--		Workout shoe model (comes from the shoes table)
--		Workout shoe brand description (comes from the shoeBrands table)
--	Users Shoes
--		Shoes shoeId
--		Shoes shoe brand description (comes from the shoeBrands table)
--		Shoes shoe model
--		Shoes totalMiles
--===================================================================================================
SELECT(
	SELECT	u.userName,
			[fullName] = u.firstName + ' ' + u.lastName,
			u.email,
			[Workout] = (
				SELECT	w.workoutDate,
						w.totalMiles,
						w.totalSeconds,
						-- Give descriptions aliases so they do not conflict
						[TimeOfDay] = td.description,
						[WorkoutType] = wt.description,
						s.model,
						[ShoeBrand] = sb.description
				FROM workouts w, timeOfDay td, workoutTypes wt, shoes s, shoeBrands sb
				WHERE	u.userId = w.userId AND -- connect each workout to current user
						w.timeOfDayId = td.timeOfDayId AND -- finish joining tables (5 tables, so 4 extra connections?)
						w.workoutTypeId = wt.workoutTypeId AND 
						w.userId = s.userId AND 
						s.shoeBrandId = sb.shoeBrandId
				FOR JSON PATH
			), -- end workout statements
			[Shoe] = (
				SELECT	s.shoeId,
						sb.description,
						s.model,
						s.totalMiles
				FROM shoes s, shoeBrands sb
				WHERE	s.userId = u.userId AND -- connect each shoe to current user
						s.shoeBrandId = sb.shoeBrandId -- finish join
				FOR JSON PATH
			) -- end shoe statements
	FROM users u
	WHERE u.userId IN (	SELECT DISTINCT userId FROM workouts UNION
						SELECT DISTINCT userId FROM shoes)
	FOR JSON PATH, ROOT('Users')
) FOR XML PATH('')

--================================================================================================= Q2:  
--	Process the following XML document:
--===================================================================================================
DECLARE @xml AS XML =	
	'
		<Records>
			<Adds>
				<ShoeBrand shoeBrandId="999"  description = "K-Mart Kicks"  sortOrder = "500" />
				<Shoe shoeBrandId="999"  userId = "1"   model = "789-Fire Storm"   totalMiles = "25"/>
			</Adds>
									
			<Updates>
				<User userId = "1"  firstName = "Jack" />
				<User userId = "2"  lastName = "Stahr" />
			</Updates>
									
			<Deletes>
				<Workouts workoutId = "1"/>
				<User userId = "3" />
			</Deletes>
		</Records>
	'

		-- ADD
SET IDENTITY_INSERT shoeBrands ON;
	INSERT INTO shoeBrands (shoeBrandId, description, sortOrder)
	SELECT	child.value	('@shoeBrandId', 'int'),
			child.value	('@description', 'VARCHAR(100)'),
			child.value	('@sortOrder', 'int')
	FROM @xml.nodes('/Records/Adds') Parent(parent)
		CROSS APPLY parent.nodes('ShoeBrand') Child(child)
SET IDENTITY_INSERT shoeBrands OFF;

INSERT INTO shoes(shoeBrandId, userId, model, totalMiles)
SELECT	child.value	('@shoeBrandId', 'int'),
		child.value	('@userId', 'int'),
		child.value	('@model', 'VARCHAR(100)'),
		child.value	('@totalMiles', 'int')
FROM @xml.nodes('/Records/Adds') Parent(parent)
	CROSS APPLY parent.nodes('Shoe') Child(child)

		-- UPDATE
UPDATE users
SET	firstName		= ISNULL(fn, firstName),
	lastName		= ISNULL(ln, lastName)
FROM (
	SELECT	[uid] = child.value ('@userId', 'int'),
			[fn] = child.value	('@firstName', 'VARCHAR(50)'),
			[ln] = child.value	('@lastName', 'VARCHAR(50)')
	FROM @xml.nodes('/Records/Updates') Parent(parent)
		CROSS APPLY parent.nodes('User') Child(child)
) tbl
WHERE userId = uid

		-- DELETE 
DELETE workouts
FROM (
	SELECT	[deleteid] = child.value ('@workoutId', 'int')
	FROM @xml.nodes('/Records/Deletes') Parent(parent)
		CROSS APPLY parent.nodes('Workouts') Child(child)
) tbl
WHERE workoutId = deleteid

DELETE users
FROM (
	SELECT	[deleteid] = child.value ('@userId', 'int')
	FROM @xml.nodes('/Records/Deletes') Parent(parent)
		CROSS APPLY parent.nodes('User') Child(child)
) tbl
WHERE userId = deleteid


--================================================================================================= Q3:  	
--	Create a Trigger for the timeOfDay table that does not allow the inserting or updating of 
--	a description that is already in the table
--===================================================================================================

CREATE TRIGGER trgDescDuplicateCheck ON timeOfDay
	AFTER INSERT, UPDATE
AS BEGIN
	IF EXISTS(SELECT NULL FROM inserted i, timeOfDay td WHERE i.description = td.description AND
															i.timeOfDayId <> td.timeOfDayId	) BEGIN
		ROLLBACK TRANSACTION
		RAISERROR (
			'No duplicate descriptions allowed in time of day', -- message
			12,-- severity
			1-- state
		)
	END
END

--================================================================================================= Q4:  	
--	Create a UNION query that returns: userId, userName, the total miles they have run, and one of 
--	3 mileage categories (low, average, high). To determine their mileageStatus use the following:
--		  0 - 100 miles		low
--		101 - 500 miles		average
--		500 - ... miles		high
--===================================================================================================

	SELECT	u.userId,
			u.userName,
			[TotalMiles] = SUM(s.totalMiles),
			[Mileage] = 'low'
	FROM users u, shoes s
	WHERE u.userId = s.userId 
	GROUP BY u.userId, u.userName
	HAVING SUM(s.totalMiles) BETWEEN 0 AND 100

UNION

	SELECT	u.userId,
			u.userName,
			[TotalMiles] = SUM(s.totalMiles),
			[Mileage] = 'average'
	FROM users u, shoes s
	WHERE u.userId = s.userId 
	GROUP BY u.userId, u.userName
	HAVING SUM(s.totalMiles) BETWEEN 101 AND 500

UNION

	SELECT	u.userId,
			u.userName,
			[TotalMiles] = SUM(s.totalMiles),
			[Mileage] = 'high'
	FROM users u, shoes s
	WHERE u.userId = s.userId 
	GROUP BY u.userId, u.userName
	HAVING SUM(s.totalMiles) > 500

--================================================================================================= Q5:  	
--	Write the same query as above but use a CASE statement
--===================================================================================================

SELECT	u.userId,
		u.userName,
		[TotalMiles] = SUM(s.totalMiles),
		[Mileage] = (
			CASE 
				WHEN SUM(s.totalMiles) BETWEEN 0 AND 100 THEN 'low'
				WHEN SUM(s.totalMiles) BETWEEN 100 AND 500 THEN 'average'
				WHEN SUM(s.totalMiles) > 500 THEN 'high'
			END
		)
FROM users u, shoes s
WHERE u.userId = s.userId
GROUP BY u.userId, u.userName

--================================================================================================= Q6:  	
--	Create an AddUpdateDelete Stored Procedure for the workouts table
--===================================================================================================

CREATE PROC sp_AddUpdateDelete_workouts
	@workoutId		INT,
	@userId			INT,
	@workoutTypeId	INT,
	@timeOfDayId	INT,
	@shoeId			INT,
	@workoutDate	datetime,
	@totalMiles		INT,
	@totalSeconds	INT,
	@comments		VARCHAR(MAX),
	@delete			BIT = 0
AS BEGIN 
	IF(@workoutId > 0) BEGIN		-- update or del existing entry
		IF(@delete = 0) BEGIN		-- UPDATE (no special duplicate issue specified)
			IF EXISTS(SELECT NULL FROM workouts WHERE workoutId = @workoutId) BEGIN
				UPDATE workouts
				SET	userId = @userId,
					workoutTypeId = @workoutTypeId,
					timeOfDayId = @timeOfDayId,
					shoeId = @shoeId,
					workoutDate = @workoutDate,
					totalMiles = @totalMiles,
					totalSeconds = @totalSeconds,
					comments = @comments
				WHERE workoutId = @workoutId
				SELECT [errors] = ''
			END ELSE BEGIN 
				SELECT [errors] = 'No such workoutId exists to UPDATE'
			END
		END ELSE BEGIN				-- DELETE
			IF EXISTS(SELECT NULL FROM workouts WHERE workoutId = @workoutId) BEGIN
				DELETE workouts WHERE workoutId = @workoutId
				SELECT [errors] = ''
			END ELSE BEGIN
				SELECT [errors] = 'No such workoutId exists to UPDATE'
			END
		END							-- end UPDATE/DELETE
	END ELSE BEGIN					-- INSERT new entry
		INSERT INTO workouts VALUES(	@userId,
										@workoutTypeId,
										@timeOfDayId,
										@shoeId,
										@workoutDate,
										@totalMiles,
										@totalSeconds,
										@comments)
		SELECT [errors] = ''
	END								-- end INSERT
END -- END proc code

--================================================================================================= Q7:  	
--	Somehow the total miles recorded in the shoes table doesn't match what the miles indicate
--	in the workouts table. You are to create a cursor that will sum up all the miles per shoe 
--	from the workouts table and update the shoe table with the correct current miles
--===================================================================================================

DECLARE @shoeId INT, @TotalMiles float

DECLARE cur CURSOR STATIC FOR
	-- select the IDs and workouts, sum total miles
	-- order by IDs to loop through
	SELECT	w.shoeId, [TotalMiles] = SUM(w.totalMiles)
	FROM workouts w
	GROUP BY shoeId
	ORDER BY w.shoeId

OPEN cur 
	-- Loop through workouts summed results, update shoes where possible
	FETCH NEXT FROM cur INTO @shoeId, @TotalMiles
	WHILE ( @@FETCH_STATUS = 0 ) BEGIN
		-- update shoes table appropriately
		UPDATE shoes
		SET shoes.totalMiles = @TotalMiles
		WHERE shoes.shoeId = @shoeId
		-- keep the loopin going
		FETCH NEXT FROM cur INTO @shoeId, @TotalMiles
	END
CLOSE cur
DEALLOCATE cur

--================================================================================================= Q8:  
-- Write the query that will return the top 20 users with the most run miles.  You should allow  for
-- multiple users having the same amount of miles too.  So if the 21st user has the same amount of
-- miles as the 20th user then include the 21st user (and so on)
--===================================================================================================

SELECT	TOP(20) WITH TIES u.userName,
		[MilesRun] = SUM(s.totalMiles)
FROM users u, shoes s
WHERE u.userId = s.userId
GROUP BY u.userName
ORDER BY MilesRun DESC

--================================================================================================= Q9:
-- Write a query that will return a sorted list of total miles run per shoe brand
--===================================================================================================

SELECT	[Brand] = sb.description,
		[MilesRun] = SUM(s.totalMiles)
FROM shoes s, shoeBrands sb
WHERE s.shoeBrandId = sb.shoeBrandId
GROUP BY sb.description
ORDER BY MilesRun DESC

--================================================================================================= Q10:  	
-- Write a query that returns an ordered list of miles run by email extension.  So, for instance,
-- gmail.com would be an email extension.  So, you currently don't know the method that finds the
-- index of a character in a string; however, you are all programmers and could do this in Java. 
-- The two methods you will need is SUBSTRING(, , 100) and CHARINDEX('', )
--		Example:
--			SELECT SUBSTRING('Mike Stahr',CHARINDEX(' ', 'Mike Stahr') + 1, 100); 
--				would return 'Stahr'
-- You are capable of creating this type of query for this problem. Of course, you won't be hard
-- coding the email address, you will be using the field in the table.  You will, of course, need
-- to join the users table with the workouts table
--===================================================================================================

SELECT	[Extension] = (
			SUBSTRING(u.email, CHARINDEX('@', u.email) + 1, 100)
		),
		[MilesRun] = SUM(w.totalMiles)
FROM users u, workouts w
WHERE u.userId = w.userId
GROUP BY SUBSTRING(u.email, CHARINDEX('@', u.email) + 1, 100)
ORDER BY MilesRun DESC