-- ID: 202310821 | Name: Qusai
-- Database Programming - Homework #1 (2025/2026 Second Semester)

-- =====================================================
-- Q1
-- =====================================================

-- 1) Total number of orders placed by each customer
SELECT c.customer_id, c.name, COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name;

-- 2) Customers who placed more orders than the average number of orders per customer
SELECT c.customer_id, c.name, COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >
  (SELECT COUNT(*) / (SELECT COUNT(*) FROM Customers) FROM Orders);

-- 3) Index on customer_id in Orders
CREATE INDEX idx_orders_customer_id ON Orders(customer_id);

-- 4) Transaction: insert order + items, rollback everything if any step fails
DELIMITER //
CREATE PROCEDURE qusai_place_order()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    INSERT INTO Orders (order_id, customer_id, order_date, total_amount)
    VALUES (821, 1, CURDATE(), 230.00);

    INSERT INTO Order_Items (item_id, order_id, product_name, quantity, price)
    VALUES (8211, 821, 'Headphones', 1, 150.00),
           (8212, 821, 'USB Cable',  2, 40.00);
  COMMIT;
END //
DELIMITER ;

CALL qusai_place_order();

-- 5) ACID properties
-- Atomicity:   a transaction is all-or-nothing; if one step fails, all changes are undone.
-- Consistency: a transaction takes the database from one valid state to another,
--              respecting all constraints and rules.
-- Isolation:   concurrent transactions do not see each other's uncommitted changes.
-- Durability:  once a transaction is committed, its changes survive crashes or power loss.

-- =====================================================
-- Q2) Window functions: cumulative sum of qty
-- =====================================================
SELECT day, qty,
       SUM(qty) OVER (ORDER BY day
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumQty
FROM demand;
