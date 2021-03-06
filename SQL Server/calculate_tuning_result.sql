USE [Tuning]
GO
/****** Object:  StoredProcedure [dbo].[Sp_calculate_tuning_result]    Script Date: 2/23/2022 5:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Sp_calculate_tuning_result]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @spe_id int,@model_spe_id int,@mod_id int,@serialno int

    -- Insert statements for procedure here
	SELECT @serialno=serial_no FROM dbo.tbl_test_mmu 
	SELECT @mod_id=mmu_model_id FROM dbo.mmu_model_tbl WHERE serial_no = @serialno 
	SELECT @model_spe_id=mmu_model_specification_id FROM dbo.mmu_model_specification_tbl WHERE mmu_model_id = @mod_id
	SELECT @spe_id=specification_id FROM dbo.mmu_model_specification_tbl WHERE mmu_model_specification_id = @model_spe_id

	If exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tuning_result' AND TABLE_SCHEMA = 'dbo')
		BEGIN
			drop table dbo.tuning_result
		END

	IF exists (SELECT vals,min_value, max_value FROM dbo.tbl_test_mmu INNER JOIN dbo.mmu_specification_tbl ON dbo.mmu_specification_tbl.id = dbo.tbl_test_mmu.id WHERE mmu_specification_id = @spe_id)
			BEGIN 
			
			SELECT serial_no,dbo.tbl_test_mmu.description,vals,min_value,max_value,CAST(
				 CASE
					  WHEN (min_value<=vals AND vals<=max_value) or (vals is null AND max_value is null AND min_value is null)
						 THEN 'OK'
					  ELSE 'NG'
				 END AS nvarchar(max)) AS result INTO dbo.tuning_result FROM dbo.tbl_test_mmu INNER JOIN dbo.mmu_specification_tbl ON dbo.mmu_specification_tbl.id = dbo.tbl_test_mmu.id WHERE mmu_specification_id = @spe_id
			END
	
	IF @@ROWCOUNT != 0
		BEGIN
			Select (Select 1 as ret ,  'Insert tuning result data successfully' as msg for json path) as ret_obj;
		END
	ELSE 
		BEGIN
			Select (Select -1 as ret ,  'Insert tuning result data failed' as msg for json path) as ret_obj;
		END

END
