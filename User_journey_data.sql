SET sql_mode = '';
SET SESSION group_concat_max_len = 100000;

WITH paid_users AS (
	SELECT
		user_id,
        MIN(date_purchased) AS first_purchase_date,
        CASE
			WHEN purchase_type = 0 THEN 'Monthly'
            WHEN purchase_type = 1 THEN 'Quarterly'
            WHEN purchase_type = 2 THEN 'Annual'
            ELSE 'Other'
        END AS subscription_type,
        purchase_price
	FROM
		student_purchases
	GROUP BY
		user_id
	HAVING
		purchase_price > 0
		AND
		CAST(first_purchase_date as DATE) >= '2023-01-01'
		AND
		CAST(first_purchase_date as DATE) < '2023-03-01'
),

user_interactions AS (
	SELECT
		pu.user_id,
        pu.first_purchase_date,
        pu.subscription_type,
		fi.visitor_id,
        fi.session_id,
        fi.event_source_url,
        fi.event_destination_url,
        fi.event_date
	FROM
		paid_users pu 
	JOIN
		front_visitors fv ON fv.user_id = pu.user_id
	JOIN
		front_interactions fi ON fi.visitor_id = fv.visitor_id
	WHERE
		fi.event_date < pu.first_purchase_date -- User interactions before first purchase
),

aliased_user_interactions AS (
	SELECT
		user_id,
        session_id,
        subscription_type,
        CASE 
			WHEN event_source_url LIKE 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_source_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_source_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_source_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources center'
            WHEN event_source_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career tracks'
            WHEN event_source_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_source_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_source_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_source_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_source_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
			WHEN event_source_url LIKE 'https://365datascience.com/checkout%' AND event_source_url LIKE '%coupon%' THEN 'Coupon'
			WHEN event_source_url LIKE 'https://365datascience.com/checkout%' AND event_source_url NOT LIKE '%coupon%' THEN 'Checkout'
            ELSE 'Other'
        END AS event_source_url,
        CASE
			WHEN event_destination_url LIKE 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_destination_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_destination_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_destination_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources center'
            WHEN event_destination_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career tracks'
            WHEN event_destination_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_destination_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_destination_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_destination_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_destination_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
            WHEN event_destination_url LIKE 'https://365datascience.com/checkout%' AND event_destination_url LIKE '%coupon%' THEN 'Coupon'
			WHEN event_destination_url LIKE 'https://365datascience.com/checkout%' AND event_destination_url NOT LIKE '%coupon%' THEN 'Checkout'
            ELSE 'Other'
        END AS event_destination_url,
        event_date
	FROM
		user_interactions
),

user_session_journey AS (
	SELECT 
		user_id,
		subscription_type,
		session_id,
		event_source_url,
		event_destination_url,
		CONCAT(event_source_url,'->', event_destination_url) AS event_url
	FROM 
		aliased_user_interactions
),

mod_session_journey AS (
	SELECT 
		user_id,
		session_id,
		subscription_type,
		GROUP_CONCAT(event_url SEPARATOR '->') AS user_journey
	FROM
		user_session_journey
	GROUP BY
		session_id
	ORDER BY
		user_id, session_id
)

SELECT 
	user_id,
    session_id,
    subscription_type,
    user_journey
FROM
	mod_session_journey
ORDER BY
	user_id, session_id;
    















