--select * from album;
--select * from album2;
--select * from artist;
--select * from customer;
--select * from employee;
--select * from genre;
--select * from invoice;
--select * from invoice_line;
--select * from media_type;
--select * from playlist;
--select * from playlist_track;
--select * from track;

--EASY LEVEL
--1. Who is the senior most employee based on job title?
select * from employee
order by levels desc

--2. Which countries have the most Invoices?
select count(*) as country_count, billing_country from invoice
group by billing_country
order by country_count desc
--limit 1;

--3. What are top 3 values of total invoice?
select total from invoice
order by total desc
--limit 3


--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals

select sum(total) as total_invoice_by_city, billing_city from invoice
group by billing_city
order by total_invoice_by_city desc


--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money
select * from customer

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total from customer as c
JOIN invoice as i ON c.customer_id = i.customer_id 
group by c.customer_id
order by total desc
--limit 1;


--INTERMEDIATE
--1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
--Return your list ordered alphabetically by email starting with A
select DISTINCT c.email, c.first_name, c.last_name from customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
where track_id in 
(	Select track_id from track
	JOIN genre g ON g.genre_id = track.genre_id
	where g.name Like 'Rock'
)
order by c.email


select * from genre
select * from track
select * from artist

--2. Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands
select ar.artist_id, ar.name, count(ar.artist_id) as number_of_songs from track t
JOIN album a ON a.album_id = t.album_id
JOIN artist ar ON ar.artist_id = a.artist_id
JOIN genre g ON g.genre_id = t.genre_id
where g.name LIKE 'Rock'
group by ar.artist_id
order by number_of_songs desc;

--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select track_id, name, milliseconds from track
where milliseconds > 
	(Select avg(milliseconds) as avg_length from track)
order by milliseconds desc;

--ADVANCE
--1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
--select * from invoice_line
--select * from customer
--select * from artist
--select * from invoice

WITH total_amount AS 
(		select ar.artist_id, ar.name as artist_name, sum(il.unit_price*il.quantity) as total_sales_amount  
		from invoice_line il
		join track t ON t.track_id = il.track_id
		join album a ON a.album_id = t.album_id
		join artist ar ON ar.artist_id = a.artist_id
		group by 1
		order by 3 desc
		limit 1
)
select c.customer_id, c.first_name, c.last_name, ta.artist_name, sum(il.unit_price*il.quantity) as total_sales_amount 
from invoice i
join customer c ON c.customer_id = i.customer_id
join invoice_line il ON il.invoice_id = i.invoice_id
join track t ON t.track_id = il.track_id
join album a ON a.album_id = t.album_id
join total_amount ta ON ta.artist_id = a.album_id
group by 1,2,3,4
order by 5 desc;

--2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--3. Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1








