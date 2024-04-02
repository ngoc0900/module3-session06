create database btvn_03_ss5;
use btvn_03_ss5;
create table users(
id int primary key auto_increment,
name_ varchar(100) not null unique ,
phone varchar(100) not null,
adrress  varchar(100) not null,
dateOfBirth  date,
status_ bit(1) default 1
);

create table products(
id int primary key auto_increment,
name_ varchar(100) not null unique ,
price int,
stock int,
status_ bit(1) default 1
);


create table shopping_cart (
id int primary key auto_increment,
user_id int not null,
foreign key(user_id) references users(id),
product_id int not null,
foreign key(product_id) references products(id),
quantity int ,
amount int
);

insert into users(name_,phone,adrress,dateOfBirth) values
('ngoc','01234','hp','2000-11-09'),
('mai','045325','hp','2000-12-23'),
('lan','090606','hp','2000-10-12'),
('hung','05324','hp','2000-06-04');
insert into products(name_,price,stock) values
('ao',100,3),
('quan',500,5),
('mu',200,2),
('giay',300,3);
insert into shopping_cart(user_id,product_id,quantity,amount) values
(1,1,1,0),
(1,2,1,0),
(2,2,1,0),
(2,3,1,0),
(3,3,1,0),
(3,1,2,0);

select * from users;
select * from products;
select * from shopping_cart;

DELIMITER $$
	create trigger tg_insert_products_update_shopping_cart
    after update on products
     for each row
		begin
			update shopping_cart SET amount = quantity * new.price where product_id = NEW.id;
        end
$$
DELIMITER ;
drop trigger tg_insert_products_update_shopping_cart;

update products set price = 600 where id = 1;
update products set price = 300 where id = 2;
update products set price = 400 where id = 3;
update products set price = 500 where id = 4;

DELIMITER $$
create trigger change_price
before insert on shopping_cart
for each row
begin
	DECLARE new_price int;
    set new_price = (select price from products where id = new.product_id);
    set new.amount = new_price * new.quantity;
end
$$ DELIMITER ;

insert into shopping_cart(user_id,product_id,quantity,amount) values
(1,4,10,0);
update products set price = 100 where id = 4;

DELIMITER $$
create trigger delete_product
after delete on products
for each row
begin
	 DELETE from shopping_cart where product_id = OLD.id;
end
$$ DELIMITER ;
 
  -- xóa bảng shopping_cart mà có product_id tương ứng với id muốn xóa từ bảng products.
DELETE from shopping_cart where product_id = 1; 
DELETE from products where id = 1; 


DELIMITER $$
create trigger insert_shopping_cart_update_products
after insert on shopping_cart
for each row
begin
	DECLARE new_stock int;
    set new_stock = (select stock from products where id = new.product_id);
    if (new_stock >= NEW.quantity) then
		update products set stock = stock - NEW.quantity where id = new.product_id;
    else
		SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'lỗi vì số lượng không đủ';
    end if;
end
$$ DELIMITER ;

insert into shopping_cart(user_id,product_id,quantity) values
(3,2,2);

select * from shopping_cart;
-- lỗi vì bị lồng e cái trigger
       