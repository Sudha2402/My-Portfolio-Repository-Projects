-- Enable RLS
alter table public.leads enable row level security;

-- JWT helpers
create or replace function public.current_jwt_role()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claims', true), ''),
    '{}'
  )::json ->> 'role';
$$;

create or replace function public.current_jwt_user_id()
returns uuid
language sql
stable
as $$
  select (coalesce(
    nullif(current_setting('request.jwt.claims', true), ''),
    '{}'
  )::json ->> 'user_id')::uuid;
$$;

create or replace function public.current_jwt_tenant_id()
returns uuid
language sql
stable
as $$
  select (coalesce(
    nullif(current_setting('request.jwt.claims', true), ''),
    '{}'
  )::json ->> 'tenant_id')::uuid;
$$;

-- Helper: check if current user is in a given team
create or replace function public.is_member_of_team(team uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.user_teams ut
    where ut.team_id = team
      and ut.user_id = public.current_jwt_user_id()
  );
$$;

-- SELECT policy for leads
drop policy if exists "Leads select by role and team" on public.leads;

create policy "Leads select by role and team"
on public.leads
for select
using (
  tenant_id = public.current_jwt_tenant_id()
  and (
    public.current_jwt_role() = 'admin'
    or (
      public.current_jwt_role() = 'counselor'
      and (
        owner_id = public.current_jwt_user_id()
        or (team_id is not null and public.is_member_of_team(team_id))
      )
    )
  )
);

-- INSERT policy for leads
drop policy if exists "Leads insert by tenant for counselors and admins" on public.leads;

create policy "Leads insert by tenant for counselors and admins"
on public.leads
for insert
with check (
  tenant_id = public.current_jwt_tenant_id()
  and public.current_jwt_role() in ('admin', 'counselor')
);
