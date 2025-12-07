-- 1) Choose a tenant id you will reuse everywhere
-- you can change this to any uuid you like
-- (no tenants table needed, it's just a value)
-- 4a1a0f18-0f5c-4cdd-9c3a-111111111111

-- 2) Create one admin user
insert into public.users (id, tenant_id, role, email)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',      -- user_id
  '4a1a0f18-0f5c-4cdd-9c3a-111111111111',      -- tenant_id
  'admin',
  'admin@example.com'
)
on conflict (id) do nothing;

-- 3) (Optional) one team
insert into public.teams (id, tenant_id, name)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  '4a1a0f18-0f5c-4cdd-9c3a-111111111111',
  'Default Team'
)
on conflict (id) do nothing;

-- 4) (Optional) link user to team
insert into public.user_teams (user_id, team_id)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'dddddddd-dddd-dddd-dddd-dddddddddddd'
)
on conflict do nothing;

-- 5) Insert a lead and RETURNING id
insert into public.leads (tenant_id, owner_id, team_id, stage, full_name, email, phone)
values (
  '4a1a0f18-0f5c-4cdd-9c3a-111111111111',  -- tenant_id
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',  -- owner_id (user above)
  'dddddddd-dddd-dddd-dddd-dddddddddddd',  -- team_id (optional; can be null)
  'new',
  'Test Student',
  'student@example.com',
  '+91-9999999999'
)
returning id;

-- 391f5f3f-0cad-48fa-a234-863979b2068e



insert into public.applications (tenant_id, lead_id, program_name, status)
values (
 '4a1a0f18-0f5c-4cdd-9c3a-111111111111', -- same tenant
 '391f5f3f-0cad-48fa-a234-863979b2068e', 
 'BSc Computer Science',
 'pending'
)
returning id;


-- 91fa211c-6c3a-49d2-99dd-d9baf7b886f4



insert into public.tasks (tenant_id, application_id, type, title, due_at, status)
values (
 '4a1a0f18-0f5c-4cdd-9c3a-111111111111', -- same tenant
 '91fa211c-6c3a-49d2-99dd-d9baf7b886f4', 
 'call',
 'Call student about documents',
 now() + interval '2 hours',
 'pending'
);











-- Single tenant for all records
-- id: 11111111-1111-1111-1111-111111111111

-- ---------- USERS ----------
insert into public.users (id, tenant_id, role, email)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'admin',     'admin@crmtool.in'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'counselor', 'sudha.counselor@crmtool.in'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'counselor', 'shanaya.counselor@crmtool.in')
on conflict (id) do nothing;

-- ---------- TEAMS ----------
insert into public.teams (id, tenant_id, name)
values
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'North India Team'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 'South India Team')
on conflict (id) do nothing;

-- ---------- USER_TEAMS ----------
insert into public.user_teams (user_id, team_id)
values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee')
on conflict do nothing;

-- ---------- LEADS ----------
insert into public.leads (id, tenant_id, owner_id, team_id, stage, full_name, email, phone)
values
  ('11111111-2222-3333-4444-555555555555',
   '11111111-1111-1111-1111-111111111111',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'dddddddd-dddd-dddd-dddd-dddddddddddd',
   'new',
   'Sudha Sharma',
   'sudha.sharma@example.com',
   '+91-9876543210'),

  ('11111111-2222-3333-4444-666666666666',
   '11111111-1111-1111-1111-111111111111',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'dddddddd-dddd-dddd-dddd-dddddddddddd',
   'contacted',
   'Shanaya Singh',
   'shanaya.singh@example.com',
   '+91-9823456789'),

  ('11111111-2222-3333-4444-777777777777',
   '11111111-1111-1111-1111-111111111111',
   'cccccccc-cccc-cccc-cccc-cccccccccccc',
   'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
   'in_review',
   'Sana Khan',
   'sana.khan@example.com',
   '+91-9811122233'),

  ('11111111-2222-3333-4444-888888888888',
   '11111111-1111-1111-1111-111111111111',
   'cccccccc-cccc-cccc-cccc-cccccccccccc',
   'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
   'new',
   'Arjun Verma',
   'arjun.verma@example.com',
   '+91-9797979797'),

  ('11111111-2222-3333-4444-999999999999',
   '11111111-1111-1111-1111-111111111111',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'dddddddd-dddd-dddd-dddd-dddddddddddd',
   'contacted',
   'Aditi Rao',
   'aditi.rao@example.com',
   '+91-9900011122')
on conflict (id) do nothing;

-- ---------- APPLICATIONS ----------
insert into public.applications (id, tenant_id, lead_id, program_name, status)
values
  ('aaaa1111-2222-3333-4444-555555555555',
   '11111111-1111-1111-1111-111111111111',
   '11111111-2222-3333-4444-555555555555',
   'BCom (Hons) - Delhi University',
   'pending'),

  ('aaaa1111-2222-3333-4444-666666666666',
   '11111111-1111-1111-1111-111111111111',
   '11111111-2222-3333-4444-666666666666',
   'BBA - NMIMS Mumbai',
   'submitted'),

  ('aaaa1111-2222-3333-4444-777777777777',
   '11111111-1111-1111-1111-111111111111',
   '11111111-2222-3333-4444-777777777777',
   'BTech CSE - VIT Chennai',
   'fee_paid'),

  ('aaaa1111-2222-3333-4444-888888888888',
   '11111111-1111-1111-1111-111111111111',
   '11111111-2222-3333-4444-888888888888',
   'BA Economics - Christ University',
   'pending'),

  ('aaaa1111-2222-3333-4444-999999999999',
   '11111111-1111-1111-1111-111111111111',
   '11111111-2222-3333-4444-999999999999',
   'BSc Psychology - DU',
   'reviewing')
on conflict (id) do nothing;

-- ---------- TASKS (several due today, pending) ----------
insert into public.tasks (tenant_id, application_id, type, title, due_at, status)
values
  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-555555555555',
   'call',
   'Call Sudha about missing 12th marksheet',
   now() + interval '1 hour',
   'pending'),

  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-555555555555',
   'email',
   'Email prospectus to Sudha',
   now() + interval '2 hour',
   'pending'),

  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-666666666666',
   'call',
   'Follow up with Shanaya for application fee',
   now() + interval '3 hour',
   'pending'),

  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-777777777777',
   'review',
   'Review Sana’s SOP and LORs',
   now() + interval '4 hour',
   'pending'),

  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-888888888888',
   'email',
   'Send Arjun fee payment reminder',
   now() + interval '5 hour',
   'pending'),

  ('11111111-1111-1111-1111-111111111111',
   'aaaa1111-2222-3333-4444-999999999999',
   'call',
   'Call Aditi for counselling session scheduling',
   now() + interval '6 hour',
   'pending');
