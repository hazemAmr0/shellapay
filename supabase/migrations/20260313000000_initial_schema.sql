-- Migration: 001_initial_schema
-- Description: Creates initial tables, RLS policies, indexes, and storage buckets for ShellaPay

-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-------------------------------------------------------------------------------
-- 1. USERS TABLE
-------------------------------------------------------------------------------
create table public.users (
  id uuid references auth.users not null primary key,
  full_name text not null,
  phone_number text not null unique,
  avatar_url text,
  fcm_token text,
  phone_hash text not null unique,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS
alter table public.users enable row level security;
create policy "Users can read own profile" on public.users for select using (auth.uid() = id);
create policy "Users can update own profile" on public.users for update using (auth.uid() = id);

-- Indexes
create index idx_users_phone_hash on public.users (phone_hash);

-------------------------------------------------------------------------------
-- 2. CONTACTS TABLE
-------------------------------------------------------------------------------
create table public.contacts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  friend_name text not null check (char_length(friend_name) between 1 and 100),
  phone_number text,
  registered_user_id uuid references public.users(id),
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS
alter table public.contacts enable row level security;
create policy "Users can CRUD own contacts" on public.contacts for all using (auth.uid() = user_id);

-- Indexes
create index idx_contacts_user_id on public.contacts (user_id);

-------------------------------------------------------------------------------
-- 3. GROUPS TABLE
-------------------------------------------------------------------------------
create table public.groups (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  group_name text not null check (char_length(group_name) between 1 and 50),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, group_name)
);

-- RLS
alter table public.groups enable row level security;
create policy "Users can CRUD own groups" on public.groups for all using (auth.uid() = user_id);

-------------------------------------------------------------------------------
-- 4. GROUP MEMBERS TABLE
-------------------------------------------------------------------------------
create table public.group_members (
  id uuid default uuid_generate_v4() primary key,
  group_id uuid references public.groups(id) on delete cascade not null,
  contact_id uuid references public.contacts(id) on delete cascade not null,
  unique (group_id, contact_id)
);

-- RLS
alter table public.group_members enable row level security;
create policy "Users can CRUD own group members" on public.group_members for all 
using (
  exists (
    select 1 from public.groups
    where groups.id = group_members.group_id
    and groups.user_id = auth.uid()
  )
);

-------------------------------------------------------------------------------
-- 5. OUTINGS TABLE
-------------------------------------------------------------------------------
create table public.outings (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  place_name text,
  total_amount decimal(12,2) not null check (total_amount >= 0),
  tax_amount decimal(12,2) default 0 not null check (tax_amount >= 0),
  service_amount decimal(12,2) default 0 not null check (service_amount >= 0),
  receipt_image_url text,
  status text default 'draft' not null check (status in ('draft', 'completed', 'shared')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS
alter table public.outings enable row level security;
create policy "Users can CRUD own outings" on public.outings for all using (auth.uid() = user_id);

-- Indexes
create index idx_outings_user_id_created on public.outings (user_id, created_at desc);

-------------------------------------------------------------------------------
-- 6. OUTING PARTICIPANTS TABLE
-------------------------------------------------------------------------------
create table public.outing_participants (
  id uuid default uuid_generate_v4() primary key,
  outing_id uuid references public.outings(id) on delete cascade not null,
  contact_id uuid references public.contacts(id) not null,
  total_owed decimal(12,2) default 0 not null,
  unique (outing_id, contact_id)
);

-- RLS
alter table public.outing_participants enable row level security;
create policy "Users can CRUD own outing participants" on public.outing_participants for all 
using (
  exists (
    select 1 from public.outings
    where outings.id = outing_participants.outing_id
    and outings.user_id = auth.uid()
  )
);

-------------------------------------------------------------------------------
-- 7. RECEIPT ITEMS TABLE
-------------------------------------------------------------------------------
create table public.receipt_items (
  id uuid default uuid_generate_v4() primary key,
  outing_id uuid references public.outings(id) on delete cascade not null,
  item_name text not null check (char_length(item_name) between 1 and 200),
  price decimal(12,2) not null check (price >= 0),
  sort_order integer default 0 not null
);

-- RLS
alter table public.receipt_items enable row level security;
create policy "Users can CRUD own receipt items" on public.receipt_items for all 
using (
  exists (
    select 1 from public.outings
    where outings.id = receipt_items.outing_id
    and outings.user_id = auth.uid()
  )
);

-- Indexes
create index idx_items_outing_id on public.receipt_items (outing_id);

-------------------------------------------------------------------------------
-- 8. ITEM SPLITS TABLE
-------------------------------------------------------------------------------
create table public.item_splits (
  id uuid default uuid_generate_v4() primary key,
  item_id uuid references public.receipt_items(id) on delete cascade not null,
  contact_id uuid references public.contacts(id) not null,
  split_percentage decimal(5,2) default 100.00 not null check (split_percentage between 0.01 and 100.00),
  split_amount decimal(12,2) not null,
  unique (item_id, contact_id)
);

-- RLS
alter table public.item_splits enable row level security;
create policy "Users can CRUD own item splits" on public.item_splits for all 
using (
  exists (
    select 1 from public.receipt_items
    join public.outings on outings.id = receipt_items.outing_id
    where receipt_items.id = item_splits.item_id
    and outings.user_id = auth.uid()
  )
);

-- Indexes
create index idx_splits_item_id on public.item_splits (item_id);

-------------------------------------------------------------------------------
-- 9. DEBTS TABLE
-------------------------------------------------------------------------------
create table public.debts (
  id uuid default uuid_generate_v4() primary key,
  outing_id uuid references public.outings(id) on delete cascade not null,
  debtor_contact_id uuid references public.contacts(id) not null,
  creditor_user_id uuid references public.users(id) not null,
  amount decimal(12,2) not null,
  is_paid boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS
alter table public.debts enable row level security;
create policy "Users can CRUD own debts as creditor" on public.debts for all using (auth.uid() = creditor_user_id);

-- Indexes
create index idx_debts_outing_id on public.debts (outing_id);
create index idx_debts_creditor on public.debts (creditor_user_id, is_paid);


-------------------------------------------------------------------------------
-- STORAGE BUCKETS
-------------------------------------------------------------------------------
-- Setup requires superuser (usually done via dashboard or seed), mapped here for completeness
insert into storage.buckets (id, name, public) 
values ('avatars', 'avatars', true), ('receipts', 'receipts', false)
on conflict (id) do nothing;

create policy "Avatars are public" on storage.objects for select using (bucket_id = 'avatars');
create policy "Users can upload own avatar" on storage.objects for insert with check (bucket_id = 'avatars' and owner = auth.uid());
create policy "Users can update own avatar" on storage.objects for update using (bucket_id = 'avatars' and owner = auth.uid());

create policy "Users can read own receipts" on storage.objects for select using (bucket_id = 'receipts' and owner = auth.uid());
create policy "Users can insert own receipts" on storage.objects for insert with check (bucket_id = 'receipts' and owner = auth.uid());
