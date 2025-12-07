-- Enable extensions
create extension if not exists "pgcrypto";

-- USERS: minimal auth mirror for RLS context
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  role text not null check (role in ('admin', 'counselor')),
  email text
);

-- TEAMS: per-tenant teams
create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  name text
);

-- USER_TEAMS: team membership
create table if not exists public.user_teams (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade
);

create index if not exists user_teams_user_id_idx on public.user_teams (user_id);
create index if not exists user_teams_team_id_idx on public.user_teams (team_id);

-- LEADS
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  owner_id uuid not null references public.users(id) on delete restrict,
  team_id uuid references public.teams(id) on delete set null,
  stage text not null default 'new',
  full_name text,
  email text,
  phone text
);

-- APPLICATIONS
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  lead_id uuid not null references public.leads(id) on delete cascade,
  program_name text,
  status text default 'pending'
);

-- TASKS
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  application_id uuid not null references public.applications(id) on delete cascade,
  type text not null,
  title text,
  due_at timestamptz not null,
  status text not null default 'pending'
);

alter table public.tasks
  add constraint tasks_type_check
  check (type in ('call', 'email', 'review'));

alter table public.tasks
  add constraint tasks_due_at_check
  check (due_at >= created_at);

-- Simple EVENTS table for broadcasts
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  type text not null,
  payload jsonb
);

-- INDEXES

-- Leads: tenant_id, owner_id, stage
create index if not exists leads_tenant_id_idx on public.leads (tenant_id);
create index if not exists leads_owner_id_idx on public.leads (tenant_id, owner_id);
create index if not exists leads_stage_idx on public.leads (tenant_id, stage);

-- Applications: tenant_id, lead_id
create index if not exists applications_tenant_id_idx on public.applications (tenant_id);
create index if not exists applications_lead_id_idx on public.applications (tenant_id, lead_id);

-- Tasks: tenant_id, due_at, status
create index if not exists tasks_tenant_due_at_idx on public.tasks (tenant_id, due_at);
create index if not exists tasks_tenant_status_idx on public.tasks (tenant_id, status);
