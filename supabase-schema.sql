-- OUD Markets student platform schema
-- Run this in Supabase SQL Editor after creating your project.
-- This uses Auth user IDs and Row Level Security so students can only read/write their own records.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text,
  last_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  price_cents integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  position integer not null,
  title text not null,
  description text,
  video_url text,
  created_at timestamptz not null default now(),
  unique(course_id, position)
);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  stripe_customer_id text,
  stripe_payment_intent_id text,
  created_at timestamptz not null default now(),
  unique(user_id, course_id)
);

create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  completed boolean not null default false,
  updated_at timestamptz not null default now(),
  unique(user_id, lesson_id)
);

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.enrollments enable row level security;
alter table public.lesson_progress enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select to authenticated using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated using (auth.uid() = id);

drop policy if exists "courses_read_authenticated" on public.courses;
create policy "courses_read_authenticated" on public.courses for select to authenticated using (true);

drop policy if exists "lessons_read_authenticated" on public.lessons;
create policy "lessons_read_authenticated" on public.lessons for select to authenticated using (true);

drop policy if exists "enrollments_select_own" on public.enrollments;
create policy "enrollments_select_own" on public.enrollments for select to authenticated using (auth.uid() = user_id);

drop policy if exists "progress_select_own" on public.lesson_progress;
create policy "progress_select_own" on public.lesson_progress for select to authenticated using (auth.uid() = user_id);

drop policy if exists "progress_insert_own" on public.lesson_progress;
create policy "progress_insert_own" on public.lesson_progress for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "progress_update_own" on public.lesson_progress;
create policy "progress_update_own" on public.lesson_progress for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into public.courses (slug,title,price_cents)
values ('trading-fundamentals','Trading Fundamentals',2500)
on conflict (slug) do update set title=excluded.title, price_cents=excluded.price_cents;

insert into public.lessons (course_id,position,title,description)
select c.id, v.position, v.title, v.description
from public.courses c
cross join (values
 (1,'How markets move','Market structure & mechanics'),
 (2,'Read price action','Charts, levels & context'),
 (3,'Define the downside','Risk & position sizing'),
 (4,'Turn analysis into a plan','Execution framework'),
 (5,'Journal what happened','Review & improvement'),
 (6,'Build your playbook','Repeatable process')
) as v(position,title,description)
where c.slug='trading-fundamentals'
on conflict (course_id,position) do update set title=excluded.title, description=excluded.description;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, first_name, last_name)
  values (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
