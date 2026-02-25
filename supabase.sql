-- JollyCord Supabase schema (minimal) for cross-computer testing
-- Run in Supabase SQL Editor.

-- PROFILES
create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  handle text not null unique,
  display_name text,
  avatar_url text,
  bio text,
  accent text,
  created_at timestamptz not null default now()
);

-- FRIEND EDGES
create table if not exists public.friend_edges (
  id uuid primary key default gen_random_uuid(),
  from_user_id uuid not null references public.profiles(id) on delete cascade,
  to_user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null check (status in ('pending','accepted')) default 'pending',
  created_at timestamptz not null default now(),
  constraint friend_edges_unique_pair unique (from_user_id, to_user_id)
);

-- Direct messages + group messages share one table.
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  channel_id text not null,
  from_user_id uuid not null references public.profiles(id) on delete cascade,
  text text not null,
  created_at timestamptz not null default now()
);

-- GROUPS
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  avatar_url text,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

-- POSTS (feed)
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  text text not null,
  image_url text,
  visibility text not null check (visibility in ('friends','public','group')) default 'public',
  group_id uuid references public.groups(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

-- Helpful indexes
create index if not exists idx_messages_channel_created on public.messages(channel_id, created_at);
create index if not exists idx_posts_created on public.posts(created_at desc);
create index if not exists idx_friend_edges_to on public.friend_edges(to_user_id, status);
