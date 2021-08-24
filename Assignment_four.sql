/*Questions
 *1. A view is a virtual table based on the result-set. It can simplify multiple table into a single virrual table; It enable users to create a backward compatible interface for schema changes;
 *   It can act as aggregated tables; It can hide the complextity of data.
 *2. Yes£¬but can only modify the data directly without any aggregation.
 *3. The benedits of using stored procedure are: increases database security, provides faster execution, helps centralize Transact-SQL code in the data tire;
 *   helps reduse network traffic for large queries and provides code reusability.
 *4. View doesn't accept parameters, can only contain one select query; Stored procedure accepts parameters, can contain several statements.
 *5. Store Procedure is used to manipulate the date, but functions aim at doing some calculations.
 *6. Yes.
 *7. Yes. Because stored procedure can return value which can be in the conditions in select stamement
 *8. Triggers are a special type of stored procedure that get executed (fired) when a specific event happens.
 *9. Create the trigger by name and on it's triggered event, then with the executions in the trigger.
 *10. A stored procedure is a user defined piece of code written in the local version of PL/SQL, which may return a value (making it a function) that is invoked by calling it explicitly.
 *    A trigger is a stored procedure that runs automatically when various events happen (eg update, insert, delete).
 */

--Senarios
--1.
begin tran
select * from Region with(tablockx)
select * from Territories with(tablockx)
select * from EmployeeTerritories with(tablockx)
select * from Employees with(tablockx)
insert into Region(RegionID, RegionDescription) values (5, 'Middle Earth')
insert into Territories(TerritoryID, TerritoryDescription, RegionID) values (98105, 'Gondor', 5)
insert into Employees(LastName,FirstName,Region) values ('King','Aragorn',5)
insert into EmployeeTerritories(EmployeeID,TerritoryID) values (10,98426)
rollback tran

--2.
begin tran
update Territories set TerritoryDescription = 'Arnor'  where TerritoryDescription = 'Gondor'

--3.
begin tran
delete from Territories where RegionID = 5
delete from Region where RegionDescription='Middle Earth'


--4.
create view view_product_order_Lu
as
select p.ProductName, sum(od.Quantity) from Products p JOIN [Order Details] od on p.ProductID = od.ProductID
group by p.ProductName

--5.
create proc sp_product_order_quantity_Lu (@p_id int, @qty float out)
as
begin
select @qty = sum(o.OrderID) from Orders o JOIN [Order Details] od on o.OrderID = od.OrderID
where od.ProductID = @p_id
group by od.ProductID
print @qty
end

--6.
create proc sp_product_order_city_Lu (@p_name varchar(50), @topcity varchar(50) out)
as
begin
select @p_name=dt1.productname from (select top 5 d.ProductID, d.ProductName from 
	(select p.ProductID,p.ProductName,sum(od.quantity) t from Products p inner join [Order Details] od on p.ProductID = od.ProductID
	 group by p.ProductID, p.ProductName) as [d] Order by d.t desc
	) dt1 left join (select * from 
		(select dt2.productid, dt2.city, rank() over(partition by productid order by q desc) rk from 
			(select p.ProductID, c.city, sum(od.quantity) q from Customers c inner join orders o on c.CustomerID = o.CustomerID 
			 left join [Order Details] od on o.OrderID=od.OrderID 
			 left join Products p on od.ProductID=p.ProductID
			 group by p.ProductID, c.City
			) dt2 
		) dt3 where dt3.rk = 1
	) dt4
on dt1.productid = dt4.productid
where dt4.city = @topcity
end

--7.
create proc sp_move_employees_Lu @terroity_name char(50) = 'tory'
as
if exists(select e.EmployeeID, count(t.TerritoryDescription) c from Territories t
join EmployeeTerritories et on t.TerritoryID = et.TerritoryID
join Employees e on et.EmployeeID = e.EmployeeID
where TerritoryDescription=@terroity_name and count(t.TerritoryDescription) > 0)

begin
insert into Territories(TerritoryID,TerritoryDescription,RegionID) values (98432,'Stevens Point',11)
insert into Region(RegionID,RegionDescription) values(11,'North')
end

--8.
create trigger trg_ins_Lu on Territories
for update 
as
if exists(select e.EmployeeID, count(t.TerritoryDescription) from Territories t
join EmployeeTerritories et on t.TerritoryID = et.TerritoryID
join Employees e on et.EmployeeID = e.EmployeeID
where t.TerritoryDescription= 'stevens point'
group by e.EmployeeID
having count(t.TerritoryDescription) > 100)

begin
update Territories set TerritoryDescription= 'Tory'
where TerritoryDescription = 'stevens point'
End

drop trigger trg_ins_Lu

--9.
create table people_Lu(id int, name char(20), cityid int)
create table city_Lu(cityid int, city char(20))
insert into people_Lu(id, name, cityid) values(1, 'Aaron Rodgers', 2)
insert into people_Lu(id, name, cityid) values(2, 'Russell Wilson', 1)
insert into people_Lu(id, name, cityid) values(3, 'Jody Nelson', 2)
insert into city_Lu(cityid, city) values(1, 'Settle')
insert into city_Lu(cityid, city) values(2,'Green Bay')

create view Packers_tingting_Lu
as
select * from people_Lu p inner join city_Lu c on p.cityid = c.cityid where c.city = 'Green bay'

begin tran
rollback
drop table people_Lu
drop table city_Lu
drop view Packers_tingting_Lu

--10.
create proc sp_birthday_employees_Lu 
as
begin
select employeeid, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Photo 
into birthday_employees_Lu from Employees
where month(BirthDate) = 2
end

drop table birthday_employees_Lu

--11.
create proc sp_Lu_1
as
select c.city, count(c.CustomerID) from Customers c inner join 
	(select dt.CustomerID, count(dt.CustomerID) xx from 
		(select distinct c.CustomerID, p.ProductID from Products p
		 inner join [Order Details] od on p.ProductID=od.ProductID
		 inner join Orders o on od.OrderID=o.OrderID
		 inner join Customers c on o.CustomerID=c.CustomerID) dt
		 group by dt.CustomerID
		 having count(dt.CustomerID) < 2
	) dt2
on c.CustomerID = dt2.CustomerID
group by city
having count(c.CustomerID) > 1

--12.
select count(*) from ( select * from [t1_old] union select* from [t1_new] ) as dt1;
insert into [dbo].[t1_new]([id],[log_time]) values(1, ''), (3, ''), (4, '')
insert into [dbo].[t1_old]([id],[log_time]) values(1, ''), (2, ''), (3, '')
select * from [dbo].[t1_new]
select * from [dbo].[t1_old]
select count(*) from (select * from [t1_new] union select * from [t1_old]) as dt2;

--14.
declare @fullname varchar(20)
select @fullname = FirstName + ' ' + LastName + ' ' + MiddleName+'.' from People
print @fullname

--15.
declare @m_student varchar(20)
declare @m_marks int
set @m_marks = (select max(Marks) from Class where Sex='F')
set @m_student = (select Student from Class where Marks = @m_marks and Sex='F')
print @m_student