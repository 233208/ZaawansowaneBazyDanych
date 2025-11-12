CREATE FUNCTION [dbo].[fn_sysdac_get_currentusername]()
RETURNS sysname
BEGIN
    RETURN SUSER_SNAME();
END
