/*
    CSE-385, 2020 Summer I
    Lab_02  
    Name: Walter Tracey
    10 points each
*/

USE MyGuitarShop

/* Q1: 
    Write a SELECT statement that returns four columns from the Products table:
    ProductCode, ProductName, ListPrice, and DiscountPercent and order the results by:  
    ListPrice in descending order, and DiscountPercent in ascending order. 
*/
SELECT  Products.ProductCode,
        Products.ProductName,
        Products.ListPrice,
        Products.DiscountPercent
FROM Products
ORDER BY ListPrice DESC, DiscountPercent
GO



/* Q2: 
    Write a SELECT statement that returns one column from the Customers table 
    named FullName that joins the LastName and FirstName columns (Ryan, Tom). 
    Sort the returned data by last name and then first name. Only return
    the contacts whose last name begins with a letter from A to G or M to Z.
*/
SELECT [FullName] = Customers.LastName + ', ' + Customers.FirstName
FROM Customers
WHERE LastName LIKE '[A-G]%' OR LastName LIKE '[M-Z]%'
ORDER BY LastName, FirstName
GO



/* Q3:
    Write a SELECT statement that returns rows from the Products table with 
    a list price that's greater than 500 and less than 2000 and sorted by the 
    DateAdded. Return the following columns from the Products table:

        ProductName	       The ProductName column
        ListPrice	        The ListPrice column
        DateAdded	    The DateAdded column
*/
SELECT  Products.ProductName,
        Products.ListPrice,
        Products.DateAdded
FROM Products
WHERE ListPrice BETWEEN 500 AND 2000
ORDER BY DateAdded
GO

/* Q4:
    Write a SELECT statement that returns the following column names and data 
    from the Products table and sorted by discount price in descending order:

        ProductName	    The ProductName column
        ListPrice	    The ListPrice column
        DiscountPercent	The DiscountPercent column
        DiscountAmount	A column that's calculated from the previous two columns
        DiscountPrice	A column that's calculated from the previous three columns
*/
SELECT  Products.ProductName,
        Products.ListPrice,
        Products.DiscountPercent,
        [DiscountAmount] = (Products.ListPrice * Products.DiscountPercent / 100),
        [DiscountPrice] = Products.ListPrice - (Products.ListPrice * Products.DiscountPercent / 100)
FROM Products
ORDER BY DiscountPrice DESC
GO

/* Q5:
    Write a SELECT statement that returns the following column names and data 
    from the OrderItems table where ItemTotal is greater than 500. 
    Sort the result set by ItemTotal in descending order:

        ItemID	        The ItemID column
        ItemPrice	    The ItemPrice column
        DiscountAmount	The DiscountAmount column
        Quantity	    The Quantity column
        PriceTotal	    A column calculated: ItemPrice * Quantity
        DiscountTotal	A column calculated: DiscountAmount * Quantity
        ItemTotal	    A column calculated: (ItemPrice - the DiscountAmount) * Quantity
*/
SELECT  oi.ItemID,
        oi.ItemPrice,
        oi.DiscountAmount,
        oi.Quantity,
        [PriceTotal] = oi.ItemPrice * oi.Quantity,
        [DiscountTotal] = oi.DiscountAmount * oi.Quantity,
        [ItemTotal] = (oi.ItemPrice - oi.DiscountAmount) * oi.Quantity
FROM OrderItems oi
WHERE (oi.ItemPrice - oi.DiscountAmount) * oi.Quantity > 500
ORDER BY ItemTotal DESC
GO


/* Q6:
    Write a SELECT statement that returns these columns from the Orders table 
    where ShipDate contains a null value and the type of card used was a Visa:
        OrderID	        The OrderID column
        OrderDate	    The OrderDate column
        ShipDate	    The ShipDate column
*/
SELECT  Orders.OrderID,
        Orders.OrderDate,
        Orders.ShipDate
FROM Orders
WHERE ShipDate IS NULL AND CardType LIKE 'Visa'
GO


/* Q7:
    Write a SELECT statement without a FROM clause (so you are not selecting 
    from tables – you are just creating your own columns) that creates a 
    row with these columns.  To calculate the fourth column, add the 
    expressions you used for the first and third columns.

        Price	100     (dollars)
        TaxRate	.07     (7 percent)
        TaxAmount	    The Price * TaxRate
        Total	        The Price + TaxAmount
*/
SELECT  [Price] = 100,
        [TaxRate] = .07,
        [TaxAmount] = 100 * .07,
        [Total] = 100 + (100 * .07)
GO


/* Q8:
    Create a complete script that will build and populate a new table called 
    Employees. Fields should not accept null values.

        An Employee is defined by the following fields:
             EmployeeID 		(int)
             EmployeeName 		(30 characters)
             Salary 			(float)
             Hourly 			(bit)
             PartTime 		    (bit with a default of 0)
             WorkDays 		    (33 characters) with a default of ''
             HomePhone 		    (20 characters).

    Notes:  WorkDays has an entry format of 'ddd, ddd, …' So, if an employee 
            worked Monday, Wednesday, Friday then it would be represented in 
            the database as: 'Mon, Wed, Fri'.  If they worked every day the 
            entry would be: 'Mon, Tue, Wed, Thu, Fri, Sat, Sun'

    Your script should also include a SINGLE insert so that 4 rows get 
    inserted into the table.  You are to assign the key value for each row. 
    The 4 entries should cover every combination of Hourly / PartTime.  i.e.:

        Hourly	PartTime
        0		0
        0		1
        1		0
        1		1
*/
-- = = = CREATE TABLE = = = --
CREATE TABLE Employees(
    EmployeeID      INT         PRIMARY KEY IDENTITY,
    EmployeeName    VARCHAR(30) NOT NULL,
    Salary          float       NOT NULL,
    Hourly          BIT         NOT NULL,
    PartTime        BIT         DEFAULT 0,
    WorkDays        VARCHAR(33) DEFAULT '',
    HomePhone       VARCHAR(20) NOT NULL
)
GO
-- = = = INSERT VALUES = = = --
INSERT INTO Employees (EmployeeName, Salary, Hourly, PartTime, WorkDays, HomePhone) VALUES
    ('Wally Blake', 20000.00, 1, 0, 'Wed, Fri, Sat', '765-473-2687'),
    ('Tim Walker', 30000.00, 1, 1, 'Mon, Sun', '765-754-0354'),
    ('Jim Gok', 60000.00, 0, 0, 'Tue, Thu', '765-739-7395'),
    ('Qi Feng', 10000.00, 0, 1, 'Mon, Tue, Wed, Thu, Fri, Sat, Sun', '765-437-8945')
GO


/* Q9:
    Write a query that returns the full time employees (i.e., not part time) 
    that can work on Wednesday or Saturdays. Only include the employee name 
    and home phone from the Employees table.
*/
SELECT  Employees.EmployeeName,
        Employees.HomePhone, 
        Employees.PartTime
FROM Employees
WHERE PartTime = 0 AND (WorkDays LIKE '%Wed%' OR WorkDays LIKE '%Sat%')
GO

/* Q10:
    Write an update method that gives a 13% increase in salary to all employees 
    that are not hourly and are full-time 
*/
UPDATE Employees
SET Salary = Salary + (Salary * .13)
WHERE Hourly = 0 AND PartTime = 0
GO
