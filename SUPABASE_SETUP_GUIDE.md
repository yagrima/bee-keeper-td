# 🚀 Supabase Setup Guide für BeeKeeperTD

## 📋 Overview

Diese Anleitung führt dich durch das Setup von Supabase als Backend für BeeKeeperTD Web App.

**Ziel**: Account-basiertes Session-Tracking mit Cloud-Sync für Spielfortschritt

---

## ✅ Step 1: Supabase Account & Project erstellen

### 1.1 Account erstellen
1. Gehe zu: https://supabase.com
2. Klicke auf "Start your project"
3. Registriere dich mit:
   - GitHub Account (empfohlen) ODER
   - Email + Password

### 1.2 Neues Projekt erstellen
1. Klicke auf "New Project"
2. Wähle/Erstelle eine Organization
3. Projekt-Einstellungen:
   - **Name**: `beekeepertd`
   - **Database Password**: [Starkes Passwort generieren und sicher speichern!]
   - **Region**: Wähle die nächstgelegene Region (z.B. "Europe West (Frankfurt)")
   - **Pricing Plan**: Free (für Entwicklung)
4. Klicke auf "Create new project"
5. ⏱️ Warte ~2 Minuten bis das Projekt erstellt ist

### 1.3 API Keys speichern
Nach der Projekterstellung findest du auf der Projektseite:

**Settings → API**

Kopiere und speichere sicher:
- **Project URL**: `https://[dein-projekt].supabase.co`
- **anon public key**: `eyJhbGc...` (langer String)
- **service_role key**: `eyJhbGc...` (GEHEIM! Nur für Server-Side)

⚠️ **Wichtig**: Speichere diese Keys in einer lokalen `.env` Datei oder Passwort-Manager!

---

## ✅ Step 2: Database Schema einrichten

### 2.1 Save Data Tabelle erstellen

1. Gehe zu: **SQL Editor** (linkes Menü)
2. Klicke auf "New Query"
3. Kopiere und füge folgenden SQL-Code ein:

```sql
-- ============================================
-- BeeKeeperTD Save Data Table
-- ============================================

-- Create save_data table
CREATE TABLE IF NOT EXISTS public.save_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_save_data_user_id ON public.save_data(user_id);
CREATE INDEX IF NOT EXISTS idx_save_data_updated_at ON public.save_data(updated_at DESC);

-- Enable Row Level Security
ALTER TABLE public.save_data ENABLE ROW LEVEL SECURITY;

-- Create policies for Row Level Security
-- Users can only view their own save data
CREATE POLICY "Users can view own save data"
  ON public.save_data
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own save data
CREATE POLICY "Users can insert own save data"
  ON public.save_data
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own save data
CREATE POLICY "Users can update own save data"
  ON public.save_data
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own save data
CREATE POLICY "Users can delete own save data"
  ON public.save_data
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- Trigger for automatic updated_at timestamp
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_save_data_updated_at
  BEFORE UPDATE ON public.save_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Grant permissions
-- ============================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.save_data TO authenticated;
GRANT SELECT ON public.save_data TO anon;
```

4. Klicke auf **"Run"** (oder `Ctrl+Enter`)
5. ✅ Erwarte: "Success. No rows returned"

### 2.2 Tabelle verifizieren

1. Gehe zu: **Table Editor** (linkes Menü)
2. Wähle `save_data` aus der Liste
3. ✅ Du solltest sehen:
   - Spalten: `id`, `user_id`, `data`, `version`, `created_at`, `updated_at`
   - Policies: 4 policies (view, insert, update, delete)

---

## ✅ Step 3: Authentication konfigurieren

### 3.1 Email Auth aktivieren

1. Gehe zu: **Authentication → Providers** (linkes Menü)
2. **Email Provider** ist standardmäßig aktiviert ✅
3. Optional: Email Templates anpassen
   - Gehe zu **Authentication → Email Templates**
   - Passe "Confirm Signup" Template an (später)

### 3.2 Auth Settings anpassen

1. Gehe zu: **Authentication → Settings**
2. Empfohlene Einstellungen:
   - **Enable Email Confirmations**: ✅ ON (für Production)
     - ⚠️ Für Entwicklung: OFF (schnelleres Testing)
   - **Minimum Password Length**: 8
   - **Session Timeout**: 604800 (7 Tage)
   - **JWT Expiry**: 3600 (1 Stunde)
   - **Refresh Token Rotation**: ✅ ON
   - **Enable Custom SMTP**: OFF (nutze Supabase SMTP für Start)

3. Klicke auf **"Save"**

### 3.3 URL Configuration

1. Gehe zu: **Authentication → URL Configuration**
2. **Site URL**: `http://localhost:8060` (für lokale Entwicklung)
3. **Redirect URLs**: 
   - `http://localhost:8060`
   - `http://localhost:8060/**`
   - (Später: Deine Production URL hinzufügen)
4. Klicke auf **"Save"**

---

## ✅ Step 4: API Testing mit Postman/Insomnia

### 4.1 Test-Collection erstellen

#### Test 1: User Registration (Signup)

**Endpoint**: `POST https://[dein-projekt].supabase.co/auth/v1/signup`

**Headers**:
```
Content-Type: application/json
apikey: [dein-anon-public-key]
```

**Body** (JSON):
```json
{
  "email": "test@beekeepertd.com",
  "password": "TestPassword123!",
  "data": {
    "username": "TestPlayer"
  }
}
```

**Expected Response** (200):
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "user": {
    "id": "...",
    "email": "test@beekeepertd.com",
    "user_metadata": {
      "username": "TestPlayer"
    }
  }
}
```

#### Test 2: User Login

**Endpoint**: `POST https://[dein-projekt].supabase.co/auth/v1/token?grant_type=password`

**Headers**:
```
Content-Type: application/json
apikey: [dein-anon-public-key]
```

**Body** (JSON):
```json
{
  "email": "test@beekeepertd.com",
  "password": "TestPassword123!"
}
```

**Expected Response** (200):
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "user": { ... }
}
```

#### Test 3: Create Save Data

**Endpoint**: `POST https://[dein-projekt].supabase.co/rest/v1/save_data`

**Headers**:
```
Content-Type: application/json
apikey: [dein-anon-public-key]
Authorization: Bearer [access_token from login]
Prefer: return=representation
```

**Body** (JSON):
```json
{
  "data": {
    "current_wave": 1,
    "player_health": 20,
    "honey": 50,
    "placed_towers": [],
    "speed_mode": 0
  },
  "version": 1
}
```

**Expected Response** (201):
```json
[
  {
    "id": "...",
    "user_id": "...",
    "data": { ... },
    "version": 1,
    "created_at": "...",
    "updated_at": "..."
  }
]
```

#### Test 4: Get Save Data

**Endpoint**: `GET https://[dein-projekt].supabase.co/rest/v1/save_data?select=*`

**Headers**:
```
Content-Type: application/json
apikey: [dein-anon-public-key]
Authorization: Bearer [access_token]
```

**Expected Response** (200):
```json
[
  {
    "id": "...",
    "user_id": "...",
    "data": { ... },
    "version": 1,
    "created_at": "...",
    "updated_at": "..."
  }
]
```

#### Test 5: Update Save Data

**Endpoint**: `PATCH https://[dein-projekt].supabase.co/rest/v1/save_data?user_id=eq.[user_id]`

**Headers**:
```
Content-Type: application/json
apikey: [dein-anon-public-key]
Authorization: Bearer [access_token]
Prefer: return=representation
```

**Body** (JSON):
```json
{
  "data": {
    "current_wave": 3,
    "player_health": 15,
    "honey": 120,
    "placed_towers": [
      {"type": "stinger", "position": {"x": 144, "y": 272}}
    ],
    "speed_mode": 1
  },
  "version": 2
}
```

**Expected Response** (200):
```json
[
  {
    "id": "...",
    "user_id": "...",
    "data": { ... },
    "version": 2,
    "updated_at": "..."
  }
]
```

---

## ✅ Step 5: Environment Variables Setup

Erstelle eine `.env` Datei im Projekt-Root:

```bash
# Supabase Configuration
SUPABASE_URL=https://[dein-projekt].supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...  # NUR für Server-Side!

# Development Settings
DEV_MODE=true
```

⚠️ **Wichtig**: Füge `.env` zu `.gitignore` hinzu!

---

## ✅ Step 6: Row Level Security (RLS) Policies Testen

### 6.1 Test mit SQL Editor

```sql
-- Test 1: Verifiziere dass Policies aktiv sind
SELECT * FROM public.save_data;
-- Expected: Fehler wenn nicht authentifiziert

-- Test 2: Teste als authentifizierter User
-- (Nutze Postman/Insomnia für reale Tests)
```

### 6.2 RLS Policy Details anzeigen

```sql
-- Zeige alle Policies für save_data
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual, 
  with_check
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'save_data';
```

**Expected Output**: 4 policies (SELECT, INSERT, UPDATE, DELETE)

---

## 🎉 Setup Complete!

### ✅ Checkliste

- [x] Supabase Account erstellt
- [x] Projekt erstellt und konfiguriert
- [x] API Keys gespeichert
- [x] `save_data` Tabelle erstellt
- [x] Row Level Security (RLS) aktiviert
- [x] Policies konfiguriert
- [x] Authentication konfiguriert
- [x] API Tests durchgeführt (Postman/Insomnia)
- [x] Environment Variables setup

### 📊 Nächste Schritte

Weiter zu **Sprint 2: Frontend Integration**
- Erstelle `SupabaseClient.gd` Autoload
- Implementiere Auth UI im Main Menu
- Integriere Session Management

---

## 🔧 Troubleshooting

### Problem: "JWT expired" Error
**Lösung**: Token ist abgelaufen. Nutze Refresh Token zum Erneuern.

### Problem: "Row Level Security Policy Violation"
**Lösung**: 
1. Überprüfe ob User authentifiziert ist
2. Verifiziere dass `auth.uid()` korrekt ist
3. Prüfe Policies in SQL Editor

### Problem: "CORS Error" im Browser
**Lösung**: 
1. Gehe zu **Settings → API → CORS**
2. Füge deine Domain hinzu (z.B. `localhost:8060`)

### Problem: Email Confirmation nicht erhalten
**Lösung**:
1. Prüfe Spam-Ordner
2. Für Development: Deaktiviere "Enable Email Confirmations"
3. Gehe zu **Authentication → Users** und bestätige manuell

---

**Dokument Version**: 1.0  
**Letzte Aktualisierung**: 2024-12-30  
**Status**: Active  
