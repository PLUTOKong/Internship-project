USE [Tuning]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Tuning]    Script Date: 2/23/2022 6:00:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Tuning]
	-- Add the parameters for the stored procedure here
	@json_result nvarchar(max),@serial_no nvarchar(max),@tuning_user nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @result nvarchar(max)
    -- Insert statements for procedure here
	
	
	IF exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'temp' AND TABLE_SCHEMA = 'dbo')
		BEGIN
			drop table [dbo].[temp]
		END

	CREATE table [dbo].[temp](result nvarchar(max) NULL)
	INSERT [dbo].[temp] EXEC [dbo].[Sp_Insert_mmu_data] @json_result,@serial_no 

	Select @result=result from dbo.temp
	IF(SELECT * FROM OPENJSON (@result) WITH ([ret] nvarchar(10) '$.ret')) = 1
		BEGIN
			IF exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'temp' AND TABLE_SCHEMA = 'dbo')
				BEGIN
					drop table [dbo].[temp]
				END
			CREATE table [dbo].[temp](result nvarchar(max) NULL)	
			INSERT [dbo].[temp] EXEC [dbo].[Sp_calculate_tuning_result] 
	
			Select @result=result from dbo.temp
			IF(SELECT * FROM OPENJSON (@result) WITH ([ret] nvarchar(10) '$.ret')) = 1
				BEGIN 
					IF exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'temp' AND TABLE_SCHEMA = 'dbo')
						BEGIN
							drop table [dbo].[temp]
						END
					CREATE table [dbo].[temp](result nvarchar(max) NULL)
					INSERT [dbo].[temp] EXEC [dbo].[Sp_Insert_tuning_history] @tuning_user
					Select @result=result from dbo.temp
					IF(SELECT * FROM OPENJSON (@result) WITH ([ret] nvarchar(10) '$.ret')) = 1
						BEGIN
							Select (Select 1 as ret ,  'Insert tuning history success' as msg for json path) as ret_obj;
						END
					ELSE
						BEGIN
							Select (Select -1 as ret ,  'Insert tuning history failed' as msg for json path) as ret_obj;
						END
				END
			ELSE
				BEGIN
					Select (Select -1 as ret ,  'calculate tuning result is failed' as msg for json path) as ret_obj;
				END
		END
	ELSE
		BEGIN
			Select (Select -1 as ret ,  'Insert mmu data is failed' as msg for json path) as ret_obj;
		END
			

END
