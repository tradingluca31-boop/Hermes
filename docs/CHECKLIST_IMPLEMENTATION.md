# ✅ CHECKLIST IMPLÉMENTATION HERMÈS 2.5

> **Guide étape par étape pour l'implémentation MQL5 complète**
> **AUCUN POINT NE DOIT ÊTRE OUBLIÉ**

---

## 📋 STRUCTURE FICHIERS MQL5

### Fichiers Principaux à Créer

- [ ] **Hermes_2.5.mq5** - EA principal
- [ ] **Hermes_Indicators.mqh** - Librairie 21 indicateurs
- [ ] **Hermes_RiskManager.mqh** - Position sizing & protections
- [ ] **Hermes_TrailingStop.mqh** - Système 7 paliers
- [ ] **Hermes_Logger.mqh** - Logging CSV
- [ ] **Hermes_SHAP.mqh** - SHAP analysis
- [ ] **Hermes_SessionManager.mqh** - Gestion sessions & news
- [ ] **Hermes_Config.mqh** - Configuration centralisée

---

## 🔢 INDICATEURS TECHNIQUES (21 total)

### H4 - MACRO TREND (5 indicateurs)

#### Indicateur 1: ADX
- [ ] Calcul ADX période 14
- [ ] Condition BUY: ADX > 25
- [ ] Condition SELL: ADX > 25
- [ ] Return: bool (true si validé)
- [ ] Poids par défaut: 1.0

#### Indicateur 2: EMA 21/55 Cross
- [ ] Calcul EMA 21 sur H4
- [ ] Calcul EMA 55 sur H4
- [ ] Condition BUY: EMA 21 > EMA 55
- [ ] Condition SELL: EMA 21 < EMA 55
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 3: EMA 50/200 Cross
- [ ] Calcul EMA 50 sur H4
- [ ] Calcul EMA 200 sur H4
- [ ] Condition BUY: EMA 50 > EMA 200
- [ ] Condition SELL: EMA 50 < EMA 200
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 4: Prix vs EMA 21
- [ ] Récupère Close H4
- [ ] Récupère EMA 21 H4
- [ ] Condition BUY: Close > EMA 21
- [ ] Condition SELL: Close < EMA 21
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 5: Supertrend
- [ ] Calcul Supertrend (ATR 10, Factor 3)
- [ ] Condition BUY: Supertrend signal = BUY
- [ ] Condition SELL: Supertrend signal = SELL
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

---

### H1 - SETUP PRINCIPAL (8 indicateurs)

#### Indicateur 6: EMA Cross H1
- [ ] Détection EMA 21 croise au-dessus EMA 55 (BUY)
- [ ] Détection EMA 21 croise en-dessous EMA 55 (SELL)
- [ ] Lookback: 3 bougies maximum
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 7: MACD
- [ ] Calcul MACD (12/26/9) sur H1
- [ ] Condition BUY: MACD histogram > 0
- [ ] Condition SELL: MACD histogram < 0
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 8: RSI
- [ ] Calcul RSI période 14 sur H1
- [ ] Condition BUY: RSI entre 50-70
- [ ] Condition SELL: RSI entre 30-50
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 9: Parabolic SAR
- [ ] Calcul SAR (start 0.02, max 0.2) sur H1
- [ ] Condition BUY: SAR sous le prix
- [ ] Condition SELL: SAR au-dessus du prix
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 10: Stochastic
- [ ] Calcul Stochastic (14/3/3) sur H1
- [ ] Détection cross up (BUY)
- [ ] Détection cross down (SELL)
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 11: Bollinger Width
- [ ] Calcul Bollinger Bands (20/2) sur H1
- [ ] Calcul Width = (Upper - Lower) / Middle
- [ ] Condition: Width en expansion (> moyenne 20 périodes × 1.2)
- [ ] Return: bool (BUY et SELL)
- [ ] Poids par défaut: 1.0

#### Indicateur 12: Volume Momentum
- [ ] Récupère Volume[0] et Volume[1]
- [ ] Calcul ΔPrice = Close[0] - Close[1]
- [ ] Condition BUY: Volume × ΔPrice > 0 et croissant
- [ ] Condition SELL: Volume × ΔPrice < 0 et décroissant
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 13: Donchian Breakout
- [ ] Calcul High(20) et Low(20) sur H1
- [ ] Condition BUY: Close > High(20)
- [ ] Condition SELL: Close < Low(20)
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

---

### M15 - TIMING INSTITUTIONNEL (6 indicateurs)

#### Indicateur 14: VWAP
- [ ] Calcul VWAP (reset daily à 00h00)
- [ ] Formule: Σ(Price × Volume) / Σ(Volume)
- [ ] Condition BUY: Close > VWAP
- [ ] Condition SELL: Close < VWAP
- [ ] Return: bool
- [ ] Poids par défaut: 1.0
- [ ] **🔥 CRITIQUE SELON SHAP**

#### Indicateur 15: Order Flow Delta
- [ ] Calcul Delta = Upticks - Downticks (lookback 20)
- [ ] Condition BUY: Delta cumulatif > 0 et croissant
- [ ] Condition SELL: Delta cumulatif < 0 et décroissant
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 16: Volatility Regime
- [ ] Calcul ATR actuel vs moyenne ATR(50)
- [ ] Condition: ATR actuel > ATR moyen × 1.2 (expansion)
- [ ] Return: bool (BUY et SELL)
- [ ] Poids par défaut: 1.0

#### Indicateur 17: Tick Momentum
- [ ] Compte Upticks vs Downticks sur 20 bougies
- [ ] Condition BUY: Upticks/Total > 60%
- [ ] Condition SELL: Downticks/Total > 60%
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 18: EURUSD Correlation
- [ ] Récupère Close EURUSD M15
- [ ] Calcul direction EURUSD (hausse/baisse)
- [ ] Condition BUY: EURUSD en hausse
- [ ] Condition SELL: EURUSD en baisse
- [ ] Return: bool
- [ ] Poids par défaut: 1.0

#### Indicateur 19: Effective Spread
- [ ] Calcul spread actuel (Ask - Bid)
- [ ] Calcul spread moyen (20 bougies)
- [ ] Condition: Spread < moyenne (bonne liquidité)
- [ ] Return: bool (BUY et SELL)
- [ ] Poids par défaut: 1.0

---

### MACRO CONTEXT (2 indicateurs)

#### Indicateur 20: COT (Commitment of Traders)
- [ ] Import données COT hebdomadaires (vendredi)
- [ ] Parse Commercials Net Position
- [ ] Classification:
  - [ ] > +80k → +1.0 (STRONG BULLISH)
  - [ ] +30k à +80k → +0.5 (BULLISH)
  - [ ] -30k à +30k → 0 (NEUTRAL)
  - [ ] -80k à -30k → -0.5 (BEARISH)
  - [ ] < -80k → -1.0 (STRONG BEARISH)
- [ ] Return: vote fractionnaire
- [ ] Poids par défaut: 1.0

#### Indicateur 21: ATR Percentile
- [ ] Calcul ATR daily actuel
- [ ] Calcul percentile vs historique 200 jours
- [ ] Condition: ATR dans top 30% (volatilité favorable)
- [ ] Return: bool (BUY et SELL)
- [ ] Poids par défaut: 1.0

---

## ✅ SYSTÈME DE VALIDATION

### Comptage des Votes

- [ ] Fonction `CountVotes_H4()` → return int (0-5)
- [ ] Fonction `CountVotes_H1()` → return int (0-8)
- [ ] Fonction `CountVotes_M15()` → return int (0-6)
- [ ] Fonction `CountVotes_Macro()` → return int (0-2)
- [ ] Fonction `CountVotes_Total()` → return int (0-21)

### Validation Hiérarchique

- [ ] Check H4 ≥ 3/5
- [ ] Check H1 ≥ 5/8
- [ ] Check M15 ≥ 4/6
- [ ] Check Macro ≥ 1/2
- [ ] Check Total ≥ 14/21
- [ ] **TOUS doivent être TRUE pour valider**

### Pas de Veto Individuel

- [ ] Aucun indicateur ne peut bloquer à lui seul
- [ ] ADX < 25 ne bloque pas si consensus global OK
- [ ] COT contre ne bloque pas si consensus global OK
- [ ] Seul le score 14/21 compte

---

## 💰 MONEY MANAGEMENT

### Kelly Criterion

- [ ] Fonction `CalculateKellyFraction()`:
  - [ ] Input: Win Rate, Avg Win, Avg Loss
  - [ ] Formule: (WinRate × AvgWin - LoseRate × AvgLoss) / AvgWin
  - [ ] Cap à 0.25 maximum
  - [ ] Return: double (0-0.25)

- [ ] Base Risk = 0.7% du capital
- [ ] Kelly Risk = BaseRisk × KellyFraction

### 7 Multiplicateurs Contextuels

#### 1. Confidence Score
- [ ] Formule: (TotalVotes - 14) / (21 - 14)
- [ ] Range: 0.00 (14/21) à 1.00 (21/21)
- [ ] Linear mapping
- [ ] Minimum: 0.66 (pour 14/21)

#### 2. Session Multiplier
- [ ] Asian (01h-09h Paris): ×0.0 (INTERDIT)
- [ ] London (09h-14h): ×1.0
- [ ] Overlap (14h-17h): ×1.3
- [ ] New York (17h-22h): ×1.0
- [ ] Dead Zone (22h-01h): ×0.0 (INTERDIT)

#### 3. Regime Multiplier
- [ ] Fonction `DetectRegime()`:
  - [ ] Calcul ADX
  - [ ] Calcul ATR Ratio
  - [ ] Calcul R² regression
  - [ ] Calcul Efficiency Ratio
  - [ ] Score /8
- [ ] Strong Trend (≥6/8): ×1.2
- [ ] Weak Trend (4-5/8): ×1.0
- [ ] Ranging (<4/8): ×0.5

#### 4. Sequence Multiplier
- [ ] Track losing streak (variable globale)
- [ ] 0-1 losses: ×1.0
- [ ] 2 losses: ×0.75
- [ ] 3 losses: ×0.50
- [ ] 4+ losses: ×0.30

#### 5. Drawdown Multiplier
- [ ] Track DD% from peak
- [ ] DD < 8%: ×1.0
- [ ] DD 8-15%: ×0.5
- [ ] DD 15-20%: ×0.25
- [ ] DD ≥20%: STOP TOTAL

#### 6. COT Multiplier
- [ ] Si COT vote +1.0 (STRONG BULLISH): ×1.2
- [ ] Si COT vote +0.5 (BULLISH): ×1.1
- [ ] Si COT vote 0 (NEUTRAL): ×1.0
- [ ] Si COT vote -0.5 (BEARISH): ×0.9
- [ ] Si COT vote -1.0 (STRONG BEARISH): ×0.8

#### 7. Spread Multiplier
- [ ] Si Spread excellent (< moyenne × 0.8): ×1.1
- [ ] Si Spread normal: ×1.0
- [ ] Si Spread élargi (> moyenne × 1.5): ×0.9

### Position Sizing Final

- [ ] Fonction `CalculatePositionSize()`:
  ```
  Risk% = KellyRisk × Confidence × Session × Regime × Sequence × DD × COT × Spread
  Risk% = MathMax(0.33, MathMin(1.00, Risk%))  // Cap 0.33-1.00%

  RiskAmount = AccountBalance × (Risk% / 100)
  StopLossPips = ATR_M15 × 1.5
  LotSize = RiskAmount / (StopLossPips × PointValue)
  LotSize = NormalizeLotSize(LotSize)  // Arrondi broker minimum
  ```

### Limites Strictes

- [ ] Max 1 position XAUUSD simultanée
- [ ] Min risk: 0.33% par trade
- [ ] Max risk: 1.00% par trade
- [ ] Daily loss max: 2.00% réalisé
- [ ] Pas de hedging

---

## 🎯 GESTION DES POSITIONS

### Entrée

- [ ] Type: Market Order (OrderSend)
- [ ] Entry price: Ask (BUY) ou Bid (SELL)
- [ ] Lot size: Calculé via CalculatePositionSize()
- [ ] Magic Number: 250125 (unique Hermès)
- [ ] Comment: "Hermes_2.5 | Score: X/21"

### Stop Loss Initial

- [ ] Formule BUY: Entry - (ATR_M15 × 1.5)
- [ ] Formule SELL: Entry + (ATR_M15 × 1.5)
- [ ] Arrondi au pip le plus proche
- [ ] OrderModify immédiatement après OrderSend

### Take Profit

- [ ] ❌ AUCUN Take Profit fixe
- [ ] TP = 0 dans OrderSend
- [ ] Gestion par trailing stop uniquement

---

## 🔄 TRAILING STOP (7 PALIERS)

### Variables Globales

- [ ] `int CurrentTrailingLevel` (0-7)
- [ ] `double EntryPrice`
- [ ] `double InitialRisk` (en pips = 1R)

### Paliers Progressifs

- [ ] Fonction `UpdateTrailingStop()` appelée chaque OnTick()
- [ ] Calcul R actuel: `(CurrentPrice - EntryPrice) / InitialRisk`

#### Palier +0.5R
- [ ] Si R ≥ 0.5 et CurrentLevel < 1:
  - [ ] New SL = Entry - 0.3R (BUY)
  - [ ] OrderModify()
  - [ ] CurrentLevel = 1
  - [ ] Log: "Trailing +0.5R activated"

#### Palier +1.0R (Breakeven)
- [ ] Si R ≥ 1.0 et CurrentLevel < 2:
  - [ ] New SL = Entry (0R)
  - [ ] OrderModify()
  - [ ] CurrentLevel = 2
  - [ ] Log: "Breakeven reached"

#### Palier +1.5R
- [ ] Si R ≥ 1.5 et CurrentLevel < 3:
  - [ ] New SL = Entry + 1.0R
  - [ ] OrderModify()
  - [ ] CurrentLevel = 3
  - [ ] Log: "Trailing +1.5R - 1R locked"

#### Palier +2.0R
- [ ] Si R ≥ 2.0 et CurrentLevel < 4:
  - [ ] New SL = Entry + 1.5R
  - [ ] OrderModify()
  - [ ] CurrentLevel = 4
  - [ ] Log: "Trailing +2.0R - 1.5R locked"

#### Palier +2.5R
- [ ] Si R ≥ 2.5 et CurrentLevel < 5:
  - [ ] New SL = Entry + 2.0R
  - [ ] OrderModify()
  - [ ] CurrentLevel = 5
  - [ ] Log: "Trailing +2.5R - 2R locked"

#### Palier +3.0R
- [ ] Si R ≥ 3.0 et CurrentLevel < 6:
  - [ ] New SL = Entry + 2.5R
  - [ ] OrderModify()
  - [ ] CurrentLevel = 6
  - [ ] Log: "Trailing +3.0R - 2.5R locked"

#### Palier +3.5R (75% sécurisé)
- [ ] Si R ≥ 3.5 et CurrentLevel < 7:
  - [ ] New SL = Entry + 3.0R
  - [ ] OrderModify()
  - [ ] CurrentLevel = 7
  - [ ] Log: "Trailing +3.5R - 3R locked (75%)"

#### Après +3.5R (Trailing Continu)
- [ ] Si R > 3.5 et CurrentLevel == 7:
  - [ ] New SL = CurrentPrice - 0.5R (offset constant)
  - [ ] OrderModify() si SL > ancien SL
  - [ ] Log update tous les 0.5R

---

## 📅 SESSION AWARENESS

### Détection Session

- [ ] Fonction `GetCurrentSession()`:
  - [ ] Input: heure serveur MT5
  - [ ] Convert to Paris time (UTC+1)
  - [ ] Return: enum SESSION (ASIAN/LONDON/OVERLAP/NY/DEAD)

### Multiplicateurs

- [ ] Asian (01h-09h): ×0.0 → BLOCK nouveaux trades
- [ ] Dead Zone (22h-01h): ×0.0 → BLOCK nouveaux trades
- [ ] London (09h-14h): ×1.0
- [ ] Overlap (14h-17h): ×1.3
- [ ] NY (17h-22h): ×1.0

### Fenêtre de Trading

- [ ] Trading autorisé: 09h00 - 22h00 Paris
- [ ] Trading interdit: 22h00 - 09h00 Paris
- [ ] Check avant chaque signal

---

## 📰 NEWS BLACKOUT

### Liste Événements Majeurs

- [ ] Array `string MajorNewsEvents[]`:
  - [ ] "NFP"
  - [ ] "FOMC"
  - [ ] "CPI"
  - [ ] "GDP"
  - [ ] "Retail Sales"
  - [ ] "Unemployment"
  - [ ] "ECB Rate"
  - [ ] "Fed Speech"

### Calendrier Économique

- [ ] Import `macro_events.csv` (date, time, event, impact)
- [ ] Fonction `LoadEconomicCalendar()`:
  - [ ] Parse CSV
  - [ ] Store in array datetime
  - [ ] Filter HIGH impact only

### Règles Blackout

- [ ] Fonction `IsNewsBlackout()`:
  - [ ] Check si news dans 1h avant
  - [ ] Check si news dans 1h après
  - [ ] Return: bool (true = BLOCK)

- [ ] Positions existantes: **NON affectées**
- [ ] Nouveaux trades: **BLOQUÉS**

---

## 🌍 WEEKEND RISK MANAGEMENT

### Vendredi Soir

#### 18h00 - 20h00
- [ ] Multiplicateur: ×0.5
- [ ] Min votes required: 17/21
- [ ] Nouveaux trades: Autorisés (réduits)

#### 20h00 - 23h59
- [ ] Nouveaux trades: **INTERDITS**
- [ ] Positions existantes: Continuent
- [ ] Check: `if (DayOfWeek() == 5 && Hour() >= 20)`

### Dimanche Soir

#### 22h00 - 23h00
- [ ] Nouveaux trades: **INTERDITS**
- [ ] Check gap detection active

#### 23h00+
- [ ] Nouveaux trades: Autorisés
- [ ] Multiplicateur: ×0.8 (prudence)
- [ ] Check: `if (DayOfWeek() == 0 && Hour() >= 23)`

### Gap Detection

- [ ] Fonction `DetectGap()`:
  - [ ] Compare Close[1] vs Open[0]
  - [ ] GapSize = MathAbs(Open[0] - Close[1])
  - [ ] ATR_threshold = ATR_H4 × 2
  - [ ] Return: bool (gap > threshold)

- [ ] Si gap détecté:
  - [ ] Block nouveaux trades pendant 2-3h
  - [ ] Attente stabilisation

---

## 🚫 RÈGLES D'INTERDICTION

### Checks Préliminaires

- [ ] Fonction `CanOpenNewTrade()`:
  - [ ] Check position déjà ouverte
  - [ ] Check session autorisée
  - [ ] Check weekend proximity
  - [ ] Check gap détecté
  - [ ] Check daily loss ≥ 2%
  - [ ] Check DD ≥ 20%
  - [ ] Check spread acceptable
  - [ ] Check news blackout
  - [ ] Return: bool

### Protections Qualité Exécution

#### Spread Filter
- [ ] Max spread absolu: 6.0 pips
- [ ] Max spread vs ATR: 30%
- [ ] Max spread vs moyenne: 2.5×
- [ ] Fonction `IsSpreadAcceptable()`:
  ```
  CurrentSpread = Ask - Bid
  AvgSpread = Average(Spread, 20)
  ATR_M15_Current = iATR(M15, 14, 0)

  if (CurrentSpread > 6.0 * Point) return false;
  if (CurrentSpread > ATR_M15 * 0.3) return false;
  if (CurrentSpread > AvgSpread * 2.5) return false;

  return true;
  ```

#### Slippage Budget
- [ ] Anticipé: +0.5 pips par trade
- [ ] Max acceptable: 2.0 pips
- [ ] Enregistré dans CSV logging

---

## 🔄 TRADE SEQUENCING

### Losing Streak Tracking

- [ ] Variable globale `int LosingStreak`
- [ ] Update après chaque trade fermé
- [ ] Reset à 0 après WIN

### Auto-Réduction

- [ ] 0-1 loss:
  - [ ] Position size: ×1.0
  - [ ] Min votes: 14/21
  - [ ] Cooldown: 0

- [ ] 2 losses:
  - [ ] Position size: ×0.75
  - [ ] Min votes: 15/21
  - [ ] Cooldown: 0

- [ ] 3 losses:
  - [ ] Position size: ×0.50
  - [ ] Min votes: 16/21
  - [ ] Cooldown: Skip 1 signal

- [ ] 4+ losses:
  - [ ] Position size: ×0.30
  - [ ] Min votes: 17/21
  - [ ] Cooldown: Skip 2 signaux

### Win Rate Monitoring

- [ ] Array `double Last20Trades[]` (store R multiple)
- [ ] Fonction `CalculateRecentWinRate()`:
  - [ ] Count wins vs losses (20 derniers)
  - [ ] Return: double (0-1)

- [ ] Si WinRate < 0.40:
  - [ ] Position size: ×0.6
  - [ ] Min votes: 16/21
  - [ ] Log: "⚠️ Low performance detected"

---

## 🎲 MOMENTUM REGIME DETECTION

### 4 Métriques

#### 1. ADX Score
- [ ] ADX > 30: +2 points
- [ ] ADX 25-30: +1 point
- [ ] ADX < 25: 0 points

#### 2. ATR Ratio
- [ ] ATR actuel / ATR(50)
- [ ] Ratio > 1.3: +2 points
- [ ] Ratio 1.1-1.3: +1 point
- [ ] Ratio < 1.1: 0 points

#### 3. R² Regression
- [ ] Regression linéaire 20 périodes
- [ ] R² > 0.7: +2 points
- [ ] R² 0.5-0.7: +1 point
- [ ] R² < 0.5: 0 points

#### 4. Efficiency Ratio
- [ ] Direction / Distance
- [ ] ER > 0.7: +2 points
- [ ] ER 0.5-0.7: +1 point
- [ ] ER < 0.5: 0 points

### Classification

- [ ] Total score /8
- [ ] Strong Trend (≥6/8): Multiplicateur ×1.2, Min votes 13/21
- [ ] Weak Trend (4-5/8): Multiplicateur ×1.0, Min votes 14/21
- [ ] Ranging (<4/8): Multiplicateur ×0.5, Min votes 17/21

---

## 📊 COT DATA MANAGEMENT

### Import & Parsing

- [ ] Fichier source: `data/cot_data.csv`
- [ ] Colonnes: date, commercials_long, commercials_short, commercials_net
- [ ] Fonction `LoadCOTData()`:
  - [ ] Parse CSV
  - [ ] Store in arrays
  - [ ] Update every Friday 21h30 Paris

### Net Position Calculation

- [ ] CommercialNet = CommercialLong - CommercialShort
- [ ] Fonction `GetCOTVote()`:
  - [ ] Input: current date
  - [ ] Find latest Friday data
  - [ ] Return: double (-1.0 to +1.0)

### Classification

- [ ] > +80k: +1.0 (STRONG BULLISH) → ×1.2
- [ ] +30k à +80k: +0.5 (BULLISH) → ×1.1
- [ ] -30k à +30k: 0 (NEUTRAL) → ×1.0
- [ ] -80k à -30k: -0.5 (BEARISH) → ×0.9
- [ ] < -80k: -1.0 (STRONG BEARISH) → ×0.8

---

## 📁 LOGGING CSV

### 1. hermes_trades_detailed.csv

#### Colonnes Required
- [ ] trade_id (unique)
- [ ] entry_date
- [ ] entry_time
- [ ] direction (BUY/SELL)
- [ ] entry_price
- [ ] sl (initial)
- [ ] exit_price
- [ ] result (WIN/LOSS)
- [ ] r_multiple (gain/loss en R)
- [ ] duration_hours
- [ ] **21 indicateurs (1/0)**:
  - [ ] adx_h4
  - [ ] ema_cross_h4
  - [ ] ema_50_200_h4
  - [ ] price_ema21_h4
  - [ ] supertrend_h4
  - [ ] ema_cross_h1
  - [ ] macd_h1
  - [ ] rsi_h1
  - [ ] sar_h1
  - [ ] stoch_h1
  - [ ] bollinger_h1
  - [ ] vol_momentum_h1
  - [ ] donchian_h1
  - [ ] vwap_m15
  - [ ] orderflow_m15
  - [ ] volatility_m15
  - [ ] tick_m15
  - [ ] eurusd_m15
  - [ ] spread_m15
  - [ ] cot
  - [ ] atr_percentile
- [ ] votes_h4
- [ ] votes_h1
- [ ] votes_m15
- [ ] votes_macro
- [ ] votes_total

#### Fonctions
- [ ] `LogTradeEntry()` - Appelé à OrderSend
- [ ] `LogTradeExit()` - Appelé à OrderClose
- [ ] Header CSV créé si fichier n'existe pas

---

### 2. hermes_shap_analysis.csv

#### Trigger
- [ ] Généré tous les 50 trades fermés
- [ ] Fonction `RunSHAPAnalysis()` appelée après trade #50, #100, #150...

#### Colonnes Required
- [ ] date
- [ ] total_trades
- [ ] indicator (nom)
- [ ] weight_current
- [ ] participated_count
- [ ] participated_percent
- [ ] win_count
- [ ] loss_count
- [ ] win_rate
- [ ] avg_r_when_present
- [ ] avg_r_when_absent
- [ ] contribution_delta (🔥 MÉTRIQUE CLÉ)
- [ ] shap_value
- [ ] recommended_weight
- [ ] status (CRITICAL/HIGH/MEDIUM/LOW/NEUTRAL/WEAK/REMOVE)

#### Calcul SHAP
- [ ] Pour chaque indicateur:
  - [ ] Filtre trades où indicateur = 1 (présent)
  - [ ] Filtre trades où indicateur = 0 (absent)
  - [ ] Calcul avg_r_present
  - [ ] Calcul avg_r_absent
  - [ ] Delta = avg_r_present - avg_r_absent
  - [ ] Classification selon delta:
    - [ ] > +0.8R: CRITICAL (weight 3.0)
    - [ ] > +0.5R: HIGH (weight 2.0-2.5)
    - [ ] > +0.2R: MEDIUM (weight 1.0-1.5)
    - [ ] > +0.05R: LOW (weight 0.5-1.0)
    - [ ] -0.05 to +0.05R: NEUTRAL (weight 0.5)
    - [ ] < -0.05R: WEAK (weight 0.0)
    - [ ] < -0.15R: REMOVE

---

### 3. hermes_summary.csv

#### Trigger
- [ ] Mis à jour avec chaque SHAP analysis

#### Métriques
- [ ] total_trades_analyzed
- [ ] analysis_period_start
- [ ] analysis_period_end
- [ ] overall_win_rate
- [ ] overall_avg_r
- [ ] overall_profit_factor
- [ ] indicators_total (21)
- [ ] indicators_critical (count)
- [ ] indicators_high (count)
- [ ] indicators_medium (count)
- [ ] indicators_low (count)
- [ ] indicators_neutral (count)
- [ ] indicators_remove (count)
- [ ] best_indicator (nom)
- [ ] best_contribution
- [ ] worst_indicator (nom)
- [ ] worst_contribution

---

## 🔬 SHAP IMPLEMENTATION

### Functions Required

#### 1. CalculateSHAPForIndicator()
```cpp
double CalculateSHAPForIndicator(int indicator_id, string indicator_name) {
    // Parse hermes_trades_detailed.csv
    // Filter trades where indicator = 1
    // Calculate avg_r_present
    // Filter trades where indicator = 0
    // Calculate avg_r_absent
    // contribution_delta = avg_r_present - avg_r_absent
    return contribution_delta;
}
```

#### 2. ClassifyIndicator()
```cpp
string ClassifyIndicator(double contribution_delta, double &recommended_weight) {
    if (contribution_delta > 0.8) {
        recommended_weight = 3.0;
        return "CRITICAL";
    }
    else if (contribution_delta > 0.5) {
        recommended_weight = 2.5;
        return "HIGH";
    }
    // ... etc
}
```

#### 3. GenerateSHAPCSV()
```cpp
void GenerateSHAPCSV() {
    // Loop through 21 indicators
    // Calculate SHAP for each
    // Classify each
    // Write to hermes_shap_analysis.csv
    // Update hermes_summary.csv
    // Print("SHAP analysis updated - Check CSV files");
}
```

---

## 🎛️ PARAMÈTRES CONFIGURABLES

### Fichier Hermes_Config.mqh

```cpp
// === VALIDATION ===
input int Min_Votes_H4 = 3;           // Sur 5
input int Min_Votes_H1 = 5;           // Sur 8
input int Min_Votes_M15 = 4;          // Sur 6
input int Min_Votes_Macro = 1;        // Sur 2
input int Min_Votes_Total = 14;       // Sur 21

// === RISK MANAGEMENT ===
input double Kelly_Cap = 0.25;
input double Base_Risk_Percent = 0.7;
input double Min_Risk_Percent = 0.33;
input double Max_Risk_Percent = 1.00;
input double Daily_Loss_Max = 2.0;

// === TRAILING STOP ===
input double ATR_Multiplier_SL = 1.5;
input double Trailing_Offset_After_35R = 0.5;

// === SESSIONS ===
input bool Enable_Asian_Session = false;
input bool Enable_London_Session = true;
input bool Enable_Overlap_Session = true;
input bool Enable_NY_Session = true;

// === PROTECTIONS ===
input double Max_Spread_Pips = 6.0;
input double Max_Spread_vs_ATR = 0.30;
input int News_Blackout_Hours = 1;
input int Weekend_Block_Hour_Friday = 20;
input int Weekend_Allow_Hour_Sunday = 23;

// === SHAP ===
input int SHAP_Analysis_Frequency = 50;
input int SHAP_Min_Trades = 300;
input bool Enable_Auto_CSV_Export = true;

// === REGIME ===
input int Regime_Strong_Threshold = 6;    // Sur 8
input int Regime_Ranging_Threshold = 4;   // Sur 8

// === MAGIC NUMBER ===
input int Magic_Number = 250125;
```

---

## ✅ TESTS UNITAIRES

### Test Indicateurs

- [ ] Test_ADX()
- [ ] Test_EMA_Cross()
- [ ] Test_VWAP()
- [ ] Test_OrderFlow()
- [ ] Test_COT()
- [ ] ... (21 total)

### Test Validation

- [ ] Test_CountVotes_H4()
- [ ] Test_CountVotes_Total()
- [ ] Test_ValidationHierarchique()

### Test Position Sizing

- [ ] Test_CalculateKelly()
- [ ] Test_Multiplicateurs()
- [ ] Test_PositionSizeFinal()
- [ ] Test_LotNormalization()

### Test Trailing Stop

- [ ] Test_Trailing_05R()
- [ ] Test_Trailing_10R_Breakeven()
- [ ] Test_Trailing_35R_Lock75()
- [ ] Test_Trailing_Continuous()

### Test Sessions

- [ ] Test_GetCurrentSession()
- [ ] Test_SessionMultipliers()
- [ ] Test_WeekendBlocking()

### Test News Blackout

- [ ] Test_LoadEconomicCalendar()
- [ ] Test_IsNewsBlackout()

### Test Logging

- [ ] Test_LogTradeEntry()
- [ ] Test_LogTradeExit()
- [ ] Test_CSV_Format()

### Test SHAP

- [ ] Test_CalculateSHAP()
- [ ] Test_ClassifyIndicator()
- [ ] Test_GenerateSHAPCSV()

---

## 🚀 WORKFLOW DÉVELOPPEMENT

### Phase 1: Architecture de Base
- [ ] Créer fichiers .mqh (libs)
- [ ] Créer Hermes_2.5.mq5 (main)
- [ ] Implémenter structure OnInit/OnTick/OnDeinit
- [ ] Compiler sans erreurs

### Phase 2: Indicateurs
- [ ] Implémenter 5 indicateurs H4
- [ ] Implémenter 8 indicateurs H1
- [ ] Implémenter 6 indicateurs M15
- [ ] Implémenter 2 indicateurs Macro
- [ ] Tests unitaires chaque indicateur

### Phase 3: Validation
- [ ] Système de comptage votes
- [ ] Validation hiérarchique
- [ ] Tests validation complète

### Phase 4: Risk Management
- [ ] Kelly Criterion
- [ ] 7 multiplicateurs
- [ ] Position sizing final
- [ ] Tests calculs

### Phase 5: Trading Logic
- [ ] Checks préliminaires
- [ ] Envoi ordres (OrderSend)
- [ ] SL initial
- [ ] Logging entry

### Phase 6: Trailing Stop
- [ ] 7 paliers progressifs
- [ ] Trailing continu après +3.5R
- [ ] Tests paliers

### Phase 7: Protections
- [ ] Sessions
- [ ] News blackout
- [ ] Weekend
- [ ] Gap detection
- [ ] Spread filters

### Phase 8: Logging & SHAP
- [ ] hermes_trades_detailed.csv
- [ ] hermes_shap_analysis.csv
- [ ] hermes_summary.csv
- [ ] Tests parsing CSV

### Phase 9: Backtesting
- [ ] Backtest 2008-2020 (training)
- [ ] Validation 2020-2022
- [ ] Test 2022-2024 (jamais vu)
- [ ] Vérification métriques

### Phase 10: Optimisation
- [ ] Première SHAP analysis (300+ trades)
- [ ] Ajustement poids indicateurs
- [ ] Re-backtest
- [ ] Déploiement final

---

## ✅ CHECKLIST FINALE AVANT DÉPLOIEMENT

### Code
- [ ] 0 erreurs compilation
- [ ] 0 warnings
- [ ] Tous les tests unitaires passent
- [ ] Backtest 5 ans validé

### Documentation
- [ ] README.md complet
- [ ] SPECIFICATIONS_COMPLETE.md finalisé
- [ ] GUIDE_UTILISATION.md écrit
- [ ] GUIDE_OPTIMIZATION.md écrit

### Fichiers
- [ ] Tous les .mqh présents
- [ ] Hermes_2.5.mq5 final
- [ ] data/cot_data.csv à jour
- [ ] data/macro_events.csv à jour

### Métriques Backtest
- [ ] Win Rate: 55-65% ✅
- [ ] Profit Factor: > 1.8 ✅
- [ ] Max DD: < 15% ✅
- [ ] Sharpe: > 1.5 ✅

### Logs
- [ ] CSV files générés correctement
- [ ] SHAP analysis fonctionne
- [ ] Pas d'erreurs runtime

---

**🏛️ CHECKLIST HERMÈS 2.5 - Version 1.0**

*RIEN N'EST OUBLIÉ - IMPLÉMENTATION COMPLÈTE GARANTIE*
