/*
 * Question 1-9
 * 1. Result-set is a set of rows queried from the database by SELECT statement.
 * 2. UNION ALL returns and combines all the rows queried by two or more SELECT statements in the table, but UNION only returns distinct valuses.
 * 3. INTERSECT and EXCEPT.
 * 4. UNION is used to combine two or more result-sets, but JOIN is used to combines the rows in two or more tables.
 * 5. INNER JOIN only returns rows that have matching values in both left and right table; FULL JOIN returns all rows in left and right table.
 * 6. LEFT JOIN returns all the rows in the left table and matched rows in the right table, even there is no matached row in the right table will return NULL; OUTER JOIN returns all the rows in left and right table when there is at least one matched row in left or right table.
 * 7. CROSS JOIN returns and combines each row in the left table with each row in the right table.
 * 8. WHERE is used to filter individual rows and executed before aggregation; HAVING is applied to group rows as a whole and executed after aggregation.
 * 9. Yes.
 */

--Scenarios 1-29
--1.
SELECT COUNT(*)
FROM Production.Product

--2.
SELECT COUNT(ProductSubcategoryID)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

--3.
SELECT ProductSubcategoryID, COUNT(ProductSubcategoryID) AS CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID
HAVING ProductSubcategoryID IS NOT NULL

--4.
SELECT COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

--5.
SELECT SUM(Quantity)
FROM Production.ProductInventory

--6.
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40 AND Quantity <= 100
GROUP BY ProductID

--7.
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40 AND Quantity <= 100
GROUP BY Shelf, ProductID

--8.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10

--9.
SELECT ProductID, Shelf, AVG(Quantity)
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

--10.
SELECT ProductID, Shelf, AVG(Quantity)
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY ProductID, Shelf

--11.
SELECT Color, Class, COUNT(ListPrice) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12.
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
INNER JOIN person.StateProvince s
ON c.CountryRegionCode = s.StateProvinceCode

--13.
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
INNER JOIN person.StateProvince s
ON c.CountryRegionCode = s.StateProvinceCode
WHERE c.Name IN ('Germany', 'Canada')

--14.
SELECT DISTINCT p.ProductID
FROM Products p
INNER JOIN( 
	SELECT od.ProductID 
	FROM [Order Details] od INNER JOIN Orders o
	ON od.OrderID = o.OrderID
	WHERE Year(getDate()) - Year(OrderDate) <= 25
	) od2
ON p.ProductID = od2.ProductID
ORDER BY p.ProductID

--15.
SELECT TOP 5 ShipPostalCode
FROM Orders
GROUP BY ShipPostalCode
ORDER BY COUNT(ShipPostalCode) DESC

--16.
SELECT TOP 5 ShipPostalCode
FROM Orders
WHERE Year(getDate()) - Year(OrderDate) <= 25
GROUP BY ShipPostalCode
ORDER BY COUNT(ShipPostalCode) DESC

--17.
SELECT City, COUNT(CustomerID)
FROM Customers
GROUP BY City

--18.
SELECT City, COUNT(CustomerID)
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

--19.
SELECT DISTINCT c.ContactName
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '1/1/1998'

--20.
SELECT c.ContactName, MAX(o.OrderDate)
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName

--21.
SELECT c.ContactName, SUM(t.Quantity) AS TotalBought
FROM Customers c
INNER JOIN (
	SELECT od.Quantity, o.CustomerID
	FROM Orders o
	INNER JOIN [Order Details] od
	ON o.OrderID = od.OrderID
	) t
ON c.CustomerID = t.CustomerID
GROUP BY c.ContactName

--22.
SELECT o.CustomerID
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.Quantity) > 100

--23.
SELECT sp.CompanyName AS [Supplier Company Name], sh.CompanyName AS [Shipping Company Name]
FROM Suppliers sp
CROSS JOIN Shippers sh

--24.
SELECT o.OrderDate, p.ProductName
FROM Orders o 
JOIN [Order Details] od 
ON o.OrderID = od.OrderID 
JOIN Products p 
ON p.ProductID = od.ProductID


--25.
SELECT e1.EmployeeID, e2.EmployeeID
FROM Employees e1
INNER JOIN Employees e2
ON e1.Title = e2.Title
WHERE e1.EmployeeID != e2.EmployeeID
ORDER BY e1.EmployeeID, e2.EmployeeID

--26.
SELECT e1.EmployeeID
FROM Employees e1
INNER JOIN (
	SELECT e3.ReportsTo, e3.EmployeeID
	FROM Employees e2
	INNER JOIN Employees e3
	ON e2.EmployeeID = e3.ReportsTo
	) e4
ON e1.EmployeeID = e4.ReportsTo
GROUP BY e1.EmployeeID
HAVING COUNT(e4.EmployeeID) > 2

--27.
SELECT City, CompanyName, ContactName, 'Customer' AS TYPE FROM Customers
UNION
SELECT City, CompanyName, ContactName, 'Supplier' AS TYPE FROM Suppliers

--28.
SELECT *
FROM F1
INNER JOIN F2
ON F1.T1 = F2.T2
/* Result
 *   T1   T2
 * -----------
 *   2    2
 *   3    3
 */

--29.
SELECT *
FROM F1
LEFT JOIN F2
ON F1.T1 = F2.T2
/* Result
 *   T1   T2
 * -----------
 *   1   NULL
 *   2    2
 *   3    3
 */
