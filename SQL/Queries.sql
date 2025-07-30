Create Database NYC_Airbnb_2019 use NYC_Airbnb_2019 exec sp_tables;

select
    *
from
    reviews;

select
    *
from
    nyc_airbnb_cleaned EXEC sp_help 'cleaned_nyc_airbnb';

CREATE TABLE
    cleaned_nyc_airbnb (
        id INT,
        name NVARCHAR (1000),
        host_id INT,
        host_name NVARCHAR (255),
        neighbourhood_group NVARCHAR (255),
        neighbourhood NVARCHAR (255),
        latitude FLOAT,
        longitude FLOAT,
        room_type NVARCHAR (100),
        price float,
        minimum_nights INT,
        number_of_reviews INT,
        last_review DATE,
        reviews_per_month FLOAT,
        calculated_host_listings_count INT,
        availability_365 INT,
        listing_url NVARCHAR (1000),
        listing_name NVARCHAR (1000)
    );

SELECT
    *
FROM
    OPENROWSET (
        BULK 'C:\path\to\yourfile.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        FIRSTROW = 2
    ) AS DataFile;

EXEC sp_configure 'show advanced options',
1;

RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries',
1;

RECONFIGURE;

select
    *
from
    cleaned_nyc_airbnb
Select
    top 5 *
from
    reviews;

select
    top 5 *
from
    neighbourhoods;

select
    top 5 *
from
    cleaned_nyc_airbnb;

--Total Rows and Columns
Select
    count(*) as Total_reviews
from
    reviews;

select
    count(*) as Total_neighbourhood
from
    neighbourhoods;

select
    count(*) as total_listings
from
    cleaned_nyc_airbnb;

--Check for NULLs in critical columns
SELECT
    SUM(
        CASE
            WHEN date IS NULL THEN 1
            ELSE 0
        END
    ) AS null_reviewer_id,
    SUM(
        CASE
            WHEN listing_id IS NULL THEN 1
            ELSE 0
        END
    ) AS null_listing_id
FROM
    reviews;

SELECT
    SUM(
        CASE
            WHEN neighbourhood IS NULL THEN 1
            ELSE 0
        END
    ) AS null_neighbourhood
FROM
    neighbourhoods;

SELECT
    SUM(
        CASE
            WHEN listing_id IS NULL THEN 1
            ELSE 0
        END
    ) AS null_listing_id,
    SUM(
        CASE
            WHEN price IS NULL THEN 1
            ELSE 0
        END
    ) AS null_price
FROM
    cleaned_nyc_airbnb;

--Listings Per Neighbhourhood
Select
    neighbourhood,
    count(*) as listing_count
from
    cleaned_nyc_airbnb
group by
    neighbourhood
order by
    listing_count desc;

--Average Price per neighbourhood
Select
    neighbourhood,
    format (AVG(price), '0.00') as avg_price
from
    cleaned_nyc_airbnb
group by
    neighbourhood
order by
    avg_price desc;

--Total reviews per listings
select
    listing_id,
    count(*) as Total_reviews
from
    reviews
group by
    listing_id
order by
    Total_reviews desc;

--Reviews by Date
select
    date,
    count(*) as daily_reviews
from
    reviews
group by
    date
order by
    date;

--Reviews by month 
SELECT
    DATENAME (MONTH, date) AS month,
    COUNT(*) AS monthly_reviews
FROM
    reviews
WHERE
    date IS NOT NULL
GROUP BY
    DATENAME (MONTH, date),
    MONTH (date)
ORDER BY
    MONTH (date);

--Average Review count and price per neighbourhood
select
    l.neighbourhood,
    count(r.listing_id) as total_reviews,
    format (AVG(l.price), '0.00') as avg_price
from
    cleaned_nyc_airbnb l
    left join reviews r on r.listing_id = l.listing_id
group by
    l.neighbourhood
order by
    total_reviews desc;

--Listings per neighbourhood group (if different granularity exists)
SELECT
    n.neighbourhood_group,
    count(l.listing_id) as listing_count,
    format (avg(l.price), '0.00') as Avg_price
from
    neighbourhoods n
    join cleaned_nyc_airbnb l on l.neighbourhood = n.neighbourhood
group by
    n.neighbourhood_group
order by
    listing_count desc;

--Top 10 most expensive Listings
select
    top 10 listing_name,
    price
from
    cleaned_nyc_airbnb
order by
    price desc;

--Basic overview of listings
select
    count(distinct listing_id) as Total_listings,
    count(distinct host_id) as Unique_hosts,
    count(distinct neighbourhood_group) as total_neighbourhood_group,
    count(distinct neighbourhood) as total_neighbourhoods,
    min(price) as min_price,
    max(price) as max_price,
    format (avg(price), '0.00') as avg_price
from
    cleaned_nyc_airbnb
where
    price is not null;

--Host with most listings
select
    top 10 host_name,
    count(*) as total_listings
from
    cleaned_nyc_airbnb
group by
    host_id,
    host_name
order by
    total_listings desc
    --Distribution of listings by room type
Select
    room_type,
    count(*) as listings_count,
    format (avg(price), '0.00') as avg_price
from
    cleaned_nyc_airbnb
where
    price is not null
group by
    room_type
order by
    listings_count desc;