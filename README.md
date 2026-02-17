# Calda Challenge (Supabase)

Supabase backend setup for a simple e-commerce app:
- profiles linked to `auth.users`
- items catalogue
- orders + order_items
- item change history (CRUD audit via trigger)
- order aggregator view (`v_order_aggregates`)
- cron job that archives totals and deletes orders older than 7 days
- edge function to create an order

## Requirements
- Docker Desktop
- Node.js (recommended)
- Supabase CLI

## Local setup

### Start Supabase
    supabase start
