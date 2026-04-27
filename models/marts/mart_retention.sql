with users as (

    select * from {{ ref('int_users_first_seen') }}

),

activity as (

    select distinct
        user_id,
        cast(event_time as date) as activity_date
    from {{ ref('int_events_pivot') }}

),

cohort_activity as (

    select
        u.user_id,
        u.cohort_date,
        datediff('day', u.cohort_date, a.activity_date) as day_number
    from users u
    join activity a
        on u.user_id = a.user_id
    where datediff('day', u.cohort_date, a.activity_date) between 0 and 30

),

retention as (

    select
        cohort_date,
        day_number,
        count(distinct user_id) as retained_users
    from cohort_activity
    group by 1, 2

),

cohort_size as (

    select
        cohort_date,
        count(distinct user_id) as cohort_users
    from users
    group by 1

)

select
    r.cohort_date,
    r.day_number,
    c.cohort_users,
    r.retained_users,
    round(r.retained_users * 1.0 / c.cohort_users, 4) as retention_rate
from retention r
join cohort_size c
    on r.cohort_date = c.cohort_date
order by 1, 2