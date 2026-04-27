with source as (

    select * from raw.events

),

unnested as (

    select
        user_pseudo_id as user_id,
        event_name,
        timestamp 'epoch' + event_timestamp / 1000000 * interval '1 second' as event_time,

        ep.param.key as param_key,

        coalesce(
            ep.param.value.string_value,
            cast(ep.param.value.int_value as varchar),
            cast(ep.param.value.float_value as varchar),
            cast(ep.param.value.double_value as varchar)
        ) as param_value

    from source
    cross join unnest(event_params) as ep(param)

)

select * from unnested