with events as (

    select
        user_pseudo_id as user_id,
        timestamp 'epoch' + event_timestamp / 1000000 * interval '1 second' as event_time
    from raw.events

),

users as (

    select
        user_id,
        min(event_time) as first_seen_at,
        cast(min(event_time) as date) as cohort_date
    from events
    where user_id is not null
    group by 1

)

select * from users