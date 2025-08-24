CREATE DATABASE hamburger;

USE hamburger;

--- 1. UserTable 
CREATE TABLE guest (
    id INT AUTO_INCREMENT PRIMARY KEY,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP
)


--- 2. burger Table 
CREATE TABLE burger (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price_single INT NOT NULL,
    price_set INT NOT NULL,
    description TEXT 
) 

--- 3. Side Menu
CREATE TABLE sides (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price INT NOT NULL
)

--- 4. Drink Menu
CREATE TABLE drinks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price INT NOT NULL
)

--- 5. Cart Table 
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    burger_id INT,
    side_id INT,
    drink_id INT,
    is_set BOOLEAN DEFAULT FALSE,
    quantity INT DEFAULT 1,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guest(id),
    FOREIGN KEY (burger_id) REFERENCES burger(id),
    FOREIGN KEY (side_id) REFERENCES sides(id),
    FOREIGN KEY (drink_id) REFERENCES drinks(id)
)

--- 6. Cart Table (Kiosk)
CREATE TABLE `order` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    total_price INT NOT NULL,
    status ENUM('Payment completed', 'Payment incomplete'),
    payment_method ENUM('Card', 'Cash') DEFAULT 'Card',
    receipt_printed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (guest_id) REFERENCES guest(id)
)

--- 7. Order Table
CREATE TABLE order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    burger_id INT,
    side_id INT,
    drink_id INT,
    is_set BOOLEAN DEFAULT FALSE,
    quantity INT DEFAULT 1,
    price INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `order`(id),
    FOREIGN KEY (burger_id) REFERENCES burger(id),
    FOREIGN KEY (side_id) REFERENCES sides(id),
    FOREIGN KEY (drink_id) REFERENCES drinks(id)
)

--- 8. Scenario 

--- 1) Guest Create 
INSERT INTO guest () VALUES ();
INSERT INTO guest () VALUES ();

-- AUTO_INCREMENT id Auto 
SELECT * FROM guest;

--- 2) Menus Sample 

--- hamburger
INSERT INTO burger (name, price_single, price_set, description) VALUES 
('치즈버거', 5000, 8000, '오리지널 치즈버거'),
('불고기 버거', 5500, 8500, '불고기 버거');

--- sides 
INSERT INTO sides (name, price) VALUES 
('감자튀김', 2000),
('치즈스틱', 2800);

-- Drinks
INSERT INTO drinks (name, price) VALUES 
('콜라', 2200),
('제로콜라', 2800),
('사이다', 2500),
('제로 사이다', 2900);




-- Cart 
-- guest_id 1, 치즈버거 단품 + 감자튀김 + 제로콜라 = 5000 + 2000 + 2800 = 9800
INSERT INTO cart (guest_id, burger_id, side_id, drink_id, is_set, quantity) 
VALUES (1, 1, 1, 2, FALSE, 1);

--- guest_id 2, 불고기 버거 세트 + 치즈스틱 + 사이다 = 8500 + 2800 + 2500 x 2 = 27600
INSERT INTO cart (guest_id, burger_id, side_id, drink_id, is_set, quantity) 
VALUES (1, 2, 2, 3, TRUE, 2);

--- guest_id 3, 


SELECT * FROM cart;

--- Total Price(example)
-- SET @total_price = 5000 + 2000 + 2800 + 1500 + 7500  + 2500 + 1500;

SET @total_price_guest1 = 9800; -- 치즈버거 단품 + 감자튀김 + 제로콜라 = 5000 + 2000 + 2800 = 9800
SET @total_price_guest2 = 13800; -- 불고기 버거 세트 + 치즈스틱 + 사이다 = 5000 + 2800 + 2500 = 13800


-- Orders
INSERT INTO `order` (guest_id, total_price, status, payment_method, receipt_printed)
VALUES (1, 9800, 'Payment completed', 'Card', TRUE),
 (2, 13800, 'Payment completed', 'Card', TRUE);

SELECT * FROM `order`;


--- order_id = 1
INSERT INTO order_item(order_id, burger_id, side_id, drink_id, is_set, quantity, price)
VALUES 
(34, 1, 1, 2, FALSE, 1, 5000 + 2000 + 2800),
(35, 2, 2, 3, TRUE, 1, 8500 + 2800 + 2500);
 


SELECT 
    c.id AS cart_id,
    g.id AS guest_id,
    b.name AS burger_name,
    CASE 
        WHEN c.is_set = TRUE THEN b.price_set
        ELSE b.price_single
    END AS burger_price,
    s.name AS side_name,
    d.name AS drink_name,
    c.is_set AS is_set,
    c.quantity AS quantity,
    (CASE 
        WHEN c.is_set = TRUE THEN b.price_set
        ELSE b.price_single
    END + IFNULL((SELECT price FROM sides WHERE id = c.side_id),0) 
      + IFNULL((SELECT price FROM drinks WHERE id = c.drink_id),0)
    ) * c.quantity AS total_price,
    c.added_at AS added_at
FROM cart c
JOIN guest g ON c.guest_id = g.id
LEFT JOIN burger b ON c.burger_id = b.id
LEFT JOIN sides s ON c.side_id = s.id
LEFT JOIN drinks d ON c.drink_id = d.id
ORDER BY c.id;


DELETE FROM order_item;

DELETE FROM `order`;