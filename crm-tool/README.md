# LearnLynk – Technical Assessment (CRM Tool)

This repo contains a small CRM-style implementation for the LearnLynk technical test.

## Tech Stack

- Next.js App Router + TypeScript
- Supabase Postgres (schema + RLS)
- Supabase Edge Function (create-task)
- React Query for data fetching / mutations

## terminal code:
npm create vite@latest crm-tool
cd crm-tool
npm install
npm install @supabase/supabase-js
npm run dev

## How to run the dashboard

1. Clone the repo and install dependencies:
npm install
npm install @supabase/supabase-js
npm run dev

2. Check .env.local in the project root which connects with supabase schema:

3. In your Supabase project, run the SQL files in this order using the SQL editor in supabase:

- backend/schema.sql
- backend/rls_policies.sql
- backend/min_records.sql (sample records for testing)  


4. Start the Next.js dev server:
npm run dev

5. Open the dashboard page in your browser:
http://localhost:3000/dashboard/today

This page fetches tasks due today from Supabase and lets you mark them as complete using supabase.from("tasks").update(...).

## Edge Function: create-task

The Edge Function lives at:
backend/edge-functions/create-task/index.ts

It implements POST /create-task with:

- Input: { application_id, task_type, due_at }
- Validation for task_type and future due_at
- Insert into tasks using a service-role Supabase client
- A "task.created" broadcast via an events table
- JSON responses with status codes 200, 400, and 500 [web:71]

For local testing with the Supabase CLI, the same file can be placed under:


For local testing with the Supabase CLI, the same file can be placed under:

supabase/functions/create-task/index.ts and run with:

supabase functions serve create-task


Note: 
(Edge Function setup is not required to view /dashboard/today; the page talks directly to the tasks table.)




## Section 5:  how they would implement Stripe Checkout for an application fee. Must mention: • Creating a Checkout session • Storing payment_request • Handling Stripe webhook • Updating payment status • Updating application stage or timeline

## Stripe Answer

When the user clicks Pay application fee on an application, the backend first inserts a payment_requests row with application_id, amount, currency, tenant_id, and status = "pending". 

It then calls stripe.checkout.sessions.create with a single line item for the application fee, success/cancel URLs, and includes payment_requests.id and application_id in metadata so the session is linked to our database row. 

The frontend receives the Checkout Session id and redirects the user to Stripe Checkout to complete payment. After payment, Stripe calls our secure webhook endpoint (e.g. /api/stripe/webhook), where we verify the Stripe signature and handle the checkout.session.completed event.

In the webhook handler, we look up the matching payment_requests row using the session id or metadata, mark it as paid, and store the Stripe payment_intent / charge id for audit.

In the same transaction, we update the related application: set its payment_status or stage to something like fee_paid and append a timeline entry such as “Application fee paid via Stripe” to an application_timeline table. 

Finally, the dashboard pages simply read from payment_requests and the application’s stage/timeline to reflect that the fee is complete and unlock the next workflow steps.


