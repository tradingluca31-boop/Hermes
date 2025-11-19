# 🚀 HERMÈS 2.5 - GUIDE INSTALLATION

## 📂 FICHIERS MQL5

```
MQL5/
├── Hermes_2.5.mq5              # EA principal (main) - COMPILER CE FICHIER
├── Hermes_Config.mqh           # Configuration centralisée
├── Hermes_Indicators.mqh       # 21 indicateurs techniques
├── Hermes_RiskManager.mqh      # Position sizing Kelly + 7 multiplicateurs
├── Hermes_TrailingStop.mqh     # Trailing stop 7 paliers
├── Hermes_SessionManager.mqh   # Sessions, news blackout, weekend
├── Hermes_Logger.mqh           # Logging CSV (3 fichiers)
└── README_INSTALLATION.md      # Ce fichier
```

---

## 📥 INSTALLATION DANS MT5

### ÉTAPE 1: Copier les Fichiers

**Destination**: Dossier MetaTrader 5 Experts

```
Windows:
C:\Users\[USER]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\MQL5\Experts\

Créer sous-dossier: Hermes/
```

**Structure finale**:
```
MQL5\Experts\Hermes\
├── Hermes_2.5.mq5
├── Hermes_Config.mqh
├── Hermes_Indicators.mqh
├── Hermes_RiskManager.mqh
├── Hermes_TrailingStop.mqh
├── Hermes_SessionManager.mqh
└── Hermes_Logger.mqh
```

**IMPORTANT**: Tous les fichiers .mqh doivent être dans le MÊME dossier que Hermes_2.5.mq5

---

### ÉTAPE 2: Compiler dans MetaEditor

1. **Ouvrir MetaEditor** (F4 dans MT5)
2. **Naviguer** vers `Experts\Hermes\Hermes_2.5.mq5`
3. **Compiler** (F7 ou bouton Compile)
4. **Vérifier**:
   - ✅ `0 errors, 0 warnings`
   - ✅ Fichier `Hermes_2.5.ex5` créé

**Si erreurs de compilation**:
- Vérifier que TOUS les .mqh sont présents
- Vérifier chemins d'#include
- Vérifier syntaxe MQL5

---

### ÉTAPE 3: Charger sur Graphique

1. **Ouvrir graphique XAUUSD M15**
2. **Navigateur** (Ctrl+N) → Expert Advisors → Hermes → Hermes_2.5
3. **Glisser-déposer** sur graphique
4. **Fenêtre paramètres** s'ouvre

---

## ⚙️ PARAMÈTRES PRINCIPAUX

### VALIDATION (Laisser par défaut au début)
```
Min_Votes_H4 = 3        # Sur 5 (60%)
Min_Votes_H1 = 5        # Sur 8 (63%)
Min_Votes_M15 = 4       # Sur 6 (67%)
Min_Votes_Macro = 1     # Sur 2 (50%)
Min_Votes_Total = 14    # Sur 21 (67%)
```

### RISK MANAGEMENT
```
Kelly_Cap = 0.25                 # 25% max
Base_Risk_Percent = 0.7          # 0.7% base
Min_Risk_Percent = 0.33          # 0.33% minimum
Max_Risk_Percent = 1.00          # 1.00% maximum
Daily_Loss_Max = 2.0             # 2% daily loss max
```

### SESSIONS
```
Enable_Asian_Session = false     # INTERDITE (laisser false)
Enable_London_Session = true
Enable_Overlap_Session = true    # MEILLEURE (14h-17h)
Enable_NY_Session = true
```

### PROTECTIONS
```
Max_Spread_Pips = 6.0            # 6 pips max
News_Blackout_Hours = 1          # 1h avant/après
Weekend_Block_Hour_Friday = 20   # 20h vendredi
Weekend_Allow_Hour_Sunday = 23   # 23h dimanche
```

### SHAP ANALYSIS
```
SHAP_Analysis_Frequency = 50     # Tous les 50 trades
SHAP_Min_Trades = 300            # Minimum pour 1ère optim
Enable_Auto_CSV_Export = true
```

### POIDS INDICATEURS
```
# Laisser TOUS à 1.0 au démarrage
# Ajuster après 6 mois selon SHAP analysis
```

---

## ✅ CHECKLIST AVANT LANCEMENT

### MT5 Configuration
- [ ] Symbol = **XAUUSD**
- [ ] Timeframe = **M15**
- [ ] **AutoTrading activé** (bouton vert en haut)
- [ ] Compte démo ou compte réel selon objectif

### EA Settings
- [ ] Magic Number = 250125
- [ ] Tous poids indicateurs = 1.0
- [ ] Sessions configurées (Asian = false)
- [ ] Daily loss max = 2%

### Fichiers Externes (Optionnels)
- [ ] `data/cot_data.csv` (si COT data disponible)
- [ ] `data/macro_events.csv` (calendrier économique)

### Dossiers Logs
- [ ] `logs/` créé (MT5 le créera auto)
- [ ] `logs/hermes_trades_detailed.csv` (généré auto)
- [ ] `logs/hermes_shap_analysis.csv` (après 50 trades)
- [ ] `logs/hermes_summary.csv` (avec SHAP)

---

## 🎯 LANCEMENT

1. **Clic droit** sur graphique → **Expert Advisors** → **Properties**
2. **Onglet Common**:
   - ✅ Allow live trading
   - ✅ Allow DLL imports (si nécessaire)
3. **Onglet Inputs**: Vérifier paramètres
4. **OK**

### Vérifications Post-Lancement

**Dans l'onglet "Experts" (Toolbox → Experts)**:
```
✅ "HERMÈS 2.5 STARTING"
✅ "Checking broker and symbol compatibility..."
✅ "Initializing 21 technical indicators..."
✅ "All 21 indicators initialized successfully"
✅ "HERMÈS 2.5 READY FOR TRADING 🚀"
```

**Smiley dans coin supérieur droit du graphique**:
- 😊 = EA actif et prêt
- 😞 = EA erreur ou désactivé

---

## 📊 MONITORING

### Fichiers CSV (après trades)

**`logs/hermes_trades_detailed.csv`**:
- Enregistré après chaque trade fermé
- Contient les 21 indicateurs (1/0)
- Ouvrir avec Excel

**`logs/hermes_shap_analysis.csv`**:
- Généré tous les 50 trades
- Contribution de chaque indicateur
- Status: CRITICAL / HIGH / MEDIUM / LOW / REMOVE

**`logs/hermes_summary.csv`**:
- Métriques globales
- Win rate, avg R, profit factor

### Logs MetaTrader 5

**Onglet "Experts"**:
- Affiche tous les prints Hermès
- Signaux validés, trades ouverts/fermés
- Trailing stop activations
- SHAP analysis triggers

---

## 🐛 TROUBLESHOOTING

### EA ne démarre pas
```
❌ "Expert removed from chart"
→ Vérifier AutoTrading activé
→ Vérifier symbol = XAUUSD
→ Vérifier compilation réussie
```

### Erreur "Indicator failed"
```
❌ "ADX H4 failed"
→ Vérifier broker fournit historique H4
→ Télécharger historique: Tools → History Center
```

### Pas de trades
```
⚠️ "Session not allowed"
→ Normal si Asian/Dead Zone
→ Attendre London (09h) ou Overlap (14h)

⚠️ "Signal not validated"
→ Normal - minimum 14/21 votes requis
→ Hermès est TRÈS sélectif (qualité > quantité)
```

### Spread too high
```
⛔ "Spread too high: 8.0 pips"
→ Normal pendant Asian/Dead Zone
→ Utiliser broker avec spreads serrés (< 3 pips XAUUSD)
```

### Fichiers CSV non générés
```
⚠️ "Cannot create trades detailed CSV"
→ Vérifier dossier logs/ existe
→ Vérifier permissions écriture
→ Créer manuellement: C:\Users\[USER]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\logs\
```

---

## 📈 OPTIMISATION (Après 6 Mois)

### SHAP Analysis Workflow

**1. Attendre 300+ trades**
```
Logs → "SHAP analysis updated - Check CSV files"
```

**2. Ouvrir `hermes_shap_analysis.csv`**

**3. Trier par `contribution_delta` (décroissant)**

**4. Identifier**:
- CRITICAL (> +0.8R): Augmenter poids à 3.0
- HIGH (> +0.5R): Augmenter poids à 2.5
- MEDIUM (> +0.2R): Garder poids 1.0
- WEAK (< -0.05R): Réduire poids à 0.0 (ou supprimer)

**5. Modifier `Hermes_Config.mqh`**:
```cpp
// AVANT
input double Weight_VWAP_M15 = 1.0;

// APRÈS (si VWAP = CRITICAL)
input double Weight_VWAP_M15 = 3.0;
```

**6. Recompiler et relancer**

**7. Répéter tous les 6 mois**

---

## 🎓 RAPPELS IMPORTANTS

### Trading Institutionnel ≠ Amateur
- **Hermès est SÉLECTIF**: 2-3 trades/semaine est NORMAL
- **Qualité > Quantité**: Minimum 14/21 votes = très exigeant
- **Patience**: Laisse courir les gains (trailing, pas de TP)
- **Discipline**: Jamais modifier paramètres pendant trading

### FTMO Compliance
- Daily loss max: 2% (Hermès = auto-block)
- Overall DD max: Hermès surveille à 8%/15%/20%
- Minimum 4 jours trading: Planifier selon
- Profit target: Hermès vise +15-18% annualisé

### Maintenance
- **Logs**: Archiver tous les 3 mois
- **SHAP**: Réanalyser tous les 6 mois
- **Historique**: Télécharger régulièrement (Tools → History Center)

---

## 🚨 NEVER DO

- ❌ Modifier poids sans SHAP analysis
- ❌ Trader sur autre paire que XAUUSD
- ❌ Changer timeframe (doit rester M15)
- ❌ Désactiver protections (sessions, DD, daily loss)
- ❌ Utiliser sur compte réel avant backtest 6 mois demo

---

**🏛️ Hermès 2.5 - Expert Advisor Institutionnel pour XAUUSD**

*Version 2.50 | 2025-01-19*
*Hedge Fund Grade Trend-Following System*
