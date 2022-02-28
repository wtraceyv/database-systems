-- Walter Tracey 
-- CSE 385 XA
-- HW_03
-- 5 June 2020

USE AP

-- Q1
--SELECT	Invoices.VendorID,
--		[PaymentSum] = SUM(Invoices.PaymentTotal)
--FROM Invoices
--GROUP BY VendorID

-- Q2
--SELECT TOP(10)
--		Vendors.VendorName,
--		[PaymentSum] = SUM(Invoices.PaymentTotal)
--FROM Vendors, Invoices
--WHERE Vendors.VendorID = Invoices.VendorID
--GROUP BY VendorName
--ORDER BY SUM(Invoices.PaymentTotal) DESC

-- Q3
--SELECT	Vendors.VendorName,
--		[InvoiceCount] = COUNT(*),
--		[InvoiceSum] = SUM(Invoices.InvoiceTotal)
--FROM Invoices, Vendors
--WHERE Vendors.VendorID = Invoices.VendorID
--GROUP BY VendorName
--ORDER BY COUNT(*)

-- Q4 
--SELECT	GLAccounts.AccountDescription,
--		[LineItemCount] = COUNT(*),
--		[LineItemSum] = SUM(InvoiceLineItems.InvoiceLineItemAmount)
--FROM GLAccounts, InvoiceLineItems
--WHERE GLAccounts.AccountNo = InvoiceLineItems.AccountNo 
--GROUP BY GLAccounts.AccountDescription
--HAVING COUNT(*) > 1
--ORDER BY COUNT(*) DESC

-- Q5 
--SELECT	GLAccounts.AccountDescription,
--		[LineItemCount] = COUNT(*),
--		[LineItemSum] = SUM(InvoiceLineItems.InvoiceLineItemAmount)
--FROM GLAccounts, InvoiceLineItems, Invoices
--WHERE	GLAccounts.AccountNo = InvoiceLineItems.AccountNo AND 
--		InvoiceLineItems.InvoiceID = Invoices.InvoiceID AND 
--		CONVERT(DATE, Invoices.InvoiceDate) BETWEEN '2015-12-1' AND '2016-02-29'
--GROUP BY GLAccounts.AccountDescription
--HAVING COUNT(*) > 1
--ORDER BY COUNT(*) DESC

-- Q6
--SELECT	Vendors.VendorName,
--		GLAccounts.AccountDescription,
--		[LineItemCount] = COUNT(*),
--		[LineItemSum] = SUM(InvoiceLineItems.InvoiceLineItemAmount)
--FROM Vendors, GLAccounts, InvoiceLineItems, Invoices
--WHERE	Vendors.VendorID = Invoices.VendorID AND
--		Invoices.InvoiceID = InvoiceLineItems.InvoiceID AND 
--		GLAccounts.AccountNo = InvoiceLineItems.AccountNo
--GROUP BY VendorName, AccountDescription
--ORDER BY VendorName, AccountDescription

-- Q7
SELECT DISTINCT	Vendors.VendorName,
				[NumberOfAccounts] = COUNT(*)
FROM Vendors, InvoiceLineItems, Invoices
WHERE	Vendors.VendorID = Invoices.VendorID AND 
		Invoices.InvoiceID = InvoiceLineItems.InvoiceID
GROUP BY VendorName