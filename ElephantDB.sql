DROP DATABASE IF EXISTS elephantDB;
CREATE DATABASE elephantDB;
USE elephantDB;

CREATE TABLE `role` (
	roleId int primary key,
	roleName varchar(10) not null
);

CREATE TABLE location (
	locationId int primary key auto_increment,
    cityName varchar(25) not null,
    timeIncrement int not null,
    maxOccupancy int not null,
    beginningTime time not null,
    endTime time not null
);

CREATE TABLE timeSlot (
	timeSlotId int primary key auto_increment,
    startTime time not null,
    locationId int,
    CONSTRAINT fk_timeSlot_location
		FOREIGN KEY (locationId)
        REFERENCES location(locationId)
);

CREATE TABLE `user` (
	userId int primary key auto_increment,
    firstName varchar(25) not null,
    lastName varchar(25) not null,
    email varchar(50) not null,
    passwords varchar(15) not null,
    locationId int,
    roleId int,
    CONSTRAINT fk_user_location
		FOREIGN KEY (locationId)
        REFERENCES location(locationId),
	CONSTRAINT fk_user_role
		FOREIGN KEY (roleId)
        REFERENCES role(roleId)
);
        
CREATE TABLE arrival (
	arrivalId int primary key auto_increment,
    arrivalDate date not null,
    timeSlotId int,
    userId int,
    CONSTRAINT fk_arrival_timeSlot
		FOREIGN KEY (timeSlotId)
        REFERENCES timeSlot(timeSlotId),
	CONSTRAINT fk_arrival_user
		FOREIGN KEY (userId)
        REFERENCES user(userId)
);
	
CREATE TABLE departure (
	departureId int primary key auto_increment,
    departureDate date not null,
    timeSlotId int,
    userId int,
    CONSTRAINT fk_departure_timeSlot
		FOREIGN KEY (timeSlotId)
        REFERENCES timeSlot(timeSlotId),
	CONSTRAINT fk_departure_user
		FOREIGN KEY (userId)
        REFERENCES user(userId)
);

CREATE TABLE attendance (
	attendanceId int primary key auto_increment,
    isAttending boolean default false,
    attendanceDate date not null,
    userId int,
    CONSTRAINT fk_attendance_user
		FOREIGN KEY (userId)
        REFERENCES user(userId)
);

INSERT INTO location (cityName, timeIncrement, maxOccupancy, beginningTime, endTime) VALUES 
	("Minneapolis", 5, 20, "07:00:00", "19:00:00"),
	("Austin", 7, 15, "06:00:00", "18:00:00");

INSERT INTO `role` (roleId, roleName)
VALUES (1, "ROLE_ADMIN"),
(2, "ROLE_USER");

INSERT INTO `user` (userId, firstName, lastName, email, passwords, locationId, roleId) VALUES 
	(1, "default", "user", "user@user.com", "password", 1, 1),
    (2, "Keely", "Brennan", "keely@keely.com", "password", 1, 2),
    (3, "Ethan", "Bettenga", "ethan@ethan.com", "password", 1, 2),
    (4, "Nate", "Wood", "nate@nate.com", "password", 1, 2),
    (5, "Matthew", "Gerszewski", "matthew@matthew.com", "password", 1, 2);

DELIMITER $$
CREATE PROCEDURE genMinneapolisTimeSlots()
BEGIN
	DECLARE x INT;
    DECLARE y TIME;
    DECLARE increment INT;
    DECLARE beginningTimeHours INT;
    DECLARE beginningTimeMinutes INT;
    DECLARE endTimeHours INT;
    DECLARE endTimeMinutes INT;
    DECLARE intervalMinutes INT;
    DECLARE loopNumber INT;
    
    SET x = 0;
    SET y = (SELECT beginningTime FROM location WHERE locationId = 1);
    SET increment = (SELECT timeIncrement FROM location WHERE locationId = 1);
    SET beginningTimeHours = (SELECT HOUR(beginningTime) FROM location WHERE locationId = 1);
    SET beginningTimeMinutes = (SELECT MINUTE(beginningTime) FROM location WHERE locationId = 1);
    SET endTimeHours = (SELECT HOUR(endTime) FROM location WHERE locationId = 1);
    SET endTimeMinutes = (SELECT MINUTE(endTime) FROM location WHERE locationId = 1);
    Set intervalMinutes = (endTimeHours * 60 + endTimeMinutes) - (beginningTimeHours * 60 + beginningTimeMinutes);
	SET loopNumber = intervalMinutes / increment;
    
    loop_label: LOOP
		IF x > loopNumber THEN
			LEAVE loop_label;
		END IF;
        
        INSERT INTO timeslot (startTime, locationId) VALUES (y + INTERVAL increment * x MINUTE, 1);
        
        SET x = x + 1;
	END LOOP;
END$$

DELIMITER $$
CREATE PROCEDURE genAustinTimeSlots()
BEGIN
	DECLARE x INT;
    DECLARE y TIME;
    DECLARE increment INT;
    DECLARE beginningTimeHours INT;
    DECLARE beginningTimeMinutes INT;
    DECLARE endTimeHours INT;
    DECLARE endTimeMinutes INT;
    DECLARE intervalMinutes INT;
    DECLARE loopNumber INT;
    
    SET x = 0;
    SET y = (SELECT beginningTime FROM location WHERE locationId = 2);
    SET increment = (SELECT timeIncrement FROM location WHERE locationId = 2);
    SET beginningTimeHours = (SELECT HOUR(beginningTime) FROM location WHERE locationId = 2);
    SET beginningTimeMinutes = (SELECT MINUTE(beginningTime) FROM location WHERE locationId = 2);
    SET endTimeHours = (SELECT HOUR(endTime) FROM location WHERE locationId = 2);
    SET endTimeMinutes = (SELECT MINUTE(endTime) FROM location WHERE locationId = 2);
    Set intervalMinutes = (endTimeHours * 60 + endTimeMinutes) - (beginningTimeHours * 60 + beginningTimeMinutes);
	SET loopNumber = intervalMinutes / increment;
    
    loop_label: LOOP
		IF x > loopNumber THEN
			LEAVE loop_label;
		END IF;
        
        INSERT INTO timeslot (startTime, locationId) VALUES (y + INTERVAL increment * x MINUTE, 2);
        
        SET x = x + 1;
	END LOOP;
END$$

DELIMITER $$
CREATE PROCEDURE genMinneapolisArrivalsAndDepatures()
BEGIN
	DECLARE minTimeSlotId INT DEFAULT 0;
    DECLARE maxTimeSlotId INT DEFAULT 0;
    DECLARE x INT;
    
    SELECT MIN(timeSlotId) FROM timeSlot WHERE locationId = 1 INTO minTimeSlotId;
    SELECT MAX(timeSlotId) FROM timeSlot WHERE locationId = 1 INTO maxTimeSlotId;
    SET x = minTimeSlotId;
    
    loop_label: LOOP
		IF x > maxTimeSlotId THEN
			LEAVE loop_label;
		END IF;
        
        INSERT INTO arrival (arrivalDate, timeSlotId, userId) VALUES (CURDATE(), x, 1);
        INSERT INTO departure (departureDate, timeSlotId, userId) VALUES (CURDATE(), x, 1);
    
		SET x = x + 1;
	END LOOP;
END$$

DELIMITER $$
CREATE PROCEDURE genAustinArrivalsAndDepatures()
BEGIN
	DECLARE minTimeSlotId INT DEFAULT 0;
    DECLARE maxTimeSlotId INT DEFAULT 0;
    DECLARE x INT;
    
    SELECT MIN(timeSlotId) FROM timeSlot WHERE locationId = 2 INTO minTimeSlotId;
    SELECT MAX(timeSlotId) FROM timeSlot WHERE locationId = 2 INTO maxTimeSlotId;
    SET x = minTimeSlotId;
    
    loop_label: LOOP
		IF x > maxTimeSlotId THEN
			LEAVE loop_label;
		END IF;
        
        INSERT INTO arrival (arrivalDate, timeSlotId, userId) VALUES (CURDATE(), x, 1);
        INSERT INTO departure (departureDate, timeSlotId, userId) VALUES (CURDATE(), x, 1);
    
		SET x = x + 1;
	END LOOP;
END$$

CREATE EVENT generateTimeSlots
	ON SCHEDULE EVERY '1' day
    STARTS '2020-05-12 18:23:00'
DO
	CALL genMinneapolisTimeSlots();
    CALL genAustinTimeSlots();
    CALL genMinneapolisArrivalsAndDepatures();
    CALL genAustinArrivalsAndDepatures();