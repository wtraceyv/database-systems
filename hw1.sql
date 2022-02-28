-- Walter Tracey
-- CSE 385 XA
-- HW_01-Chapter-03
-- 26 May 2020

-- USE correct database 
USE AP
GO

--============== Exercise SELECT queries ===========

-- Q1
SELECT Vendors.VendorContactFName, 
       Vendors.VendorContactLName,
       Vendors.VendorName 
FROM Vendors 
ORDER BY VendorContactLName,
	 VendorContactFName
GO

-- Q2
SELECT Invoices.InvoiceNumber AS Number,
	   Invoices.InvoiceTotal AS Total,
	   Invoices.PaymentTotal + Invoices.CreditTotal AS Credits,
	   Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) AS Balance
FROM Invoices
GO

-- Q3
SELECT Vendors.VendorContactLName + ',' + Vendors.VendorContactFName AS FullName
FROM Vendors
ORDER BY VendorContactLName,
	 VendorContactFName
GO

-- Q4 
SELECT Invoices.InvoiceTotal,
       Invoices.InvoiceTotal * .1 AS '10%',
       Invoices.InvoiceTotal + (Invoices.InvoiceTotal * .1) AS 'Plus 10%'
FROM Invoices
WHERE Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) > 1000
ORDER BY Invoices.InvoiceTotal DESC	
GO

-- Q5
SELECT Invoices.InvoiceNumber AS Number,
	   Invoices.InvoiceTotal AS Total,
	   Invoices.PaymentTotal + Invoices.CreditTotal AS Credits,
	   Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) AS Balance
FROM Invoices
WHERE InvoiceTotal BETWEEN 500 AND 10000
GO

-- Q6 
SELECT Vendors.VendorContactLName + ',' + Vendors.VendorContactFName AS FullName
FROM Vendors
WHERE VendorContactLName LIKE 'A%' OR VendorContactLName LIKE 'B%' OR VendorContactLName LIKE 'C%' OR VendorContactLName LIKE 'E%'
ORDER BY VendorContactLName,
	 VendorContactFName
GO

-- Q7 
SELECT [InvalidPayDates] = Invoices.PaymentDate
FROM Invoices
WHERE NOT (Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) > 0 AND Invoices.PaymentDate IS NULL) 
      AND
      NOT (Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) = 0 AND Invoices.PaymentDate IS NOT NULL)
GO