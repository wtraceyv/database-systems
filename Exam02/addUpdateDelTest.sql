DECLARE @now datetime
SET @now = GETDATE()
EXEC sp_AddUpdateDelete_workouts 1003, 314, 2, 2, 98, @now, 6, 2905, 'very noice', 1 

	--@workoutId		INT,
	--@userId			INT,
	--@workoutTypeId	INT,
	--@timeOfDayId	INT,
	--@shoeId			INT,
	--@workoutDate	datetime,
	--@totalMiles		INT,
	--@totalSeconds	INT,
	--@comments		VARCHAR(MAX),
	--@delete			BIT = 0

