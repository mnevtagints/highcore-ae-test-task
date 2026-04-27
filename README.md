# Тестовое задание - Analytics Engineer (Highcore)

## Коротко о задаче

Работа с сырыми событиями мобильной игры (Firebase).  
Цель - собрать витрины для анализа:

- retention новых пользователей
- монетизация по когортам

Стек: dbt + DuckDB

---

## Как запустить


python -m venv .venv
.venv\Scripts\activate

pip install -r requirements.txt

python scripts/prepare_data.py

dbt deps
dbt build
dbt test


---

## Особенности данных

- данные событийные (1 строка = 1 событие)
- основной user id - `user_pseudo_id`
- параметры лежат в `event_params` (nested структура)

Чтобы с ними работать:
- использовал UNNEST
- привел значения к одному типу

---

## Архитектура

Разбил модели на слои.

### staging

**stg_events**
- распаковывает event_params
- приводит timestamp
- результат — “длинный” формат (event + param)

---

### intermediate

**int_events_pivot**
- переводит данные в “широкий” формат
- оставил только нужные поля (board, screen и т.д.)

**int_users_first_seen**
- дата первого события пользователя
- считается напрямую от raw (без pivot)

---

### marts

**mart_retention**
- retention по когортам
- считаю факт возврата пользователя в день

**mart_monetization**
- revenue и paying users
- использую `event_value_in_usd`

**mart_cohorts**
- финальная витрина
- объединяет retention + revenue
- готова для BI

---

## Допущения

- user = `user_pseudo_id`
- retention считаю по активности в день
- анализ ограничен 30 днями

### Монетизация

В данных мало событий с revenue.

Из-за этого:
- почти все значения = 0
- метрика есть, но разреженная

В реальном проекте уточнил бы:
- какие события = покупки
- где лежит price / currency

---

## Тесты

Добавлены:

- not null
- уникальность (cohort_date + day_number)

Бизнес-проверки:

- retention от 0 до 1
- retained_users ≤ cohort_users
- revenue ≥ 0
- day_number от 0 до 30

---

## Дашборд

Из `mart_cohorts` можно построить:

- retention (D0–D30)
- revenue по когортам
- paying users

Фильтр:
- cohort_date

---
