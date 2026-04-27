with users as (

    select * from {{ ref('int_users_first_seen') }}

),

events as (

    select
        user_pseudo_id as user_id,
        timestamp 'epoch' + event_timestamp / 1000000 * interval '1 second' as event_time,
        event_value_in_usd
    from raw.events

),

revenue_events as (

    select
        user_id,
        cast(event_time as date) as activity_date,
        event_value_in_usd
    from events
    where event_value_in_usd is not null
      and event_value_in_usd > 0

),

joined as (

    select
        u.cohort_date,
        datediff('day', u.cohort_date, r.activity_date) as day_number,
        r.user_id,
        r.event_value_in_usd
    from users u
    join revenue_events r
        on u.user_id = r.user_id
    where datediff('day', u.cohort_date, r.activity_date) between 0 and 30

),

agg as (

    select
        cohort_date,
        day_number,
        count(distinct user_id) as paying_users,
        sum(event_value_in_usd) as revenue
    from joined
    group by 1,2

)

select * from agg
order by 1,2