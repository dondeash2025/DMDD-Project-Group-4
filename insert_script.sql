USE HotelManagementDB; 
GO


INSERT INTO GUEST (First_Name, Last_Name, Age, Street, City, State, Zip_Code, Country, Phone, Email, Nationality) VALUES
('John', 'Smith', 35, '123 Main St', 'Boston', 'MA', '02101', 'USA', '617-555-0101', 'john.smith@email.com', 'American'),
('Emily', 'Johnson', 28, '456 Oak Ave', 'New York', 'NY', '10001', 'USA', '212-555-0102', 'emily.johnson@email.com', 'American'),
('Michael', 'Williams', 42, '789 Pine Rd', 'Los Angeles', 'CA', '90001', 'USA', '310-555-0103', 'michael.williams@email.com', 'American'),
('Sarah', 'Brown', 31, '321 Elm St', 'Chicago', 'IL', '60601', 'USA', '312-555-0104', 'sarah.brown@email.com', 'American'),
('David', 'Jones', 45, '654 Maple Dr', 'Houston', 'TX', '77001', 'USA', '713-555-0105', 'david.jones@email.com', 'American'),
('Maria', 'Garcia', 29, '987 Cedar Ln', 'Phoenix', 'AZ', '85001', 'USA', '602-555-0106', 'maria.garcia@email.com', 'Mexican'),
('James', 'Miller', 38, '147 Birch Way', 'Philadelphia', 'PA', '19101', 'USA', '215-555-0107', 'james.miller@email.com', 'American'),
('Linda', 'Davis', 33, '258 Spruce Ct', 'San Antonio', 'TX', '78201', 'USA', '210-555-0108', 'linda.davis@email.com', 'American'),
('Robert', 'Rodriguez', 40, '369 Willow Pl', 'San Diego', 'CA', '92101', 'USA', '619-555-0109', 'robert.rodriguez@email.com', 'Mexican'),
('Patricia', 'Martinez', 27, '741 Ash Blvd', 'Dallas', 'TX', '75201', 'USA', '214-555-0110', 'patricia.martinez@email.com', 'American'),
('William', 'Anderson', 50, '852 Poplar Ave', 'San Jose', 'CA', '95101', 'USA', '408-555-0111', 'william.anderson@email.com', 'American'),
('Jennifer', 'Taylor', 26, '963 Hickory Dr', 'Austin', 'TX', '73301', 'USA', '512-555-0112', 'jennifer.taylor@email.com', 'American');

INSERT INTO ROOM (Room_Number, Room_Type, Status, Price, Capacity) VALUES
(101, 'Single', 'Available', 89.99, 1),
(102, 'Single', 'Available', 89.99, 1),
(103, 'Double', 'Available', 129.99, 2),
(104, 'Double', 'Available', 129.99, 2),
(105, 'Suite', 'Available', 249.99, 4),
(106, 'Suite', 'Occupied', 249.99, 4),
(107, 'Deluxe', 'Available', 349.99, 4),
(108, 'Double', 'Maintenance', 129.99, 2),
(109, 'Single', 'Available', 89.99, 1),
(110, 'Deluxe', 'Occupied', 349.99, 4),
(201, 'Double', 'Available', 139.99, 2),
(202, 'Suite', 'Available', 259.99, 4);

INSERT INTO BOOKING (Guest_ID, Booking_Rate, Check_In_Date, Check_Out_Date, Status) VALUES
(1, 89.99, '2025-11-05', '2025-11-08', 'Confirmed'),
(2, 129.99, '2025-11-06', '2025-11-10', 'Confirmed'),
(3, 249.99, '2025-11-01', '2025-11-05', 'CheckedIn'),
(4, 129.99, '2025-10-28', '2025-11-03', 'CheckedOut'),
(5, 349.99, '2025-11-02', '2025-11-06', 'CheckedIn'),
(6, 89.99, '2025-11-10', '2025-11-12', 'Confirmed'),
(7, 139.99, '2025-11-08', '2025-11-11', 'Confirmed'),
(8, 249.99, '2025-10-25', '2025-10-30', 'CheckedOut'),
(9, 129.99, '2025-11-04', '2025-11-07', 'Confirmed'),
(10, 89.99, '2025-11-15', '2025-11-17', 'Confirmed'),
(11, 349.99, '2025-11-20', '2025-11-25', 'Confirmed'),
(12, 129.99, '2025-11-12', '2025-11-14', 'Confirmed');



INSERT INTO ROOM_BOOKING_ASSIGNMENT (Room_Number, Booking_ID, StartDate, EndDate) VALUES
(101, 1, '2025-11-05', '2025-11-08'),
(103, 2, '2025-11-06', '2025-11-10'),
(106, 3, '2025-11-01', '2025-11-05'),
(104, 4, '2025-10-28', '2025-11-03'),
(110, 5, '2025-11-02', '2025-11-06'),
(109, 6, '2025-11-10', '2025-11-12'),
(201, 7, '2025-11-08', '2025-11-11'),
(105, 8, '2025-10-25', '2025-10-30'),
(103, 9, '2025-11-04', '2025-11-07'),
(102, 10, '2025-11-15', '2025-11-17'),
(107, 11, '2025-11-20', '2025-11-25'),
(201, 12, '2025-11-12', '2025-11-14');



INSERT INTO DISCOUNT (Discount_Name, Discount_Type, Discount_Value, Valid_From, Valid_To) VALUES
('Early Bird Special', 'Percentage', 15.00, '2025-01-01', '2025-12-31'),
('Weekend Getaway', 'Percentage', 20.00, '2025-11-01', '2025-11-30'),
('Extended Stay', 'Percentage', 25.00, '2025-01-01', '2025-12-31'),
('Senior Discount', 'Percentage', 10.00, '2025-01-01', '2025-12-31'),
('Military Discount', 'Percentage', 15.00, '2025-01-01', '2025-12-31'),
('Corporate Rate', 'Fixed', 50.00, '2025-01-01', '2025-12-31'),
('Holiday Special', 'Percentage', 30.00, '2025-12-20', '2025-12-31'),
('Loyalty Member', 'Percentage', 12.00, '2025-01-01', '2025-12-31'),
('Group Booking', 'Percentage', 18.00, '2025-01-01', '2025-12-31'),
('Last Minute Deal', 'Fixed', 40.00, '2025-11-01', '2025-11-30'),
('Summer Special', 'Percentage', 20.00, '2025-06-01', '2025-08-31'),
('New Customer', 'Fixed', 25.00, '2025-01-01', '2025-12-31');



INSERT INTO BOOKING_DISCOUNT (Booking_ID, Discount_ID, Applied_Value) VALUES
(1, 1, 13.50),
(2, 2, 26.00),
(3, 3, 62.50),
(4, 4, 13.00),
(5, 8, 41.99),
(6, 1, 13.50),
(7, 2, 27.99),
(8, 3, 62.50),
(9, 10, 40.00),
(10, 1, 13.50),
(11, 9, 62.99),
(12, 2, 26.00);



INSERT INTO INVOICE (Booking_ID, Generated_Date, Total_Amount) VALUES
(4, '2025-11-03', 519.96),
(8, '2025-10-30', 999.96),
(3, '2025-11-05', 1187.46),
(5, '2025-11-06', 1631.96),
(1, '2025-11-08', 282.47),
(2, '2025-11-10', 545.96),
(6, '2025-11-12', 189.98),
(7, '2025-11-11', 447.97),
(9, '2025-11-07', 413.97),
(10, '2025-11-17', 189.98),
(11, '2025-11-25', 1924.95),
(12, '2025-11-14', 273.98);



INSERT INTO TAX (Tax_Name, Tax_Rate, Description) VALUES
('State Tax', 6.25, 'Massachusetts state tax'),
('City Tax', 2.75, 'Boston city tax'),
('Tourism Tax', 4.50, 'Tourism development tax'),
('Service Tax', 5.00, 'Service charge tax'),
('VAT', 10.00, 'Value Added Tax'),
('Federal Tax', 3.00, 'Federal occupancy tax'),
('County Tax', 1.50, 'County tax'),
('Resort Fee Tax', 2.00, 'Resort amenities tax'),
('Environmental Tax', 1.00, 'Environmental sustainability tax'),
('Convention Tax', 2.50, 'Convention center tax'),
('Lodging Tax', 5.50, 'General lodging tax'),
('Sales Tax', 7.00, 'General sales tax');



INSERT INTO INVOICE_TAX (Invoice_ID, Tax_ID, Tax_Amount) VALUES
(1, 1, 32.50),
(1, 2, 14.30),
(2, 1, 62.50),
(2, 2, 27.50),
(3, 1, 74.22),
(3, 3, 53.44),
(4, 1, 101.99),
(4, 2, 44.88),
(5, 1, 17.66),
(5, 2, 7.77),
(6, 1, 34.12),
(6, 3, 24.57),
(7, 1, 11.87),
(7, 2, 5.22),
(8, 1, 27.99),
(8, 2, 12.32),
(9, 1, 25.87),
(9, 3, 18.63),
(10, 1, 11.87),
(10, 2, 5.22),
(11, 1, 120.31),
(11, 2, 52.94),
(12, 1, 17.12),
(12, 2, 7.53);



INSERT INTO PAYMENT (Invoice_ID, Payment_Type, Amount, Payment_Date, Payment_Status) VALUES
(1, 'CreditCard', 519.96, '2025-11-03 14:30:00', 'Completed'),
(2, 'CreditCard', 999.96, '2025-10-30 11:15:00', 'Completed'),
(3, 'DebitCard', 1187.46, '2025-11-05 10:00:00', 'Completed'),
(4, 'Cash', 1631.96, '2025-11-06 16:45:00', 'Completed'),
(5, 'Online', 282.47, '2025-11-08 09:30:00', 'Pending'),
(6, 'CreditCard', 545.96, '2025-11-10 12:00:00', 'Pending'),
(7, 'UPI', 189.98, '2025-11-12 15:20:00', 'Pending'),
(8, 'CreditCard', 447.97, '2025-11-11 13:45:00', 'Pending'),
(9, 'DebitCard', 413.97, '2025-11-07 17:00:00', 'Pending'),
(10, 'Cash', 189.98, '2025-11-17 10:30:00', 'Pending'),
(11, 'CreditCard', 1924.95, '2025-11-25 14:00:00', 'Pending'),
(12, 'Online', 273.98, '2025-11-14 11:30:00', 'Pending');



INSERT INTO SERVICE (Service_Name, Service_Description, Price, Category) VALUES
('Spa Treatment', 'Full body massage and spa', 120.00, 'Wellness'),
('Laundry Service', 'Same-day laundry service', 25.00, 'Room Service'),
('Room Service', 'In-room dining', 15.00, 'Food & Beverage'),
('Airport Shuttle', 'Round trip airport transportation', 50.00, 'Transportation'),
('Gym Access', 'Daily gym access', 20.00, 'Fitness'),
('Mini Bar', 'In-room mini bar restocking', 35.00, 'Room Service'),
('Breakfast Buffet', 'All-you-can-eat breakfast', 25.00, 'Food & Beverage'),
('Parking', 'Daily parking service', 30.00, 'Parking'),
('Wi-Fi Premium', 'High-speed internet access', 15.00, 'Technology'),
('Late Checkout', 'Extended checkout time', 40.00, 'Room Service'),
('Pet Care', 'Pet sitting and care', 45.00, 'Pet Services'),
('Conference Room', 'Hourly conference room rental', 75.00, 'Business');



INSERT INTO SERVICE_TRANSACTION (Booking_ID, Service_ID, Quantity, Total_Amount, Transaction_Date) VALUES
(3, 1, 1, 120.00, '2025-11-02 14:00:00'),
(3, 7, 4, 100.00, '2025-11-01 08:00:00'),
(4, 2, 1, 25.00, '2025-10-29 10:00:00'),
(4, 4, 1, 50.00, '2025-10-28 15:00:00'),
(5, 3, 2, 30.00, '2025-11-03 19:00:00'),
(5, 8, 4, 120.00, '2025-11-02 06:00:00'),
(8, 1, 2, 240.00, '2025-10-26 16:00:00'),
(8, 7, 5, 125.00, '2025-10-25 08:00:00'),
(1, 9, 3, 45.00, '2025-11-05 09:00:00'),
(2, 6, 1, 35.00, '2025-11-07 20:00:00'),
(3, 10, 1, 40.00, '2025-11-05 13:00:00'),
(5, 11, 2, 90.00, '2025-11-03 10:00:00');



INSERT INTO RESTAURANT_ORDER (Guest_ID, Booking_ID, Order_Date, Total_Amount) VALUES
(3, 3, '2025-11-01 19:30:00', 85.50),
(3, 3, '2025-11-02 20:00:00', 92.00),
(4, 4, '2025-10-28 18:45:00', 67.50),
(5, 5, '2025-11-02 19:15:00', 124.00),
(5, 5, '2025-11-03 20:30:00', 98.50),
(8, 8, '2025-10-26 19:00:00', 156.00),
(1, 1, '2025-11-05 18:30:00', 73.50),
(2, 2, '2025-11-06 19:45:00', 89.00),
(6, 6, '2025-11-10 20:15:00', 112.50),
(7, 7, '2025-11-08 19:30:00', 95.00),
(9, 9, '2025-11-05 18:00:00', 78.50),
(10, 10, '2025-11-15 19:00:00', 68.00);



INSERT INTO [ORDER] (Restaurant_Order_ID, Item_Name, Quantity, Price, Total) VALUES
(1, 'Grilled Salmon', 1, 32.00, 32.00),
(1, 'Caesar Salad', 2, 12.50, 25.00),
(1, 'Red Wine', 1, 28.50, 28.50),
(2, 'Ribeye Steak', 1, 45.00, 45.00),
(2, 'Garlic Bread', 2, 8.00, 16.00),
(2, 'Cheesecake', 1, 12.00, 12.00),
(2, 'Coffee', 2, 4.50, 9.00),
(3, 'Pasta Carbonara', 1, 22.00, 22.00),
(3, 'Garden Salad', 1, 10.50, 10.50),
(3, 'Iced Tea', 2, 4.00, 8.00),
(3, 'Tiramisu', 1, 10.00, 10.00),
(4, 'Lobster Tail', 2, 48.00, 96.00),
(4, 'Baked Potato', 2, 7.00, 14.00),
(5, 'Chicken Alfredo', 1, 24.50, 24.50),
(5, 'Bruschetta', 1, 11.00, 11.00),
(5, 'White Wine', 1, 32.00, 32.00),
(6, 'Prime Rib', 2, 52.00, 104.00),
(6, 'French Onion Soup', 2, 9.00, 18.00),
(7, 'Fish and Chips', 1, 19.50, 19.50),
(7, 'Clam Chowder', 1, 12.00, 12.00),
(7, 'Apple Pie', 2, 8.00, 16.00),
(8, 'Vegetarian Pizza', 1, 18.00, 18.00),
(8, 'Greek Salad', 1, 11.50, 11.50),
(8, 'Lemonade', 2, 3.50, 7.00);



INSERT INTO FEEDBACK (Booking_ID, Rating, Comments, Feedback_Date) VALUES
(4, 5, 'Excellent service! The room was spotless and the staff were very friendly.', '2025-11-03'),
(8, 4, 'Great stay overall. The spa services were amazing. Only issue was slow Wi-Fi.', '2025-10-30'),
(3, 5, 'Best hotel experience! Will definitely return.', '2025-11-05'),
(5, 4, 'Very comfortable rooms and great location. Restaurant food was delicious.', '2025-11-06'),
(1, 5, 'Perfect for a business trip. Clean, quiet, and professional.', '2025-11-08'),
(2, 3, 'Room was nice but had some maintenance issues. Staff resolved them quickly.', '2025-11-10'),
(6, 5, 'Amazing weekend getaway! Highly recommend.', '2025-11-12'),
(7, 4, 'Good value for money. Breakfast buffet was excellent.', '2025-11-11'),
(9, 5, 'Outstanding service from check-in to check-out.', '2025-11-07'),
(10, 4, 'Clean rooms and friendly staff. Minor noise from adjacent room.', '2025-11-17'),
(11, 5, 'Luxury at its finest! Every detail was perfect.', '2025-11-25'),
(12, 4, 'Great hotel for families. Kids loved the pool.', '2025-11-14');



INSERT INTO STAFF (First_Name, Last_Name, Role, Status) VALUES
('Alice', 'Thompson', 'Manager', 'Active'),
('Bob', 'Wilson', 'Receptionist', 'Active'),
('Carol', 'Moore', 'Housekeeper', 'Active'),
('Daniel', 'White', 'Maintenance', 'Active'),
('Emma', 'Harris', 'Chef', 'Active'),
('Frank', 'Martin', 'Waiter', 'Active'),
('Grace', 'Jackson', 'Housekeeper', 'Active'),
('Henry', 'Lee', 'Bellboy', 'Active'),
('Iris', 'Walker', 'Receptionist', 'Active'),
('Jack', 'Hall', 'Maintenance', 'OnLeave'),
('Karen', 'Allen', 'Spa Therapist', 'Active'),
('Leo', 'Young', 'Security', 'Active');



INSERT INTO SHIFT (Staff_ID, Shift_Date, Start_Time, End_Time, Shift_Type) VALUES
(2, '2025-11-02', '07:00:00', '15:00:00', 'Morning'),
(6, '2025-11-02', '15:00:00', '23:00:00', 'Evening'),
(12, '2025-11-02', '23:00:00', '07:00:00', 'Night'),
(9, '2025-11-03', '07:00:00', '15:00:00', 'Morning'),
(6, '2025-11-03', '15:00:00', '23:00:00', 'Evening'),
(12, '2025-11-03', '23:00:00', '07:00:00', 'Night'),
(2, '2025-11-04', '07:00:00', '15:00:00', 'Morning'),
(6, '2025-11-04', '15:00:00', '23:00:00', 'Evening'),
(12, '2025-11-04', '23:00:00', '07:00:00', 'Night'),
(9, '2025-11-05', '07:00:00', '15:00:00', 'Morning'),
(5, '2025-11-05', '15:00:00', '23:00:00', 'Evening'),
(12, '2025-11-05', '23:00:00', '07:00:00', 'Night');



INSERT INTO TASK (Description, Scheduled_Time, Status) VALUES
('Clean Room 104', '2025-11-02 10:00:00', 'Completed'),
('Fix AC in Room 108', '2025-11-02 14:00:00', 'InProgress'),
('Restock minibar Room 106', '2025-11-03 09:00:00', 'Pending'),
('Replace towels Room 110', '2025-11-03 11:00:00', 'Completed'),
('Inspect plumbing Room 201', '2025-11-04 13:00:00', 'Pending'),
('Deep clean lobby', '2025-11-04 08:00:00', 'Completed'),
('Check fire alarms', '2025-11-05 10:00:00', 'Pending'),
('Paint Room 105', '2025-11-05 15:00:00', 'InProgress'),
('Replace carpet hallway 2nd floor', '2025-11-06 09:00:00', 'Pending'),
('Clean pool area', '2025-11-06 07:00:00', 'Completed'),
('Inspect electrical Room 107', '2025-11-07 11:00:00', 'Pending'),
('Restock cleaning supplies', '2025-11-07 14:00:00', 'Completed');



INSERT INTO TASK_ASSIGNMENT (Task_ID, Staff_ID, Assigned_Date, Completion_Date) VALUES
(1, 3, '2025-11-02', '2025-11-02'),
(2, 4, '2025-11-02', NULL),
(3, 7, '2025-11-03', NULL),
(4, 3, '2025-11-03', '2025-11-03'),
(5, 4, '2025-11-04', NULL),
(6, 7, '2025-11-04', '2025-11-04'),
(7, 10, '2025-11-05', NULL),
(8, 4, '2025-11-05', NULL),
(9, 4, '2025-11-06', NULL),
(10, 3, '2025-11-06', '2025-11-06'),
(11, 4, '2025-11-07', NULL),
(12, 7, '2025-11-07', '2025-11-07');


INSERT INTO ROOM_ASSIGNMENT (Room_Number, Staff_ID, Assignment_Date) VALUES
(101, 3, '2025-11-02'),
(102, 7, '2025-11-02'),
(103, 3, '2025-11-02'),
(104, 7, '2025-11-03'),
(105, 3, '2025-11-03'),
(106, 7, '2025-11-04'),
(107, 3, '2025-11-04'),
(108, 4, '2025-11-05'),
(109, 7, '2025-11-05'),
(110, 3, '2025-11-06'),
(201, 7, '2025-11-06'),
(202, 3, '2025-11-07');



INSERT INTO MAINTENANCE_REQUEST (Room_Number, Staff_ID, Description, Request_Date, Priority, Status, Completion_Date) VALUES
(108, 4, 'Air conditioning not working properly', '2025-11-01', 'High', 'InProgress', NULL),
(104, 4, 'Leaky faucet in bathroom', '2025-10-30', 'Medium', 'Completed', '2025-10-31'),
(201, 4, 'Light bulb replacement needed', '2025-11-02', 'Low', 'Completed', '2025-11-02'),
(106, 4, 'TV remote not working', '2025-11-03', 'Low', 'Completed', '2025-11-03'),
(110, 4, 'Clogged drain in shower', '2025-11-04', 'Medium', 'Pending', NULL),
(105, 10, 'Window lock broken', '2025-11-05', 'High', 'Pending', NULL),
(107, 4, 'Thermostat malfunction', '2025-11-05', 'Medium', 'InProgress', NULL),
(103, 4, 'Squeaky door hinge', '2025-11-06', 'Low', 'Pending', NULL),
(109, 4, 'Carpet stain removal needed', '2025-11-06', 'Low', 'Pending', NULL),
(102, 10, 'Internet connection issues', '2025-11-07', 'Medium', 'Pending', NULL),
(202, 4, 'Mini fridge not cooling', '2025-11-07', 'Medium', 'Pending', NULL),
(101, 4, 'Replace smoke detector battery', '2025-11-08', 'Critical', 'Pending', NULL);
