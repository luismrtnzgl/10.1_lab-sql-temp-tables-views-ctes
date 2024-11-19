-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
USE sakila;

CREATE VIEW view_summary_rental AS
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    c.email, 
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_total_pay AS
SELECT 
    vsr.customer_id, 
    SUM(p.amount) AS total_paid
FROM view_summary_rental vsr
JOIN payment p ON vsr.customer_id = p.customer_id
GROUP BY vsr.customer_id;

SELECT * FROM customer_total_pay;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 
WITH cte_cust_summary_pay AS (
    SELECT 
        vsr.customer_name, 
        vsr.email, 
        vsr.rental_count, 
        ctp.total_paid
    FROM view_summary_rental vsr
    JOIN customer_total_pay ctp ON vsr.customer_id = ctp.customer_id
)
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

SELECT 
    customer_name, 
    email, 
    rental_count, 
    total_paid, 
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM cte_cust_summary_pay
ORDER BY customer_name;


