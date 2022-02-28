CREATE PROC sp_AddUpdateDelete_CodingAssignment
	@studentID		INT,
	@miamiID		VARCHAR(10),
	@fullName		VARCHAR(50),
	@gpa			float,
	@delete			BIT = 0
AS BEGIN
	IF(@studentID > 0) BEGIN -- UPDATE or DELETE
		IF(@delete = 0) BEGIN -- UPDATE
			IF EXISTS(	SELECT NULL FROM CodingAssignment
						WHERE miamiID = @miamiID AND -- no username dups allowed
						studentID <> @studentID) BEGIN
				SELECT[errors] = 'Username/miamiID already exists, cannot add another'
			END ELSE BEGIN -- update passed username dup check
				IF (@gpa NOT BETWEEN 0.0 AND 4.0) BEGIN -- fail gpa check
					SELECT[errors] = 'gpa must be between 0.0 4.0 (fail update)'
				END ELSE BEGIN -- successful checks, update now
					UPDATE CodingAssignment
					SET	miamiID = @miamiID,
						fullName = @fullName,
						gpa = @gpa
					WHERE studentID = @studentID
					SELECT[errors] ='' -- no errors
				END
			END -- end UPDATE
		END ELSE BEGIN -- delete is affirmative, DELETE
			IF EXISTS(SELECT NULL FROM CodingAssignment WHERE studentID = @studentID) BEGIN
				DELETE CodingAssignment WHERE studentID = @studentID
				SELECT[errors] ='' -- successful delete
			END ELSE BEGIN
				SELECT[errors] = 'studentID cannot be found'
			END
		END -- end DELETE
	END ELSE BEGIN -- INSERT
		IF EXISTS(SELECT NULL FROM CodingAssignment WHERE miamiID = @miamiID) BEGIN
			SELECT[errors] = 'Cannot insert duplicate username/miamiID'
		END ELSE BEGIN -- passed username check
			IF (@gpa NOT BETWEEN 0.0 AND 4.0) BEGIN -- fail gpa check
				SELECT[errors] = 'gpa must be between 0.0 4.0 (fail insert)'
			END ELSE BEGIN -- successful checks, insert now
				INSERT CodingAssignment VALUES (@miamiID, @fullName, @gpa)
				SELECT[errors] = '' -- successful insert
			END 
		END
	END
END
 -- end stored procedure