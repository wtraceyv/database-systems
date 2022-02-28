-- Walter Tracey 
-- CSE 385 XA 
-- HW-02 ch.4

USE AP

-- Q1
SELECT * 
FROM Vendors
	JOIN Invoices ON Vendors.VendorID = Invoices.VendorID

-- Q2
SELECT	Vendors.VendorName,
		Invoices.InvoiceNumber,
		Invoices.InvoiceDate,
		[Balance] = Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal)
FROM Invoices
	LEFT JOIN Vendors ON Invoices.VendorID = Vendors.VendorID
WHERE Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) > 0
ORDER BY VendorName

-- Q3
SELECT	Vendors.VendorName,
		Vendors.DefaultAccountNo,
		GLAccounts.AccountDescription
FROM Vendors
	JOIN GLAccounts ON Vendors.DefaultAccountNo = GLAccounts.AccountNo
ORDER BY AccountDescription, VendorName

-- Q4 
SELECT	Vendors.VendorName,
		Invoices.InvoiceNumber,
		Invoices.InvoiceDate,
		[Balance] = Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal)
FROM Invoices, Vendors
WHERE Invoices.VendorID = Vendors.VendorID AND Invoices.InvoiceTotal - (Invoices.PaymentTotal + Invoices.CreditTotal) > 0
ORDER BY VendorName

-- Q5
SELECT	[Vendor] = v.VendorName,
		[Date] = i.InvoiceDate,
		[Number] = i.InvoiceNumber,
		[#] = li.InvoiceSequence,
		[LineItem] = li.InvoiceLineItemAmount
FROM InvoiceLineItems li
	JOIN Invoices i ON i.InvoiceID = li.InvoiceID
	JOIN Vendors v ON v.VendorID = i.VendorID
ORDER BY Vendor, Date, Number, #


-- Q6
SELECT DISTINCT
		v1.VendorID,
		v1.VendorName,
		[Name] = v1.VendorContactFName + ' ' + v1.VendorContactLName
FROM Vendors v1
	JOIN Vendors v2
		ON	v1.VendorID <> v2.VendorID AND 
			v1.VendorContactFName = v2.VendorContactFName
ORDER BY Name

-- Q7 
SELECT DISTINCT	
		GLAccounts.AccountNo,
		GLAccounts.AccountDescription
FROM GLAccounts
	RIGHT JOIN InvoiceLineItems ON GLAccounts.AccountNo = InvoiceLineItems.AccountNo
ORDER BY GLAccounts.AccountNo

-- Q8 
	SELECT	Vendors.VendorName,
			Vendors.VendorState
	FROM Vendors
	WHERE VendorState = 'CA'

UNION

	SELECT	Vendors.VendorName,
			'Outside CA'
	FROM Vendors
	WHERE VendorState <> 'CA'
	ORDER BY VendorName