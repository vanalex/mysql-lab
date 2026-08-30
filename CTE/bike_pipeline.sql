CREATE DATABASE IF NOT EXISTS bike_analytics;
USE bike_analytics;

DROP TABLE IF EXISTS bike_trip_summary;
DROP TABLE IF EXISTS raw_bike_trips;

CREATE TABLE raw_bike_trips (
    ride_id VARCHAR(64),
    rideable_type VARCHAR(50),

    started_at DATETIME,
    ended_at DATETIME,

    start_station_name VARCHAR(255),
    start_station_id VARCHAR(100),

    end_station_name VARCHAR(255),
    end_station_id VARCHAR(100),

    start_lat DECIMAL(10, 7),
    start_lng DECIMAL(10, 7),

    end_lat DECIMAL(10, 7),
    end_lng DECIMAL(10, 7),

    member_casual VARCHAR(20)
);

LOAD DATA LOCAL INFILE '/Users/alex/dataws/mysql-lab/CTE/data/202607-divvy-tripdata.csv'
INTO TABLE raw_bike_trips
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    ride_id,
    rideable_type,
    @started_at,
    @ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    @start_lat,
    @start_lng,
    @end_lat,
    @end_lng,
    @member_casual
)
SET
    started_at = NULLIF(@started_at, ''),
    ended_at = NULLIF(@ended_at, ''),
    start_lat = NULLIF(@start_lat, ''),
    start_lng = NULLIF(@start_lng, ''),
    end_lat = NULLIF(@end_lat, ''),
    end_lng = NULLIF(@end_lng, ''),
    member_casual = TRIM(TRAILING '\r' FROM @member_casual);

CREATE TABLE bike_trip_summary (
    station_name VARCHAR(255) PRIMARY KEY,
    total_trips BIGINT NOT NULL,
    avg_duration_minutes DECIMAL(10, 2),
    member_trips BIGINT NOT NULL,
    casual_trips BIGINT NOT NULL,
    member_percentage DECIMAL(5, 2)
);

INSERT INTO bike_trip_summary (
    station_name,
    total_trips,
    avg_duration_minutes,
    member_trips,
    casual_trips,
    member_percentage
)

WITH cleaned_trips AS (
    SELECT
        ride_id,
        rideable_type,
        started_at,
        ended_at,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        member_casual
    FROM raw_bike_trips
    WHERE started_at IS NOT NULL
      AND ended_at IS NOT NULL
      AND ended_at > started_at
      AND start_station_name IS NOT NULL
      AND start_station_name <> ''
      AND end_station_name IS NOT NULL
      AND end_station_name <> ''
),

trip_metrics AS (
    SELECT
        ride_id,
        rideable_type,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        member_casual,
        started_at,
        ended_at,

        TIMESTAMPDIFF(
            SECOND,
            started_at,
            ended_at
        ) AS duration_seconds,

        HOUR(started_at) AS start_hour,

        DAYOFWEEK(started_at) AS day_of_week,

        DATE(started_at) AS trip_date

    FROM cleaned_trips
),

station_stats AS (
    SELECT
        start_station_name,

        COUNT(*) AS total_trips,

        AVG(duration_seconds) AS avg_duration_seconds,

        SUM(
            CASE
                WHEN member_casual = 'member' THEN 1
                ELSE 0
            END
        ) AS member_trips,

        SUM(
            CASE
                WHEN member_casual = 'casual' THEN 1
                ELSE 0
            END
        ) AS casual_trips

    FROM trip_metrics
    GROUP BY start_station_name
)

SELECT
    start_station_name AS station_name,

    total_trips,

    ROUND(
        avg_duration_seconds / 60,
        2
    ) AS avg_duration_minutes,

    member_trips,

    casual_trips,

    ROUND(
        member_trips * 100.0 / NULLIF(total_trips, 0),
        2
    ) AS member_percentage

FROM station_stats;

SELECT *
FROM bike_trip_summary
ORDER BY total_trips DESC
LIMIT 20;
