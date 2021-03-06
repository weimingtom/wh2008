

USE QPGameUserDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[GSP_CF_LoadCustomFace]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GSP_CF_LoadCustomFace]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[GSP_CF_InsertCustomFace]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GSP_CF_InsertCustomFace]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[GSP_CF_DeleteCustomFace]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GSP_CF_DeleteCustomFace]
GO

----------------------------------------------------------------------------------------------------

--加载头像
CREATE  PROCEDURE GSP_CF_LoadCustomFace 
	@dwUserID INT
WITH ENCRYPTION AS

DECLARE @UserID INT
DECLARE @CustomFaceImage VARBINARY(MAX)
DECLARE @ImgSize INT

BEGIN
	SELECT @UserID=UserID,@CustomFaceImage=CustomFaceImage FROM CustomFaceInfo WHERE UserID=@dwUserID

	SELECT @ImgSize=DATALENGTH(@CustomFaceImage)

	SELECT @UserID AS UserID,@CustomFaceImage AS CustomFaceImage, @ImgSize AS ImgSize
END
RETURN 0
GO

----------------------------------------------------------------------------------------------------

--增加头像
CREATE  PROCEDURE GSP_CF_InsertCustomFace 
	@dwUserID INT,
	@imgCustomFaceImage VARBINARY(MAX)
WITH ENCRYPTION AS

BEGIN
	UPDATE CustomFaceInfo SET CustomFaceImage=@imgCustomFaceImage WHERE UserID=@dwUserID

	IF @@ROWCOUNT=0
	BEGIN
		INSERT CustomFaceInfo (UserID,CustomFaceImage) VALUES(@dwUserID,@imgCustomFaceImage)
	END

	IF @@ERROR<>0 RETURN -1

	UPDATE AccountsInfo SET CustomFaceVer=CustomFaceVer+1
	WHERE UserID=@dwUserID	

	DECLARE @CustomFaceVer INT
	SELECT @CustomFaceVer=CustomFaceVer FROM AccountsInfo WHERE UserID=@dwUserID

	-- 最大值
	IF @CustomFaceVer=0
	BEGIN
		UPDATE AccountsInfo SET CustomFaceVer=1
		WHERE UserID=@dwUserID	
	END

	RETURN @CustomFaceVer
END	
RETURN 0
GO


--删除头像
CREATE  PROCEDURE GSP_CF_DeleteCustomFace 
	@dwUserID INT	
WITH ENCRYPTION AS

BEGIN
	DELETE FROM CustomFaceInfo WHERE UserID=@dwUserID
	
	UPDATE AccountsInfo SET CustomFaceVer=0
	WHERE UserID=@dwUserID
END	
RETURN 0
GO