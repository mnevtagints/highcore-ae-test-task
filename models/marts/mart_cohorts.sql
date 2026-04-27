with retention as (

    select * from {{ ref('mart_retention') }}

),

revenue as (

    select * from {{ ref('mart_monetization') }}

),

joined as (

    select
        r.cohort_date,
        r.day_number,
        r.cohort_users,
        r.retained_users,
        r.retention_rate,

        coalesce(m.paying_users, 0) as paying_users,
        coalesce(m.revenue, 0) as revenue

    from retention r
    left join revenue m
        on r.cohort_date = m.cohort_date
       and r.day_number = m.day_number

)

select * from joined
order by 1,2