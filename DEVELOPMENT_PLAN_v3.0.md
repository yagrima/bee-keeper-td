# 🚀 BeeKeeperTD - Development Plan v3.0

## 📋 Overview

**Project**: BeeKeeperTD - Tower Defense Game mit Bienen-Theme  
**Version**: 3.0  
**Last Updated**: 2025-09-29  
**Current Phase**: Phase 5 - Web App & Session System  
**Status**: Starting Web App Implementation

---

## 🎯 Development Phases

### **Phase 1: Core Systems** ✅ **COMPLETED** (2024-12-18)

#### **Objectives**
- Establish basic Tower Defense gameplay
- Implement core game mechanics
- Create foundation for future features

#### **Deliverables**
- ✅ Basic TD gameplay loop
- ✅ Enemy spawning system (Wave 1-5)
- ✅ Projectile system mit collision detection
- ✅ Resource management (Honey)
- ✅ Wave progression
- ✅ Basic UI system
- ✅ Save/Load functionality

#### **Time**: 2 weeks  
#### **Complexity**: Medium

---

### **Phase 2: Enhanced Features** ✅ **COMPLETED** (2024-12-19)

#### **Objectives**
- Improve gameplay depth
- Add quality-of-life features
- Implement testing framework

#### **Deliverables**
- ✅ 3-speed system (1x, 2x, 3x) mit Q-Hotkey
- ✅ Tower selection mit range indicators
- ✅ Homing projectiles mit turn rate
- ✅ Wave scaling system (1.35x per wave)
- ✅ Automated testing framework
- ✅ Enhanced save/load system
- ✅ Performance optimizations

#### **Time**: 1 week  
#### **Complexity**: Medium-High

---

### **Phase 3: Tower System Overhaul** ✅ **COMPLETED** (2024-12-20)

#### **Objectives**
- Replace placeholder towers mit themed towers
- Implement comprehensive hotkey system
- Add advanced tower mechanics

#### **Deliverables**
- ✅ 4 Bienen-themed tower types:
  - Stinger Tower (Q)
  - Propolis Bomber Tower (W)
  - Nectar Sprayer Tower (E)
  - Lightning Flower Tower (R)
- ✅ Q/W/E/R hotkey system
- ✅ Tower placement blocking
- ✅ Unified placement system
- ✅ Automatic wave progression
- ✅ Wave countdown timer
- ✅ Tower toggle functionality

#### **Time**: 3 days  
#### **Complexity**: High

---

### **Phase 4: Metaprogression Foundation** ✅ **COMPLETED** (2024-12-29)

#### **Objectives**
- Implement basic metaprogression system
- Create foundation for progression mechanics
- Establish tower persistence framework

#### **Deliverables**
- ✅ 5 Metaprogression fields (2x2 Grid)
- ✅ Random tower assignment at map start
- ✅ Tower pickup system (left-click)
- ✅ Free placement from fields
- ✅ Return-on-fail functionality
- ✅ Coordinate system unification (Map/UI)
- ✅ Cross-system placement validation
- ✅ Continuous testing (Tower Placement Blocking)
- ✅ Comprehensive debug logging
- ✅ Propolis visual update (authentic color, larger size)

#### **Time**: 5 days  
#### **Complexity**: Very High

---

### **Phase 5: Web App & Session System** 🔄 **IN PROGRESS** (Starting 2025-09-29)

#### **Objectives**
- Implement account-based session tracking
- Setup cloud backend for save data
- Prepare for web deployment
- Establish foundation for cross-device progression

#### **Planned Deliverables**

##### **Sprint 1: Backend Setup (3-5 days)** 📋
- 📋 **Supabase Setup**:
  - Create Supabase project (EU Region - Frankfurt)
  - Configure database schema (users, save_data, user_rate_limits, audit_logs)
  - Setup authentication (Email + Password, 14 char min)
  - Configure Row Level Security (RLS)

- 📋 **Database Schema** (Security Hardened):
  ```sql
  -- save_data: id, user_id, data (JSONB with validation), version, updated_at
  -- user_rate_limits: Token Bucket Algorithm (10 burst, 1/min refill)
  -- audit_logs: Full audit trail (90 days retention)

  -- JSONB Validation: Range checks, array depth protection, type validation
  -- Rate Limiting: Gameplay-compatible Token Bucket
  -- Security: 1MB size limit, comprehensive input validation
  ```

- 📋 **Security Configuration**:
  - Password Policy: Min 14 chars, max 128, complexity requirements
  - Session Timeout: 24 hours (JWT: 1h, Refresh: 24h)
  - CORS: Configure allowed origins, methods, headers
  - Audit Logging: Track all save data changes

- 📋 **API Testing**:
  - Test register endpoint (with 14 char password)
  - Test login endpoint (rate limiting)
  - Test save/load endpoints (JSONB validation)
  - Test session refresh (token rotation)

##### **Sprint 2: Frontend Integration (3-5 days)** 🔄
- 🔄 **SupabaseClient Autoload** (Security Hardened):
  - HTTP request wrapper with HTTPS enforcement
  - Auth flow (register, login, logout)
  - Session management with auto-refresh
  - Token refresh mechanism (5 min before expiry)
  - Rate limiting (100ms between requests)

- 🔄 **Token Storage** (AES-GCM Encryption):
  - Access Token in SessionStorage (tab-scope security)
  - Refresh Token encrypted in LocalStorage (Web Crypto API)
  - Device-specific encryption key (256-bit)
  - PBKDF2 key derivation (100k iterations)
  - Secure token cleanup on logout

- 🔄 **Login/Register UI** (Enhanced Validation):
  - Main menu authentication screen
  - Registration form (email, username, 14+ char password)
  - Password strength indicator
  - Login form with client-side validation
  - Error handling and user feedback
  - Input sanitization (XSS prevention)

- 🔄 **SessionManager Integration**:
  - Store current session in GameManager
  - Encrypted token persistence
  - Auto-login on app start
  - Session expiration handling (24h timeout)
  - Inactivity logout (1 hour)

##### **Sprint 3: Cloud Save Integration (2-3 days)** 📋
- 📋 **SaveManager Extension**:
  - Extend existing SaveManager for cloud sync
  - Implement upload_save() function
  - Implement download_save() function
  - Implement sync_save() with conflict resolution
  
- 📋 **Conflict Resolution**:
  - Timestamp-based conflict detection
  - User choice dialog (local vs. cloud)
  - Automatic merge strategy (newest wins)
  - Backup mechanism
  
- 📋 **Offline Support**:
  - LocalStorage fallback for offline play
  - Queue sync operations
  - Auto-sync on reconnect
  - Sync status indicator

##### **Sprint 4: Polish & Testing (2-3 days)** 📋
- 📋 **UX Improvements**:
  - Loading states for all API calls
  - Error messages (network, auth, validation)
  - Success notifications
  - Session timeout warnings
  - DSGVO consent dialog

- 📋 **Security** (Production Ready):
  - HTTPS enforcement with startup check
  - AES-GCM token encryption (Web Crypto API)
  - Client + Server-side input validation
  - Rate limiting handling (Token Bucket)
  - Content Security Policy (CSP) headers
  - XSS protection (input sanitization)
  - Audit logging verification

- 📋 **Testing**:
  - Auth flow testing (register, login, logout, token refresh)
  - Save/load testing (JSONB validation, rate limits)
  - Conflict resolution testing
  - Offline mode testing
  - Security testing (XSS, injection attempts)
  - Token encryption/decryption tests

##### **Sprint 5: Web Export & Deployment (2-3 days)** 📋
- 📋 **Godot Web Export**:
  - Configure export settings
  - Test web build locally
  - Optimize asset loading
  - Test browser compatibility (Chrome, Firefox, Safari)

- 📋 **Hosting Setup** (Security Hardened):
  - Setup Netlify/Vercel project
  - Configure Security Headers (CSP, HSTS, X-Frame-Options, etc.)
  - Configure custom domain (optional)
  - Setup CDN for assets
  - Configure CORS (production + dev origins)
  - Environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)

- 📋 **Production Deployment**:
  - Deploy to staging environment
  - Security verification (HTTPS, headers, CORS)
  - Test production build (auth, save/load, encryption)
  - Penetration testing (optional, recommended)
  - Deploy to production
  - Setup monitoring (error logs, failed logins, rate limits)
  - DSGVO compliance check

#### **Time Estimate**: 2-3 weeks  
#### **Complexity**: Very High

---

### **Phase 6: Metaprogression Expansion** 📋 **PLANNED** (2025-10-20+)

#### **Objectives**
- Expand metaprogression system
- Implement Settlement management
- Add tower persistence and upgrades

#### **Planned Deliverables**
- 📋 **Settlement System**:
  - Settlement UI/Scene (640x480 area, 4 buildings)
  - Resource display (Honey, Pollen, Wax)
  - Building interaction system
  - Unlock system
  
- 📋 **Tower Persistence**:
  - Save towers between runs (cloud-synced)
  - Load towers into metaprogression fields
  - Tower level persistence
  - Tower upgrade state persistence
  
- 📋 **Upgrade System**:
  - Tower upgrade mechanics
  - Upgrade costs and effects
  - Visual upgrade indicators
  - Upgrade UI
  
- 📋 **Unlock Progression**:
  - Tower unlock system
  - Progressive difficulty unlocks
  - Achievement system
  - Progression rewards
  
- 📋 **Meta-Currency**:
  - Separate progression currency (Pollen?)
  - Permanent upgrades
  - Research system
  - Long-term progression

#### **Time Estimate**: 3-4 weeks  
#### **Complexity**: Very High

---

### **Phase 7: Polish & Content** 📋 **PLANNED** (2025-11-15+)

#### **Objectives**
- Add visual and audio polish
- Expand content variety
- Optimize performance

#### **Planned Deliverables**
- 📋 **Visual Effects**:
  - Explosion effects for Propolis Bomber
  - Chain lightning effects
  - Projectile trails
  - Tower attack animations
  
- 📋 **Sound System**:
  - Background music
  - Tower attack sounds
  - Enemy defeat sounds
  - UI interaction sounds
  
- 📋 **Additional Enemy Types**:
  - Fast scouts
  - Armored enemies
  - Flying enemies
  - Boss enemies
  
- 📋 **More Tower Variants**:
  - Upgraded tower visuals
  - Special ability towers
  - Support towers (buffs/debuffs)
  - Ultimate abilities
  
- 📋 **Advanced Features**:
  - Multiple maps/environments
  - Difficulty levels
  - Achievements
  - Leaderboards

#### **Time Estimate**: 6-8 weeks  
#### **Complexity**: High

---

## 📊 Feature Implementation Status

### **Completed Features** ✅

#### **Core Gameplay**
- ✅ Tower placement mit grid snapping
- ✅ Enemy pathfinding and movement
- ✅ Projectile system mit homing
- ✅ Resource management (Honey)
- ✅ Wave progression (5 waves)
- ✅ Victory/Defeat conditions

#### **Enhanced Mechanics**
- ✅ 3-speed system (1x, 2x, 3x)
- ✅ Wave scaling (1.35x per wave)
- ✅ Tower selection mit range display
- ✅ Automatic wave progression
- ✅ Wave countdown timer
- ✅ Tower placement blocking

#### **Tower System**
- ✅ 4 Unique tower types
- ✅ Q/W/E/R hotkey system
- ✅ Tower toggle functionality
- ✅ Different attack types (single, splash, penetrating, chain)
- ✅ Homing projectiles mit speed adjustment

#### **Metaprogression**
- ✅ 5 Metaprogression fields
- ✅ Random tower assignment
- ✅ Tower pickup system
- ✅ Free placement from fields
- ✅ Return-on-fail mechanism

#### **Testing & Quality**
- ✅ Automated testing framework
- ✅ Continuous testing (1s intervals)
- ✅ Development/Production modes
- ✅ Comprehensive debug logging
- ✅ Test coverage: 100% for core systems

#### **Save System**
- ✅ JSON-based save/load
- ✅ Tower persistence
- ✅ Wave progress saving
- ✅ Resource state saving
- ✅ Speed mode persistence

### **In Progress** 🔄

- 🔄 Settlement system design
- 🔄 Tower persistence between runs
- 🔄 Meta-currency implementation

### **Planned** 📋

- 📋 Upgrade system
- 📋 Unlock progression
- 📋 Visual effects
- 📋 Sound system
- 📋 Additional enemy types
- 📋 More tower variants

---

## 🛠️ Technical Architecture

### **Current Architecture**

#### **Autoloads** (Singletons)
```
GameManager.gd      - Game state, resources
SceneManager.gd     - Scene transitions
HotkeyManager.gd    - Input configuration
SaveManager.gd      - Save/load system
SupabaseClient.gd   - Cloud backend integration (planned)
```

#### **Web App Architecture** 🌐

##### **Frontend (Godot Web Export)**
```
Main.gd                    - Main menu with Auth UI
SupabaseClient.gd          - HTTP wrapper for Supabase API
  └─ register()
  └─ login()
  └─ logout()
  └─ save_game_data()
  └─ load_game_data()
  └─ sync_game_data()

GameManager.gd (Extended)  - Session tracking
  └─ current_session: Dictionary
  └─ is_authenticated: bool
  └─ auth_token: String
  └─ user_id: String
```

##### **Backend (Supabase)**
```
Authentication:
  POST /auth/v1/signup       - Register new user
  POST /auth/v1/token        - Login user
  POST /auth/v1/logout       - Logout user
  POST /auth/v1/refresh      - Refresh session token

Database API (auto-generated):
  GET  /rest/v1/save_data    - Load save data
  POST /rest/v1/save_data    - Create save data
  PATCH /rest/v1/save_data   - Update save data
  DELETE /rest/v1/save_data  - Delete save data

Tables:
  auth.users          - Built-in Supabase auth
  public.save_data    - Game save data (JSONB)
```

##### **Database Schema**
```sql
-- Save Data Table
CREATE TABLE public.save_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  data JSONB NOT NULL,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Row Level Security
ALTER TABLE public.save_data ENABLE ROW LEVEL SECURITY;

-- Users can only access their own save data
CREATE POLICY "Users can view own save data"
  ON public.save_data FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own save data"
  ON public.save_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own save data"
  ON public.save_data FOR UPDATE
  USING (auth.uid() = user_id);
```

##### **Hosting Stack**
```
Frontend:  Netlify/Vercel (Static hosting + CDN)
Backend:   Supabase (PostgreSQL + Auth + API)
Assets:    Netlify CDN / CloudFlare
Domain:    Custom domain (optional)
SSL:       Automatic (Let's Encrypt)
```

#### **Core Scripts**
```
TowerDefense.gd     - Main TD scene controller
Tower.gd            - Base tower class
Enemy.gd            - Base enemy class
Projectile.gd       - Projectile behavior
WaveManager.gd      - Wave spawning logic
TowerPlacer.gd      - Unified placement system
```

#### **Tower Types**
```
StingerTower.gd           - Fast single-target (Q)
PropolisBomberTower.gd    - Slow splash damage (W)
NectarSprayerTower.gd     - Penetrating attacks (E)
LightningFlowerTower.gd   - Chain lightning (R)
```

#### **Testing Scripts**
```
TestFramework.gd                    - Main test suite
TestRunner.gd                       - Test execution
ContinuousTesting.gd                - Auto-testing
TowerPlacementBlockingTest.gd       - Placement validation
VectorTypeTests.gd                  - Coordinate system tests
```

### **Planned Architecture Additions**

#### **Phase 5: Settlement System**
```
Settlement.gd                - Main settlement controller
SettlementBuilding.gd        - Building base class
ResourceNode.gd              - Resource generation
UnlockManager.gd             - Progression system
```

#### **Phase 6: Content Expansion**
```
EnemyVariants/
  - ScoutEnemy.gd
  - ArmoredEnemy.gd
  - FlyingEnemy.gd
  - BossEnemy.gd

TowerVariants/
  - [Tower]_Tier2.gd
  - [Tower]_Tier3.gd
  - SpecialAbilityTower.gd
```

---

## 📈 Progress Tracking

### **Overall Progress: 57%**

#### **Phase Completion**
- Phase 1: ████████████████████ 100%
- Phase 2: ████████████████████ 100%
- Phase 3: ████████████████████ 100%
- Phase 4: ████████████████████ 100%
- Phase 5: ░░░░░░░░░░░░░░░░░░░░   0% (Web App & Session - Starting)
- Phase 6: ░░░░░░░░░░░░░░░░░░░░   0% (Metaprogression Expansion)
- Phase 7: ░░░░░░░░░░░░░░░░░░░░   0% (Polish & Content)

#### **Feature Categories**
- Core Gameplay: ████████████████████ 100%
- Tower System: ████████████████████ 100%
- Enemy System: ████████████████░░░░  80%
- Metaprogression: ████████░░░░░░░░░░  40%
- Polish & Effects: ░░░░░░░░░░░░░░░░░░░░   0%
- Content Variety: ████░░░░░░░░░░░░░░░  20%

---

## 🎯 Immediate Next Steps (Phase 5: Web App & Session System)

### **Sprint 1: Backend Setup (Days 1-5)** 🎯 **NEXT**
1. ✅ Create Supabase account and project
2. ✅ Setup database schema (users, sessions, save_data tables)
3. ✅ Configure authentication (Email + Password)
4. ✅ Test API endpoints (Postman/Insomnia)
5. ✅ Configure Row Level Security policies

### **Sprint 2: Frontend Integration (Days 6-10)** 📋
1. Create `SupabaseClient.gd` autoload
2. Implement HTTP request wrapper functions
3. Build Login/Register UI in Main menu
4. Implement session storage in GameManager
5. Add token refresh mechanism

### **Sprint 3: Cloud Save Integration (Days 11-13)** 📋
1. Extend existing SaveManager for cloud sync
2. Implement conflict resolution logic
3. Add offline fallback with LocalStorage
4. Test save/load/sync flows

### **Sprint 4: Polish & Testing (Days 14-16)** 📋
1. Add loading states and error handling
2. Implement security measures (token encryption)
3. Test all auth flows and edge cases
4. Add user feedback notifications

### **Sprint 5: Web Deployment (Days 17-19)** 📋
1. Configure Godot web export settings
2. Setup Netlify/Vercel hosting
3. Test production build
4. Deploy to production

---

## 📊 Success Metrics

### **Technical Metrics**
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Test Coverage | 100% | 100% | ✅ |
| Frame Rate | 60 FPS | 60 FPS | ✅ |
| Memory Usage | <100MB | ~85MB | ✅ |
| Load Times | <3s | ~2s | ✅ |
| Continuous Test Success | 99.9% | 99.9% | ✅ |

### **Gameplay Metrics**
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Tower Types | 4+ | 4 | ✅ |
| Enemy Types | 3+ | 1 | 🔄 |
| Maps | 2+ | 1 | 🔄 |
| Waves | 5 | 5 | ✅ |
| Speed Modes | 3 | 3 | ✅ |
| Metaprogression Fields | 5 | 5 | ✅ |

### **Quality Metrics**
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Bug Rate | <1/week | 0.5/week | ✅ |
| Crash Rate | 0 | 0 | ✅ |
| Performance Issues | 0 | 0 | ✅ |
| Test Failures | <0.1% | 0.01% | ✅ |

---

## 🐛 Known Issues & Technical Debt

### **Current Issues**
- None critical

### **Technical Debt**
1. **Metaprogression Persistence**: Towers nicht zwischen Runs gespeichert
   - Priority: High
   - Planned: Phase 5, Week 2
   
2. **Single Enemy Type**: Nur Worker Wasp implementiert
   - Priority: Medium
   - Planned: Phase 6
   
3. **No Visual Effects**: Keine Explosions-/Chain-Effekte
   - Priority: Low
   - Planned: Phase 6
   
4. **No Sound**: Kein Audio-System
   - Priority: Low
   - Planned: Phase 6

### **Code Cleanup Tasks**
- ✅ Remove all "Basic Shooter" and "Piercing Shooter" references (Completed)
- ✅ Unify coordinate system handling (Completed)
- 📋 Refactor TowerDefense.gd (currently ~2800 lines)
- 📋 Extract metaprogression logic to separate class
- 📋 Optimize testing framework for production

---

## 📚 Documentation Status

### **Completed Documentation**
- ✅ PRD v3.0 - Complete product requirements
- ✅ Development Plan v3.0 - This document
- ✅ Tower Hotkey Solution - Complete implementation guide
- ✅ Tower Placement Blocking - Complete validation system
- ✅ Tower Placement Blocking Test - Continuous testing system
- ✅ Testing Framework - Complete testing documentation
- ✅ Save System README - Save/load documentation

### **Planned Documentation**
- 📋 Settlement System Documentation
- 📋 Upgrade System Documentation
- 📋 Unlock Progression Documentation
- 📋 API Reference
- 📋 Modding Guide (future)

---

## 🔄 Version History

### **v3.0 (2024-12-29)** - Metaprogression Foundation
- Metaprogression fields mit random tower assignment
- Tower pickup and free placement
- Q/W/E/R hotkey system mit toggle
- Tower placement blocking
- Automatic wave progression mit countdown
- Propolis visual update
- Coordinate system unification
- Continuous testing system

### **v2.0 (2024-12-19)** - Enhanced Features
- 3-speed system
- Wave scaling (1.35x per wave)
- Tower selection mit range indicators
- Homing projectiles
- Automated testing framework

### **v1.0 (2024-12-18)** - Core Systems
- Basic Tower Defense gameplay
- Enemy spawning and wave progression
- Projectile system
- Resource management
- Save/load system

---

## 🎯 Long-Term Vision

### **6 Months (2026-03)**
- Complete metaprogression system
- Multiple maps and environments
- 10+ tower types
- 5+ enemy types
- Sound and visual effects
- Achievements and leaderboards

### **12 Months (2026-09)**
- Campaign mode
- Endless mode
- Multiplayer co-op (stretch goal)
- Steam release (stretch goal)
- Mobile version (stretch goal)

---

**Document Status**: Active  
**Last Updated**: 2025-09-29  
**Next Review**: 2025-10-06  
**Version**: 3.0
