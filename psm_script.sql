USE HotelManagementDB;
GO

CREATE OR ALTER PROCEDURE sp_CheckInGuest
    @BookingID INT,
    @StaffID INT,
    @Message VARCHAR(200) OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @GuestID INT, @RoomNumber INT, @CheckInDate DATE;
        
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE Booking_ID = @BookingID AND Status = 'Confirmed')
        BEGIN
            SET @Success = 0;
            SET @Message = 'Invalid booking or booking not confirmed';
            ROLLBACK;
            RETURN;
        END
        
        SELECT @GuestID = Guest_ID, @CheckInDate = Check_In_Date
        FROM BOOKING WHERE Booking_ID = @BookingID;
        
        SELECT @RoomNumber = Room_Number 
        FROM ROOM_BOOKING_ASSIGNMENT 
        WHERE Booking_ID = @BookingID;
        
        UPDATE ROOM SET Status = 'Occupied' WHERE Room_Number = @RoomNumber;
        
        UPDATE BOOKING SET Status = 'CheckedIn' WHERE Booking_ID = @BookingID;
        
        INSERT INTO INVOICE (Booking_ID, Generated_Date, Total_Amount)
        SELECT Booking_ID, GETDATE(), Booking_Rate * DATEDIFF(DAY, Check_In_Date, Check_Out_Date)
        FROM BOOKING WHERE Booking_ID = @BookingID;
        
        INSERT INTO ROOM_ASSIGNMENT (Room_Number, Staff_ID, Assignment_Date)
        VALUES (@RoomNumber, @StaffID, GETDATE());
        
        COMMIT TRANSACTION;
        SET @Success = 1;
        SET @Message = 'Check-in successful for Room ' + CAST(@RoomNumber AS VARCHAR(10));
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Success = 0;
        SET @Message = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_CheckOutGuest
    @BookingID INT,
    @PaymentMethod VARCHAR(20),
    @TotalAmount DECIMAL(10,2) OUTPUT,
    @Message VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @RoomNumber INT, @InvoiceID INT;
        DECLARE @RoomCharges DECIMAL(10,2), @ServiceCharges DECIMAL(10,2);
        DECLARE @DiscountAmount DECIMAL(10,2); 
        
        DECLARE @TaxableBase DECIMAL(10,2);
        DECLARE @TargetTaxAmount DECIMAL(10,2);
        DECLARE @TotalAppliedRate DECIMAL(5,2) = 13.50; 

        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE Booking_ID = @BookingID AND Status = 'CheckedIn')
        BEGIN
            SET @Message = 'Invalid booking or guest not checked in';
            ROLLBACK;
            RETURN;
        END
        
        SET @TotalAmount = dbo.fn_CalculateTotalBill(@BookingID);
        
        UPDATE INVOICE 
        SET Total_Amount = @TotalAmount 
        WHERE Booking_ID = @BookingID;
        
        SELECT @InvoiceID = Invoice_ID FROM INVOICE WHERE Booking_ID = @BookingID;

        DELETE FROM INVOICE_TAX WHERE Invoice_ID = @InvoiceID;
        
        SELECT @RoomCharges = Booking_Rate * DATEDIFF(DAY, Check_In_Date, Check_Out_Date)
        FROM BOOKING WHERE Booking_ID = @BookingID;
        
        SELECT @ServiceCharges = ISNULL(SUM(Total_Amount), 0)
        FROM SERVICE_TRANSACTION WHERE Booking_ID = @BookingID;
        
        SELECT @DiscountAmount = ISNULL(SUM(Applied_Value), 0)
        FROM BOOKING_DISCOUNT WHERE Booking_ID = @BookingID;
        
        SET @TaxableBase = @RoomCharges + @ServiceCharges - @DiscountAmount;
        
        SET @TargetTaxAmount = @TaxableBase * 0.09; 
        
        INSERT INTO INVOICE_TAX (Invoice_ID, Tax_ID, Tax_Amount)
        SELECT 
            @InvoiceID, 
            Tax_ID, 
            (@TargetTaxAmount) * (Tax_Rate / @TotalAppliedRate) 
        FROM TAX 
        WHERE Tax_ID IN (1, 2, 3); 

        INSERT INTO PAYMENT (Invoice_ID, Payment_Type, Amount, Payment_Date, Payment_Status)
        VALUES (@InvoiceID, @PaymentMethod, @TotalAmount, GETDATE(), 'Completed');
        
        SELECT @RoomNumber = rba.Room_Number
        FROM BOOKING b
        JOIN ROOM_BOOKING_ASSIGNMENT rba ON b.Booking_ID = rba.Booking_ID
        WHERE b.Booking_ID = @BookingID;
        
        UPDATE ROOM SET Status = 'Available' WHERE Room_Number = @RoomNumber;
        
        UPDATE BOOKING SET Status = 'CheckedOut' WHERE Booking_ID = @BookingID;
        
        COMMIT TRANSACTION;
        SET @Message = 'Checkout successful. Total: $' + CAST(@TotalAmount AS VARCHAR(20));
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Message = 'Checkout Error: ' + ERROR_MESSAGE();
        SET @TotalAmount = 0;
    END CATCH
END;
GO




CREATE OR ALTER PROCEDURE sp_FindAvailableRooms
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @RoomType VARCHAR(50) = NULL,
    @MinCapacity INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            r.Room_Number,
            r.Room_Type,
            r.Price,
            r.Capacity,
            r.Status AS Current_Status,
            CASE 
                WHEN rba.Room_Number IS NULL THEN 'Available'
                ELSE 'Will be available'
            END AS Availability
        FROM ROOM r
        LEFT JOIN ROOM_BOOKING_ASSIGNMENT rba ON r.Room_Number = rba.Room_Number
            AND NOT (@CheckOutDate <= rba.StartDate OR @CheckInDate >= rba.EndDate)
        WHERE r.Status != 'Maintenance'
            AND rba.Room_Number IS NULL
            AND (@RoomType IS NULL OR r.Room_Type = @RoomType)
            AND r.Capacity >= @MinCapacity
        ORDER BY r.Price;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO





CREATE OR ALTER PROCEDURE sp_MakeReservation
    @GuestID INT,
    @RoomNumber INT,
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @BookingID INT OUTPUT,
    @Message VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @RoomRate DECIMAL(10,2);
        
        IF EXISTS (
            SELECT 1 FROM ROOM_BOOKING_ASSIGNMENT 
            WHERE Room_Number = @RoomNumber
            AND NOT (@CheckOutDate <= StartDate OR @CheckInDate >= EndDate)
        )
        BEGIN
            SET @Message = 'Room not available for selected dates';
            ROLLBACK;
            RETURN;
        END
        
        SELECT @RoomRate = Price FROM ROOM WHERE Room_Number = @RoomNumber;
        
        INSERT INTO BOOKING (Guest_ID, Booking_Rate, Check_In_Date, Check_Out_Date, Status)
        VALUES (@GuestID, @RoomRate, @CheckInDate, @CheckOutDate, 'Confirmed');
        
        SET @BookingID = SCOPE_IDENTITY();
        
        INSERT INTO ROOM_BOOKING_ASSIGNMENT (Room_Number, Booking_ID, StartDate, EndDate)
        VALUES (@RoomNumber, @BookingID, @CheckInDate, @CheckOutDate);
        
        COMMIT TRANSACTION;
        SET @Message = 'Reservation created successfully. Booking ID: ' + CAST(@BookingID AS VARCHAR(10));
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @BookingID = 0;
        SET @Message = 'Reservation Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_ProcessMonthlyBilling
    @Month INT,
    @Year INT,
    @ProcessedCount INT OUTPUT,
    @TotalAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        SELECT @ProcessedCount = COUNT(*), 
               @TotalAmount = SUM(i.Total_Amount)
        FROM BOOKING b
        JOIN INVOICE i ON b.Booking_ID = i.Booking_ID
        WHERE MONTH(b.Check_Out_Date) = @Month
        AND YEAR(b.Check_Out_Date) = @Year
        AND b.Status = 'CheckedOut';
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ProcessedCount = 0;
        SET @TotalAmount = 0;
        THROW;
    END CATCH
END;
GO



CREATE OR ALTER VIEW vw_RoomBookingStatus
AS
SELECT 
    r.Room_Number,
    r.Room_Type,
    r.Status AS Room_Status,
    r.Price,
    g.First_Name + ' ' + g.Last_Name AS Guest_Name,
    b.Check_In_Date,
    b.Check_Out_Date,
    b.Status AS Booking_Status,
    CASE 
        WHEN GETDATE() BETWEEN b.Check_In_Date AND b.Check_Out_Date THEN 'Current'
        WHEN b.Check_In_Date > GETDATE() THEN 'Future'
        WHEN b.Check_Out_Date < GETDATE() THEN 'Past'
        ELSE 'No Booking'
    END AS Booking_Timeline
FROM ROOM r
LEFT JOIN ROOM_BOOKING_ASSIGNMENT rba ON r.Room_Number = rba.Room_Number
LEFT JOIN BOOKING b ON rba.Booking_ID = b.Booking_ID
LEFT JOIN GUEST g ON b.Guest_ID = g.Guest_ID;
GO





CREATE OR ALTER VIEW vw_RevenueReport
AS
SELECT 
    YEAR(p.Payment_Date) AS Year,
    MONTH(p.Payment_Date) AS Month,
    DATENAME(MONTH, p.Payment_Date) AS Month_Name,
    COUNT(DISTINCT b.Booking_ID) AS Total_Bookings,
    COUNT(DISTINCT b.Guest_ID) AS Unique_Guests,
    SUM(p.Amount) AS Total_Revenue,
    AVG(p.Amount) AS Average_Booking_Value,
    SUM(CASE WHEN p.Payment_Type = 'Cash' THEN p.Amount ELSE 0 END) AS Cash_Revenue,
    SUM(CASE WHEN p.Payment_Type = 'CreditCard' THEN p.Amount ELSE 0 END) AS Card_Revenue
FROM PAYMENT p
JOIN INVOICE i ON p.Invoice_ID = i.Invoice_ID
JOIN BOOKING b ON i.Booking_ID = b.Booking_ID
GROUP BY YEAR(p.Payment_Date), MONTH(p.Payment_Date), DATENAME(MONTH, p.Payment_Date);
GO





CREATE OR ALTER VIEW vw_GuestHistory
AS
SELECT 
    g.Guest_ID,
    g.First_Name + ' ' + g.Last_Name AS Guest_Name,
    g.City + ', ' + g.State AS Location,
    COUNT(b.Booking_ID) AS Total_Stays,
    MIN(b.Check_In_Date) AS First_Visit,
    MAX(b.Check_Out_Date) AS Last_Visit,
    SUM(DATEDIFF(DAY, b.Check_In_Date, b.Check_Out_Date)) AS Total_Nights_Stayed,
    AVG(CAST(f.Rating AS FLOAT)) AS Average_Rating,
    SUM(p.Amount) AS Total_Spent
FROM GUEST g
LEFT JOIN BOOKING b ON g.Guest_ID = b.Guest_ID
LEFT JOIN FEEDBACK f ON b.Booking_ID = f.Booking_ID
LEFT JOIN INVOICE i ON b.Booking_ID = i.Booking_ID
LEFT JOIN PAYMENT p ON i.Invoice_ID = p.Invoice_ID
GROUP BY g.Guest_ID, g.First_Name, g.Last_Name, g.City, g.State;
GO





CREATE OR ALTER VIEW vw_DailyOperations
AS
SELECT 
    'Check-In' AS Operation_Type,
    b.Booking_ID,
    g.First_Name + ' ' + g.Last_Name AS Guest_Name,
    r.Room_Number,
    b.Check_In_Date AS Operation_Date
FROM BOOKING b
JOIN GUEST g ON b.Guest_ID = g.Guest_ID
JOIN ROOM_BOOKING_ASSIGNMENT rba ON b.Booking_ID = rba.Booking_ID
JOIN ROOM r ON rba.Room_Number = r.Room_Number
WHERE b.Check_In_Date = CAST(GETDATE() AS DATE)
    AND b.Status = 'Confirmed'

UNION ALL

SELECT 
    'Check-Out' AS Operation_Type,
    b.Booking_ID,
    g.First_Name + ' ' + g.Last_Name AS Guest_Name,
    r.Room_Number,
    b.Check_Out_Date AS Operation_Date
FROM BOOKING b
JOIN GUEST g ON b.Guest_ID = g.Guest_ID
JOIN ROOM_BOOKING_ASSIGNMENT rba ON b.Booking_ID = rba.Booking_ID
JOIN ROOM r ON rba.Room_Number = r.Room_Number
WHERE b.Check_Out_Date = CAST(GETDATE() AS DATE)
    AND b.Status = 'CheckedIn';
GO





CREATE OR ALTER FUNCTION fn_CalculateTotalBill(@BookingID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    DECLARE @RoomCharges DECIMAL(10,2);
    DECLARE @ServiceCharges DECIMAL(10,2);
    DECLARE @Discounts DECIMAL(10,2);
    DECLARE @Tax DECIMAL(10,2);
    
    SELECT @RoomCharges = Booking_Rate * DATEDIFF(DAY, Check_In_Date, Check_Out_Date)
    FROM BOOKING WHERE Booking_ID = @BookingID;
    
    SELECT @ServiceCharges = ISNULL(SUM(Total_Amount), 0)
    FROM SERVICE_TRANSACTION WHERE Booking_ID = @BookingID;
    
    SELECT @Discounts = ISNULL(SUM(Applied_Value), 0)
    FROM BOOKING_DISCOUNT WHERE Booking_ID = @BookingID;
    
    DECLARE @SubtotalNet DECIMAL(10,2) = ISNULL(@RoomCharges, 0) + ISNULL(@ServiceCharges, 0) - ISNULL(@Discounts, 0);
    
    SET @Tax = @SubtotalNet * 0.09;
    
    SET @Total = @SubtotalNet + @Tax;
    
    RETURN ISNULL(@Total, 0);
END;
GO





CREATE OR ALTER FUNCTION fn_IsRoomAvailable(
    @RoomNumber INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 1;
    
    IF EXISTS (SELECT 1 FROM ROOM WHERE Room_Number = @RoomNumber AND Status = 'Maintenance')
        SET @IsAvailable = 0;
    
    IF EXISTS (
        SELECT 1 FROM ROOM_BOOKING_ASSIGNMENT 
        WHERE Room_Number = @RoomNumber
        AND NOT (@CheckOutDate <= StartDate OR @CheckInDate >= EndDate)
    )
        SET @IsAvailable = 0;
    
    RETURN @IsAvailable;
END;
GO



CREATE OR ALTER FUNCTION fn_GetStayDuration(@BookingID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT;
    
    SELECT @Duration = DATEDIFF(DAY, Check_In_Date, Check_Out_Date)
    FROM BOOKING WHERE Booking_ID = @BookingID;
    
    RETURN ISNULL(@Duration, 0);
END;
GO



CREATE OR ALTER FUNCTION fn_GetOccupancyRate(@Date DATE = NULL)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @OccupancyRate DECIMAL(5,2);
    DECLARE @TotalRooms INT;
    DECLARE @OccupiedRooms INT;
    
    SET @Date = ISNULL(@Date, GETDATE());
    
    SELECT @TotalRooms = COUNT(*) 
    FROM ROOM 
    WHERE Status != 'Maintenance';
    
    SELECT @OccupiedRooms = COUNT(DISTINCT rba.Room_Number)
    FROM ROOM_BOOKING_ASSIGNMENT rba
    JOIN BOOKING b ON rba.Booking_ID = b.Booking_ID
    WHERE @Date BETWEEN rba.StartDate AND rba.EndDate
    AND b.Status IN ('Confirmed', 'CheckedIn');
    
    SET @OccupancyRate = (CAST(@OccupiedRooms AS FLOAT) / CAST(@TotalRooms AS FLOAT)) * 100;
    
    RETURN ISNULL(@OccupancyRate, 0);
END;
GO





CREATE OR ALTER TRIGGER trg_BookingAudit
ON BOOKING
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO BOOKING_AUDIT (Booking_ID, Action_Type, New_Status, New_CheckIn, New_CheckOut)
        SELECT Booking_ID, 'INSERT', Status, Check_In_Date, Check_Out_Date
        FROM inserted;
    END
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO BOOKING_AUDIT (
            Booking_ID, Action_Type, 
            Old_Status, New_Status,
            Old_CheckIn, New_CheckIn,
            Old_CheckOut, New_CheckOut
        )
        SELECT 
            i.Booking_ID, 'UPDATE',
            d.Status, i.Status,
            d.Check_In_Date, i.Check_In_Date,
            d.Check_Out_Date, i.Check_Out_Date
        FROM inserted i
        JOIN deleted d ON i.Booking_ID = d.Booking_ID;
    END
    
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO BOOKING_AUDIT (Booking_ID, Action_Type, Old_Status, Old_CheckIn, Old_CheckOut)
        SELECT Booking_ID, 'DELETE', Status, Check_In_Date, Check_Out_Date
        FROM deleted;
    END
END;
GO






CREATE OR ALTER TRIGGER trg_ValidatePayment
ON PAYMENT
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @InvoiceTotal DECIMAL(10,2);
    DECLARE @PaymentAmount DECIMAL(10,2);
    DECLARE @InvoiceID INT;
    
    SELECT @InvoiceID = Invoice_ID, @PaymentAmount = Amount FROM inserted;
    SELECT @InvoiceTotal = Total_Amount FROM INVOICE WHERE Invoice_ID = @InvoiceID;
    
    IF ABS(@PaymentAmount - @InvoiceTotal) > 0.01
    BEGIN
        RAISERROR('Payment amount must match invoice total', 16, 1);
        ROLLBACK;
        RETURN;
    END
    
    INSERT INTO PAYMENT (Invoice_ID, Payment_Type, Amount, Payment_Date, Payment_Status)
    SELECT Invoice_ID, Payment_Type, Amount, Payment_Date, Payment_Status
    FROM inserted;
END;
GO




CREATE OR ALTER TRIGGER trg_UpdateRoomStatus
ON MAINTENANCE_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE ROOM
    SET Status = 'Maintenance'
    FROM ROOM r
    JOIN inserted i ON r.Room_Number = i.Room_Number
    WHERE i.Priority IN ('High', 'Critical') AND i.Status = 'Pending';
    
    UPDATE ROOM
    SET Status = 'Available'
    FROM ROOM r
    JOIN inserted i ON r.Room_Number = i.Room_Number
    JOIN deleted d ON i.Request_ID = d.Request_ID
    WHERE i.Status = 'Completed' 
    AND d.Status != 'Completed'
    AND NOT EXISTS (
        SELECT 1 FROM MAINTENANCE_REQUEST mr2
        WHERE mr2.Room_Number = r.Room_Number
        AND mr2.Status IN ('Pending', 'InProgress') 
        AND mr2.Priority IN ('High', 'Critical')
        AND mr2.Request_ID != i.Request_ID
    );
END;
GO





CREATE OR ALTER TRIGGER trg_AutoEncryptGuest
ON GUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only proceed if there are affected records
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Open the symmetric key for encryption
        OPEN SYMMETRIC KEY GuestDataKey
        DECRYPTION BY CERTIFICATE GuestDataCert;
        
        -- Update encrypted columns for inserted/updated records
        UPDATE g
        SET 
            Phone_Encrypted = CASE 
                WHEN g.Phone IS NOT NULL AND g.Phone_Encrypted IS NULL 
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Phone)
                WHEN i.Phone <> d.Phone OR g.Phone_Encrypted IS NULL
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Phone)
                ELSE g.Phone_Encrypted
            END,
            Email_Encrypted = CASE 
                WHEN g.Email IS NOT NULL AND g.Email_Encrypted IS NULL 
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Email)
                WHEN i.Email <> d.Email OR g.Email_Encrypted IS NULL
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Email)
                ELSE g.Email_Encrypted
            END,
            Street_Encrypted = CASE 
                WHEN g.Street IS NOT NULL AND g.Street_Encrypted IS NULL 
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Street)
                WHEN i.Street <> d.Street OR g.Street_Encrypted IS NULL
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.Street)
                ELSE g.Street_Encrypted
            END,
            City_Encrypted = CASE 
                WHEN g.City IS NOT NULL AND g.City_Encrypted IS NULL 
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.City)
                WHEN i.City <> d.City OR g.City_Encrypted IS NULL
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.City)
                ELSE g.City_Encrypted
            END,
            State_Encrypted = CASE 
                WHEN g.State IS NOT NULL AND g.State_Encrypted IS NULL 
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.State)
                WHEN i.State <> d.State OR g.State_Encrypted IS NULL
                THEN EncryptByKey(Key_GUID('GuestDataKey'), g.State)
                ELSE g.State_Encrypted
            END
        FROM GUEST g
        INNER JOIN inserted i ON g.Guest_ID = i.Guest_ID
        LEFT JOIN deleted d ON i.Guest_ID = d.Guest_ID;  -- For UPDATE operations
        
        -- Close the symmetric key
        CLOSE SYMMETRIC KEY GuestDataKey;
    END
END;





