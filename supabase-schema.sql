-- ============================================================
-- Kelime Rotası — Supabase veritabanı şeması
-- ============================================================
-- Bu dosyanın TAMAMINI Supabase projenizde SQL Editor'e yapıştırıp
-- "Run" ile bir kere çalıştırmanız yeterli. Kurulum rehberinde
-- (KURULUM-REHBERI.md) bu adım ayrıntılı anlatılıyor.
-- ============================================================

-- ---------- Tablolar ----------

-- Öğretmen profilleri (Supabase Auth kullanıcılarıyla 1:1 eşleşir)
create table public.teachers (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text,
  created_at timestamptz not null default now()
);

-- Sınıflar — her sınıfın kendine özgü, öğrencilerin gireceği bir kodu var
create table public.classes (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references public.teachers(id) on delete cascade,
  name text not null,
  code text not null unique,
  created_at timestamptz not null default now()
);

-- Öğrenciler — hesapsız, anonim girişle oluşur (id = Supabase'in ürettiği
-- anonim kullanıcı id'si). Sınıf koduna bağlıdır.
create table public.students (
  id uuid primary key references auth.users(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  name text not null,
  points integer not null default 0,
  streak integer not null default 0,
  last_day date,
  badges jsonb not null default '{}'::jsonb,
  ever_perfect_quiz boolean not null default false,
  ever_comeback boolean not null default false,
  created_at timestamptz not null default now(),
  last_active timestamptz not null default now()
);

-- Kelime bazında ilerleme — her öğrenci x kelime bir satır
create table public.word_progress (
  student_id uuid not null references public.students(id) on delete cascade,
  word_key text not null,               -- örn. "3::fry"  (unite id :: kelime)
  status text not null default 'new',   -- 'new' | 'review' | 'known'
  wrong integer not null default 0,
  consecutive integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (student_id, word_key)
);

-- ---------- Otomasyon: sınıf kodu üretimi ----------

create or replace function public.generate_class_code() returns text
language plpgsql as $$
declare
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- karışabilecek 0/O, 1/I çıkarıldı
  code text := '';
  i int;
begin
  for i in 1..6 loop
    code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  end loop;
  return code;
end;
$$;

create or replace function public.set_class_code() returns trigger
language plpgsql as $$
declare
  candidate text;
  tries int := 0;
begin
  if new.code is null or new.code = '' then
    loop
      candidate := public.generate_class_code();
      tries := tries + 1;
      exit when not exists (select 1 from public.classes where code = candidate) or tries > 20;
    end loop;
    new.code := candidate;
  else
    new.code := upper(new.code);
  end if;
  return new;
end;
$$;

create trigger trg_set_class_code
  before insert on public.classes
  for each row execute function public.set_class_code();

-- ---------- Otomasyon: öğretmen kaydı olunca profil satırı aç ----------
-- Not: anonim öğrenci girişleri de auth.users'a satır ekler ama e-postası
-- olmaz — bu yüzden sadece e-postalı (gerçek) kayıtlar öğretmen sayılır.

create or replace function public.handle_new_teacher() returns trigger
language plpgsql security definer as $$
begin
  if new.email is not null then
    insert into public.teachers (id, name, email)
    values (new.id, coalesce(new.raw_user_meta_data->>'name', ''), new.email)
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_teacher();

-- ---------- Güvenli sınıf-kodu arama (öğrenci katılma akışı) ----------
-- classes tablosunun kendisini herkese açmadan, sadece kod doğruysa
-- sınıfın id + adını döndüren dar bir fonksiyon.

create or replace function public.find_class_by_code(p_code text)
returns table(class_id uuid, class_name text)
language sql security definer as $$
  select id, name from public.classes where code = upper(p_code);
$$;

grant execute on function public.find_class_by_code(text) to anon, authenticated;

-- ---------- Temel erişim izinleri ----------
-- RLS politikaları TEK BAŞINA yeterli değil: PostgREST, satır bazlı
-- kuralları değerlendirmeden önce "authenticated" rolünün o tabloya en
-- azından temel bir GRANT'i olup olmadığına bakıyor. Bu satırlar
-- olmadan tüm istekler RLS'e hiç uğramadan 403 "permission denied"
-- ile geri dönüyor (aşağıdaki policy'ler hangi SATIRLARA erişileceğini,
-- bu GRANT'ler ise tabloya erişilip erişilemeyeceğini belirler).
grant select, insert, update, delete on public.teachers to authenticated;
grant select, insert, update, delete on public.classes to authenticated;
grant select, insert, update, delete on public.students to authenticated;
grant select, insert, update, delete on public.word_progress to authenticated;

-- ---------- Row Level Security ----------

alter table public.teachers enable row level security;
alter table public.classes enable row level security;
alter table public.students enable row level security;
alter table public.word_progress enable row level security;

-- teachers: sadece kendi profilini görebilir/güncelleyebilir
create policy "teachers_select_own" on public.teachers
  for select using (auth.uid() = id);
create policy "teachers_update_own" on public.teachers
  for update using (auth.uid() = id);

-- classes: öğretmen sadece kendi sınıflarını yönetir
create policy "classes_select_own" on public.classes
  for select using (auth.uid() = teacher_id);
create policy "classes_insert_own" on public.classes
  for insert with check (auth.uid() = teacher_id);
create policy "classes_update_own" on public.classes
  for update using (auth.uid() = teacher_id);
create policy "classes_delete_own" on public.classes
  for delete using (auth.uid() = teacher_id);

-- students: öğrenci kendi kaydını okur/günceller/oluşturur
create policy "students_select_own" on public.students
  for select using (auth.uid() = id);
create policy "students_insert_own" on public.students
  for insert with check (auth.uid() = id);
create policy "students_update_own" on public.students
  for update using (auth.uid() = id);
-- öğretmen kendi sınıfındaki öğrencileri okuyabilir (salt okunur)
create policy "students_select_by_teacher" on public.students
  for select using (
    exists (select 1 from public.classes c where c.id = students.class_id and c.teacher_id = auth.uid())
  );

-- word_progress: öğrenci kendi ilerlemesini okur/yazar
create policy "wp_select_own" on public.word_progress
  for select using (auth.uid() = student_id);
create policy "wp_insert_own" on public.word_progress
  for insert with check (auth.uid() = student_id);
create policy "wp_update_own" on public.word_progress
  for update using (auth.uid() = student_id);
-- öğretmen kendi öğrencilerinin ilerlemesini okuyabilir (salt okunur)
create policy "wp_select_by_teacher" on public.word_progress
  for select using (
    exists (
      select 1 from public.students s
      join public.classes c on c.id = s.class_id
      where s.id = word_progress.student_id and c.teacher_id = auth.uid()
    )
  );

-- ============================================================
-- Bitti. Şimdi Supabase panelinde Authentication > Providers'dan
-- "Anonymous Sign-Ins" seçeneğini açmayı unutmayın — öğrenciler
-- e-posta olmadan bu sayede giriş yapabiliyor.
-- ============================================================
