# 📚 BeeKeeperTD Documentation Index

**Version**: 3.0  
**Last Updated**: 2025-01-12  
**Total Documents**: 26 (organized)

---

## 📂 Verzeichnisstruktur

```
MD-Files/
├── 01-Planning/          # Projekt-Planung & Design
├── 02-Setup/             # Installation & Konfiguration
├── 03-Security/          # Security Dokumentation
├── 04-Features/          # Feature-Dokumentation
├── 05-Testing/           # Test-Dokumentation
├── 06-Status/            # Projekt-Status & Logs
└── Archive/              # Archivierte Dokumente
    ├── v2.0/            # Version 2.0 Dokumente
    └── detailed_plans/  # Detaillierte Planungsdokumente
```

---

## 🗂️ Dokumenten-Übersicht

### 📋 01-Planning (Projekt-Planung)
- **PRD_v3.0.md** (24.4 KB)
  - Product Requirements Document Version 3.0
  - Definiert Features, Scope, User Stories
  - Reference für alle Feature-Entwicklung

- **Development_Plan_v3.0.md** (25.1 KB)
  - Entwicklungsplan mit Sprints und Meilensteinen
  - Timeline und Prioritäten
  - MVP-Scope und spätere Phasen

- **Tower_Ideas_Archive.md** (5.3 KB)
  - Sammlung von Tower-Design-Ideen
  - Brainstorming für zukünftige Features
  - Einige bereits implementiert

---

### ⚙️ 02-Setup (Installation & Konfiguration)
- **Getting_Started.md** (1.3 KB)
  - Quick Start Guide
  - Erste Schritte für Entwickler

- **Environment_Setup.md** (4.7 KB)
  - .env Datei Konfiguration
  - Environment Variables
  - Godot Setup

- **Supabase_Setup.md** (11.0 KB)
  - Supabase Projekt-Setup
  - Database Schema
  - RLS Policies
  - API Keys

- **Deployment.md** (2.0 KB)
  - Netlify/Vercel Deployment
  - Environment Variables für Production
  - CI/CD Hinweise

- **Web_Build.md** (2.6 KB)
  - Godot Web Export
  - Browser-Kompatibilität
  - Performance Optimierungen

---

### 🔒 03-Security (Security Dokumentation)
- **Quickstart_Security.md** (2.7 KB)
  - 5-Minuten Security Setup
  - Wichtigste Security-Maßnahmen
  - Quick Checklist

- **Security_Fixes_History.md** (9.5 KB)
  - Historie aller Security-Fixes
  - HMAC Implementation
  - CSP Headers
  - Supabase Keys Externalisierung

- **Server_Validation.md** (8.7 KB)
  - Server-Side Tower Validation
  - SQL Triggers
  - Anti-Cheat Maßnahmen
  - Deployment Guide

**Security Score**: 9.2/10 ✅

---

### 🎮 04-Features (Feature-Dokumentation)
- **Save_System.md** (8.0 KB)
  - Cloud-First Save Strategy
  - HMAC Checksums
  - Auto-Save System
  - Local & Cloud Sync

- **Tower_Hotkey_System.md** (konsolidiert, neu)
  - Q/W/E/R Hotkeys
  - Toggle-Funktionalität
  - Implementation Details
  - Troubleshooting

- **Tower_Placement_Blocking.md** (8.8 KB)
  - UI-Element Blocking
  - Collision Detection
  - Vector Transformations

---

### 🧪 05-Testing (Test-Dokumentation)
- **How_To_Run_Tests.md** (8.3 KB)
  - Test-Ausführung (3 Methoden)
  - Troubleshooting
  - Test-Strategie
  - Expected Output

- **Testing_Summary.md** (6.7 KB)
  - Test Coverage: 100% (20/20)
  - Signal-based Pattern
  - Impact Analysis

- **Test_Fixes.md** (5.4 KB)
  - Signal-based Testing Pattern
  - Migration von Return-Values zu Signals
  - Code-Beispiele

- **Testing_Framework_Details.md** (13.2 KB)
  - Technische Details zum Test-Framework
  - Test-Kategorien
  - Performance Impact
  - Test-Erstellung

- **Tower_Placement_Tests.md** (10.4 KB)
  - Spezifische Tests für Tower Placement
  - UI-Blocking Tests
  - Collision Tests

**Test Coverage**: 100% (20/20 Tests) ✅

---

### 📊 06-Status (Projekt-Status & Logs)
- **Project_Status.md** (18.2 KB)
  - Aktueller Projekt-Status
  - Security Score: 9.2/10
  - Abgeschlossene Features
  - Roadmap & Nächste Schritte
  - **WICHTIG**: Haupt-Referenz für Projekt-Fortschritt

- **Work_Log_2025-01-12.md** (9.5 KB)
  - Arbeitslog vom 2025-01-12
  - Test-Migration auf Signal-based
  - Server-Side Validation Implementation
  - Impact Analysis

---

### 📦 Archive (Archivierte Dokumente)

#### Archive/v2.0/ (Alte Version)
- **PRD_v2.0.md** (9.6 KB)
- **Development_Plan_v2.0.md** (12.7 KB)
- **Feature_Matrix_v2.0.md** (13.5 KB)

#### Archive/detailed_plans/ (Detaillierte Planungsdokumente)
- **Web_App_Implementation_Security_Review.md** (53.4 KB)
  - Sehr detaillierter Implementierungsplan
  - Security-Review
  - Größtenteils bereits umgesetzt

- **Testing_System_Overview.md** (6.4 KB)
  - Alte Test-Framework Übersicht
  - Ersetzt durch How_To_Run_Tests.md

- **Tower_Hotkey_v1.0_Cleanup_Solution.md** (8.0 KB)
  - Version 1.0 der Hotkey-Lösung (Cleanup-Problem)
  
- **Tower_Hotkey_v2.0_Toggle_Solution.md** (10.0 KB)
  - Version 2.0 der Hotkey-Lösung (Toggle-Feature)

- **Environment_Setup_Old.md** (1.1 KB)
  - Alte Environment Setup Doku

---

## 🔍 Schnellzugriff

### Für neue Entwickler:
1. **Getting_Started.md** - Start hier
2. **Environment_Setup.md** - .env Konfiguration
3. **Supabase_Setup.md** - Backend Setup
4. **How_To_Run_Tests.md** - Tests ausführen

### Für Feature-Entwicklung:
1. **PRD_v3.0.md** - Feature-Requirements
2. **Development_Plan_v3.0.md** - Roadmap
3. **Project_Status.md** - Was ist implementiert?
4. **04-Features/** - Bestehende Features verstehen

### Für Deployment:
1. **Deployment.md** - Deployment Guide
2. **Quickstart_Security.md** - Security Checklist
3. **Server_Validation.md** - SQL Triggers deployen
4. **Project_Status.md** - Pre-Deployment Checklist

### Für Testing:
1. **How_To_Run_Tests.md** - Tests ausführen
2. **Test_Fixes.md** - Signal-based Pattern
3. **Testing_Framework_Details.md** - Framework verstehen

---

## 📈 Statistiken

| Kategorie | Anzahl Dokumente | Gesamt-Größe |
|-----------|------------------|--------------|
| Planning | 3 | ~55 KB |
| Setup | 5 | ~20 KB |
| Security | 3 | ~21 KB |
| Features | 3 | ~25 KB |
| Testing | 5 | ~43 KB |
| Status | 2 | ~28 KB |
| **Total (Active)** | **21** | **~192 KB** |
| Archive | 5 | ~100 KB |
| **Grand Total** | **26** | **~292 KB** |

---

## 🔄 Wartung

### Neue Dokumente hinzufügen:
1. Wähle passende Kategorie (01-06)
2. Verwende konsistente Namenskonvention (Snake_Case)
3. Update diesen INDEX.md
4. Update README.md im Root

### Dokumente archivieren:
- Alte Versionen → `Archive/v{version}/`
- Detaillierte Planungsdokumente → `Archive/detailed_plans/`
- Immer Grund für Archivierung dokumentieren

### Redundanzen vermeiden:
- Vor neuem Dokument prüfen: Existiert bereits ähnliches?
- Lieber bestehende Docs erweitern als neue erstellen
- Veraltete Docs zeitnah archivieren

---

## 📝 Namenskonventionen

- **Dateinamen**: Snake_Case (z.B. `Tower_Hotkey_System.md`)
- **Verzeichnisse**: Nummeriert + Beschreibung (z.B. `01-Planning`)
- **Archive**: Versionsnummer oder Kategorie (z.B. `v2.0`, `detailed_plans`)

---

## 🔗 Verwandte Ressourcen

- **Hauptverzeichnis**: `bee-keeper-td/`
- **README.md**: Haupt-README (im Root)
- **SQL Scripts**: `SERVER_SIDE_VALIDATION.sql` (im Root)
- **Environment**: `.env`, `.env.example` (im Root)

---

**Letzte Reorganisation**: 2025-01-12  
**Durchgeführt von**: Dokumentations-Konsolidierung  
**Status**: ✅ Complete & Organized
