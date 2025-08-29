SELECT
	*
FROM
	ARTIST;
	
SELECT
	*
FROM
	ALBUM;
	
SELECT
	*
FROM
	TRACK;
	
SELECT
	*
FROM
	PLAYLIST;
	
SELECT
	*
FROM
	PLAYLIST_TRACK;
	
SELECT
	*
FROM
	MEDIA_TYPE;
	
SELECT
	*
FROM
	GENRE;
	
SELECT
	*
FROM
	INVOICE_LINE;
	
SELECT
	*
FROM
	INVOICE;
	
SELECT
	*
FROM
	CUSTOMERS;
	
SELECT
	*
FROM
	EMPLOYEE;
	
	--Q1. Who is the senior most employee based on job title?
SELECT
	*
FROM
	EMPLOYEE
ORDER BY
	LEVELS DESC
LIMIT
	1
	--Q2. Which countries have the most Invoices?
SELECT
	COUNT(INVOICE_ID) AS MOST_INVOICE,
	BILLING_COUNTRY
FROM
	INVOICE
GROUP BY
	BILLING_COUNTRY
ORDER BY
	MOST_INVOICE DESC
LIMIT
	1
	--Q3.  What are top 3 values of total invoice?
SELECT
	*
FROM
	INVOICE
ORDER BY
	TOTAL DESC
LIMIT
	3
	--Q4. Which city has the best customers? 
	--We would like to throw a promotional Music Festival in the city we made the most money. 
	--Write a query that returns one city that has the highest sum of invoice totals. 
	--Return both the city name & sum of all invoice totals
SELECT
	SUM(TOTAL) AS TOTAL,
	BILLING_CITY
FROM
	INVOICE
GROUP BY
	BILLING_CITY
ORDER BY
	TOTAL DESC
LIMIT
	1
	--Q5. Who is the best customer? 
	--The customer who has spent the most money will be declared the best customer.
	--Write a query that returns the person who has spent the most money.
SELECT
	C.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	SUM(I.TOTAL) AS TOTAL
FROM
	INVOICE I
	JOIN CUSTOMERS C ON I.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	C.CUSTOMER_ID
ORDER BY
	TOTAL DESC
LIMIT
	1
	--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
	--Return your list ordered alphabetically by email starting with A 
SELECT
	C.FIRST_NAME,
	C.LAST_NAME,
	C.EMAIL
FROM
	CUSTOMERS C
	JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE IL ON IL.INVOICE_ID = I.INVOICE_ID
WHERE
	TRACK_ID IN (
		SELECT
			TRACK_ID
		FROM
			TRACK T
			JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
		WHERE
			G.NAME = 'Rock'
	)
ORDER BY
	C.EMAIL
	--Q7. Let's invite the artists who have written the most rock music in our dataset.
	--Write a query that returns the Artist name and total track count of the top 10 rock bands
SELECT
	A.ARTIST_ID,
	A.NAME,
	COUNT(TRACK_ID) AS TOTAL
FROM
	ARTIST A
	JOIN ALBUM AB ON A.ARTIST_ID = AB.ARTIST_ID
	JOIN TRACK T ON T.ALBUM_ID = AB.ALBUM_ID
WHERE
	GENRE_ID IN (
		SELECT
			GENRE_ID
		FROM
			GENRE
		WHERE
			NAME LIKE 'Rock'
	)
GROUP BY
	A.ARTIST_ID
ORDER BY
	TOTAL DESC
LIMIT
	10
	--Q8. Return all the track names that have a song length longer than the average song length.
	--Return the Name and Milliseconds for each track. 
	--Order by the song length with the longest songs listed first
SELECT
	NAME,
	MILLISECOUND
FROM
	TRACK
WHERE
	MILLISECOUND > (
		SELECT
			AVG(MILLISECOUND)
		FROM
			TRACK
	)
ORDER BY
	MILLISECOUND DESC
	--Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, 
	--artist name and total spent.
WITH
	BEST_SELLING AS (
		SELECT
			A.ARTIST_ID,
			A.NAME,
			SUM(IL.UNIT_PRICE * IL.QUANTITY) AS TOTAL
		FROM
			INVOICE_LINE IL
			JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
			JOIN ALBUM AB ON T.ALBUM_ID = AB.ALBUM_ID
			JOIN ARTIST A ON A.ARTIST_ID = AB.ARTIST_ID
		GROUP BY
			A.ARTIST_ID
		ORDER BY
			A.ARTIST_ID
	)
SELECT
	C.FIRST_NAME,
	C.CUSTOMER_ID,
	BS.NAME,
	SUM(IL.UNIT_PRICE * IL.QUANTITY) AS TOTAL
FROM
	CUSTOMERS C
	JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
	JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
	JOIN ALBUM AB ON AB.ALBUM_ID = T.ALBUM_ID
	JOIN BEST_SELLING BS ON BS.ARTIST_ID = AB.ARTIST_ID
GROUP BY
	1,
	2,
	3
ORDER BY
	TOTAL DESC
	--Q10. We want to find out the most popular music Genre for each country.
	--We determine the most popular genre as the genre with the highest amount of purchases.
	--Write a query that returns each country along with the top Genre. 
WITH
	POPULAR_GENRE AS (
		SELECT
			COUNT(IL.QUANTITY) AS PURCHASE,
			G.NAME,
			C.COUNTRY,
			ROW_NUMBER() OVER (
				PARTITION BY
					C.COUNTRY
				ORDER BY
					SUM(IL.QUANTITY)
			) AS NUM_PURCHASE
		FROM
			CUSTOMERS C
			JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
			JOIN INVOICE_LINE IL ON IL.INVOICE_ID = I.INVOICE_ID
			JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
			JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
		GROUP BY
			2,
			3
		ORDER BY
			PURCHASE
	)
SELECT
	COUNTRY,
	NAME,
	NUM_PURCHASE
FROM
	POPULAR_GENRE
WHERE
	NUM_PURCHASE = 1
	--Q11. Write a query that determines the customer that has spent the most on music for each country.
	--Write a query that returns the country along with the top customer and how much they spent. 
	--For countries where the top amount spent is shared, provide all customers who spent this amount.
	--For countries where the maximum number of purchases is shared return all Genres.
WITH
	CUSTOMER_WITH_COUNTRY AS (
		SELECT
			C.FIRST_NAME,
			C.CUSTOMER_ID,
			C.LAST_NAME,
			I.BILLING_COUNTRY,
			SUM(TOTAL) AS TOTAL_SPENT,
			ROW_NUMBER() OVER (
				PARTITION BY
					I.BILLING_COUNTRY
				ORDER BY
					SUM(TOTAL) DESC
			) AS ROW_NUM
		FROM
			CUSTOMERS C
			JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
		GROUP BY
			1,
			2,
			3,
			4
	)
SELECT
	BILLING_COUNTRY,
	FIRST_NAME,
	LAST_NAME,
	CUSTOMER_ID,
	TOTAL_SPENT
FROM
	CUSTOMER_WITH_COUNTRY
WHERE
	ROW_NUM = 1
	--Q12. Who are the most popular artists?
SELECT
	COUNT(IL.QUANTITY) PURCHASE,
	A.NAME
FROM
	INVOICE_LINE IL
	JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
	JOIN ALBUM AB ON AB.ALBUM_ID = T.ALBUM_ID
	JOIN ARTIST A ON A.ARTIST_ID = AB.ARTIST_ID
GROUP BY
	A.NAME
ORDER BY
	PURCHASE DESC
	--Q13. Which is the most popular song?
SELECT
	COUNT(IL.QUANTITY) AS PURCHASE,
	T.NAME AS SONG_NAME
FROM
	INVOICE_LINE IL
	JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
GROUP BY
	SONG_NAME
ORDER BY
	PURCHASE DESC
	--Q14. What are the average prices of different types of music?
WITH
	PURCHASE AS (
		SELECT
			G.NAME,
			SUM(TOTAL) AS TOTAL_SPENT
		FROM
			GENRE G
			JOIN TRACK T ON G.GENRE_ID = T.GENRE_ID
			JOIN INVOICE_LINE IL ON IL.TRACK_ID = T.TRACK_ID
			JOIN INVOICE I ON I.INVOICE_ID = IL.INVOICE_ID
		GROUP BY
			G.NAME
		ORDER BY
			TOTAL_SPENT
	)
SELECT
	NAME,
	CONCAT('$', ROUND(AVG(TOTAL_SPENT))) AS TOTAL_SPENT
FROM
	PURCHASE
GROUP BY
	NAME;

--Q15. What are the most popular countries for music purchases?
SELECT
	COUNT(IL.QUANTITY) PURCHASE,
	C.COUNTRY
FROM
	INVOICE_LINE IL
	JOIN INVOICE I ON IL.INVOICE_ID = I.INVOICE_ID
	JOIN CUSTOMERS C ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY
	C.COUNTRY
ORDER BY
	PURCHASE DESC