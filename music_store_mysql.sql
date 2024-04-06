# Music Store Data Analysis


/* Q.1  Who is the senior most employee based on job title? */

SELECT title, employee_id, first_name, last_name 
	FROM employee
		ORDER BY levels DESC
        LIMIT 1;

        
/* Q.2  Which contries have the most invoices? */

SELECT billing_country, COUNT(invoice_id) AS invoice_count
	FROM invoice
		GROUP BY billing_country
        ORDER BY invoice_count DESC;


/* Q.3  What are top 3 values of total invoice? */

SELECT ROUND(total,2) AS total_invoice
	FROM invoice
		ORDER BY total DESC
        LIMIT 3;


/* Q.4  Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/ 

SELECT billing_city, SUM(total) AS invoice_total
	FROM invoice
		GROUP BY Billing_city
        ORDER BY invoice_total DESC
        LIMIT 1;


/* Q.5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, c.first_name, c.last_name, ROUND(SUM(i.total),2) AS invoice_total
	FROM customer c
	JOIN invoice i
		ON c.customer_id = i.customer_id
	GROUP BY c.customer_id
    ORDER BY invoice_total DESC
    LIMIT 1;

    
/* Q.6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT(c.email), c.first_name, c.last_name,  g.name
	FROM customer c
		JOIN invoice i 
			ON c.customer_id = i.customer_id
		JOIN invoice_line il
			ON il.invoice_id = i.invoice_id
		JOIN track t
			ON t.track_id = il.track_id
		JOIN genre g
			ON g.genre_id = t.genre_id
	WHERE g.name LIKE "Rock"
	ORDER BY c.email; 


/*Method 2 */

SELECT DISTINCT c.email, c.first_name, c.last_name
	FROM customer c
		JOIN invoice i 
			ON c.customer_id = i.customer_id
		JOIN invoice_line il
			ON i.invoice_id = il.invoice_id
	WHERE il.track_id IN (SELECT t.track_id
							FROM track t
								JOIN genre g
									ON g.genre_id = t.genre_id
							WHERE g.name LIKE 'Rock')
	ORDER BY c.email;


/* Q.7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT a.artist_id, a.name, COUNT(t.track_id) as track_count
	FROM artist a
		JOIN album2 al
			ON a.artist_id = al.artist_id
		JOIN track t
			ON al.album_id= t.album_id
		JOIN genre g
			ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
	GROUP BY a.name
	ORDER BY track_count DESC 
	LIMIT 10;


/* Q.8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds AS song_length
	FROM track
	WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_song_length
							FROM track)
	ORDER BY milliseconds DESC;


/* Q.9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT c.customer_id, c.first_name, c.last_name, i.invoice_id ,a.name AS artist_name, SUM(il.unit_price*il.quantity) as total_spent_on_artist
	FROM customer c
		JOIN invoice i 
			ON c.customer_id = i.customer_id
		JOIN invoice_line il
			ON i.invoice_id = il.invoice_id
		JOIN track t
			ON il.track_id = t.track_id
		JOIN album2 al
			ON t.album_id = al.album_id
		JOIN artist a
			ON al.artist_id = a.artist_id
	GROUP BY c.customer_id, artist_name
	ORDER BY c.customer_id, total_spent_on_artist DESC;


/* Q.10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH best_genre AS 
(
	SELECT g.genre_id, g.name AS genre_name, c.country, COUNT(il.quantity) AS purchases, 
		RANK() OVER (PARTITION BY country ORDER BY COUNT(il.quantity) DESC) AS g_rank
		FROM customer c
			JOIN invoice i
				ON c.customer_id = i.customer_id
			JOIN invoice_line il
				ON i.invoice_id = il.invoice_id
			JOIN track t
				ON il.track_id = t.track_id
			JOIN genre g
				ON t.genre_id = g.genre_id
		GROUP BY c.country, g.name
		ORDER BY country, purchases DESC
)
SELECT * FROM best_genre
WHERE g_rank <=1;

/* Q.11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH top_customers AS
(
	SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(i.total) AS total_spent,
		RANK() OVER (PARTITION BY country ORDER BY SUM(i.total) DESC) AS c_rank
		FROM customer c
			JOIN invoice i
				ON c.customer_id = i.customer_id
		GROUP BY c.customer_id, c.country
		ORDER BY c.country, total_spent DESC
)
SELECT * FROM top_customers 
WHERE c_rank <= 1














