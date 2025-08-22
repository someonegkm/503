-- Schema and sample data for MySQL 8.0+

-- 1) 사용자 정보 테이블 (users)
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id      INT AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(50) NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE,
    password     CHAR(60) NOT NULL,
    gender       ENUM('M','F','O') DEFAULT 'O',
    birth_date   DATE,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login   DATETIME,
    is_active    BOOLEAN DEFAULT TRUE,
    preferences  JSON
) ENGINE=InnoDB;

INSERT INTO users (username, email, password, gender, birth_date, last_login, preferences)
VALUES
('kim123', 'kim@test.com', 'hash_pw1', 'M', '1990-05-21', NOW(), '{"theme":"dark","lang":"ko"}'),
('lee456', 'lee@test.com', 'hash_pw2', 'F', '1988-11-03', NOW(), '{"theme":"light","lang":"en"}'),
('park789', 'park@test.com', 'hash_pw3', 'M', '1995-07-15', NOW(), '{"theme":"dark","lang":"jp"}');

-- 2) 상품 & 주문 테이블 (products, orders)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2) CHECK (price > 0),
    stock_qty    INT DEFAULT 0,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    product_id   INT NOT NULL,
    order_date   DATETIME DEFAULT NOW(),
    quantity     INT NOT NULL CHECK (quantity > 0),
    status       ENUM('PENDING','PAID','SHIPPED','CANCELLED') DEFAULT 'PENDING',
    total_price  DECIMAL(12,2) GENERATED ALWAYS AS (quantity * (SELECT price FROM products WHERE products.product_id = orders.product_id)) STORED,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

INSERT INTO products (product_name, category, price, stock_qty) VALUES
('Americano', 'Coffee', 4500, 100),
('Latte', 'Coffee', 5000, 80),
('Bagel', 'Bakery', 3000, 50),
('Sandwich', 'Bakery', 6000, 30);

INSERT INTO orders (user_id, product_id, quantity, status)
VALUES
(1, 1, 2, 'PAID'),
(2, 2, 1, 'PENDING'),
(3, 3, 5, 'SHIPPED');

-- 3) 로그 테이블 (system_logs)
DROP TABLE IF EXISTS system_logs;
CREATE TABLE system_logs (
    log_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    event_type   ENUM('LOGIN','LOGOUT','PURCHASE','ERROR','API_CALL') NOT NULL,
    event_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address   VARBINARY(16),
    user_agent   VARCHAR(255),
    event_detail JSON,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

INSERT INTO system_logs (user_id, event_type, ip_address, user_agent, event_detail)
VALUES
(1, 'LOGIN', INET6_ATON('192.168.0.101'), 'Chrome/120.0', '{"success":true}'),
(2, 'PURCHASE', INET6_ATON('2001:db8::ff00:42:8329'), 'Firefox/115.0', '{"order_id":2,"amount":5000}'),
(3, 'ERROR', INET6_ATON('172.16.0.55'), 'curl/7.79.1', '{"error":"timeout"}');
