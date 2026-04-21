create schema db_lab7;
use db_lab7;

delimiter //
create procedure getAccountCustomer ()
begin
	select * from account 
    inner join depositor 
    on account.account_number = depositor.account_number
	inner join customer 
    on depositor.customer_name = customer.customer_name
    order by account.account_number;
end//

create procedure getTotalAsset ()
begin
	declare totalAsset float default 0;
    select sum(branch.asset)
    into totalAsset
    from branch;
    
    select totalAsset;
end//

create procedure getAssetAvgBalance (
	in b_name char(9),
    out b_asset float,
    out avg_a_balance float
)
begin
	select branch.asset
    into b_asset
    from branch
    where branch.branch_name = b_name;
    
    select avg(account.balance)
    into avg_a_balance
    from account
    where account.branch_name = b_name;
end//

create procedure checkAccountStatus (
	in a_number int(11),
    out a_status varchar(10)
)
begin
	declare a_balance float default 0;
    declare l_amount float default 0;
    
    select account.balance
    into a_balance
    from account
    where account_number = a_number;
    
    select sum(loan.amount)
    into l_amount
    from loan inner join account on loan.branch_name = account.branch_name
    where account.account_number = a_number;
    
    if a_balance > l_amount then
		set a_status = 'OK';
    elseif a_balance = l_amount then
		set a_status = 'Warning';
    else
		set a_status = 'Critical';
	end if;
end//

CREATE PROCEDURE InsertAccountCustomer(
    IN account_number INT(11),
    IN branch_name VARCHAR(9),
    IN balance FLOAT,
    IN customer_name VARCHAR(9),
    IN customer_street VARCHAR(20),
    IN customer_city VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT CONCAT('Duplicate key (', account_number, ') occurred') AS message;
    END;

  
    INSERT INTO account 
    VALUES (account_number, branch_name, balance);
    INSERT INTO customer 
    VALUES (customer_name, customer_street, customer_city);
  
END //

CREATE FUNCTION  GenAccountNumber (account_number int)
returns int 
DETERMINISTIC
begin
set account_number = account_number + 100;
return account_number ;
end //

create function BranchNameToID (branch_name char(9))
returns varchar(4)
deterministic 
begin 
	declare cod_e varchar(4) ;
	if branch_name = 'SUT' then 
    set  cod_e = '0001' ;
    elseif branch_name = 'Mall' then 
    set  cod_e = '0002' ; 
    END IF 
    ; 
    return cod_e ;
end// 

delimiter ;
#1
call getAccountCustomer();
#2
call getTotalAsset();
#3
call getAssetAvgBalance('Mall', @b_asset, @avg_a_balance);
select @b_asset,@avg_a_balance;
#4
set @a_number = 3;
call checkAccountStatus(@a_number, @a_status);
select @a_number, @a_status;
#5
call InsertAccountCustomer(3,'SUT',300,'Nun','University','Korat');
#6
insert into account value(GenAccountNumber(4),'SUT',3000);
#7
select 
	BranchNameToID(branch_name),
	branch_name ,
	branch_city,
	asset 
from 
	branch 
	order by BranchNameToID(branch_name); 
