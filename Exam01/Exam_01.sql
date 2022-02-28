/*
	Name:	Walter Tracey (traceywd@miamioh.edu)
	Date:	29 May 2020

*/

USE StahrExam01
GO

----------------------------------------------------------------------------------------------------------------------------
-- Q1: 	Write the code that will insert the following 5 records into the Products table 
--		in one INSERT statement (if you can't write it in one statement then write out the 5 
--		INSERT statements for a minor deduction). For the DateAdded field, use a built-in  
--		function that is the current date.  Make sure the ProductID is inserted as is.

/*
		ProductID	CategoryID	ProductCode		ProductName		Description		ListPrice	DiscountPercent
		12			2			AP_1			Trash Bag		Trash bags		11.42		10.0
		14			2			TR_44			Small Dog		Small dogs		32.0		5.3
		16			1			XY_23			Big Dog			Big dogs		161.0		40.0
		18			1			LL_41			RS232			RS232			27.0		11.5
		20			4			JK_345			System-1		System-1		41.0		7.0

*/
	SET IDENTITY_INSERT Products ON
	INSERT INTO Products (ProductID, CategoryID, ProductCode, ProductName, Description, ListPrice, DiscountPercent, DateAdded) VALUES 
		(12, 2, 'AP_1', 'Trash Bag', 'Trash bags', 11.42, 10.0, GETDATE()), 
		(14, 2, 'TR_44', 'Small Dog', 'Small dogs', 32.0, 5.3, GETDATE()),
		(16, 1, 'XY_23', 'Big Dog', 'Big dogs', 161.0, 40.0, GETDATE()),
		(18, 1, 'LL_41', 'RS232', 'RS232', 27.0, 11.5, GETDATE()),
		(20, 4, 'JK_345', 'System-1', 'System-1', 41.0, 7.0, GETDATE())
	--SELECT * FROM Products where ProductID in (12,14,16,18,20)
	GO
	

----------------------------------------------------------------------------------------------------------------------------
-- Q2:	Write the code that will import the Exam_01_AddressData.txt file into the Addresses table.

	BULK INSERT Addresses
	FROM 'C:\temp\Exam_01_Addresses.txt' -- fix me
	WITH (
		FIRSTROW = 1, 
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n',
		KEEPIDENTITY,
		TABLOCK
	)
	GO
----------------------------------------------------------------------------------------------------------------------------
-- Q3:	(9 rows) Write the query that returns at least the first 7 zip codes from the Addresses  
--		table (zip codes should be in ascending order). Note: if the 8th zip code matches  
--		the 7th zip code then include it. The same goes for the 9th, 10th, etc.

	SELECT TOP(7) WITH TIES Addresses.ZipCode 
	FROM Addresses
	ORDER BY Addresses.ZipCode
GO

----------------------------------------------------------------------------------------------------------------------------
-- Q4:	(28 rows) There are 512 Addresses in the Addresses table – I want a list of all zip codes   
--		from 'OR' and 'OH' ordered by ZipCode. Do not return duplicates though.

	SELECT DISTINCT Addresses.ZipCode 
	FROM Addresses
	WHERE Addresses.State IN ('OR', 'OH')
	ORDER BY Addresses.ZipCode
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q5:	(2 rows) Write a query that returns all orders from Texas that have not shipped.    
--		Return the customer's FirstName, LastName, OrderID, OrderDate, City and ZipCode    
--		of the shipping address. Convert the OrderDate, which is a "datetime" data type,    
--		to a "DATE" datatype and name the field OrderDate.
	
	SELECT	c.FirstName,
			c.LastName,
			o.OrderID,
			[OrderDate] = CONVERT(DATE, o.OrderDate),
			a.City,
			a.ZipCode
	FROM Customers c, Orders o, Addresses a
	WHERE	c.CustomerID = o.CustomerID AND 
			a.CustomerID = c.CustomerID AND 
			a.State LIKE 'TX' AND 
			o.ShipDate IS NULL
			-- one of customers has one order, but different billing addresses
			-- they show up twice so I'm not sure how to get to 2 rows correctly
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q6:	(485 rows) Write the one line code that creates a complete copy of the Customers     
--		table and saves it to a new table called CustomersArchive that has the same     
--		structure as the Customer’s table. Do NOT manually create a table called     
--		CustomersArchive.

	SELECT * 
	INTO CustomersArchive
	FROM Customers
	GO
----------------------------------------------------------------------------------------------------------------------------
-- Q7:	(67 rows) Write the code that deletes customers from the CustomersArchive table      
--		that have a hotmail.com email address.

	DELETE FROM CustomersArchive
	WHERE CustomersArchive.EmailAddress LIKE '%hotmail.com'
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q8:	Write the code that deletes the actual table CustomersArchive from the database.

	DROP TABLE CustomersArchive
	GO
----------------------------------------------------------------------------------------------------------------------------
-- Q9:	(3 rows) Write the code that will tell me the top 3 most popular products sold and       
--		the total number ordered.  Write the query using an implicit JOIN       
--		Return ProductName and [TotalOrdered] (hint: you'll need a COUNT(*) and GROUP BY)

	SELECT	Products.ProductName,
			[TotalOrdered] = COUNT(*)
	FROM	OrderItems, Products
	WHERE Products.ProductID = OrderItems.ProductID
	GROUP BY ProductName
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q10:	(16 rows) Write the code that will return the State and the total count of products sold        
--		in that state.  Sort the list by the total products sold in descending order. Write the 
--		query using an Explicit JOIN.       
--		(hint: again, you’ll need COUNT and GROUP BY)
	
	SELECT	Addresses.State, 
			[CountOfProducts] = COUNT(*)
	FROM Addresses
		JOIN Orders ON Addresses.CustomerID = Orders.CustomerID
		JOIN OrderItems ON Orders.OrderID = OrderItems.OrderID
	GROUP BY Addresses.State
	ORDER BY COUNT(*) DESC
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q11:	(450 rows) Write the query that will return EmailAddress, FirstName, and LastName for all         
--		customers that don't have orders. Write this query using a sub-query.          
--		Order the list by FirstName, LastName

	SELECT	Customers.EmailAddress,
			Customers.FirstName,
			Customers.LastName
	FROM Customers
	WHERE Customers.CustomerID NOT IN (SELECT DISTINCT Orders.CustomerID FROM Orders)
	ORDER BY FirstName, LastName
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q12:	(10 rows) Write the query that returns all columns from the Customer's table that have          
--		ordered products and have a different customer shipping and billing address

	SELECT * 
	FROM Customers
	WHERE Customers.ShippingAddressID <> Customers.BillingAddressID AND CUSTOMERS.CustomerID IN (SELECT DISTINCT ORDERS.CustomerID FROM ORDERS)
	GO


----------------------------------------------------------------------------------------------------------------------------
-- Q13:	(5 rows) Write the query that will return the total orders for each customer that have           
--		ordered more than once. Return the CustomerID, FirstName, LastName, and the count of orders           
--		(same hint as #'s 9 and 10)

	SELECT	Customers.CustomerID,
			Customers.FirstName,
			Customers.LastName,
			[CountOfOrders] = COUNT(*)
	FROM Customers, Orders
	WHERE Customers.CustomerID = Orders.CustomerID
	GROUP BY Customers.CustomerID, FirstName, LastName
	HAVING COUNT(*) > 1
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q14:	(11 rows) Write the query that, if sorted by EmailAddress, will give me the          
--		FirstName, LastName, and EmailAddress for the 350'th to 360'th customer          
--		(note: the 0'th customer is the first customer in the table)

	SELECT	Customers.FirstName,
			Customers.LastName,
			Customers.EmailAddress
	FROM Customers
	ORDER BY Customers.EmailAddress
		OFFSET 349 ROWS
			FETCH NEXT 11 ROWS ONLY
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q15:	(4 rows) Write the query that returns OrderID, CustomerID, OrderDate, and ShipDate           
--		for all orders from, and including, '4-21-16' to '5/1/2016'.  Note, because           
--		OrderDate includes a timestamp you need to convert it to just a DATE.           
--		Also, if the ShipDate is null display it as '1/1/1900'

	SELECT	o.OrderID,
			o.CustomerID,
			[OrderDate] = CONVERT(DATE, o.OrderDate),
			[ShipDate] = ISNULL(o.ShipDate, '1/1/1900')
	FROM Orders o
	WHERE OrderDate BETWEEN '4-21-16' AND '5/1/2016'
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q16:	(47 rowS) Delete all data from the OrderItems table in such a way that it can be undone…           
--		Then undo the delete.

	BEGIN TRAN
	DELETE FROM OrderItems WHERE (1 > 0) -- some trivially true expression..
	ROLLBACK TRAN
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q17: (5 rowS) Using an OUTER JOIN, write a query that returns all products never used on an order.
	--NOT IN (SELECT DISTINCT OrderItems.ProductID FROM OrderItems)

	SELECT * 
	FROM Products
		LEFT JOIN OrderItems ON Products.ProductID = OrderItems.ProductID
	WHERE Products.ProductID NOT IN (SELECT DISTINCT OrderItems.ProductID FROM OrderItems)
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q18: (10 rows) Write the query that will return the ProductName from the Products table as well
--		as the total sales for each product. Total sales is calculated by taking the following formula:
--		(ItemPrice * Quantity) - DiscountAmount. You will need to sum all of these records for each product
--		Return the ProductName and a column for the total sales called TotalSales. (hint: group by ProductName)
	
	SELECT	Products.ProductName,
			[TotalSales] = SUM((ItemPrice * Quantity) - DiscountAmount)
	FROM Products, OrderItems
	WHERE Products.ProductID = OrderItems.ProductID
	GROUP BY ProductName
	GO

----------------------------------------------------------------------------------------------------------------------------
-- Q19:	(1 row) Write the query that returns the CustomerID and the number of orders. Only return the customer 
--		with the most orders (hint: you only need 1 table to do this and it's not the Customer's table)
	
	SELECT TOP(1)	Orders.CustomerID,
					[NumberOfOrders] = COUNT(*)
	FROM Orders
	GROUP BY Orders.CustomerID
	ORDER BY COUNT(*) DESC
	GO


----------------------------------------------------------------------------------------------------------------------------
-- Q20: (2 rows) Write a query that will return the products sold as long as there were over 10 sold. 
--		Only return the ProductID.  You will need to take into consideration the Quantity sold. 
--		(hint: only the OrderItems table is needed and you'll need to use the SUM() method) 
	
	SELECT OrderItems.ProductID
	FROM OrderItems
	GROUP BY OrderItems.ProductID
	HAVING SUM(OrderItems.Quantity) > 10
	GO