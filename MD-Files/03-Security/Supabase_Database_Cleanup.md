# 🗑️ Supabase Database Cleanup Guide

**Ziel**: Testdaten und fehlerhafte User-Accounts aus Supabase entfernen  
**Wichtig**: Nur in Development-Umgebung verwenden!

---

## 🔍 Problem

- Registrierung schlägt fehl mit "unknown error"
- Supabase Dashboard zeigt leere Tabellen
- User-Accounts existieren möglicherweise in Auth, aber nicht in Custom Tables

---

## 📊 Wo sind die Daten?

Supabase speichert Daten an **zwei Stellen**:

### 1. **Authentication (Auth Schema)**
- Path: `Authentication` → `Users`
- Tabelle: `auth.users`
- Enthält: Email, User-ID, Metadata (username)
- **Hier werden User bei Registrierung gespeichert**

### 2. **Public Tables (Custom Schema)**  
- Path: `Table Editor` → `public.users` / `public.save_data`
- Tabelle: `public.users`, `public.save_data`
- Enthält: Game-spezifische Daten
- **Hier sollten User-Profile und Savegames sein**

---

## 🧹 Cleanup-Schritte

### Option 1: Supabase Dashboard (GUI)

#### Schritt 1: Auth Users löschen
1. Öffne Supabase Dashboard: https://supabase.com/dashboard
2. Wähle dein Projekt: `porfficpmtayqccmpsrw`
3. Gehe zu **Authentication** → **Users**
4. Du solltest `Yagrima` und `Yagrima2` sehen (falls Registrierung erfolgreich war)
5. Klicke auf jeden User → **Delete User**
6. Bestätige die Löschung

#### Schritt 2: Public Tables prüfen
1. Gehe zu **Table Editor**
2. Prüfe Tabellen:
   - `public.users` (falls vorhanden)
   - `public.save_data`
   - `public.profiles` (falls vorhanden)
3. Falls Daten vorhanden: Zeilen markieren → **Delete**

---

### Option 2: SQL Query (Schneller)

1. Gehe zu **SQL Editor** in Supabase Dashboard
2. Führe folgende Queries aus:

#### Delete Auth Users:
```sql
-- ⚠️ WARNING: Deletes ALL users in auth schema
-- Only use in development!

DELETE FROM auth.users;
```

#### Delete Save Data:
```sql
-- Delete all save data
DELETE FROM public.save_data;
```

#### Delete User Profiles (falls Tabelle existiert):
```sql
-- Delete all user profiles
DELETE FROM public.users;
-- oder
DELETE FROM public.profiles;
```

#### Reset Auto-Increment IDs (optional):
```sql
-- Reset sequences if you want clean IDs
ALTER SEQUENCE save_data_id_seq RESTART WITH 1;
```

---

### Option 3: Complete Database Reset (Nuclear Option)

**⚠️ ACHTUNG: Löscht ALLES!**

```sql
-- Delete all data from all tables
TRUNCATE TABLE public.save_data CASCADE;
TRUNCATE TABLE public.users CASCADE;
TRUNCATE TABLE public.profiles CASCADE;

-- Delete all auth users
DELETE FROM auth.users;

-- Reset all sequences
ALTER SEQUENCE save_data_id_seq RESTART WITH 1;
```

---

## 🔍 Debugging: Warum schlägt Registrierung fehl?

### Mögliche Ursachen:

#### 1. **Email Confirmation Required**
Supabase verlangt standardmäßig Email-Bestätigung.

**Check:**
1. Gehe zu **Authentication** → **Settings** → **Auth Settings**
2. Suche: `Enable email confirmations`
3. Falls aktiviert: User muss Email bestätigen **bevor** Login

**Fix für Development:**
```
Deaktiviere "Enable email confirmations" für Testing
```

#### 2. **Username bereits vergeben**
Username wird in `user_metadata` gespeichert.

**Check:**
```sql
-- Prüfe ob Username schon existiert
SELECT 
    id, 
    email, 
    raw_user_meta_data->>'username' as username,
    created_at
FROM auth.users
WHERE raw_user_meta_data->>'username' = 'Yagrima';
```

**Fix:**
```sql
-- Lösche User mit diesem Username
DELETE FROM auth.users 
WHERE raw_user_meta_data->>'username' IN ('Yagrima', 'Yagrima2');
```

#### 3. **RLS Policies blockieren Insert**
Row Level Security könnte INSERT blockieren.

**Check:**
```sql
-- Prüfe RLS Policies
SELECT * FROM pg_policies 
WHERE tablename = 'save_data';
```

**Temporary Fix für Testing:**
```sql
-- Disable RLS für Testing (NUR Development!)
ALTER TABLE public.save_data DISABLE ROW LEVEL SECURITY;
```

**Proper Fix:**
```sql
-- Allow authenticated users to insert their own data
CREATE POLICY "Users can insert own save data" 
ON public.save_data 
FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());
```

---

## 📝 Complete Cleanup Script

Kopiere diesen SQL-Code in **SQL Editor**:

```sql
-- ========================================
-- COMPLETE SUPABASE CLEANUP
-- ⚠️ Only use in Development!
-- ========================================

-- 1. Delete all save data
DELETE FROM public.save_data;
TRUNCATE TABLE public.save_data RESTART IDENTITY CASCADE;

-- 2. Delete all user profiles (if table exists)
-- Uncomment if you have these tables:
-- DELETE FROM public.users;
-- DELETE FROM public.profiles;

-- 3. Delete all auth users
DELETE FROM auth.users;

-- 4. Verify cleanup
SELECT 'save_data' as table_name, COUNT(*) as count FROM public.save_data
UNION ALL
SELECT 'auth.users', COUNT(*) FROM auth.users;

-- Expected result: All counts should be 0

SELECT '✅ Cleanup complete!' as status;
```

---

## ✅ Nach dem Cleanup

1. **Neue Registrierung testen**:
   - Username: `TestUser1`
   - Email: `test@example.com`
   - Passwort: `Test1234!@#$Abcd` (min 14 chars, alle requirements)

2. **Browser Console öffnen** (F12):
   ```
   Suche nach:
   - "📝 Registering user: test@example.com"
   - "📡 HTTP Response Code: 200"
   - "✅ Authentication successful"
   ```

3. **Supabase Dashboard prüfen**:
   - `Authentication` → `Users` → Neuer User sollte erscheinen
   - `Table Editor` → `save_data` → (noch leer, wird beim ersten Save befüllt)

---

## 🔧 Email Confirmation deaktivieren (für Testing)

1. Gehe zu **Authentication** → **Settings**
2. Unter **Auth Settings**:
   - ❌ Deaktiviere `Enable email confirmations`
3. Unter **Email Templates**:
   - Du kannst Custom Templates setzen, aber nicht nötig für Testing

**Nach dieser Änderung:**
- User kann sich sofort nach Registrierung einloggen
- Keine Email-Bestätigung nötig

---

## 🐛 Debugging Checklist

Wenn Registrierung immer noch fehlschlägt:

- [ ] Browser Console öffnen (F12)
- [ ] Supabase Logs prüfen: `Logs` → `API Logs`
- [ ] Response Body prüfen (wird jetzt im Console geloggt)
- [ ] Email Confirmation deaktiviert?
- [ ] RLS Policies korrekt?
- [ ] Auth Users wirklich gelöscht?

---

## 📚 Verwandte Dokumente

- [Supabase_Setup.md](../02-Setup/Supabase_Setup.md) - Initial Setup
- [Auth_Screen_Improvements.md](../04-Features/Auth_Screen_Improvements.md) - Auth UX
- [Server_Validation.md](Server_Validation.md) - SQL Triggers

---

**Status**: Development Guide  
**Use Case**: Testing & Debugging  
**⚠️ Warning**: Never use in Production!
