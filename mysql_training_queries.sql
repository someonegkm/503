-- 다양한 MySQL 8.0 쿼리 연습 예제

-- 1) 사용자 테이블 관련 쿼리 -----------------------------

-- 전체 사용자 조회
SELECT * FROM users;

-- 특정 조건 (여성 사용자만)
SELECT username, email FROM users WHERE gender = 'F';

-- JSON 필드에서 테마 값 추출
SELECT username, JSON_UNQUOTE(JSON_EXTRACT(preferences, '$.theme')) AS theme
FROM users;

-- 로그인 기록이 없는 사용자 찾기
SELECT username FROM users WHERE last_login IS NULL;

-- 2) 상품/주문 테이블 관련 쿼리 -----------------------------

-- 전체 상품 조회
SELECT * FROM products;

-- 가격이 4000원 이상인 상품
SELECT product_name, price FROM products WHERE price >= 4000;

-- 상품 카테고리별 평균 가격
SELECT category, AVG(price) AS avg_price FROM products GROUP BY category;

-- 주문 내역과 사용자 이름 조인
SELECT o.order_id, u.username, p.product_name, o.quantity, o.status, o.total_price
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN products p ON o.product_id = p.product_id;

-- 주문 상태별 개수
SELECT status, COUNT(*) AS order_count FROM orders GROUP BY status;

-- 윈도우 함수: 사용자별 주문 금액 순위
SELECT u.username, o.order_id, o.total_price,
       RANK() OVER (PARTITION BY u.user_id ORDER BY o.total_price DESC) AS rank_within_user
FROM orders o
JOIN users u ON o.user_id = u.user_id;

-- 3) 로그 테이블 관련 쿼리 -----------------------------

-- 최근 로그인 기록 5개
SELECT * FROM system_logs WHERE event_type = 'LOGIN' ORDER BY event_time DESC LIMIT 5;

-- 에러 발생 로그 확인
SELECT user_id, event_time, event_detail FROM system_logs WHERE event_type = 'ERROR';

-- IP 주소를 문자열로 변환하여 출력
SELECT log_id, INET6_NTOA(ip_address) AS ip, event_type, event_time
FROM system_logs;

-- 이벤트별 발생 횟수
SELECT event_type, COUNT(*) AS cnt FROM system_logs GROUP BY event_type;

-- 사용자별 API_CALL 이벤트 수
SELECT u.username, COUNT(*) AS api_calls
FROM system_logs l
JOIN users u ON l.user_id = u.user_id
WHERE l.event_type = 'API_CALL'
GROUP BY u.username;

-- 4) 혼합/심화 쿼리 -----------------------------

-- 특정 사용자(예: kim123)의 총 주문 금액
SELECT u.username, SUM(o.total_price) AS total_spent
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE u.username = 'kim123'
GROUP BY u.username;

-- 가장 많이 주문된 상품 TOP 3
SELECT p.product_name, SUM(o.quantity) AS total_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 3;

-- 사용자별 최근 로그인 시간과 주문 횟수
SELECT u.username,
       MAX(l.event_time) AS last_login,
       COUNT(o.order_id) AS order_count
FROM users u
LEFT JOIN system_logs l ON u.user_id = l.user_id AND l.event_type = 'LOGIN'
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.username;

