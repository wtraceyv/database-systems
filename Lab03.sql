-- CSE 385
-- Lab 03
-- Walter Tracey, traceywd
-- 11 June 2020

/* Q1 (25 points) Write a query that exports an XML document with the following information for ONLY Customers with orders */
--    Customer CustomerID as an attribute
--    Customer Email
--    Customer FirstName
--    Customer LastName
--    Customer Orders
----    OrderID as an attribute
----    Order Date
----    Order Items
------    ProductName as attribute
------    Category CategoryName
------    OrderItems Quantity
------    Product ListPrice
------    OrderItem ItemPrice
------    OrderItem DiscountAmount

/* Note: When you get to the Items on an order you'll need to join 3 tables (OrderItems, Products, and Categories) */

SELECT	[@CustomerID] = CustomerID,
		c.EmailAddress,
		c.FirstName,
		c.LastName,
		[Orders] = (
			SELECT	[@OrderID] = o.OrderID,
					o.OrderDate,
					[Items] = (
						SELECT	[@Product] = p.ProductName,
								cat.CategoryName,
								oi.Quantity, 
								p.ListPrice,
								oi.ItemPrice,
								oi.DiscountAmount
						FROM OrderItems oi, Products p, Categories cat
						WHERE	oi.OrderID = o.OrderID AND -- make order item select apply to this specific order
								p.ProductID = oi.ProductID AND -- finish joining tables ..
								cat.CategoryID = p.CategoryID
						FOR XML PATH('Item'), TYPE
					)
			FROM Orders o
			WHERE o.CustomerID = c.CustomerID -- make order select apply to this specific customer
			FOR XML PATH('Order'), TYPE
		)
FROM Customers c
WHERE c.CustomerID IN (SELECT DISTINCT CustomerID FROM Orders)
FOR XML PATH('Customer'), ROOT('Customers')






-- Q2 (25 points) Write a query that exports a JSON version of the above (there are no attributes in JSON so just have those fields show like the other fields in the query) 
--                ALSO: Make sure you surround your JSON query with an XML SELECT so you can format it:

-- Answer:
SELECT(
	SELECT	CustomerID,
		EmailAddress,
		FirstName,
		LastName,
		[Orders] = (
			SELECT	o.OrderID,
					o.OrderDate,
					[Items] = (
						SELECT	p.ProductName,
								cat.CategoryName,
								oi.Quantity, 
								p.ListPrice,
								oi.ItemPrice,
								oi.DiscountAmount
						FROM OrderItems oi, Products p, Categories cat
						WHERE	oi.OrderID = o.OrderID AND -- make order item select apply to this specific order
								p.ProductID = oi.ProductID AND -- finish joining tables ..
								cat.CategoryID = p.CategoryID
						FOR JSON PATH
					)
			FROM Orders o
			WHERE o.CustomerID = c.CustomerID -- make order select apply to this specific customer
			FOR JSON PATH
		)
	FROM Customers c
	WHERE c.CustomerID IN (SELECT DISTINCT CustomerID FROM Orders)
	FOR JSON PATH, ROOT('Customers')
)
FOR XML PATH('')
