CREATE DATABASE Music_store;
USE Music_store;

CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

select * from genre;

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

select * from Mediatype;

-- Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT NULL,
    levels VARCHAR(255),
	birthdate VARCHAR(50),
	hire_date VARCHAR(50),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);
SET SQL_SAFE_UPDATES = 0;
UPDATE Employee
SET birthdate = STR_TO_DATE(birthdate, '%d-%m-%Y %H:%i'),
    hire_date = STR_TO_DATE(hire_date, '%d-%m-%Y %H:%i');
SELECT * FROM Employee;
-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);
    
-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

--  Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);


-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date VARCHAR(50),
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
select * from Invoice;
UPDATE Invoice
SET invoice_date= STR_TO_DATE(invoice_date, '%d-%m-%Y %H:%i');
    

-- 8. InLvoiceLine
CREATE TABE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);
-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);


LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/playlist_track.csv'
INTO TABLE  PlaylistTrack
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(playlist_id, track_id
);

select * from Invoiceline;

-- 1. Who is the senior most employee based on job title? 
SELECT * FROM Employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT billing_country, COUNT(*) AS total_invoices
FROM Invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

-- 3. What are the top 3 values of total invoice?
SELECT total
FROM Invoice
ORDER BY total DESC
LIMIT 3;

/* 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
 Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */
SELECT billing_city, SUM(total) AS invoice_total
FROM Invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

/*5. Who is the best customer? - The customer who has spent the most money will be declared the best customer.
 Write a query that returns the person who has spent the most money, customer.last_name */
SELECT c.customer_id, c.first_name, c.last_name, 
SUM(i.total) AS total_spent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

/* 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
 Return your list ordered alphabetically by email starting with A */
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
JOIN Track t ON il.track_id = t.track_id
JOIN Genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

/* 7. Let's invite the artists who have written the most rock music in our dataset. 
 Write a query that returns the Artist name and total track count of the top 10 rock bands */
SELECT a.name AS artist_name, COUNT(t.track_id) AS track_count
FROM Track t
JOIN Album al ON t.album_id = al.album_id
JOIN Artist a ON al.artist_id = a.artist_id
JOIN Genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id
ORDER BY track_count DESC
LIMIT 10;

/* 8. Return all the track names that have a song length longer than the average song length.
 Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first */
SELECT name, milliseconds
FROM Track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM Track
)
ORDER BY milliseconds DESC;

/* 9. Find how much amount is spent by each customer on artists?
  Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
    SELECT a.artist_id, a.name, SUM(il.unit_price * il.quantity) AS total_sales
    FROM InvoiceLine il
    JOIN Track t ON il.track_id = t.track_id
    JOIN Album al ON t.album_id = al.album_id
    JOIN Artist a ON al.artist_id = a.artist_id
    GROUP BY a.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.first_name, c.last_name, bsa.name AS artist_name, 
SUM(il.unit_price * il.quantity) AS amount_spent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
JOIN Track t ON il.track_id = t.track_id
JOIN Album al ON t.album_id = al.album_id
JOIN best_selling_artist bsa ON al.artist_id = bsa.artist_id
GROUP BY c.customer_id, bsa.name
ORDER BY amount_spent DESC;

/*10. We want to find out the most popular music Genre for each country.  
 We determine the most popular genre as the genre with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. 
 For countries where the maximum number of purchases is shared, return all Genres */
WITH GenreCountryPurchases AS (
    SELECT c.country, g.name AS genre_name, COUNT(*) AS purchase_count
    FROM Customer c
    JOIN Invoice i ON c.customer_id = i.customer_id
    JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
    JOIN Track t ON il.track_id = t.track_id
    JOIN Genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
),
MaxGenreByCountry AS (
    SELECT country, MAX(purchase_count) AS max_purchase
    FROM GenreCountryPurchases
    GROUP BY country
)
SELECT gcp.country, gcp.genre_name, gcp.purchase_count
FROM GenreCountryPurchases gcp
JOIN MaxGenreByCountry mg ON gcp.country = mg.country AND gcp.purchase_count = mg.max_purchase
ORDER BY gcp.country;

/* 11. Write a query that determines the customer that has spent the most on music for each country.
 Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount */
WITH CustomerSpending AS (
    SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(i.total) AS total_spent
    FROM Customer c
    JOIN Invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
),
MaxSpending AS (
    SELECT country, MAX(total_spent) AS max_spent
    FROM CustomerSpending
    GROUP BY country
)
SELECT cs.country, cs.first_name, cs.last_name, cs.total_spent
FROM CustomerSpending cs
JOIN MaxSpending ms ON cs.country = ms.country AND cs.total_spent = ms.max_spent
ORDER BY cs.country;






