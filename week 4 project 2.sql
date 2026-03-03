-- Create the Database
CREATE DATABASE IF NOT EXISTS AirbnbProject;
USE AirbnbProject;

-- Drop tables in reverse order of dependencies (to avoid FK errors)
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS guests;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS hosts;
DROP TABLE IF EXISTS locations;

-- Create locations table (dimension for nationalities)
CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(255) NOT NULL
);

-- Create hosts table (dimension)
CREATE TABLE hosts (
    host_id INT PRIMARY KEY AUTO_INCREMENT,
    host_name VARCHAR(255) NOT NULL,
    is_superhost CHAR(1) DEFAULT 'N' CHECK (is_superhost IN ('Y', 'N'))
);

-- Create properties table (dimension)
CREATE TABLE properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    host_id INT,
    property_type VARCHAR(255) NOT NULL,
    location_id INT,
    average_rating DECIMAL(3, 2),
    FOREIGN KEY (host_id) REFERENCES hosts(host_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Create guests table (dimension)
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    age_group VARCHAR(10) NOT NULL,  -- e.g., '18-25', '26-35'
    nationality VARCHAR(255) NOT NULL
);

-- Create bookings table (fact table)
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT,
    guest_id INT,
    booking_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    nights INT NOT NULL,
    rating DECIMAL(3, 2),
    FOREIGN KEY (property_id) REFERENCES properties(property_id),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

-- Insert sample data
INSERT INTO locations (country) VALUES ('USA'), ('Canada'), ('UK');
INSERT INTO hosts (host_name, is_superhost) VALUES ('Alice Johnson', 'Y'), ('Bob Smith', 'N'), ('Charlie Brown', 'Y');
INSERT INTO properties (host_id, property_type, location_id, average_rating) VALUES
(1, 'Apartment', 1, 4.8),
(2, 'House', 2, 4.2),
(3, 'Villa', 3, 4.9),
(1, 'Condo', 1, 4.3);
INSERT INTO guests (age_group, nationality) VALUES
('18-25', 'USA'),
('26-35', 'Canada'),
('36-45', 'UK'),
('18-25', 'USA');
INSERT INTO bookings (property_id, guest_id, booking_date, price, nights, rating) VALUES
(1, 1, '2023-10-01', 150.00, 3, 5.0),
(2, 2, '2023-10-02', 200.00, 2, 4.0),
(3, 3, '2023-10-03', 300.00, 4, 4.8),
(4, 4, '2023-10-04', 120.00, 2, 4.5),
(1, 2, '2023-10-05', 180.00, 3, 4.9);

-- Task 1: Host Success – Superhosts and total bookings received
SELECT 
    h.host_name AS Host_Name,
    COUNT(b.booking_id) AS Total_Bookings
FROM 
    hosts h
INNER JOIN 
    properties p ON h.host_id = p.host_id
INNER JOIN 
    bookings b ON p.property_id = b.property_id
WHERE 
    h.is_superhost = 'Y'
GROUP BY 
    h.host_id, h.host_name
ORDER BY 
    Total_Bookings DESC;

-- Task 2: Property Revenue – Revenue by property type
SELECT 
    p.property_type AS Property_Type,
    SUM(b.price * b.nights) AS Total_Revenue
FROM 
    properties p
INNER JOIN 
    bookings b ON p.property_id = b.property_id
GROUP BY 
    p.property_type
ORDER BY 
    Total_Revenue DESC;

-- Task 3: Guest Demographics – Average booking price by age group
SELECT 
    g.age_group AS Age_Group,
    AVG(b.price) AS Average_Booking_Price
FROM 
    guests g
INNER JOIN 
    bookings b ON g.guest_id = b.guest_id
GROUP BY 
    g.age_group
ORDER BY 
    Average_Booking_Price DESC;

-- Task 4: Booking Origins – Total bookings by nationality
SELECT 
    g.nationality AS Nationality,
    COUNT(b.booking_id) AS Total_Bookings
FROM 
    guests g
INNER JOIN 
    bookings b ON g.guest_id = b.guest_id
GROUP BY 
    g.nationality
ORDER BY 
    Total_Bookings DESC;

-- Task 5: Rating Analysis – Properties with average rating above 4.5
SELECT 
    p.property_type AS Property_Type,
    h.host_name AS Host_Name,
    p.average_rating AS Average_Rating
FROM 
    properties p
INNER JOIN 
    hosts h ON p.host_id = h.host_id
WHERE 
    p.average_rating > 4.5
ORDER BY 
    Average_Rating DESC;