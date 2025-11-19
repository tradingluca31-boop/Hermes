# 🏛️ HERMÈS 2.5 - Expert Advisor Institutionnel

## Vue d'Ensemble

**Hermès 2.5** est un Expert Advisor (EA) MQL5 de niveau hedge fund pour le trading de **XAUUSD (Gold)**.

**Type**: Trend-Following Institutionnel
**Paire**: XAUUSD uniquement
**Timeframes**: H4 (Macro) + H1 (Setup) + M15 (Timing)
**Version**: 2.5
**Date**: 2025-01-19

---

## 🎯 Caractéristiques Principales

### Architecture Tri-Timeframe
```
🏔️ H4 (4h)  → Macro Trend Direction
⛰️ H1 (1h)   → Setup Construction
🎯 M15 (15m) → Timing Précis
```

### 21 Indicateurs Techniques
- **H4 (5)**: ADX, EMA 21/55, EMA 50/200, Prix/EMA21, Supertrend
- **H1 (8)**: EMA Cross, MACD, RSI, SAR, Stochastic, Bollinger, Volume, Donchian
- **M15 (6)**: VWAP, Order Flow, Volatility, Tick Momentum, EURUSD Corr, Spread
- **Macro (2)**: COT (Smart Money), ATR Percentile

### Système de Validation
- Vote démocratique: Tous poids = 1.0 au démarrage
- Consensus minimum: **14/21 votes (67%)**
- Validation par niveau: H4≥3/5, H1≥5/8, M15≥4/6, Macro≥1/2
- **Aucun indicateur obligatoire** ou éliminatoire

### Risk Management Institutionnel
- **Position Sizing**: Kelly conservateur (0.33-1.00% par trade)
- **7 Multiplicateurs**: Confidence, Session, Regime, Sequence, DD, COT, Spread
- **Daily Loss Max**: 2% réalisé → Block nouveaux trades
- **Drawdown Circuit Breakers**: 8% / 15% / 20%
- **Trailing Stop**: 7 paliers progressifs (0.5R → 3.5R+)
- **Take Profit**: AUCUN (laisse courir les tendances)

### Protections Temporelles
- ❌ **Asian Session interdite** (01h-09h Paris)
- 🔥 **Overlap London-NY** boosté ×1.3 (14h-17h Paris)
- 🚫 **News Blackout** 1h avant/après événements majeurs
- ⚠️ **Weekend Risk**: Pas de nouveaux trades vendredi 20h+

### Optimisation Continue
- **SHAP Analysis** automatique tous les 50 trades
- Logging exhaustif de tous les indicateurs
- Ajustement des poids tous les 6 mois
- 3 fichiers CSV générés automatiquement

---

## 📂 Structure du Projet

```
Hermes/
├── MQL5/
│   ├── Hermes_2.5.mq5              # EA principal
│   ├── Hermes_Indicators.mqh       # Librairie 21 indicateurs
│   ├── Hermes_RiskManager.mqh      # Position sizing & protections
│   ├── Hermes_TrailingStop.mqh     # Système 7 paliers
│   ├── Hermes_Logger.mqh           # Logging CSV
│   └── Hermes_SHAP.mqh             # SHAP analysis
├── docs/
│   ├── SPECIFICATIONS_COMPLETE.md  # Specs complètes (ce document)
│   ├── ARCHITECTURE.md             # Architecture technique
│   ├── CHECKLIST_IMPLEMENTATION.md # Checklist développement
│   ├── GUIDE_UTILISATION.md        # Guide utilisateur
│   └── GUIDE_OPTIMIZATION.md       # Guide SHAP optimization
├── backtest/
│   ├── backtest_report.html        # Rapport backtest MT5
│   └── optimization_results/       # Résultats optimisations
├── logs/
│   ├── hermes_trades_detailed.csv  # Tous les trades (logging)
│   ├── hermes_shap_analysis.csv    # SHAP analysis
│   └── hermes_summary.csv          # Statistiques globales
├── data/
│   ├── cot_data.csv                # COT weekly data
│   └── macro_events.csv            # Calendrier économique
├── tests/
│   └── test_indicators.mq5         # Tests unitaires indicateurs
└── README.md                        # Ce fichier
```

---

## 🚀 Installation

### 1. Copier les Fichiers MQL5

```bash
# Copier les fichiers .mq5 et .mqh dans MetaTrader 5
Source: C:\Users\lbye3\Desktop\Hermes\MQL5\*
Destination: C:\Users\[USER]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\MQL5\Experts\
```

### 2. Compiler dans MT5

1. Ouvrir MetaEditor (F4 dans MT5)
2. Ouvrir `Hermes_2.5.mq5`
3. Compiler (F7)
4. Vérifier 0 erreurs, 0 warnings

### 3. Charger sur Graphique XAUUSD

1. Ouvrir graphique XAUUSD M15
2. Glisser-déposer `Hermes_2.5` depuis Navigateur → Expert Advisors
3. Activer "Autoriser le trading automatique" (AutoTrading ON)
4. Configurer les paramètres (voir GUIDE_UTILISATION.md)

---

## ⚙️ Paramètres Principaux

### Risk Management
```
Kelly_Cap = 0.25                    // Kelly fraction maximum
Base_Risk_Percent = 0.7             // Base risk (avant multiplicateurs)
Min_Risk_Percent = 0.33             // Minimum absolu par trade
Max_Risk_Percent = 1.00             // Maximum absolu par trade
Daily_Loss_Max = 2.0                // % perte journalière max
```

### Validation
```
Min_Votes_H4 = 3                    // Sur 5 indicateurs H4
Min_Votes_H1 = 5                    // Sur 8 indicateurs H1
Min_Votes_M15 = 4                   // Sur 6 indicateurs M15
Min_Votes_Macro = 1                 // Sur 2 indicateurs Macro
Min_Votes_Total = 14                // Sur 21 total (67%)
```

### Sessions
```
Enable_Asian_Session = false        // Asian INTERDITE
Enable_London_Session = true        // 09h-14h Paris
Enable_Overlap_Session = true       // 14h-17h Paris (×1.3)
Enable_NY_Session = true            // 17h-22h Paris
```

### Protections
```
Max_Spread_Pips = 6.0               // Spread max absolu
Max_Spread_vs_ATR = 0.30            // 30% de l'ATR M15
News_Blackout_Hours = 1             // 1h avant/après news
Weekend_Block_Hour_Friday = 20      // Vendredi 20h
Weekend_Allow_Hour_Sunday = 23      // Dimanche 23h
```

### SHAP Analysis
```
SHAP_Analysis_Frequency = 50        // Recalcul tous les 50 trades
SHAP_Min_Trades = 300               // Minimum pour 1ère optimisation
Enable_Auto_CSV_Export = true       // Export CSV automatique
```

---

## 📊 Fichiers CSV Générés

### 1. `hermes_trades_detailed.csv`
Enregistré **après chaque trade fermé**:
- Infos du trade (entry, exit, direction, R multiple, durée)
- Les 21 indicateurs (1 = présent, 0 = absent)
- Votes par niveau (H4, H1, M15, Macro, Total)

### 2. `hermes_shap_analysis.csv`
Généré **tous les 50 trades**:
- Contribution de chaque indicateur (+1.30R à -0.27R)
- Win rate quand présent vs absent
- R moyen quand présent vs absent
- Poids recommandé (0.0 à 3.0)
- Status (CRITICAL / HIGH / MEDIUM / LOW / REMOVE)

### 3. `hermes_summary.csv`
Mis à jour **avec chaque SHAP analysis**:
- Statistiques globales (win rate, avg R, profit factor)
- Nombre d'indicateurs par catégorie (CRITICAL/HIGH/etc)
- Meilleur/pire indicateur
- Période d'analyse

---

## 🎯 Objectifs de Performance (Backtest 5 ans)

```
Win Rate:           55-65%
Profit Factor:      > 1.8
Sharpe Ratio:       > 1.5
Max Drawdown:       < 15%
Daily Max Loss:     < 3%
Trades/an:          80-150
Avg R/trade:        +1.5R à +3.0R
Best trade:         +15R (grandes tendances)
Avg gagnant:        +5.0R (trailing sans TP)
Avg perdant:        -0.8R (trailing protège)
```

---

## 📖 Documentation Complète

- **[SPECIFICATIONS_COMPLETE.md](docs/SPECIFICATIONS_COMPLETE.md)** - Spécifications détaillées
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Architecture technique MQL5
- **[CHECKLIST_IMPLEMENTATION.md](docs/CHECKLIST_IMPLEMENTATION.md)** - Checklist développement
- **[GUIDE_UTILISATION.md](docs/GUIDE_UTILISATION.md)** - Guide utilisateur
- **[GUIDE_OPTIMIZATION.md](docs/GUIDE_OPTIMIZATION.md)** - Guide optimisation SHAP

---

## ⚠️ Important - Différences vs Trading Amateur

| Amateur | Hermès 2.5 Pro |
|---------|----------------|
| 2-3 indicateurs "feeling" | 21 indicateurs vote objectif |
| 1 timeframe (M5/M15) | 3 timeframes hiérarchiques |
| Position fixe (0.1 lot) | Kelly adaptatif × 7 multiplicateurs |
| TP fixe (40 pips) | Trailing sans limite (+5R, +10R, +15R) |
| Trade 24/7 | Asian interdite, focus Overlap |
| Ignore news | Blackout auto 1h avant/après |
| Continue à -20% DD | Circuit breakers 8%/15%/20% |
| Revenge trade | Auto-réduit 50-70% après losses |
| Sur-optimise | SHAP évolutif tous les 6 mois |
| Win rate 45-50% | Win rate 55-65% |

---

## 🏆 Statut Projet

**Version**: 2.5
**Statut**: 🚧 En développement
**Prochaine étape**: Implémentation code MQL5 principal

**Développeur**: Claude Code + lbye3
**Licence**: Propriétaire
**Contact**: Projet privé

---

## 🎓 Ressources

- **MQL5 Documentation**: https://www.mql5.com/en/docs
- **FTMO Rules**: https://ftmo.com/en/
- **COT Reports**: https://www.cftc.gov/MarketReports/CommitmentsofTraders/index.htm
- **SHAP Library**: https://github.com/slundberg/shap

---

**🏛️ Hermès 2.5 - Trading Institutionnel pour XAUUSD**

*"In God we trust, all others bring data." - W. Edwards Deming*
