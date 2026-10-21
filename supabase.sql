-- Ejecutar en Supabase: SQL Editor -> New query -> Run
-- Los usuarios (correo y contraseña) ya los guarda Supabase en auth.users.
-- Esta tabla guarda datos extra del perfil (el nombre del registro).

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text,
  email text,
  created_at timestamptz not null default now()
);

-- Seguridad (RLS): cada usuario solo ve y edita su propio perfil
alter table public.profiles enable row level security;

create policy "Ver mi perfil"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Editar mi perfil"
  on public.profiles for update
  using (auth.uid() = id);

-- Al registrarse un usuario, crea su perfil automáticamente
-- usando el "nombre" enviado en options.data de signUp()
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nombre, email)
  values (new.id, new.raw_user_meta_data ->> 'nombre', new.email);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- Tabla de productos (simple: id, nombre, precio)
-- ============================================================
create table if not exists public.productos (
  id bigint generated always as identity primary key,
  nombre text not null,
  precio numeric(10, 2) not null
);

alter table public.productos enable row level security;

-- Cualquier usuario con sesión iniciada puede ver y agregar productos
create policy "Ver productos"
  on public.productos for select
  to authenticated
  using (true);

create policy "Agregar productos"
  on public.productos for insert
  to authenticated
  with check (true);
