-- =========================
-- chinook data analysis
-- =========================
-- Data quality checks and database exploration
-- were completed in 01_data_quality_check.sql
-- before starting this analysis.

-- =========================================
-- 1. Overall Revenue and Sales Performance
-- =========================================

-- Total Revenue

select round(sum(Total), 2) as total_revenue
from Invoice;

-- Finding:
-- The store generated a total revenue of $2,328.60 from all recorded invoices.

-- Total invoices 

select count(*) as total_invoices 
from Invoice;

-- Finding : 
-- A total of 412 invoices were recorded.

-- Total Tracks sold

select sum(Quantity) as total_tracks_sold
from InvoiceLine;

-- Finding :
-- A total of 2240 tracks were sold.

-- Average Invoice Value

select round(avg(Total), 2) as average_invoice_value
from Invoice;

-- Finding:
-- The average value of an invoice is $5.65.

-- ============================
-- 2. Revenue change over time
-- ============================

-- How did revenue change over the years?

select year(InvoiceDate) as invoice_year, round(sum(Total),2) as total_revenue
from Invoice 
group by year(InvoiceDate)
order by invoice_year desc;

-- Finding:
-- Revenue fluctuated slightly from year to year.
-- The highest annual revenue was generated in 2022 ($481.45),
-- while the lowest was recorded in 2021 ($449.46).

-- How did revenue change over the months

select date_format(InvoiceDate, '%Y-%m') as invoice_year_month,
round(sum(Total),2) as total_revenue
from Invoice
group by date_format(InvoiceDate, '%Y-%m')
order by invoice_year_month;

with monthly_sales as (
select date_format(InvoiceDate, '%Y-%m') as invoice_year_month, round(sum(Total),2) as monthly_revenue
from Invoice
group by date_format(InvoiceDate, '%Y-%m')
)

select round(avg(monthly_revenue),2) as avg_monthly_revenue
from monthly_sales;

-- Finding:
-- Monthly revenue was mostly stable, with most months generating around $38.81. 
-- Some months had higher revenue, especially January 2022, April 2023, and June 2023. 
-- The lowest revenue was recorded in November 2023.
-- Overall, revenue changed slightly from month to month, but there was no clear seasonal pattern.

-- =====================================
-- 3. countries generating the most revenue
-- =====================================

-- Revenue by country 

select BillingCountry, round(sum(Total),2) as total_revenue
from Invoice
group by BillingCountry
order by total_revenue desc;

-- Finding:
-- Revenue was different across countries.
-- The USA generated the highest revenue ($523.06), followed by Canada ($303.96),
-- France ($195.10), and Brazil ($190.10).
-- Most countries generated lower revenue compared to the top countries.
-- This shows that sales are mainly coming from a few main markets.

-- Number of customers by country 

select Country, count(CustomerId) as total_customers
from Customer
group by Country
order by total_customers desc;

-- Finding:
-- The USA had the highest number of customers with 13 customers, followed by Canada with 8 customers.
-- Brazil and France had the next highest number with 5 customers each.
-- Most other countries had fewer customers, with many countries having only one customer.
-- This shows that the customer base is mainly concentrated in a few countries, especially the USA and Canada.

-- ==============================
-- 4. top 10 customers by spending
-- ==============================

-- Customer name 

-- Top 10 customers by spending

select concat(c.FirstName, ' ', c.LastName) as full_name, c.Country,
round(sum(i.Total),2) as total_spent, count(i.InvoiceId) as number_of_purchases
from Customer c
inner join Invoice i
on c.CustomerId = i.CustomerId
group by c.CustomerId, c.FirstName, c.LastName, c.Country
order by total_spent desc
limit 10;

-- Finding:
-- Helena Holý generated the highest revenue among customers with $49.62, followed by Richard Cunningham with $47.62.
-- The top 10 customers had similar spending levels and all made 7 purchases.
-- This shows that the difference in total spending was due to the value of purchases rather than the number of purchases.

-- ==============================
-- 5. best-selling tracks
-- ==============================

select t.Name as track_name, a.Name as artist_name, sum(i.Quantity) as number_of_purchases,
round(sum(i.Quantity * i.UnitPrice), 2) as revenue
from Track t
inner join Album al on t.AlbumId = al.AlbumId
inner join Artist a on al.ArtistId = a.ArtistId
inner join InvoiceLine i on t.TrackId = i.TrackId
group by t.TrackId, t.Name, a.Name
order by number_of_purchases desc, revenue desc, t.TrackId;

-- Finding:
-- Several tracks shared the highest revenue of $3.98, with 2 purchases each.
-- Most tracks were purchased only once, generating lower revenue.
-- Since purchases are spread across a large number of tracks, no individual track strongly dominates sales.

-- =================================
-- 6. Most Popular Genres.
-- =================================

-- Genre by quantity sold 

select g.Name as genre_name, sum(i.Quantity) as quantity_sold 
from Genre g
inner join Track t
on g.GenreId = t.GenreId
inner join InvoiceLine i
on t.TrackId = i.TrackId 
group by g.GenreId, g.Name
order by quantity_sold desc;

-- Finding:
-- Rock was the most popular genre with 835 tracks sold, followed by Latin with 386 and Metal with 264.
-- Alternative & Punk was also popular with 244 tracks sold.
-- The remaining genres had much lower sales compared to the top genres.
-- Overall, Rock was clearly the most popular genre in terms of quantity sold.

-- Genre by revenue 

select g.Name as genre_name, round(sum(i.Quantity * i.UnitPrice),2) as total_revenue 
from Genre g
inner join Track t
on g.GenreId = t.GenreId
inner join InvoiceLine i
on t.TrackId = i.TrackId 
group by g.GenreId, g.Name
order by total_revenue desc;

-- Finding:
-- Rock generated the highest revenue ($826.65), followed by Latin, Metal, and Alternative & Punk.
-- The revenue ranking was similar to the quantity sold ranking,
-- showing that the most purchased genres also generated the most revenue.

-- =====================================
-- 7. Artists generating the most revenue
-- =====================================

select a.Name as artist_name, round(sum(i.Quantity * i.UnitPrice),2) as revenue, sum(i.Quantity) as number_of_tracks_sold
from Artist a 
inner join Album al
on a.ArtistId = al.ArtistId
inner join Track t
on t.AlbumId = al.AlbumId
inner join InvoiceLine i
on t.TrackId = i.TrackId
group by a.ArtistId, a.Name
order by revenue desc, number_of_tracks_sold desc;

-- Finding:
-- Iron Maiden was the highest-revenue artist with $138.60, followed by U2, Metallica, and Led Zeppelin.
-- These artists also had the highest number of tracks sold.
-- Overall, artists with more track sales generated more revenue.

-- ===============================
-- 8. Albums performing the best
-- ==============================

-- Album sales 

select a.Title, sum(i.Quantity) as number_of_tracks_sold
from Album a
inner join Track t
on t.AlbumId = a.AlbumId
inner join InvoiceLine i
on t.TrackId = i.TrackId
group by a.AlbumId, a.Title
order by number_of_tracks_sold desc;

-- Finding:
-- Minha Historia had the highest number of tracks sold, with 35, followed by Greatest Hits with 26 and Unplugged with 25.
-- After that, sales dropped gradually, with many albums having fewer than 20 tracks sold.
-- Overall, Minha Historia was the best-selling album based on the number of tracks sold.

select a.Title as album_title, round(sum(i.Quantity * i.UnitPrice), 2) as revenue
from Album a
inner join Track t 
on a.AlbumId = t.AlbumId
inner join InvoiceLine i
on t.TrackId = i.TrackId
group by a.AlbumId, a.Title
order by revenue desc;

-- Finding:
-- Battlestar Galactica (Classic), Season 1 generated the highest revenue at $35.82,
-- followed by Minha Historia ($34.65) and The Office, Season 3 ($31.84).
-- Some TV show albums generated more revenue despite having fewer tracks sold,
-- because their tracks have higher prices than most music tracks.

-- =========================================
-- 9. Employees generating the highest sales
-- =========================================

select count(*) as total_employees
from Employee;

-- Finding:
-- The Employee table contains 8 employees in total.

select concat(e.FirstName, ' ', e.LastName) as full_name, count(distinct c.CustomerId) as number_of_customers_managed,
round(sum(i.Total), 2) as total_revenue
from Employee e
inner join Customer c
on e.EmployeeId = c.SupportRepId
inner join Invoice i
on i.CustomerId = c.CustomerId
group by e.EmployeeId, e.FirstName, e.LastName
order by number_of_customers_managed desc, total_revenue desc;

-- Finding:
-- Jane Peacock managed the most customers (21) and generated the highest revenue at $833.04.
-- Margaret Park followed with 20 customers and $775.40 in revenue,
-- while Steve Johnson managed 18 customers and generated $720.16.
-- Overall, Jane Peacock had both the highest number of managed customers and the highest revenue
-- among the three employees who have assigned customers. The Employee table contains 8 employees
-- in total, but the other 5 do not have customers assigned to them.

-- ===================================
-- 10. Average spending per customer
-- ===================================

-- Average spending per customer

select round(sum(i.Total) / count(distinct i.CustomerId), 2) as average_spending_per_customer
from Invoice i;

-- Finding:
-- The average customer spent $39.47.

-- ================================================
-- 11. Playlists containing the most popular music
-- ===============================================

-- Playlist size 

select p.Name as playlist_name, count(pt.TrackId) as playlist_size
from Playlist p
inner join PlaylistTrack pt
on p.PlaylistId = pt.PlaylistId
group by p.PlaylistId, p.Name
order by playlist_size desc;

-- Finding:
-- The Music playlists contain the largest number of tracks, with 3,290 tracks each,
-- followed by 90's Music with 1,477 tracks. TV Shows and Classical contain
-- significantly fewer tracks, with 213 and 75 respectively. This shows that
-- the database is heavily centered around broad music playlists, while
-- specialized playlists contain a much smaller selection of tracks.

-- Most common genres in playlists 

select p.Name as playlist_name, g.Name as genre_name, count(pt.TrackId) as tracks_count
from Playlist p
inner join PlaylistTrack pt
on p.PlaylistId = pt.PlaylistId
inner join Track t
on pt.TrackId = t.TrackId
inner join Genre g
on t.GenreId = g.GenreId
group by p.PlaylistId, p.Name, g.GenreId, g.Name
order by p.Name, tracks_count desc;

-- Finding:
-- Rock is the most represented genre in the Music playlist, with 1,297 tracks,
-- followed by Latin (579), Metal (374), and Alternative & Punk (332).
-- Rock is also the dominant genre in the 90's Music playlist, with 621 tracks.
-- More specialized playlists show a stronger focus on specific genres, such as
-- Latin in Brazilian Music and Classical in the Classical playlists.
-- TV Shows is mainly made up of TV Shows, Drama, and Science Fiction & Fantasy content.

-- =======================================
-- 12. Top 10% highest-value customers
-- =======================================

with customer_spending as (
select c.CustomerId, concat(c.FirstName, ' ', c.LastName) as customer_name, round(sum(i.Total), 2) as total_spending
from Customer c
inner join Invoice i
on c.CustomerId = i.CustomerId
group by c.CustomerId, c.FirstName, c.LastName
),

ranked_customers as (
select CustomerId, customer_name, total_spending,
ntile(10) over (order by total_spending desc) as spending_group
from customer_spending
)

select customer_name, total_spending
from ranked_customers
where spending_group = 1
order by total_spending desc;

-- Finding:
-- The top 10% of customers are relatively high-value customers,
-- with Helena Holý spending the most at $49.62, followed by
-- Richard Cunningham at $47.62 and Luis Rojas at $46.62.
-- The results show that spending among the highest-value customers
-- is fairly close, with the top customers spending between $43.62
-- and $49.62.

-- ===============================================
-- 13. Artists rank within each genre by revenue
-- ===============================================

with artist_revenue as (
select g.GenreId, g.Name as genre_name, a.ArtistId, a.Name as artist_name,
round(sum(il.UnitPrice * il.Quantity), 2) as revenue
from InvoiceLine il
inner join Track t
on il.TrackId = t.TrackId
inner join Album al
on t.AlbumId = al.AlbumId
inner join Artist a
on al.ArtistId = a.ArtistId
inner join Genre g
on t.GenreId = g.GenreId
group by g.GenreId, g.Name, a.ArtistId, a.Name
)

select genre_name, artist_name, revenue,
rank() over (partition by GenreId order by revenue desc) as artist_rank
from artist_revenue
order by genre_name, artist_rank;

-- Finding:
-- Artists are ranked separately within each genre based on their revenue.
-- U2 leads the Rock genre with $90.09, while Metallica leads the Metal
-- genre with $90.09. Some artists share the same rank because they have
-- equal revenue. This shows that different artists perform better in
-- different genres, which can help with genre-specific marketing,
-- promotions, and playlist curation.

-- ===========================
-- Summary of Key Insights:
-- ===========================

-- The analysis shows that revenue is concentrated among a number of important artists,
-- genres, and customers. Rock was the most popular genre and generated the highest revenue,
-- while Iron Maiden was the highest-revenue artist overall. Jane Peacock managed the most
-- customers and generated the highest revenue among employees with assigned customers.
-- The analysis also identified high-value customers and differences in purchasing behavior
-- across countries and genres. These insights can support customer targeting, genre-specific
-- marketing, artist promotion, playlist curation, and better business decisions.