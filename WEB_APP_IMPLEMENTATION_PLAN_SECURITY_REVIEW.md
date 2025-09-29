# 🔒 BeeKeeperTD Web App Implementation Plan - Security Review

## 📋 Executive Summary

**Datum**: 2025-09-29  
**Status**: Ready for Security Expert Review  
**Ziel**: Account-basiertes Session-Tracking mit Cloud-Sync für Spielfortschritt

---

## 🛡️ Sicherheitsarchitektur Übersicht

### **Frontend**: Godot Web Export (Client-Side)
- **Plattform**: JavaScript/WebAssembly im Browser
- **Daten-Storage**: LocalStorage (verschlüsselt) + IndexedDB
- **Kommunikation**: HTTPS-only zu Supabase Backend

### **Backend**: Supabase (Managed Service)
- **Hosting**: AWS (Frankfurt/EU Region)
- **Database**: PostgreSQL mit Row Level Security (RLS)
- **Auth**: Built-in Supabase Auth (JWT-based)
- **API**: Auto-generated REST API mit RLS enforcement

---

## 🔐 Sprint 1: Backend Setup - Sicherheitsanalyse

### **1.1 Supabase Projekt Setup**

#### ✅ **Sichere Komponenten:**
- **Managed Service**: Supabase handhabt Server-Infrastruktur
- **EU-Region**: DSGVO-konforme Datenhaltung (Frankfurt/EU)
- **Automatische Backups**: Daily backups included
- **SSL/TLS**: Automatic HTTPS enforcement

#### ⚠️ **Sicherheitsbedenken:**
- **Database Password**: Muss stark sein und sicher gespeichert werden
  - **Mitigation**: Password Manager, min. 20 Zeichen, Sonderzeichen
  - **Wichtig**: Nie in Code oder Git committen!

#### 🔧 **Empfohlene Maßnahmen:**
1. Password Manager nutzen (1Password, Bitwarden)
2. Database Password min. 20 Zeichen
3. Backup-Strategie dokumentieren
4. Region-Lock auf EU (DSGVO)

---

### **1.2 Database Schema & Row Level Security**

#### ✅ **Sichere Design-Entscheidungen:**

##### **Row Level Security (RLS) Policies:**
```sql
-- ✅ SICHER: User kann nur eigene Daten sehen
CREATE POLICY "Users can view own save data"
  ON public.save_data FOR SELECT
  USING (auth.uid() = user_id);

-- ✅ SICHER: User kann nur eigene Daten erstellen
CREATE POLICY "Users can insert own save data"
  ON public.save_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ✅ SICHER: User kann nur eigene Daten ändern
CREATE POLICY "Users can update own save data"
  ON public.save_data FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

##### **Sichere Datentypen:**
- `user_id UUID`: Nicht-guessbar, referenziert auth.users
- `data JSONB`: Flexible Speicherung, aber erfordert Input Validation
- `ON DELETE CASCADE`: Automatische Löschung bei User-Deletion (DSGVO)

#### ⚠️ **Sicherheitsbedenken:**

##### **1. JSONB Injection Risk**
**Problem**: JSONB-Spalte akzeptiert beliebigen JSON-Content
- Potenzial für oversized payloads (DoS)
- Potenzial für malformed JSON
- Keine Schema-Validierung

**Mitigation**:
```sql
-- Füge Constraints hinzu für Datengröße
ALTER TABLE public.save_data 
  ADD CONSTRAINT save_data_size_limit 
  CHECK (pg_column_size(data) < 1048576); -- Max 1MB

-- Füge Validierungs-Trigger hinzu
CREATE OR REPLACE FUNCTION validate_save_data()
RETURNS TRIGGER AS $$
BEGIN
  -- Prüfe auf erforderliche Felder
  IF NOT (NEW.data ? 'current_wave' AND NEW.data ? 'player_health') THEN
    RAISE EXCEPTION 'Invalid save data structure';
  END IF;
  
  -- Prüfe Datentypen
  IF NOT (jsonb_typeof(NEW.data->'current_wave') = 'number') THEN
    RAISE EXCEPTION 'Invalid data type for current_wave';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_save_data_trigger
  BEFORE INSERT OR UPDATE ON public.save_data
  FOR EACH ROW
  EXECUTE FUNCTION validate_save_data();
```

##### **2. Rate Limiting**
**Problem**: Keine eingebaute Rate-Limiting im Schema

**Mitigation**:
```sql
-- Füge last_updated_at Constraint hinzu (prevent spam)
CREATE OR REPLACE FUNCTION check_update_frequency()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.updated_at IS NOT NULL AND 
     (NOW() - OLD.updated_at) < INTERVAL '1 second' THEN
    RAISE EXCEPTION 'Updates too frequent';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_update_frequency_trigger
  BEFORE UPDATE ON public.save_data
  FOR EACH ROW
  EXECUTE FUNCTION check_update_frequency();
```

#### 🔧 **Empfohlene Zusatz-Maßnahmen:**
1. ✅ Implementiere Data Size Constraint (1MB Limit)
2. ✅ Implementiere Save Data Validierung (Schema Check)
3. ✅ Implementiere Update Rate Limiting (1 Update/Sekunde)
4. ✅ Füge Audit-Log hinzu für alle Änderungen
5. ⚠️ Überlege Version-History für Rollback bei Corruption

---

### **1.3 Authentication Configuration**

#### ✅ **Sichere Default-Settings:**
- **JWT Expiry**: 3600s (1 Stunde) - ✅ Gut
- **Refresh Token Rotation**: ON - ✅ Sehr gut
- **Session Timeout**: 7 Tage - ⚠️ Prüfen
- **Password Min Length**: 8 - ⚠️ Zu kurz

#### ⚠️ **Sicherheitsbedenken:**

##### **1. Password Policy**
**Problem**: 8 Zeichen sind zu schwach für 2025

**Empfehlung**:
- **Min Length**: 12 Zeichen (besser: 14)
- **Complexity**: Min. 1 Groß-, 1 Klein-, 1 Zahl, 1 Sonderzeichen
- **Common Passwords**: Blocken (Have I Been Pwned Integration)

##### **2. Email Confirmation**
**Problem**: Ohne Email-Confirmation können Fake-Accounts erstellt werden

**Empfehlung für Production**:
- ✅ Enable Email Confirmations: ON
- ✅ Double-Opt-In für Registrierung
- ⚠️ Rate Limiting für Registrierungen (Max 5/IP/Stunde)

##### **3. Session Timeout**
**Problem**: 7 Tage Session ist lang für ein Spiel

**Empfehlung**:
- ✅ Session Timeout: 24 Stunden (statt 7 Tage)
- ✅ "Remember Me" Feature optional mit längerer Session
- ✅ Automatic Token Refresh bei Aktivität

##### **4. Brute Force Protection**
**Problem**: Supabase hat eingebauten Schutz, aber konfigurierbar

**Empfehlung**:
```
Max Failed Login Attempts: 5
Lockout Duration: 15 Minuten
Progressive Delays: 1s, 2s, 4s, 8s, 16s
```

#### 🔧 **Empfohlene Auth-Settings:**

```yaml
# Supabase Auth Configuration (Production)
Auth Settings:
  Password Policy:
    Min Length: 12
    Require Uppercase: true
    Require Lowercase: true
    Require Numbers: true
    Require Special: true
  
  Email:
    Enable Confirmations: true
    Confirmation Token Expiry: 24 hours
    
  Sessions:
    JWT Expiry: 3600 (1 hour)
    Refresh Token Expiry: 86400 (24 hours - nicht 7 Tage!)
    Refresh Token Rotation: true
    
  Security:
    Max Password Attempts: 5
    Lockout Duration: 900 (15 min)
    Rate Limiting: true
```

---

### **1.4 API Key Management**

#### ⚠️ **KRITISCHE SICHERHEITSBEDENKEN:**

##### **1. Anon Key Exposure**
**Problem**: Anon Key wird im Frontend-Code verwendet
- **Risiko**: Anon Key ist öffentlich sichtbar (Web Inspector)
- **Aber**: Das ist OK! Anon Key ist designed für Client-Side
- **Schutz**: Row Level Security (RLS) schützt Daten

**Wichtig**:
- ✅ Anon Key darf im Frontend verwendet werden
- ❌ Service Role Key **NIEMALS** im Frontend!
- ✅ RLS Policies **MÜSSEN** korrekt sein

##### **2. Service Role Key**
**Problem**: Service Role Key bypassed RLS

**KRITISCH**:
```
❌ NIEMALS Service Role Key im Frontend/Git
❌ NIEMALS Service Role Key in Environment Variables (Frontend)
❌ NIEMALS Service Role Key in Client-Side Code
✅ NUR für Server-Side Operations (wenn nötig)
✅ NUR in Backend Environment (nicht Godot)
```

#### 🔧 **Empfohlene Key-Management-Strategie:**

1. **Frontend (Godot)**:
   ```gdscript
   # ✅ OK: Anon Key im Frontend
   const SUPABASE_URL = "https://xxx.supabase.co"
   const SUPABASE_ANON_KEY = "eyJhbGc..."
   ```

2. **Environment Variables** (Development):
   ```bash
   # .env (NIEMALS in Git!)
   SUPABASE_URL=https://xxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc...
   # SUPABASE_SERVICE_ROLE_KEY - NICHT für Frontend!
   ```

3. **Production** (Netlify/Vercel):
   - Environment Variables in Dashboard setzen
   - Build-Time Injection
   - Niemals hardcoded in Code

---

## 🔐 Sprint 2: Frontend Integration - Sicherheitsanalyse

### **2.1 SupabaseClient.gd Implementation**

#### ⚠️ **Sicherheitsbedenken:**

##### **1. Token Storage**
**Problem**: Wo speichern wir JWT Tokens im Browser?

**Optionen**:
1. **LocalStorage** (Standard)
   - ✅ Persistent über Sessions
   - ⚠️ Anfällig für XSS (Cross-Site Scripting)
   - ⚠️ JavaScript hat vollen Zugriff

2. **SessionStorage**
   - ✅ Besser gegen XSS (Tab-Scope)
   - ❌ Geht verloren beim Tab-Close

3. **Encrypted LocalStorage**
   - ✅ Zusätzliche Sicherheit
   - ⚠️ Key muss auch gespeichert werden (Chicken-Egg Problem)

**Empfehlung**:
```gdscript
# SupabaseClient.gd
const TOKEN_KEY = "bktd_auth_token"
const REFRESH_KEY = "bktd_refresh_token"

func store_tokens_secure(access_token: String, refresh_token: String):
    # Option 1: Simple (für MVP)
    JavaScriptBridge.eval("localStorage.setItem('%s', '%s')" % [TOKEN_KEY, access_token])
    JavaScriptBridge.eval("sessionStorage.setItem('%s', '%s')" % [REFRESH_KEY, refresh_token])
    
    # Option 2: Encrypted (für Production) - TODO
    # var encrypted_token = encrypt_token(access_token)
    # JavaScriptBridge.eval("localStorage.setItem('%s', '%s')" % [TOKEN_KEY, encrypted_token])

func clear_tokens():
    # WICHTIG: Immer beide löschen beim Logout!
    JavaScriptBridge.eval("localStorage.removeItem('%s')" % TOKEN_KEY)
    JavaScriptBridge.eval("sessionStorage.removeItem('%s')" % REFRESH_KEY)
```

##### **2. Password Handling**
**Problem**: Passwort-Übertragung und -Handling

**KRITISCH**:
```gdscript
# ❌ NIEMALS: Password in Logs
print("Login with password: ", password)  # NIEMALS!

# ❌ NIEMALS: Password in lokalen Variablen speichern
var stored_password = password  # NIEMALS!

# ✅ RICHTIG: Sofort senden und vergessen
func login(email: String, password: String):
    # Password sofort in Request, dann verwerfen
    var body = JSON.stringify({"email": email, "password": password})
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)
    # Password-Variable ist danach out-of-scope
```

##### **3. HTTPS Enforcement**
**Problem**: HTTP-Requests sind unsicher

**KRITISCH**:
```gdscript
# ✅ Prüfe IMMER HTTPS
func _ready():
    if not SUPABASE_URL.begins_with("https://"):
        push_error("CRITICAL: SUPABASE_URL must use HTTPS!")
        get_tree().quit()
```

##### **4. Token Refresh Timing**
**Problem**: Expired Tokens führen zu 401 Errors

**Empfehlung**:
```gdscript
var token_expires_at: int = 0

func check_token_expiry():
    var current_time = Time.get_unix_time_from_system()
    # Refresh 5 Minuten VOR Ablauf (Buffer)
    if token_expires_at - current_time < 300:
        refresh_session()

func refresh_session():
    # Nutze Refresh Token für neuen Access Token
    var refresh_token = get_refresh_token()
    # POST /auth/v1/token?grant_type=refresh_token
    # ...
```

#### 🔧 **Empfohlene SupabaseClient.gd Security Features:**

```gdscript
# SupabaseClient.gd - Security Hardened Version
extends Node

# Constants
const SUPABASE_URL = "https://xxx.supabase.co"  # ✅ HTTPS enforced
const SUPABASE_ANON_KEY = "eyJhbGc..."  # ✅ OK for frontend
const TOKEN_REFRESH_BUFFER = 300  # 5 minutes before expiry

# Security flags
var _https_verified: bool = false
var _rate_limit_last_request: int = 0
var _rate_limit_interval: int = 100  # Min 100ms between requests

func _ready():
    _verify_https()
    _setup_security()

func _verify_https():
    """Verify HTTPS is used"""
    if not SUPABASE_URL.begins_with("https://"):
        push_error("CRITICAL SECURITY ERROR: HTTPS required!")
        get_tree().quit()
    _https_verified = true
    print("✅ HTTPS verified")

func _setup_security():
    """Setup security features"""
    # TODO: Setup Content Security Policy headers
    # TODO: Setup rate limiting
    pass

func login(email: String, password: String):
    """Login user - password is NOT stored"""
    # Rate limiting check
    var now = Time.get_ticks_msec()
    if now - _rate_limit_last_request < _rate_limit_interval:
        push_warning("Rate limit: Request too soon")
        return
    _rate_limit_last_request = now
    
    # Validate input (prevent injection)
    if not _validate_email(email):
        push_error("Invalid email format")
        return
    
    if password.length() < 12:
        push_error("Password too short (min 12 chars)")
        return
    
    # ✅ Password sent immediately, not stored
    var headers = [
        "Content-Type: application/json",
        "apikey: " + SUPABASE_ANON_KEY
    ]
    var body = JSON.stringify({
        "email": email,
        "password": password  # ✅ Sent via HTTPS, immediately out of scope
    })
    
    http_request.request(
        SUPABASE_URL + "/auth/v1/token?grant_type=password",
        headers,
        HTTPClient.METHOD_POST,
        body
    )
    # ✅ password variable is now out of scope

func _validate_email(email: String) -> bool:
    """Basic email validation"""
    var regex = RegEx.new()
    regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    return regex.search(email) != null

func store_session(access_token: String, refresh_token: String, expires_in: int):
    """Store session tokens securely"""
    # Calculate expiry time
    var expires_at = Time.get_unix_time_from_system() + expires_in
    
    # Store tokens (encrypted in production)
    JavaScriptBridge.eval("localStorage.setItem('bktd_token', '%s')" % access_token)
    JavaScriptBridge.eval("sessionStorage.setItem('bktd_refresh', '%s')" % refresh_token)
    JavaScriptBridge.eval("localStorage.setItem('bktd_expires', '%d')" % expires_at)
    
    print("✅ Session stored (expires at: %s)" % Time.get_datetime_string_from_unix_time(expires_at))

func clear_session():
    """Clear all session data"""
    JavaScriptBridge.eval("localStorage.removeItem('bktd_token')")
    JavaScriptBridge.eval("sessionStorage.removeItem('bktd_refresh')")
    JavaScriptBridge.eval("localStorage.removeItem('bktd_expires')")
    JavaScriptBridge.eval("localStorage.removeItem('bktd_user_id')")
    print("✅ Session cleared")

func check_and_refresh_token():
    """Check token expiry and refresh if needed"""
    var expires_at_str = JavaScriptBridge.eval("localStorage.getItem('bktd_expires')", true)
    if expires_at_str == "null" or expires_at_str == "":
        return false
    
    var expires_at = int(expires_at_str)
    var current_time = Time.get_unix_time_from_system()
    
    # Refresh if within buffer time
    if expires_at - current_time < TOKEN_REFRESH_BUFFER:
        refresh_session()
        return true
    
    return false
```

---

### **2.2 Login/Register UI**

#### ⚠️ **Sicherheitsbedenken:**

##### **1. Input Validation (Client-Side)**
**Problem**: User-Input muss validiert werden

**Empfehlung**:
```gdscript
func _on_register_pressed():
    var email = email_input.text
    var username = username_input.text
    var password = password_input.text
    var password_confirm = password_confirm_input.text
    
    # ✅ Validate Email
    if not validate_email(email):
        show_error("Invalid email format")
        return
    
    # ✅ Validate Username (prevent SQL injection chars)
    if not validate_username(username):
        show_error("Invalid username (only a-z, A-Z, 0-9, _, -)")
        return
    
    # ✅ Validate Password Strength
    var password_check = validate_password_strength(password)
    if not password_check.valid:
        show_error(password_check.message)
        return
    
    # ✅ Confirm Password Match
    if password != password_confirm:
        show_error("Passwords do not match")
        return
    
    # Proceed with registration
    supabase_client.register(email, password, username)

func validate_username(username: String) -> bool:
    if username.length() < 3 or username.length() > 20:
        return false
    var regex = RegEx.new()
    regex.compile("^[a-zA-Z0-9_-]+$")
    return regex.search(username) != null

func validate_password_strength(password: String) -> Dictionary:
    # Min 12 Zeichen
    if password.length() < 12:
        return {"valid": false, "message": "Password must be at least 12 characters"}
    
    # Min 1 Großbuchstabe
    if not password.to_upper() != password:
        return {"valid": false, "message": "Password must contain uppercase letter"}
    
    # Min 1 Kleinbuchstabe
    if not password.to_lower() != password:
        return {"valid": false, "message": "Password must contain lowercase letter"}
    
    # Min 1 Zahl
    var has_number = false
    for c in password:
        if c.is_valid_int():
            has_number = true
            break
    if not has_number:
        return {"valid": false, "message": "Password must contain a number"}
    
    # Min 1 Sonderzeichen
    var special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
    var has_special = false
    for c in password:
        if c in special_chars:
            has_special = true
            break
    if not has_special:
        return {"valid": false, "message": "Password must contain a special character"}
    
    return {"valid": true, "message": ""}
```

##### **2. Password Visibility Toggle**
**Empfehlung**: Implementiere "Show Password" Button
```gdscript
func _on_show_password_toggled(is_visible: bool):
    password_input.secret = not is_visible
```

##### **3. CAPTCHA für Registration** (Optional, aber empfohlen)
**Problem**: Bot-Registrierungen verhindern

**Empfehlung** (später):
- Integration von hCaptcha oder reCAPTCHA
- Nur bei Registrierung, nicht bei Login
- Supabase hat keine native CAPTCHA-Integration

---

## 🔐 Sprint 3: Cloud Save Integration - Sicherheitsanalyse

### **3.1 Save Data Encryption**

#### ⚠️ **Sicherheitsbedenken:**

##### **1. Sensitive Data in Save Files**
**Problem**: Spielfortschritt enthält keine sensitiven Daten, ABER:
- User-Identifizierung möglich durch Patterns
- Potenzial für Cheating (Honey, Towers, etc.)

**Empfehlung**:
```gdscript
# Save Data Structure - Security Considerations
var save_data = {
    "current_wave": 3,  # ✅ OK - Gameplay data
    "player_health": 15,  # ✅ OK - Gameplay data
    "honey": 120,  # ⚠️ Cheat-anfällig, aber OK für Single-Player
    "placed_towers": [...],  # ⚠️ Cheat-anfällig
    # ❌ NIEMALS: Persönliche Daten (Name, Adresse, etc.)
    # ❌ NIEMALS: Payment Info
    # ❌ NIEMALS: Auth Tokens
}
```

**Für Anti-Cheat** (später, optional):
```gdscript
# Server-Side Validation (Cloud Function)
func validate_save_data(save_data: Dictionary) -> bool:
    # Prüfe auf unrealistische Werte
    if save_data.honey > 10000:  # Unrealistisch für Welle 3
        return false
    if save_data.current_wave > 5:  # Max 5 waves
        return false
    return true
```

##### **2. Data Tampering Protection**
**Problem**: User könnte Save Data im LocalStorage manipulieren

**Mitigation** (optional):
```gdscript
# Add checksum to save data
func create_save_data() -> Dictionary:
    var data = {
        "current_wave": current_wave,
        "player_health": player_health,
        "honey": honey,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Add checksum
    data["checksum"] = calculate_checksum(data)
    return data

func calculate_checksum(data: Dictionary) -> String:
    # Simple checksum (für komplexere Lösung: HMAC)
    var json_string = JSON.stringify(data)
    return json_string.md5_text()

func validate_save_data(data: Dictionary) -> bool:
    var stored_checksum = data.get("checksum", "")
    data.erase("checksum")
    var calculated_checksum = calculate_checksum(data)
    return stored_checksum == calculated_checksum
```

---

### **3.2 Conflict Resolution**

#### ⚠️ **Sicherheitsbedenken:**

##### **1. Concurrent Modifications**
**Problem**: User spielt auf 2 Geräten gleichzeitig

**Empfehlung**:
```gdscript
func sync_save_data():
    # Lade Cloud Save
    var cloud_save = await load_cloud_save()
    var local_save = load_local_save()
    
    # Compare timestamps
    if cloud_save.timestamp > local_save.timestamp:
        # Cloud ist neuer
        show_conflict_dialog("Cloud save is newer. Use cloud save?")
    elif local_save.timestamp > cloud_save.timestamp:
        # Local ist neuer
        upload_save(local_save)
    else:
        # Gleich alt - nutze Cloud als Source of Truth
        apply_cloud_save(cloud_save)
```

##### **2. Data Loss Prevention**
**Empfehlung**:
```gdscript
func upload_save_with_backup(save_data: Dictionary):
    # Backup current cloud save before overwrite
    var current_cloud_save = await load_cloud_save()
    if current_cloud_save:
        save_backup(current_cloud_save)
    
    # Upload new save
    upload_save(save_data)

func save_backup(save_data: Dictionary):
    # Store in separate backup table or versioned column
    # Allows rollback if corruption detected
    pass
```

---

## 🔐 Sprint 4: Production Security Checklist

### **4.1 Pre-Deployment Security Audit**

#### ✅ **Security Checklist:**

**Authentication & Authorization:**
- [ ] ✅ Password min. 12 characters (besser: 14)
- [ ] ✅ Email confirmation enabled
- [ ] ✅ Rate limiting configured (5 attempts / 15 min lockout)
- [ ] ✅ JWT expiry: 1 hour (nicht 7 Tage!)
- [ ] ✅ Refresh token rotation: ON
- [ ] ✅ HTTPS enforced (no HTTP fallback)

**Database Security:**
- [ ] ✅ Row Level Security (RLS) enabled
- [ ] ✅ All policies tested and verified
- [ ] ✅ Service Role Key NICHT im Frontend
- [ ] ✅ Data size constraints (1MB limit)
- [ ] ✅ Input validation triggers
- [ ] ✅ Rate limiting on updates (1/second)

**Frontend Security:**
- [ ] ✅ No passwords in logs
- [ ] ✅ No sensitive data in LocalStorage (unencrypted)
- [ ] ✅ HTTPS verification on startup
- [ ] ✅ Input validation (email, username, password)
- [ ] ✅ XSS protection (sanitize all user input)
- [ ] ✅ CORS configured correctly

**API Security:**
- [ ] ✅ Anon Key used (not Service Role Key)
- [ ] ✅ All requests use Bearer token
- [ ] ✅ Token refresh before expiry
- [ ] ✅ Logout clears all tokens

**Monitoring & Logging:**
- [ ] ✅ Error logging (without sensitive data)
- [ ] ✅ Failed login attempts logged
- [ ] ✅ Audit trail for data changes
- [ ] ⚠️ Alerting für suspicious activity (später)

---

### **4.2 DSGVO / Privacy Compliance**

#### ✅ **DSGVO Requirements:**

**Datenschutzerklärung:**
- [ ] ✅ Welche Daten werden gesammelt? (Email, Username, Save Data)
- [ ] ✅ Warum? (Account-Management, Spielfortschritt)
- [ ] ✅ Wo gespeichert? (Supabase AWS Frankfurt/EU)
- [ ] ✅ Wie lange? (Bis Account-Löschung)
- [ ] ✅ Wer hat Zugriff? (Nur User selbst via RLS)

**User Rights:**
- [ ] ✅ Right to Access (User kann eigene Daten sehen)
- [ ] ✅ Right to Rectification (User kann Daten ändern)
- [ ] ✅ Right to Erasure (Account-Löschung)
- [ ] ✅ Right to Data Portability (Export-Funktion)

**Implementation:**
```gdscript
# Account Settings UI
func _on_export_data_pressed():
    """Export all user data (DSGVO Right to Data Portability)"""
    var user_data = {
        "user_id": current_user.id,
        "email": current_user.email,
        "username": current_user.username,
        "created_at": current_user.created_at,
        "save_data": load_all_save_data()
    }
    
    var json = JSON.stringify(user_data, "\t")
    save_file_dialog("user_data_export.json", json)

func _on_delete_account_pressed():
    """Delete account (DSGVO Right to Erasure)"""
    var confirm = await show_confirmation_dialog(
        "Are you sure? This will permanently delete your account and all data."
    )
    
    if confirm:
        # Supabase CASCADE DELETE handles save_data automatically
        await supabase_client.delete_account()
        show_notification("Account deleted successfully")
        SceneManager.goto_main_menu()
```

**Consent Management:**
```gdscript
# First Launch - Consent Dialog
func show_privacy_consent():
    """Show privacy consent on first launch"""
    var dialog = AcceptDialog.new()
    dialog.dialog_text = """
    We collect and store:
    - Your email address (for login)
    - Your username (for display)
    - Your game progress (to sync between devices)
    
    Data is stored in EU (Frankfurt) and protected by encryption.
    
    By clicking Accept, you agree to our Privacy Policy.
    """
    
    # Links
    dialog.add_button("Privacy Policy", false, "privacy_policy")
    dialog.add_button("Accept", true, "accept")
    dialog.add_button("Decline", false, "decline")
    
    # ...
```

---

## 🔐 Sprint 5: Deployment Security

### **5.1 Netlify/Vercel Security Configuration**

#### ✅ **Secure Headers:**

**Netlify `netlify.toml`:**
```toml
[[headers]]
  for = "/*"
  [headers.values]
    # Security Headers
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "geolocation=(), microphone=(), camera=()"
    
    # Content Security Policy (CSP)
    Content-Security-Policy = """
      default-src 'self';
      script-src 'self' 'unsafe-inline' 'unsafe-eval' https://*.supabase.co;
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      connect-src 'self' https://*.supabase.co;
      font-src 'self';
      frame-ancestors 'none';
      base-uri 'self';
      form-action 'self';
    """
    
    # HTTPS enforcement
    Strict-Transport-Security = "max-age=31536000; includeSubDomains; preload"

# Redirect HTTP to HTTPS
[[redirects]]
  from = "http://*"
  to = "https://:splat"
  status = 301
  force = true
```

**Vercel `vercel.json`:**
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {"key": "X-Frame-Options", "value": "DENY"},
        {"key": "X-Content-Type-Options", "value": "nosniff"},
        {"key": "X-XSS-Protection", "value": "1; mode=block"},
        {"key": "Referrer-Policy", "value": "strict-origin-when-cross-origin"},
        {"key": "Strict-Transport-Security", "value": "max-age=31536000; includeSubDomains; preload"}
      ]
    }
  ]
}
```

---

### **5.2 Environment Variables Security**

#### ⚠️ **KRITISCH:**

**Netlify/Vercel Dashboard:**
```
✅ Set Environment Variables in Dashboard (NOT in code!)
✅ Use Build-Time Variables (not Runtime)
✅ Never commit .env to Git

Variables:
- SUPABASE_URL (Public - OK)
- SUPABASE_ANON_KEY (Public - OK, protected by RLS)
- GODOT_BUILD_MODE=production
```

**.gitignore:**
```
# ❌ Never commit these!
.env
.env.local
.env.production
*.pck  # Godot export files may contain embedded secrets
```

---

## 🎯 Security Risk Assessment Summary

### **HIGH RISK** 🔴
1. **Service Role Key Exposure**: ❌ NIEMALS im Frontend!
2. **Password in Logs**: ❌ Kann zu Account-Takeover führen
3. **Missing HTTPS**: ❌ Man-in-the-Middle attacks möglich
4. **Weak Password Policy**: ⚠️ 8 chars ist zu schwach (min. 12)

### **MEDIUM RISK** 🟡
1. **Long Session Timeout**: 7 Tage ist lang (empfohlen: 24h)
2. **No Rate Limiting on Save**: Potenzial für DoS
3. **No JSONB Size Limit**: Potenzial für oversized payloads
4. **LocalStorage Token**: Anfällig für XSS (aber akzeptabel für MVP)

### **LOW RISK** 🟢
1. **Anon Key in Frontend**: ✅ OK, designed for client-side
2. **Game Data Tampering**: Nur Cheating, kein Security-Risk
3. **No CAPTCHA**: Für MVP OK, später empfohlen

---

## ✅ Recommended Implementation Order

### **Phase 1: MVP (Sprint 1-4)** - Essential Security
1. ✅ HTTPS enforcement
2. ✅ Strong password policy (min. 12 chars)
3. ✅ Row Level Security (RLS) policies
4. ✅ Token storage (LocalStorage)
5. ✅ Input validation (Client-Side)
6. ✅ Session timeout (24h statt 7 Tage)

### **Phase 2: Production (Sprint 5)** - Enhanced Security
1. ✅ Security headers (CSP, HSTS, etc.)
2. ✅ Email confirmation
3. ✅ Rate limiting (Auth + API)
4. ✅ JSONB size constraints
5. ✅ Audit logging
6. ✅ DSGVO compliance (Datenschutzerklärung, User Rights)

### **Phase 3: Post-Launch** - Advanced Security
1. ⚠️ Token encryption (LocalStorage)
2. ⚠️ CAPTCHA integration
3. ⚠️ Anti-cheat measures (Server-Side validation)
4. ⚠️ Advanced monitoring & alerting
5. ⚠️ Penetration testing

---

## 📞 Questions for Security Expert Review

### **1. Authentication & Session Management**
- Ist 24h Session Timeout angemessen für ein Browser-Game?
- Sollten wir zusätzlich eine "Remember Me" Option mit längerer Session anbieten?
- Reicht Client-Side Input Validation oder brauchen wir Server-Side Validation?

### **2. Token Storage**
- Ist LocalStorage für JWT Tokens akzeptabel für MVP?
- Sollten wir Token-Encryption implementieren (und wenn ja, wie Key Management)?
- Alternative: HttpOnly Cookies (aber Supabase unterstützt das nicht nativ)?

### **3. Data Protection**
- Brauchen wir zusätzliche Verschlüsselung für Save Data (JSONB)?
- Ist Checksum-basierte Tamper-Detection ausreichend gegen Cheating?
- Sollten wir Server-Side Validation für Save Data implementieren?

### **4. Rate Limiting & DoS Protection**
- Sind die vorgeschlagenen Rate Limits angemessen?
  - Login: 5 Versuche / 15 min
  - Save Updates: 1/second
  - Registration: 5/IP/hour
- Brauchen wir zusätzliche DDoS-Protection (Cloudflare, etc.)?

### **5. DSGVO & Privacy**
- Reicht die vorgeschlagene Datenschutzerklärung?
- Müssen wir Cookie-Consent implementieren (obwohl wir nur Technical Cookies nutzen)?
- Sollten wir Data Retention Policies definieren (automatische Löschung nach X Monaten Inaktivität)?

### **6. Production Deployment**
- Sind die Security Headers ausreichend?
- Sollten wir zusätzliche Monitoring-Tools einsetzen (Sentry, LogRocket)?
- Brauchen wir ein WAF (Web Application Firewall)?

---

## 📋 Final Security Checklist for Expert Review

**Bitte prüfe besonders:**
- [ ] Row Level Security Policies (sind diese wasserdicht?)
- [ ] Token Storage Strategy (LocalStorage vs. alternatives?)
- [ ] Password Policy (12 chars ausreichend?)
- [ ] Session Management (24h Timeout OK?)
- [ ] JSONB Injection Protection (ausreichend?)
- [ ] Rate Limiting Strategy (angemessen?)
- [ ] DSGVO Compliance (vollständig?)
- [ ] Security Headers (fehlt etwas Wichtiges?)

---

**Dokument Status**: Ready for Security Expert Review  
**Version**: 1.0  
**Datum**: 2025-09-29  
**Erstellt von**: AI Assistant  
**Review benötigt von**: Security Expert

---

## 📎 Anhang: Nützliche Links

**Supabase Security:**
- https://supabase.com/docs/guides/auth/row-level-security
- https://supabase.com/docs/guides/auth/auth-helpers
- https://supabase.com/docs/guides/database/postgres/row-level-security

**OWASP Guidelines:**
- https://owasp.org/www-project-web-security-testing-guide/
- https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html

**DSGVO / GDPR:**
- https://gdpr.eu/
- https://www.datenschutz-grundverordnung.eu/

**Security Headers:**
- https://securityheaders.com/
- https://observatory.mozilla.org/
