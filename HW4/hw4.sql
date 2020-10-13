SELECT o.orderNumber, d.priceEach, d.quantityOrdered, p.productName, c.city, c.country, o.orderDate
FROM orders o
INNER JOIN customers c
   USING(customerNumber)
INNER JOIN orderDetails d
	USING (orderNumber)
INNER JOIN products p 
	USING (productCode);