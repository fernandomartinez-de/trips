-- =============================================================================
-- Japan trip schema (Supabase)
-- =============================================================================
-- Family collaborative trip-planning site, 13-30 Nov 2026.
--
-- Access model
-- ------------
-- The site is public via GitHub Pages. There is no user auth; anyone with the
-- URL can read AND write. We rely on URL secrecy + RLS policies that allow
-- anonymous CRUD via the publishable key. Add proper auth later if needed.
--
-- Naming convention
-- -----------------
-- All tables prefixed with `japan_` so future trips (italy_*, hawaii_*, ...)
-- can share the same Supabase project cleanly.
--
-- Idempotency
-- -----------
-- This script uses `create table if not exists`, `create policy if not exists`,
-- and `on conflict do nothing` on seeds so it is safe to re-run.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.japan_days (
    day_number  int primary key check (day_number between 1 and 30),
    title       text not null default '',
    subtitle    text not null default '',
    focus       text not null default '',
    updated_at  timestamptz not null default now()
);

create table if not exists public.japan_activities (
    id           text primary key,
    day_number   int  not null references public.japan_days(day_number) on delete cascade,
    title        text not null default '',
    description  text not null default '',
    time_of_day  text not null default 'tarde'
                 check (time_of_day in ('mañana', 'tarde', 'noche')),
    cost         int  not null default 0 check (cost >= 0),
    ubicacion    text not null default '',
    lat          double precision,
    lng          double precision,
    image_url    text not null default '',
    created_by   text not null default '',
    created_at   timestamptz not null default now(),
    updated_at   timestamptz not null default now()
);
create index if not exists japan_activities_day_idx on public.japan_activities(day_number);

create table if not exists public.japan_votes (
    activity_id  text not null references public.japan_activities(id) on delete cascade,
    voter_name   text not null,
    created_at   timestamptz not null default now(),
    primary key (activity_id, voter_name)
);
create index if not exists japan_votes_activity_idx on public.japan_votes(activity_id);

create table if not exists public.japan_inspo (
    id          uuid primary key default gen_random_uuid(),
    url         text not null,
    caption     text not null default '',
    author      text not null default 'family',
    sort_order  int  not null default 0,
    created_at  timestamptz not null default now()
);
create index if not exists japan_inspo_sort_idx on public.japan_inspo(sort_order);
-- Unique constraint on url so re-running the seed below is idempotent.
-- Wrapped in a DO block because ADD CONSTRAINT itself is not idempotent.
do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'japan_inspo_url_unique' and conrelid = 'public.japan_inspo'::regclass
    ) then
        alter table public.japan_inspo add constraint japan_inspo_url_unique unique (url);
    end if;
end $$;

create table if not exists public.japan_trip_glance (
    key         text primary key,
    label       text not null default '',
    title       text not null default '',
    subtitle    text not null default '',
    updated_at  timestamptz not null default now()
);

create table if not exists public.japan_geocache (
    ubicacion   text primary key,
    lat         double precision,
    lng         double precision,
    created_at  timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- Row Level Security: allow anonymous CRUD on every table.
-- The publishable API key is public; RLS is what gates access.
-- With these policies, any client can read and write. That is intentional for
-- a small family site; tighten later if needed.
-- -----------------------------------------------------------------------------

alter table public.japan_days         enable row level security;
alter table public.japan_activities   enable row level security;
alter table public.japan_votes        enable row level security;
alter table public.japan_inspo        enable row level security;
alter table public.japan_trip_glance  enable row level security;
alter table public.japan_geocache     enable row level security;

do $$
declare
    t text;
begin
    for t in
        select unnest(array[
            'japan_days',
            'japan_activities',
            'japan_votes',
            'japan_inspo',
            'japan_trip_glance',
            'japan_geocache'
        ])
    loop
        execute format('drop policy if exists %I on public.%I', t || '_public_all', t);
        execute format(
            'create policy %I on public.%I for all to anon, authenticated using (true) with check (true)',
            t || '_public_all',
            t
        );
    end loop;
end $$;


-- -----------------------------------------------------------------------------
-- Realtime: broadcast row-level changes so clients see each other's edits.
-- geocache is intentionally excluded (heavy write volume, low value to sync).
-- -----------------------------------------------------------------------------

do $$
begin
    -- Add tables to the supabase_realtime publication if not already present.
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'japan_days'
    ) then
        alter publication supabase_realtime add table public.japan_days;
    end if;
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'japan_activities'
    ) then
        alter publication supabase_realtime add table public.japan_activities;
    end if;
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'japan_votes'
    ) then
        alter publication supabase_realtime add table public.japan_votes;
    end if;
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'japan_inspo'
    ) then
        alter publication supabase_realtime add table public.japan_inspo;
    end if;
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'japan_trip_glance'
    ) then
        alter publication supabase_realtime add table public.japan_trip_glance;
    end if;
end $$;


-- -----------------------------------------------------------------------------
-- Auto-touch updated_at on writes.
-- -----------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
    new.updated_at := now();
    return new;
end $$;

drop trigger if exists japan_days_touch         on public.japan_days;
drop trigger if exists japan_activities_touch   on public.japan_activities;
drop trigger if exists japan_trip_glance_touch  on public.japan_trip_glance;

create trigger japan_days_touch
    before update on public.japan_days
    for each row execute function public.touch_updated_at();

create trigger japan_activities_touch
    before update on public.japan_activities
    for each row execute function public.touch_updated_at();

create trigger japan_trip_glance_touch
    before update on public.japan_trip_glance
    for each row execute function public.touch_updated_at();


-- -----------------------------------------------------------------------------
-- Seed data
-- -----------------------------------------------------------------------------

insert into public.japan_days (day_number, title, subtitle, focus) values
    ( 1, 'Tokio',    'Llegada',                'Llegamos a Narita, cena tranquila, a recuperar el sueño.'),
    ( 2, 'Tokio',    'Shibuya y Shinjuku',     'El lado eléctrico de Tokio. Cruces, neón, izakayas.'),
    ( 3, 'Tokio',    'Asakusa y Ueno',         'El Tokio antiguo. Templos, mercados, una tarde sin prisa.'),
    ( 4, 'Tokio',    'teamLab y Odaiba',       'Arte inmersivo en la mañana, mar en la tarde.'),
    ( 5, 'Nikko',    'Excursión desde Tokio',  'Un día en la montaña. Cascadas, templos, hojas rojas.'),
    ( 6, 'Hakone',   'Día de traslado',        'Traslado sin prisa a Hakone. Onsen en la noche.'),
    ( 7, 'Hakone',   'Día del Fuji',           'El circuito de Hakone. Si sale el Fuji, lo perseguimos.'),
    ( 8, 'Kioto',    'Día del Shinkansen',     'Tren bala al oeste. Llegar a Kioto por la tarde.'),
    ( 9, 'Kioto',    'Fushimi y Higashiyama',  'Las dos caminatas de Kioto que todos recuerdan.'),
    (10, 'Kioto',    'Arashiyama',             'Kioto oeste. Bambú, río, monos y tofu.'),
    (11, 'Kioto',    'Templos dorados',        'Kioto norte. Jardines zen y hoja de oro.'),
    (12, 'Nara',     'Excursión desde Kioto',  'Venados, Buda gigante, pueblo tranquilo.'),
    (13, 'Osaka',    'Día de traslado',        'Salto corto a Osaka. Base para el tramo final.'),
    (14, 'Osaka',    'Día de comer',           'Osaka es la cocina de Japón. Nos toca comer.'),
    (15, 'Miyajima', 'Excursión a Hiroshima',  'Día largo. Torii sobre el mar y un momento para reflexionar.'),
    (16, 'Osaka',    'Castillo y compras',     'Osaka local. Castillo y los últimos souvenirs.'),
    (17, 'Osaka',    'Día libre',              'Día en blanco. Universal, spa, o no hacer nada.'),
    (18, 'Osaka',    'Vuelo a casa',           'Aeropuerto Kansai, último snack de conbini, a casa.')
on conflict (day_number) do nothing;

insert into public.japan_trip_glance (key, label, title, subtitle) values
    ('fechas',    'Fechas',    '13 - 30 nov 2026',  '18 días, 17 noches'),
    ('ciudades',  'Ciudades',  'Seis paradas',      'Tokio, Nikko, Hakone, Kioto, Nara, Osaka'),
    ('temporada', 'Temporada', 'Otoño tardío',      'Hojas rojas (koyo, 紅葉) en su mejor momento'),
    ('viajeros',  'Viajeros',  'La familia',        'Cada quien pone su nombre arriba')
on conflict (key) do nothing;

insert into public.japan_inspo (url, caption, author, sort_order) values
    ('assets/img/inspo-01-6a13a9ca.jpg', 'Japón, foto 1',  'family',  1),
    ('assets/img/inspo-02-320658f7.jpg', 'Japón, foto 2',  'family',  2),
    ('assets/img/inspo-03-a67a549b.jpg', 'Japón, foto 3',  'family',  3),
    ('assets/img/inspo-04-559e847f.jpg', 'Japón, foto 4',  'family',  4),
    ('assets/img/inspo-05-974c205f.jpg', 'Japón, foto 5',  'family',  5),
    ('assets/img/inspo-06-f66f4c96.jpg', 'Japón, foto 6',  'family',  6),
    ('assets/img/inspo-07-366f200c.jpg', 'Japón, foto 7',  'family',  7),
    ('assets/img/inspo-08-c5c784c1.jpg', 'Japón, foto 8',  'family',  8),
    ('assets/img/inspo-09-5212a32a.jpg', 'Japón, foto 9',  'family',  9),
    ('assets/img/inspo-10-59fce568.jpg', 'Japón, foto 10', 'family', 10),
    ('assets/img/inspo-11-57b13703.jpg', 'Japón, foto 11', 'family', 11),
    ('assets/img/inspo-12-61a70fed.jpg', 'Japón, foto 12', 'family', 12),
    ('assets/img/inspo-13-da9bb830.jpg', 'Japón, foto 13', 'family', 13)
on conflict (url) do nothing;
