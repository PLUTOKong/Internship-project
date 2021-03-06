USE [Tuning]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Insert_tuning_history]    Script Date: 2/23/2022 5:59:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Insert_tuning_history]
	-- Add the parameters for the stored procedure here
	 @tuning_user nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @final_result varchar(10),@serialno nvarchar(max),@history_id int;
	
    -- Insert statements for procedure here
	select @serialno= serial_no from dbo.tuning_result

	If not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tuning_result' AND TABLE_SCHEMA = 'dbo')
		BEGIN
			Select (Select -1 as ret ,  'No tuning data' as msg for json path) as ret_obj;
		END

	ELSE 
		BEGIN
		IF exists (SELECT result FROM dbo.tuning_result WHERE result like 'NG')
					SET @final_result = 'failed'
			ELSE
					SET @final_result = 'success'	
		END

	If not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'mmu_tuning_history' AND TABLE_SCHEMA = 'dbo')
		BEGIN
		CREATE TABLE [dbo].[mmu_tuning_history](  
		id int NOT NULL IDENTITY(1,1)
		,serial_no nvarchar(max) NOT NULL 
		,result nvarchar(max) NOT NULL
		,tuning_user nvarchar(max) NOT NULL
		,tuning_date datetime NULL		
		); 
		END

	INSERT INTO dbo.mmu_tuning_history([result],[serial_no],[tuning_user],[tuning_date])
	VALUES(@final_result,@serialno,@tuning_user,GETDATE())
	SET @history_id = scope_identity();

	IF not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'mmu_tuning_history_detail' AND TABLE_SCHEMA = 'dbo')
	BEGIN
	CREATE TABLE [dbo].[mmu_tuning_history_detail](  
	id int NOT NULL IDENTITY(1,1)
	,history_id int NOT NULL
	,serial_no nvarchar(max) NOT NULL 
	,descriptions nvarchar(max) NULL
	,vals float NULL
	,min_value float NULL
	,max_value float NULL
	,result nvarchar(max) NOT NULL	
	); 
	END

	INSERT INTO dbo.mmu_tuning_history_detail([history_id],[serial_no],[descriptions],[vals],[min_value],[max_value],[result])
	SELECT @history_id,[serial_no],[description],[vals],[min_value],[max_value],[result] FROM dbo.tuning_result

	IF @@ROWCOUNT != 0
		BEGIN
			Select (Select 1 as ret ,  'Insert tuning history successfully' as msg for json path) as ret_obj;
		END
	ELSE 
		BEGIN
			Select (Select -1 as ret ,  'Insert tuning history failed' as msg for json path) as ret_obj;
		END
	

END

