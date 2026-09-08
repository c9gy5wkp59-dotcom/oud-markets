# OUD Markets production wiring

## Customer flow
Course page -> Stripe Checkout -> webhook -> course entitlement -> Supabase account -> student dashboard.

## Backend
Use Stripe Checkout on the server. On a verified successful checkout webhook, create/activate an entitlement for the customer in Supabase.

## Suggested tables
- profiles
- courses
- lessons
- enrollments
- lesson_progress
- purchases

## Security
Enable Supabase Row Level Security on exposed tables and write explicit policies for each operation. Keep Stripe secret keys and Supabase server/secret keys on the server only.

## Current demo
`course-trading-fundamentals.html` is the polished product page. Its Buy Now button is intentionally a placeholder until Stripe credentials and a server endpoint are connected.

References:
- Stripe Checkout: https://docs.stripe.com/payments/checkout
- Supabase Auth: https://supabase.com/docs/guides/auth
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
