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