with base as (

    select * from {{ ref('stg_events') }}

),

pivoted as (

    select
        user_id,
        event_name,
        event_time,

        max(case when param_key = 'board' then param_value end) as board,
        max(case when param_key = 'engagement_time_msec' then param_value end) as engagement_time_msec,
        max(case when param_key = 'firebase_screen_class' then param_value end) as screen_class,
        max(case when param_key = 'firebase_screen_id' then param_value end) as screen_id

    from base
    group by 1,2,3

)

select * from pivoted