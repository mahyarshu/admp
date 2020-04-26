-- Drop table

-- DROP TABLE public.musicbrainz_artists;

CREATE TABLE public.musicbrainz_artists (
	gid text NULL,
	"name" text NULL,
	"type" float8 NULL,
	gender float8 NULL,
	is_active bool NULL
);

-- Drop table

-- DROP TABLE public.dim_mbartist;

CREATE TABLE public.dim_mbartist (
	mbid text NULL,
	"name" text NULL,
	"type" float8 NULL,
	gender float8 NULL
);

-- Drop table

-- DROP TABLE public.dim_venues;

CREATE TABLE public.dim_venues (
	venue_id float8 NULL,
	"name" text NULL,
	city text NULL,
	capacity float8 NULL
);

--fct_event_artist_venue
SELECT 
	mb.gid as artist_id,
	ve.venue_id,
	ve.city,
	count(*) count_event,
	sum(popularity) sum_popularity,
	avg(popularity) avg_popularity
--into fct_event_artist_venue
FROM public.songkick_uk_events eve --50,155
inner join public.dim_mbartist mb on eve.mbid  = mb.gid --48,665
inner join public.dim_venues ve on eve.venue_id  = ve.venue_id  --46063
group by artist_id, mb.name, ve.venue_id , city;

--fct_event_venues
SELECT 
	ve.venue_id,
	ve.city,
	count(*) count_event,
	sum(popularity) sum_popularity,
	avg(popularity) avg_popularity
--into fct_event_venues
FROM public.songkick_uk_events eve --50,155
inner join public.dim_venues ve on eve.venue_id  = ve.venue_id  --46063
group by ve.venue_id , city;

--fct_event_cities
SELECT 
	ve.city,
	count(*) count_event,
	sum(popularity) sum_popularity,
	avg(popularity) avg_popularity
--into fct_event_cities
FROM public.songkick_uk_events eve --50,155
inner join public.dim_venues ve on eve.venue_id = ve.venue_id  --46063
group by city;

update fct_event_cities
set city = 'Unknown' where city is null

--fct_artist_cities
SELECT 
	mb.gid as artist_id,
	ve.city,
	count(*) count_event,
	sum(popularity) sum_popularity,
	avg(popularity) avg_popularity
--into fct_artist_cities
FROM public.songkick_uk_events eve --50,155
inner join public.dim_mbartist mb on eve.mbid  = mb.gid --48,665
inner join public.dim_venues ve on eve.venue_id  = ve.venue_id  --46063
group by artist_id, mb.name, city;


--dw_fct_city_events
SELECT 
	ve.city,
	t."year" ,
	t."month" ,
	count(*) count_event,
	avg(popularity) avg_popularity
into dw_fct_city_events
FROM public.songkick_uk_events eve --50,155
inner join public.dim_venues ve on eve.venue_id  = ve.venue_id  --46063
inner join public.dim_time t on eve.start_date = t.chart_date 
group by city, t."year" , t."month" ;

-- dw_fct_city_venue_events
SELECT 
	ve.city,
	ve."name",
	t."year" ,
	t."month" ,
	count(*) count_event,
	avg(popularity) avg_popularity
into dw_fct_city_venue_events
FROM public.songkick_uk_events eve --50,155
inner join public.dim_venues ve on eve.venue_id  = ve.venue_id  --46063
inner join public.dim_time t on eve.start_date = t.chart_date 
group by city, ve."name", t."year" , t."month" ;