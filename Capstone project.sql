--Q1(a) Which product categories drive the biggest profits?
WITH
  total_profit
  AS
  (
    SELECT
      p.product_category,
      SUM((p.product_price - p.product_cost) * s.units) AS total_profit
    FROM products AS p
      LEFT JOIN
      sales AS s
      ON p.product_id = s.product_id
    GROUP BY
p.product_category
  )

SELECT
  *
FROM total_profit
WHERE
	total_profit = (SELECT
  MAX(total_profit)
FROM total_profit)
--Toys are the product categories that drive the biggest profit

--Q1(b) Is this the same across store_locations
SELECT
	st.store_location,	 
	SUM((p.product_price - p.product_cost) * s.units) AS total_profit,
	p.product_category
FROM products AS p
LEFT JOIN
	sales AS s
ON p.product_id = s.product_id
LEFT JOIN
	stores AS st
ON s.store_id = st.store_id
GROUP BY
	st.store_location,
	p.product_category
ORDER BY
	store_location DESC,
	total_profit DESC;
-- Toys categories dont drive the biggest profits in all locations. It did not drive the biggest profit in Commercial and Airport.

-- Q2(a) How much money is tied up in the inventory at the toy stores?
WITH
  money_store
  AS
  (
    SELECT
      p.product_id,
      p.product_category,
      p.product_name,
      i.stock_on_hand,
	  (p.product_price * s.units) AS sales_rate,
      (p.product_cost * i.stock_on_hand) AS inventory
    FROM
      products AS p
      LEFT JOIN
      sales AS s
      ON s.product_id = p.product_id
	  LEFT JOIN
	  inventory AS i
	  ON i.product_id = s.product_id
	 WHERE
	  product_category = 'Toys'
  )
SELECT
  SUM(inventory) AS total_inventory
FROM money_store

--Q2(b) How long would it last?
WITH
  money_store
  AS
  (
    SELECT
      p.product_id,
	  s.date,
      p.product_category,
      p.product_name,
      i.stock_on_hand,
	  (p.product_price * s.units) AS sales_rate,
      (p.product_cost * i.stock_on_hand) AS inventory
    FROM
      products AS p
      LEFT JOIN
      sales AS s
      ON s.product_id = p.product_id
	  LEFT JOIN
	  inventory AS i
	  ON i.product_id = s.product_id
	 WHERE
	  product_category = 'Toys'
  )
SELECT
  (SUM(sales_rate)/SUM(inventory)*(MAX(date) - MIN(date))) AS duration_of_time
FROM money_store
-- It would last for 43.5 days.

--Q3
SELECT
  s.product_id,
  st.store_location,
  SUM(s.units) AS sales_quantity,
  SUM(i.stock_on_hand) AS total_inventory
FROM sales AS s
  INNER JOIN
  stores AS st
  ON st.store_id = s.store_id
  INNER JOIN
  inventory AS i
  ON i.store_id = st.store_id
GROUP BY
	s.product_id,
	st.store_location
HAVING
	SUM(s.units) > SUM(i.stock_on_hand)
-- There is no location where the sales units is more than stock on hand. Therefore, no sales is being lost with out of products