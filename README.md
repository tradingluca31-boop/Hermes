# Hermes 2.5 - Expert Advisor Institutionnel XAUUSD

**Version 2.50** | EA de trading automatique pour XAUUSD (Gold) optimise pour les comptes FTMO.

## Architecture

```
Hermes_2.5.mq5          <- EA Principal
    |
    +-- Hermes_Config.mqh        <- Configuration centralisee
    +-- Hermes_Indicators.mqh    <- 20 indicateurs techniques
    +-- Hermes_SessionManager.mqh <- Gestion sessions & regime
    +-- Hermes_RiskManager.mqh   <- Kelly Criterion + 7 multiplicateurs
    +-- Hermes_TrailingStop.mqh  <- Trailing 7 paliers
    +-- Hermes_Logger.mqh        <- CSV export + SHAP analysis
```

## Caracteristiques

### Systeme de Votes Multi-Timeframe
- **20 indicateurs** repartis sur 3 timeframes (H4, H1, M15) + Macro
- Minimum **17/20 votes** (85%) requis pour ouvrir un trade
- Validation par niveau : H4 (3/5), H1 (6/8), M15 (3/6), Macro (0/1)

### Indicateurs

#### H4 (5 indicateurs)
| # | Indicateur | Parametres |
|---|------------|------------|
| 1 | ADX | periode 14 |
| 2 | EMA Cross | 21/55 |
| 3 | EMA Trend | 50/200 |
| 4 | Prix vs EMA21 | - |
| 5 | Supertrend | ATR 10 |

#### H1 (8 indicateurs)
| # | Indicateur | Parametres |
|---|------------|------------|
| 6 | EMA Cross Signal | 21/55 |
| 7 | MACD | 12, 26, 9 |
| 8 | RSI | periode 14 |
| 9 | Parabolic SAR | 0.02, 0.2 |
| 10 | Stochastic | 14, 3, 3 |
| 11 | Bollinger Width | 20, dev 2.0 |
| 12 | Volume Momentum | - |
| 13 | Donchian | - |

#### M15 (6 indicateurs)
| # | Indicateur | Parametres |
|---|------------|------------|
| 14 | VWAP | - |
| 15 | Order Flow Delta | - |
| 16 | Volatility Regime | - |
| 17 | Tick Momentum | - |
| 18 | EURUSD Correlation | - |
| 19 | Effective Spread | - |

#### Macro (1 indicateur)
| # | Indicateur | Description |
|---|------------|-------------|
| 20 | ATR Percentile | Volatilite relative (top 60%) |

> **Note:** COT (Commitment of Traders) a ete desactive pour simplifier l'EA.

### Risk Management

| Parametre | Valeur |
|-----------|--------|
| **Risque par trade** | $150 fixe |
| **Calcul lot** | `Lot = $150 / (SL x 100)` |
| **Stop Loss** | ATR H1 x 3.0 |
| **Take Profit** | SL x 3.0 (RR 3:1) |
| **Max positions** | 1 |
| **Max trades/jour** | 1 |

### Trailing Stop 7 Paliers

| Palier | Declenchement | Nouveau SL | Gain Securise |
|--------|---------------|------------|---------------|
| 1 | +0.5R | Entry -0.3R | Risque -70% |
| 2 | +1.0R | Entry | BREAKEVEN |
| 3 | +1.5R | Entry +1.0R | 25% |
| 4 | +2.0R | Entry +1.5R | 37.5% |
| 5 | +2.5R | Entry +2.0R | 50% |
| 6 | +3.0R | Entry +2.5R | 62.5% |
| 7 | +3.5R+ | Trailing continu | Offset 1.5R |

### Sessions Trading

| Session | Heures (UTC+1) | Status |
|---------|----------------|--------|
| Asian | 01h-09h | Desactive |
| London | 09h-14h | Active |
| Overlap | 14h-17h | Active (meilleure) |
| New York | 17h-22h | Active |

### Protections FTMO

- Max Spread : 6 pips
- Weekend Block : Vendredi 20h
- Gap Detection : ATR x 2.0
- Daily Loss Max : 2%

## Performance Backtest

| Metrique | Valeur |
|----------|--------|
| Profit | +24% |
| Drawdown Max | 5.12% |
| Profit Factor | 2.07 |
| Sharpe Ratio | 4.66 |
| Win Rate | 46.55% |
| Gain moyen | $173 |
| Perte moyenne | $72 |

## Installation

1. Copier tous les fichiers dans `MQL5/Experts/`
2. Compiler `Hermes_2.5.mq5` dans MetaEditor
3. Attacher l'EA sur un chart XAUUSD H1
4. Activer le trading automatique

## Fichiers

| Fichier | Description |
|---------|-------------|
| `Hermes_2.5.mq5` | EA principal |
| `Hermes_Config.mqh` | Configuration et parametres |
| `Hermes_Indicators.mqh` | 21 indicateurs |
| `Hermes_SessionManager.mqh` | Gestion sessions |
| `Hermes_RiskManager.mqh` | Gestion risque |
| `Hermes_TrailingStop.mqh` | Trailing stop 7 paliers |
| `Hermes_Logger.mqh` | Logging et CSV export |

## Fonctionnalites Avancees

### Detection de Regime Momentum
Score /8 base sur 4 metriques:
- ADX (force trend)
- ATR Ratio (volatilite)
- R² Regression (linearite)
- Efficiency Ratio Kaufman (directionnalite)

| Regime | Score | Action |
|--------|-------|--------|
| Strong Trend | >= 6/8 | Boost +20% |
| Weak Trend | 4-5/8 | Normal |
| Ranging | < 4/8 | Reduction 50% |

### SHAP Analysis
Export CSV automatique pour analyse des indicateurs:
- `hermes_trades_detailed.csv` - Details de chaque trade
- `hermes_shap_analysis.csv` - Contribution de chaque indicateur
- `hermes_summary.csv` - Metriques globales

## Compatibilite

- MetaTrader 5
- XAUUSD uniquement
- Comptes FTMO (Free Trial, Challenge, Funded)

## Auteur

Trading System by Hermes

---
*Generated with Claude Code*
