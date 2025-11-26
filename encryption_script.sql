USE HotelManagementDB;
GO

PRINT '========================================';
PRINT 'SETTING UP ENCRYPTION INFRASTRUCTURE';
PRINT '========================================';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HotelDB_Str0ng!Pass2025';
    PRINT 'Master Key Created Successfully';
END
ELSE
BEGIN
    PRINT 'Master Key Already Exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'GuestDataCert')
BEGIN
    CREATE CERTIFICATE GuestDataCert
    WITH SUBJECT = 'Guest Sensitive Information';
    PRINT 'Certificate Created Successfully';
END
ELSE
BEGIN
    PRINT 'Certificate Already Exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'GuestDataKey')
BEGIN
    CREATE SYMMETRIC KEY GuestDataKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE GuestDataCert;
    PRINT 'Symmetric Key Created Successfully';
END
ELSE
BEGIN
    PRINT 'Symmetric Key Already Exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('GUEST') AND name = 'Phone_Encrypted')
BEGIN
    ALTER TABLE GUEST 
    ADD Phone_Encrypted VARBINARY(256),
        Email_Encrypted VARBINARY(256),
        Street_Encrypted VARBINARY(256),
        City_Encrypted VARBINARY(256),
        State_Encrypted VARBINARY(256);
    PRINT 'Encrypted Columns Added Successfully';
END
ELSE
BEGIN
    PRINT 'Encrypted Columns Already Exist';
END
GO

IF OBJECT_ID('dbo.fn_DecryptData', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DecryptData;
GO

CREATE FUNCTION dbo.fn_DecryptData(@EncryptedData VARBINARY(256))
RETURNS VARCHAR(100)
AS
BEGIN
    RETURN CONVERT(VARCHAR(100), DecryptByKey(@EncryptedData))
END;
GO

PRINT 'Decryption Function Created Successfully';
GO

PRINT '';
PRINT '========================================';
PRINT 'ENCRYPTION COMPONENT VERIFICATION';
PRINT '========================================';

DECLARE @ComponentCount INT = 0;

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    PRINT 'Master Key: READY';
    SET @ComponentCount = @ComponentCount + 1;
END
ELSE
    PRINT 'Master Key: MISSING';

IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'GuestDataCert')
BEGIN
    PRINT 'Certificate: READY';
    SET @ComponentCount = @ComponentCount + 1;
END
ELSE
    PRINT 'Certificate: MISSING';

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'GuestDataKey')
BEGIN
    PRINT 'Symmetric Key: READY';
    SET @ComponentCount = @ComponentCount + 1;
END
ELSE
    PRINT 'Symmetric Key: MISSING';

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('GUEST') AND name = 'Phone_Encrypted')
BEGIN
    PRINT 'Encrypted Columns: READY';
    SET @ComponentCount = @ComponentCount + 1;
END
ELSE
    PRINT 'Encrypted Columns: MISSING';

IF OBJECT_ID('dbo.fn_DecryptData', 'FN') IS NOT NULL
BEGIN
    PRINT 'Decryption Function: READY';
    SET @ComponentCount = @ComponentCount + 1;
END
ELSE
    PRINT 'Decryption Function: MISSING';

PRINT '';
IF @ComponentCount = 5
BEGIN
    PRINT '========================================';
    PRINT 'ENCRYPTION SETUP COMPLETE!';
    PRINT 'All 5 components configured successfully';
    PRINT '';
    PRINT 'NOTE: The auto-encryption trigger will be';
    PRINT 'created in psm_script.sql and will handle';
    PRINT 'encryption automatically during INSERT/UPDATE';
    PRINT '========================================';
END
ELSE
BEGIN
    PRINT '========================================';
    PRINT 'WARNING: INCOMPLETE SETUP';
    PRINT 'Only ' + CAST(@ComponentCount AS VARCHAR(2)) + ' of 5 components configured';
    PRINT 'Please check error messages above';
    PRINT '========================================';
END





