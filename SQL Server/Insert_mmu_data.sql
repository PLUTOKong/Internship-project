USE [Tuning]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Insert_mmu_data]    Script Date: 2/23/2022 5:59:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Insert_mmu_data]
	-- Add the parameters for the stored procedure here
	@json_result nvarchar(max),
	@serial_no nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Get_serial nvarchar(max)
    -- Insert statements for procedure here
	IF @json_result = '' or @json_result is null
		BEGIN
			Select (Select -1 as ret , 'Get MMU data failed' as msg for json path) as ret_obj;
		END
	IF @serial_no = '' or @serial_no is null
		BEGIN
		 set @Get_serial = '000';
		END
	ELSE 
		set @Get_serial = @serial_no;

	
	if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tbl_test_mmu' AND TABLE_SCHEMA = 'dbo')
		BEGIN
			drop table [dbo].[tbl_test_mmu]
		END

	BEGIN
		CREATE TABLE [dbo].[tbl_test_mmu](  
		id int NOT NULL IDENTITY(1,1)
		,serial_no nvarchar(max) NULL 
		,col int  NOT NULL  
		,row int NOT NULL  
		,location_id nvarchar(max)  NULL  
		,axis_no nvarchar(max)  NULL  
		,description nvarchar(max) NULL  
		,eeprom_value nvarchar(max)  NULL  
		,multiplier nvarchar(max)  NULL  
		,offset int NULL  
		,vals float NULL  
		,update_date datetime NULL		
		); 
		INSERT INTO [dbo].[tbl_test_mmu]([col],[row],[serial_no],[location_id],[axis_no],[description],[eeprom_value],[multiplier],[offset],[vals],[update_date])
		SELECT [col],[row],@Get_serial,[location_id],[axis_no],[description],[eeprom_value],[multiplier],[offset],[vals],[update_date] FROM OPENJSON (@json_result,'$.data')
		WITH
		(
		col int '$.col' 
		,row int '$.row'
		,location_id nvarchar(max)  '$.location_id'
		,axis_no nvarchar(max) '$.axis_no'  
		,description nvarchar(max) '$.description'
		,eeprom_value nvarchar(max) '$.eeprom_value'  
		,multiplier nvarchar(max) '$.multiplier' 
		,offset int  '$.offset' 
		,vals nvarchar(max)  '$.vals'  
		,update_date datetime  '$.update_date' 		
		)

	END

	IF @@ROWCOUNT != 0
		BEGIN
			Select (Select 1 as ret ,  'Insert MMU data successfully' as msg for json path) as ret_obj;
		END
	ELSE 
		BEGIN
			Select (Select -1 as ret ,  'Insert MMU data failed' as msg for json path)as ret_obj;
		END
	


END