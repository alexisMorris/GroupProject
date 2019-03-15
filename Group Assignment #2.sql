CREATE TABLE Departments
(
	DepartmentKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Department varchar(255)
)

SET IDENTITY_INSERT Departments ON
INSERT Departments (DepartmentKey, Department) VALUES
	(1, 'Finance'),
	(2, 'Business Intelligence'),
	(3, 'Information Technology'),
	(4, 'Accounting')
SET IDENTITY_INSERT Departments OFF

CREATE TABLE Employees
(
	EmployeeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LastName varchar(25) NOT NULL,
	FirstName varchar(25) NOT NULL,
	Email varchar(50) NOT NULL,
	Hired date NOT NULL,
	Terminated date NULL,
	DepartmentKey int NOT NULL,
	CurrentSupervisorEmployeeKey int NOT NULL --CEO/Top of hierarchy should have their own EmployeeKey
)

SET IDENTITY_INSERT Employees ON
INSERT Employees (EmployeeKey, LastName, FirstName, Email, Hired, DepartmentKey, CurrentSupervisorEmployeeKey) VALUES
	(1, 'Reed', 'Russell', 'russ@mythicalCompany.com', '1/1/2015', 2, 4),
	(2, 'Barnes', 'Eric', 'eric@mythicalCompany.com', '1/1/2015', 3, 1),
	(3, 'Gotti', 'Jason', 'jason@mythicalCompany.com', '1/1/2015', 3, 2),
	(4, 'Boss', 'Da', 'DaBoss@mythicalCompany.com', '1/1/2015', 1, 4)
SET IDENTITY_INSERT Employees OFF

CREATE TABLE EmployeeJobs
(
	EmployeeJobKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	EmployeeKey int NOT NULL,
	JobStart date NOT NULL,
	JobFinish date NULL,
	Title varchar(50) NOT NULL,
	SupervisorEmployeeKey int NOT NULL,
	Salary money
)

INSERT EmployeeJobs (EmployeeKey, JobStart, JobFinish, Title, SupervisorEmployeeKey, Salary) VALUES
(1, '1/1/2015', '7/4/2016', 'Director, IT Development', 4, 60000),
(1, '7/5/2016', '3/1/2017', 'Director, Analytics', 4, 70000),
(1, '3/2/2017', NULL, 'VP, Technology & Analytics', 4, 80000),
(2, '1/1/2015', '3/2/2017', 'Developer 3', 1, 50000),
(2, '3/3/2017', NULL, 'Director, IT Development', 1, 60000),
(3, '1/1/2015', NULL, 'Developer 2', 2, 50000),
(4, '1/1/2015', NULL, 'Da Boss', 4, 100000)


CREATE TABLE ComputerTypes
(
	ComputerTypeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerType varchar(25) NOT NULL
) 
SET IDENTITY_INSERT ComputerTypes ON
INSERT ComputerTypes (ComputerTypeKey, ComputerType) VALUES 
	(1, 'Desktop'),
	(2, 'Laptop'),
	(3, 'Tablet'),
	(4, 'Phone')
SET IDENTITY_INSERT ComputerTypes OFF


CREATE TABLE ComputerStatuses
(
	ComputerStatusKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerStatus varchar(50) NOT NULL,
	ActiveStatus bit NOT NULL  --an indicator of if this status means the computer is available or not
)

SET IDENTITY_INSERT ComputerStatuses ON
INSERT ComputerStatuses (ComputerStatusKey, ComputerStatus, ActiveStatus) VALUES 
		(0, 'New', 1),
		(1, 'Assigned', 1),
		(2, 'Available', 1),
		(3, 'Lost', 0),
		(4, 'In for Repairs', 0), 
		(5, 'Retired', 1)
SET IDENTITY_INSERT ComputerStatuses OFF


CREATE TABLE Computers
(
	ComputerKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerTypeKey int NOT NULL,
	ComputerStatusKey int NOT NULL DEFAULT(0),
	PurchaseDate date NOT NULL,
	PurchaseCost money NOT NULL,
	ComputerDetails varchar(max) NULL
)

CREATE TABLE EmployeeComputers
(
	EmployeeComputerKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	EmployeeKey int NOT NULL,
	ComputerKey int NOT NULL,
	Assigned date NOT NULL,
	Returned date NULL
)

ALTER TABLE Employees
	ADD CONSTRAINT FK_EmployeeDepartment
	FOREIGN KEY (DepartmentKey)
	REFERENCES Departments (DepartmentKey)

ALTER TABLE Employees
	ADD CONSTRAINT FK_EmployeeSupervisor
	FOREIGN KEY (CurrentSupervisorEmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE EmployeeJobs
	ADD CONSTRAINT FK_Employee
	FOREIGN KEY (EmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE EmployeeJobs
	ADD CONSTRAINT FK_EmployeeSupervisorHistory
	FOREIGN KEY (SupervisorEmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE Computers 
	ADD CONSTRAINT FK_ComputerComputerTypes 
	FOREIGN KEY (ComputerTypeKey) 
	REFERENCES ComputerTypes (ComputerTypeKey)

ALTER TABLE Computers
	ADD CONSTRAINT FK_ComputerComputerStatus
	FOREIGN KEY (ComputerStatusKey) 
	REFERENCES ComputerStatuses (ComputerStatusKey)

ALTER TABLE EmployeeComputers
	ADD CONSTRAINT FK_EmployeeComputerEmployee
	FOREIGN KEY (EmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE EmployeeComputers
	ADD CONSTRAINT FK_EmployeeComputerComputer
	FOREIGN KEY (ComputerKey)
	REFERENCES Computers (ComputerKey)


/*
DROP TABLE EmployeeComputers
DROP TABLE EmployeeJobs
DROP TABLE Employees
DROP TABLE Departments
DROP TABLE Computers
DROP TABLE ComputerTypes
DROP TABLE ComputerStatuses 
*/


/* This is a pretty standard employee and asset tracking database */

/* 
Rules of engagement...

 - All objects that you create need to have a prefix in front of them.  It
	should be the same prefix for all objects.  Pick whatever you want - 
	an example..  SuperGroup_AddEmployee or JazzRule_NewComputer

 - You can change the table design if you want but you have to provide
	alter table scripts as part of your submission.  You really don't need 
	to change the tables..

 - Look at the tables and take obvious steps to prevent bad data from getting
	into them as you build stored procedures, triggers, functions, etc.  For
	example - can two people have the same computer at the same time?

 - Always fail gracefully.  Trap errors and return messages

 - There is a lot of work to be done.  Don't wait until the last minute
	or you will not get it done


All the things you have to get done...

 - Stored procedures that accomplish the following things:

	- Create new departments
	- Update the name of existing departments
	- Create new employees.  Every new employee has to have a job.  Job
		information is stored in "EmployeeJobs".  Make sure you trap
		errors and prevent orphan records in the Employees table.
	- Update an employees job.  Any update to a job should generate
		a new record for that employee in the EmployeeJobs table.  This
		would include changing their title, salary, or supervisor
	- Update an employees department
	- Update an employees supervisor
	- Terminate an employee.  When an employee is terminated, their
		computer equipment is returned to the company.  Their job
		record is also ended.
	- Add a new computer to the companies inventory.  You'll need to 
		pass in a JSON string that has the computer details you want 
		stored in your database (stored in ComputerDetails).
	- Assign/return/report lost/retire a computer.  You cannot retire
		a computer that still has some value left (has to be put back 
		in inventory or reported as lost).

 - Views that need to be written
 
	 - A list of all active computers (i.e. exclude lost and retired).  Include
		who is assigned the computer (if applicable), when it was purchased, 
		its monthly depreciation rate, and the specs of the computer
	 - A list of current employees, their supervisor, the department they are in,
		their current salary, their current title, the date they last
		recieved a raise, and the percentage increase that raise was

 - Triggers that need to be written

	- I don't trust people when they have full access to my database.  Write
		something that prevents someone from deleting an employee.  Instead,
		have it add a termination date to their employee record and close
		out their active job record.

- Constraints to write

	- On the Computers table, ensure the data put into the ComputerDetails
		field is properly formatted JSON.
	- At our mythical company, no employee can make less than 50k and no
		more than 150k.
	- Also at our fun company, no computer can cost more than 10k.  

- Functions to write

	- Write a function that takes a date and a dollar value and calculates
		a monthly depreciation value.  Computer equipment is usually 
		depreciated over 36 months - i.e. it loses 1/36th of its value
		each month after it is purchased.  
	- Write a function that provides the current value of any computer currently
		in your inventory


- Queries to write

	- Write a query that provides me the active employees for any date I want
		to provide.  Include their job, supervisor, department, title, 
		name, and email address

	- Write a query that provides all lost or retired computers.  Include
		the purchase details, how many people were assigned the computer,
		the last person to have the computer, and the last status of the computer


Once you're done, you'll need to test everything out by hiring/firing employees,
	changing their departments, changing their boss, changing their job, etc.  You'll
	need to add new computers, assign them to the new people, return them, assign them
	back out, etc.  All this should be done with the stored procedures you've created.
	No inserts, updates, deletes, outside of what is needed to test constraints and 
	triggers.

Include your lengthly script as part of your submission


