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
    out avg_b_balance float
)
begin
	select branch.asset
    into b_asset
    from branch
    where branch.branch_name = b_name;
    
    select avg(account.balance)
    into avg_b_balance
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

delimiter ;