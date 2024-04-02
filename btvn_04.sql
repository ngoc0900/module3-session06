create database btvn_04_ss5;
use btvn_04_ss5;
create table users(
id int primary key auto_increment,
name_ varchar(100) not null unique ,
phone varchar(100) not null,
adrress  varchar(100) not null,
dateOfBirth  date,
status_ bit(1) default 1
);

create table transfer(
sender_id int not null,
foreign key(sender_id) references users(id),
receiver_id int not null,
foreign key(sender_id) references users(id),
money decimal
);

START TRANSACTION;

-- Lấy số dư của người gửi

SELECT money INTO @sender_money FROM users WHERE id = sender_id;

-- Kiểm tra xem có đủ tiền để gửi không
IF @sender_money >= money THEN
    -- Trừ tiền từ người gửi
    UPDATE users SET money = money - money WHERE id = sender_id;

    -- Cộng tiền vào tài khoản của người nhận
    UPDATE users SET money = money + money WHERE id = receiver_id;

    -- Thêm giao dịch vào bảng transfer
    INSERT INTO transfer (sender_id, receiver_id, money) VALUES (sender_id, receiver_id, money);

    COMMIT;
ELSE
    -- Nếu không đủ tiền, rollback giao dịch
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tiền không đủ trong tài khoản người gửi';
END IF;

SET autocommit = 0;

