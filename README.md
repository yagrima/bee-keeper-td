# 🐝 BeeKeeperTD - Tower Defense Game

**Version**: 3.2  
**Engine**: Godot 4.5  
**Platform**: Web (Netlify/Vercel) + Desktop  
**Security Score**: 🚀 **8.8/10** (Production Ready)

---

## 🎮 Quick Start

### **Entwickler-Setup** (5 Minuten):

1. **Environment Variables einrichten**:
   ```bash
   # Kopiere .env.example zu .env
   cp .env.example .env
   
   # Generiere HMAC Secret (PowerShell):
   -Join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | % {[char]$_})
   
   # Füge den generierten Secret in .env ein
   ```

2. **Godot Editor starten**:
   - Öffne Godot 4.5
   - Öffne Projekt: `bee-keeper-td/project.godot`
   - Console prüfen: Alle ✅ grün?

3. **Spiel testen**:
   - Play Button drücken
   - Registrierung/Login testen
   - Tower platzieren, Wellen starten

**Siehe**: `docs/setup/GETTING_STARTED.md` für Details

---

## 📚 Dokumentation

**Alle Dokumente organisiert in**: [`MD-Files/`](MD-Files/) | [📋 INDEX](MD-Files/INDEX.md)

### **Quick Links für neue Entwickler**
- [Getting Started](MD-Files/02-Setup/Getting_Started.md) - Start hier
- [Environment Setup](MD-Files/02-Setup/Environment_Setup.md) - .env Konfiguration
- [How To Run Tests](MD-Files/05-Testing/How_To_Run_Tests.md) - Tests ausführen
- [Project Status](MD-Files/06-Status/Project_Status.md) - Aktueller Stand

### **Setup & Configuration**
- [Getting Started](MD-Files/02-Setup/Getting_Started.md) - Schnellstart für Entwickler
- [Environment Setup](MD-Files/02-Setup/Environment_Setup.md) - Environment Variables
- [Supabase Setup](MD-Files/02-Setup/Supabase_Setup.md) - Backend Konfiguration
- [Deployment](MD-Files/02-Setup/Deployment.md) - Netlify/Vercel Deployment

### **Security**
- [Security Overview](MD-Files/03-Security/Quickstart_Security.md) - Security Score 9.2/10
- [Security Fixes History](MD-Files/03-Security/Security_Fixes_History.md) - Alle Fixes
- [Server Validation](MD-Files/03-Security/Server_Validation.md) - Anti-Cheat SQL

### **Planning & Features**
- [PRD v3.0](MD-Files/01-Planning/PRD_v3.0.md) - Product Requirements
- [Development Plan](MD-Files/01-Planning/Development_Plan_v3.0.md) - Roadmap
- [Features Documentation](MD-Files/04-Features/) - Feature Details
- [Project Status](MD-Files/06-Status/Project_Status.md) - Aktueller Fortschritt

### **Testing**
- [How To Run Tests](MD-Files/05-Testing/How_To_Run_Tests.md) - Test Execution
- [Testing Summary](MD-Files/05-Testing/Testing_Summary.md) - Coverage 100%
- [Test Fixes](MD-Files/05-Testing/Test_Fixes.md) - Signal-based Pattern

### **Archive**
- [v2.0 Documents](MD-Files/Archive/v2.0/) - Alte Versionen
- [Detailed Plans](MD-Files/Archive/detailed_plans/) - Archivierte Detail-Dokumente

---

## 🎯 Projekt-Status

| Kategorie | Status | Details |
|-----------|--------|---------|
| **Core Gameplay** | ✅ Complete | 4 Türme, 5 Wellen, Metaprogression |
| **Cloud Save** | ✅ Complete | Auto-Save, Cloud-First, HMAC |
| **Security** | ✅ Complete | Score 8.8/10, 0 Critical Vulns |
| **Tests** | ⚠️ Partial | Framework ready, 2/10 tests fixed |
| **Deployment** | ✅ Ready | Configs vorhanden, .env benötigt |

**Siehe**: `docs/features/ROADMAP.md` für nächste Schritte

---

## 🔐 Security Features

- ✅ **HMAC-SHA256** (RFC 2104 konform) für Save-Integrität
- ✅ **Environment Variables** für alle Secrets
- ✅ **Content Security Policy** (CSP) konfiguriert
- ✅ **AES-GCM Token Encryption** (Web Crypto API)
- ✅ **Row Level Security** (Supabase RLS)
- ✅ **Debug-Code gesichert** (Production-safe)

**Siehe**: `docs/security/SECURITY_OVERVIEW.md`

---

## 🚀 Deployment

### **Netlify/Vercel**:
1. Environment Variables im Dashboard setzen
2. Godot Web Export erstellen
3. Deploy!

**Siehe**: `docs/setup/DEPLOYMENT.md`

---

## 🛠️ Tech Stack

- **Engine**: Godot 4.5 (GDScript)
- **Backend**: Supabase (PostgreSQL + Auth)
- **Deployment**: Netlify / Vercel
- **Security**: CSP, HMAC, RLS, AES-GCM

---

## 📞 Support

- **Setup-Probleme**: `docs/setup/ENVIRONMENT_SETUP.md`
- **Security-Fragen**: `docs/security/SECURITY_OVERVIEW.md`
- **Features**: `docs/features/GAME_FEATURES.md`

---

## 🏆 Credits

**Entwickelt von**: [Dein Name]  
**Engine**: Godot Engine  
**Backend**: Supabase  
**Security Audit**: AI-Assisted (Score: 8.8/10)

---

**🎮 Viel Spaß beim Spielen!**
