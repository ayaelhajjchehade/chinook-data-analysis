-- =========================
-- chinook data analysis
-- =========================

-- =========================
-- Data Exploration
-- =========================

describe album;
describe artist;
describe customer;
describe employee;
describe genre;
describe invoice;
describe invoiceline;
describe mediatype;
describe playlist;
describe playlisttrack;
describe track;

select count(*) from track;
select count(*) from album;

-- =========================
-- Data Quality Check
-- =========================

select count(*) as null_countries
from Customer
where Country is null;

select count(*) as null_composers
from Track
where Composer is null;

select count(*) as null_albums
from track
where albumId is null;

select count(*) as null_genres
from track
where genreId is null;

select count(*) as null_artists
from album
where artistId is null;

select count(*) as null_customers
from invoice
where customerId is null;

-- Result:
-- Only the Composer column contains NULL values (977).
-- Since the analysis focuses on sales, customers, artists,
-- albums, and genres, these missing values do not affect
-- the business questions and were left unchanged.

-- =========================
-- Duplicate Primary Key Check
-- =========================

-- Customer
select CustomerId, count(*) as duplicates
from Customer
group by CustomerId
having count(*) > 1;

-- Invoice
select InvoiceId, count(*) as duplicates
from Invoice
group by InvoiceId
having count(*) > 1;

-- InvoiceLine
select InvoiceLineId, count(*) as duplicates
from InvoiceLine
group by InvoiceLineId
having count(*) > 1;

-- Track
select TrackId, count(*) as duplicates
from Track
group by TrackId
having count(*) > 1;

-- Album
select AlbumId, count(*) as duplicates
from Album
group by AlbumId
having count(*) > 1;

-- Artist
select ArtistId, count(*) as duplicates
from Artist
group by ArtistId
having count(*) > 1;

-- Genre
select GenreId, count(*) as duplicates
from Genre
group by GenreId
having count(*) > 1;

-- Result:
-- No duplicate primary keys were found in the main tables used for analysis.
