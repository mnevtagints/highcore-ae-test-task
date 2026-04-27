\# Event Exploration



\## Зачем нужен



Этот skill использую, когда получаю новый событийный датасет (например, Firebase).



Помогает быстро понять:

\- какие есть события

\- какой user\_id использовать

\- как устроено время

\- какие есть вложенные поля (event\_params)

\- есть ли вообще revenue



\---



\## Шаги



\### 1. Общее количество событий



select count(\*) as events\_cnt

from raw.events;



\---



\### 2. Какие события есть



select

&#x20;   event\_name,

&#x20;   count(\*) as events\_cnt

from raw.events

group by 1

order by 2 desc;



\---



\### 3. Проверка user\_id



select

&#x20;   count(\*) as total\_events,

&#x20;   count(user\_id) as events\_with\_user\_id,

&#x20;   count(user\_pseudo\_id) as events\_with\_user\_pseudo\_id,

&#x20;   count(distinct user\_id) as distinct\_user\_id,

&#x20;   count(distinct user\_pseudo\_id) as distinct\_user\_pseudo\_id

from raw.events;



Обычно в Firebase лучше использовать user\_pseudo\_id.



\---



\### 4. Работа со временем



select

&#x20;   min(timestamp 'epoch' + event\_timestamp / 1000000 \* interval '1 second') as min\_event\_time,

&#x20;   max(timestamp 'epoch' + event\_timestamp / 1000000 \* interval '1 second') as max\_event\_time

from raw.events;



\---



\### 5. Разбор event\_params



select

&#x20;   event\_name,

&#x20;   ep.param.key as param\_key,

&#x20;   count(\*) as events\_cnt

from raw.events

cross join unnest(event\_params) as ep(param)

group by 1, 2

order by 3 desc;



\---



\### 6. Проверка revenue



select

&#x20;   event\_name,

&#x20;   count(\*) as events\_cnt,

&#x20;   count(event\_value\_in\_usd) as events\_with\_revenue,

&#x20;   sum(event\_value\_in\_usd) as total\_revenue

from raw.events

group by 1

order by total\_revenue desc nulls last;



\---



\## Вывод



После этих шагов обычно понятно:

\- какие события важны

\- какой user\_id использовать

\- как работать с временем

\- какие параметры нужно вытаскивать

\- можно ли строить метрики по revenue



\---



\## Комментарий



В этом датасете:

\- основной id - user\_pseudo\_id

\- данные сильно событийные

\- revenue встречается редко



Поэтому дальше логика строилась вокруг retention, а не монетизации.

