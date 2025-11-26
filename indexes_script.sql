USE HotelManagementDB;

CREATE NONCLUSTERED INDEX IX_Booking_GuestID
ON BOOKING (Guest_ID, Check_In_Date, Check_Out_Date)
INCLUDE (Status, Booking_Rate);


CREATE NONCLUSTERED INDEX IX_RoomBooking_Dates
ON ROOM_BOOKING_ASSIGNMENT (StartDate, EndDate, Room_Number);


CREATE NONCLUSTERED INDEX IX_Payment_Date
ON PAYMENT (Payment_Date, Payment_Type)
INCLUDE (Amount);


CREATE NONCLUSTERED INDEX IX_ServiceTrans_BookingID
ON SERVICE_TRANSACTION (Booking_ID)
INCLUDE (Service_ID, Total_Amount);


CREATE NONCLUSTERED INDEX IX_Maintenance_Status
ON MAINTENANCE_REQUEST (Status, Priority)
INCLUDE (Room_Number, Request_Date);


