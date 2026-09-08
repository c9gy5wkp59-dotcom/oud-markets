# OUD Markets — Student Platform Setup

## What is included
- `login.html` — Supabase email/password sign in + account creation
- `dashboard.html` — authenticated student dashboard
- `supabase-schema.sql` — profiles, courses, lessons, enrollments, progress + RLS
- `supabase-config.js` — client-side Project URL + Publishable Key placeholders
- Existing OUD Markets homepage and Trading Fundamentals course page

## Step 1 — Create Supabase
Open the Supabase dashboard and create a project for OUD Markets.

## Step 2 — Run the database
Open the project's SQL Editor and run the complete `supabase-schema.sql` file.

## Step 3 — Add the two public client values
Open Project Settings / Connect and copy:
- Project URL
- Publishable key

Put them into `supabase-config.js`.

IMPORTANT: only use the public/publishable key in browser code. Never put a `service_role` or secret key in this file.

## Step 4 — Auth redirect
In Supabase Authentication URL settings, add the production site URL:
`https://oud-markets.vercel.app`

Also allow the dashboard path if your Supabase project requires an explicit redirect:
`https://oud-markets.vercel.app/dashboard.html`

## Step 5 — Stripe entitlement
The database is ready for paid enrollments, but the secure automatic Stripe → enrollment step should be implemented server-side with a Stripe webhook. Do not grant course access based only on a browser redirect or a client-side flag.

The intended production flow is:
Stripe payment → verified Stripe webhook → server inserts `enrollments` row → student signs in → dashboard sees enrollment.

## Security
Supabase Auth sessions persist in the browser by default. RLS policies restrict profile, enrollment, and progress records to the authenticated user's own rows. Keep Stripe secrets and Supabase service-role keys server-side only.
