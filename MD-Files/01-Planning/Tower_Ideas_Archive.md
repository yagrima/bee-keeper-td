# 🏗️ Tower Ideas Archive - Bee Keeper TD

*Sammlung aller Turmideen für zukünftige Implementierung*

---

## 📋 **Grundlegende Turmtypen (Erste Iteration)**

### 🎯 **Stinger Tower (Einzelziel-Spezialist)**
**Konzept:** Präzise, hochfrequente Einzelziel-Angriffe
- **Mechanik:** Schnelle, schwache Projektile auf ein Ziel
- **Spielerverhalten:** Platzierung an Engstellen, wo Feinde einzeln durchlaufen
- **Stärke:** Viele schwache Feinde, konstanter DPS
- **Schwäche:** Tanky Einzelfeinde, AoE-Situationen
- **Honey Cost:** 20
- **Status:** Konzept erstellt
- **Kategorie:** Offensiv

### 🌪️ **Pollen Cloud Tower (Flächen-Spezialist)**
**Konzept:** Bereichsschäden über Zeit ohne Projektile
- **Mechanik:** Erzeugt giftige Pollenwolken in einem Radius um sich
- **Spielerverhalten:** Strategische Platzierung an Kurven/Kreuzungen
- **Stärke:** Gruppen von Feinden, Crowd Control
- **Schwäche:** Schnelle Einzelfeinde, die durch den Bereich hindurcheilen
- **Honey Cost:** 35
- **Status:** Konzept erstellt
- **Kategorie:** Offensiv/Area Control

### 🛡️ **Honey Trap Tower (Unterstützungs-Spezialist)**
**Konzept:** Verlangsamt Feinde, unterstützt andere Türme
- **Mechanik:** Schießt Honig-Projektile, die Feinde verkleben und verlangsamen
- **Spielerverhalten:** Kombination mit anderen Türmen für Synergien
- **Stärke:** Macht alle anderen Türme effektiver, Zeitgewinn
- **Schwäche:** Kein direkter Schaden, teuer in der Alleinstellung
- **Honey Cost:** 25
- **Status:** Konzept erstellt
- **Kategorie:** Unterstützung

### ⚡ **Worker Drone Tower (Ressourcen-Spezialist)**
**Konzept:** Schwacher Kampf, aber generiert zusätzliche Ressourcen
- **Mechanik:** Langsame, mittlere Angriffe + produziert 1 Honey alle 10 Sekunden
- **Spielerverhalten:** Investment für längere Spiele, Economy-Building
- **Stärke:** Ressourcen-Generation, nachhaltiges Gameplay
- **Schwäche:** Schwacher Kampfwert, braucht Schutz durch andere Türme
- **Honey Cost:** 40
- **Status:** Konzept erstellt
- **Kategorie:** Unterstützung/Ressourcen

---

## 📊 **Gameplay-Dynamik Analyse**
- **Stinger** → Spam-Platzierung für konstanten DPS
- **Pollen Cloud** → Strategische Area-Denial Platzierung
- **Honey Trap** → Synergy-Kombinationen mit anderen Türmen
- **Worker Drone** → Economy-Management und Planning

**Design-Prinzipien:**
1. **Einzelziel vs. Gruppe**
2. **Direkter Schaden vs. Area Control**
3. **Solo-Power vs. Team-Synergy**
4. **Sofort-Kraft vs. Investment-Strategie**

---

## 🔮 **Zukünftige Turm-Kategorien**

### **Offensiv-Türme**
- Direkter Schaden auf Feinde
- Verschiedene Angriffsmuster
- Unterschiedliche Zielpriorisierung

### **Defensiv-Türme**
- Verlangsamung, Betäubung
- Area Denial Effects
- Crowd Control Mechaniken

### **Unterstützungs-Türme**
- Buff andere Türme
- Ressourcen-Generation
- Informations-/Scouting-Fähigkeiten

### **Spezial-Türme**
- Einzigartige Mechaniken
- Situative Anwendung
- Komplexe Interaktionen

---

## ⚔️ **Vier Offensive Grundtürme (Finaler Vorschlag)**

### 🎯 **Stinger Tower (Schnellfeuer-Spezialist)**
**Konzept:** Hochfrequente, schwache Einzelschüsse
- **Angriff:** 8 Schaden, 2.5 Angriffe/Sekunde
- **Reichweite:** 80 Pixel
- **Targeting:** Nächster Feind
- **Honey Cost:** 20
- **Status:** ✅ IMPLEMENTIERT
- **Kategorie:** Offensiv

### 💥 **Propolis Bomber (Explosions-Spezialist)**
**Konzept:** Langsame, mächtige Explosions-Projektile aus klebrigem Propolis
- **Angriff:** 35 Schaden, 0.8 Angriffe/Sekunde, 40px Explosion
- **Reichweite:** 100 Pixel
- **Targeting:** Feind mit den meisten HP in Reichweite
- **Honey Cost:** 45
- **Status:** ✅ IMPLEMENTIERT
- **Kategorie:** Offensiv

### 🌊 **Nectar Sprayer (Durchdringungs-Spezialist)**
**Konzept:** Projektile durchdringen mehrere Feinde in einer Linie
- **Angriff:** 15 Schaden, 1.2 Angriffe/Sekunde, durchdringt 3 Feinde
- **Reichweite:** 120 Pixel
- **Targeting:** Feind am weitesten entfernt (für max. Durchdringung)
- **Honey Cost:** 30
- **Status:** ✅ IMPLEMENTIERT
- **Kategorie:** Offensiv

### ⚡ **Lightning Flower (Kettenblitz-Spezialist)**
**Konzept:** Blitze springen zwischen nahen Feinden
- **Angriff:** 12 Schaden, 1.5 Angriffe/Sekunde, springt auf 2 nahe Feinde
- **Reichweite:** 90 Pixel (Sprung-Reichweite: 50px)
- **Targeting:** Feind mit den wenigsten HP (für Kettenreaktionen)
- **Honey Cost:** 35
- **Status:** ✅ IMPLEMENTIERT
- **Kategorie:** Offensiv

**Gameplay-Unterschiede:**
- **Stinger** → Anti-Swarm, konstanter DPS
- **Propolis Bomber** → Anti-Tank, Gruppenschäden
- **Nectar Sprayer** → Anti-Line-Formation, Mehrfachtreffer
- **Lightning Flower** → Anti-Cluster, Kettenreaktionen

---

## 📝 **Template für neue Turm-Ideen**

### **[Turmname] ([Spezialisierung])**
**Konzept:** [Kurze Beschreibung der Grundidee]
- **Mechanik:** [Wie der Turm funktioniert]
- **Spielerverhalten:** [Wie Spieler den Turm einsetzen]
- **Stärke:** [Wogegen der Turm gut ist]
- **Schwäche:** [Wo der Turm versagt]
- **Honey Cost:** [Kosten]
- **Status:** [Konzept/In Entwicklung/Implementiert]
- **Kategorie:** [Offensiv/Defensiv/Unterstützung/Spezial]

---

*Letzte Aktualisierung: 29.12.2024*
*Erstellt von: Claude (KI-Assistent)*