# 📋 HERMÈS 2.5 - SPÉCIFICATIONS COMPLÈTES

---

## 🎯 CONCEPT GÉNÉRAL

**Hermès 2.5** est un algorithme de trading **trend-following institutionnel** pour **XAUUSD (Gold)** optimisé pour **FTMO** et les prop firms.

**Philosophie**: Capturer les grandes tendances haussières et baissières de l'or avec un système de validation multi-niveaux, un risk management professionnel, et laisser courir les gains sans limite tout en coupant rapidement les pertes.

**Type de stratégie**: Trend-following pur (suiveur de tendance)
**Paire tradée**: XAUUSD uniquement (1 position max à la fois)

---

## 📊 ARCHITECTURE TRI-TIMEFRAME

### Validation Hiérarchique (Top-Down)

```
🏔️ H4 (4 heures) - MACRO
    → Filtre la direction générale du marché
    → "Où va le marché ?"

⛰️ H1 (1 heure) - SETUP
    → Construction du signal d'entrée
    → "Le setup est-il prêt ?"

🎯 M15 (15 minutes) - TIMING
    → Timing précis d'exécution
    → "C'EST MAINTENANT !"
```

**Principe**: Les 3 timeframes doivent être alignés pour valider un trade.

---

## 🔢 LES 21 INDICATEURS TECHNIQUES

### H4 - MACRO TREND (5 indicateurs)

| # | Indicateur | Paramètres | Condition BUY | Condition SELL | Rôle |
|---|------------|------------|---------------|----------------|------|
| 1 | **ADX** | Période 14 | ADX > 25 | ADX > 25 | Filtre trend vs range |
| 2 | **EMA 21/55** | - | EMA 21 > EMA 55 | EMA 21 < EMA 55 | Direction principale |
| 3 | **EMA 50/200** | - | EMA 50 > EMA 200 | EMA 50 < EMA 200 | Trend long terme |
| 4 | **Prix/EMA21** | - | Close > EMA 21 | Close < EMA 21 | Force haussière immédiate |
| 5 | **Supertrend** | ATR 10, Factor 3 | Supertrend = BUY | Supertrend = SELL | Confirmation visuelle |

**Rôle H4**: Valider que la tendance générale est haussière (pour BUY) ou baissière (pour SELL).

---

### H1 - SETUP PRINCIPAL (8 indicateurs)

| # | Indicateur | Paramètres | Condition BUY | Condition SELL | Rôle |
|---|------------|------------|---------------|----------------|------|
| 6 | **EMA Cross** | 21/55 | EMA 21 croise au-dessus EMA 55 | EMA 21 croise en-dessous EMA 55 | Signal d'entrée principal |
| 7 | **MACD** | 12/26/9 | MACD histogram > 0 | MACD histogram < 0 | Momentum haussier/baissier |
| 8 | **RSI** | Période 14 | RSI entre 50-70 | RSI entre 30-50 | Zone de force optimale |
| 9 | **Parabolic SAR** | 0.02/0.2 | SAR sous le prix | SAR au-dessus du prix | Confirmation trend |
| 10 | **Stochastic** | 14/3/3 | Stochastic cross up | Stochastic cross down | Momentum court terme |
| 11 | **Bollinger Width** | 20/2 std | Width en expansion | Width en expansion | Volatility breakout imminent |
| 12 | **Volume Momentum** | - | Vol × ΔPrice > 0 et croissant | Vol × ΔPrice < 0 et décroissant | Conviction volume |
| 13 | **Donchian** | Période 20 | Prix > High(20) | Prix < Low(20) | Breakout structurel |

**Rôle H1**: Construire le signal technique avec confirmation momentum.

---

### M15 - EXÉCUTION INSTITUTIONNELLE (6 indicateurs)

| # | Indicateur | Paramètres | Condition BUY | Condition SELL | Rôle |
|---|------------|------------|---------------|----------------|------|
| 14 | **VWAP** | Reset daily | Prix > VWAP | Prix < VWAP | Contrôle acheteurs/vendeurs |
| 15 | **Order Flow Delta** | Lookback 20 | Delta cumulatif > 0 et croissant | Delta cumulatif < 0 et décroissant | Pression achat/vente réelle |
| 16 | **Volatility Regime** | Window 50 | Volatilité en expansion | Volatilité en expansion | Mouvement imminent |
| 17 | **Tick Momentum** | - | Upticks/Downticks > 60% | Downticks/Upticks > 60% | Urgence acheteurs/vendeurs |
| 18 | **EURUSD Correlation** | - | EURUSD en hausse | EURUSD en baisse | Macro alignment (corr +0.75) |
| 19 | **Effective Spread** | Moyenne 20 | Spread < moyenne | Spread < moyenne | Liquidité élevée |

**Rôle M15**: Timing précis avec outils institutionnels (microstructure de marché).

---

### MACRO CONTEXT (2 indicateurs)

| # | Indicateur | Fréquence | Condition BUY | Condition SELL | Rôle |
|---|------------|-----------|---------------|----------------|------|
| 20 | **COT (Commitment of Traders)** | Hebdo (vendredi) | Commercials net long > seuil | Commercials net short > seuil | Smart money positioning |
| 21 | **ATR Percentile** | Daily | ATR dans top 30% historique | ATR dans top 30% historique | Contexte volatilité favorable |

**Rôle Macro**: Alignement avec smart money institutionnel et contexte volatilité.

---

## ✅ SYSTÈME DE VALIDATION (Vote Pondéré)

### Démarrage: Tous Poids Égaux (1.0)

Au démarrage, **tous les 21 indicateurs ont le même poids = 1.0**

**Principe**: Vote démocratique pour établir une baseline objective.

### Seuils de Validation

Hermès compte les votes par niveau et exige:

| Niveau | Votes Minimum | Pourcentage |
|--------|---------------|-------------|
| **H4** | 3/5 | 60% |
| **H1** | 5/8 | 63% |
| **M15** | 4/6 | 67% |
| **Macro** | 1/2 | 50% |
| **GLOBAL** | **14/21** | **67%** |

**TOUTES ces conditions doivent être remplies simultanément pour valider un signal.**

### Exemple de Validation

```
Signal BUY détecté à 14h30:

H4: EMA21>55 ✅, EMA50>200 ✅, Prix>EMA21 ✅, ADX=28 ✅, Supertrend ✅
→ 5/5 votes H4 ✅ (> 3 minimum)

H1: EMA cross ✅, MACD ✅, RSI ✅, SAR ✅, Stoch ✅, Bollinger ✅, Volume ❌, Donchian ❌
→ 6/8 votes H1 ✅ (> 5 minimum)

M15: VWAP ✅, OrderFlow ✅, Volatility ✅, Tick ✅, EURUSD ❌, Spread ✅
→ 5/6 votes M15 ✅ (> 4 minimum)

Macro: COT ✅, ATR Percentile ✅
→ 2/2 votes Macro ✅ (> 1 minimum)

TOTAL: 18/21 votes ✅ (> 14 minimum)

→ ✅ SIGNAL VALIDÉ - Hermès entre en position BUY
```

### Pas d'Indicateur Obligatoire ou Éliminatoire

**Important**: Aucun indicateur n'a de statut spécial ou de veto absolu.

- ADX < 25 ne bloque pas un signal si les autres compensent
- Tous les indicateurs sont traités équitablement
- Seul le consensus global (14/21) compte

---

## 💰 MONEY MANAGEMENT

### Position Sizing (Kelly Conservateur)

**Base de calcul**:
```
Kelly Fraction = (Win Rate × Avg Win - Lose Rate × Avg Loss) / Avg Win
Kelly Cappé à 25% maximum (sécurité)
Base Risk = 0.7% du capital
```

**Range final**:
```
Minimum: 0.33% du capital par trade
Maximum: 1.00% du capital par trade
```

### 7 Multiplicateurs Contextuels

La position size finale est ajustée dynamiquement selon 7 facteurs:

| Multiplicateur | Range | Impact |
|----------------|-------|--------|
| **1. Confidence** | 0.66 - 1.00 | Score global (67%-100%) |
| **2. Session** | 0.00 - 1.30 | Asian ×0 (interdit), Overlap ×1.3 |
| **3. Regime** | 0.50 - 1.20 | Range ×0.5, Strong Trend ×1.2 |
| **4. Sequence** | 0.30 - 1.00 | Losing streak → réduit 50-70% |
| **5. Drawdown** | 0.30 - 1.00 | DD 8%→×0.5, DD 15%→×0.25 |
| **6. COT** | 0.70 - 1.20 | Smart money aligned ×1.2 ou contre ×0.7 |
| **7. Spread** | 0.90 - 1.10 | Liquidité excellente ×1.1 |

**Formule finale**:
```
Position Size = Kelly Base × Confidence × Session × Regime × Sequence × Drawdown × COT × Spread

Avec caps:
- Minimum absolu: 0.33%
- Maximum absolu: 1.00%
```

### Limites Strictes

**Par Trade**:
```
Risk minimum: 0.33% du capital
Risk maximum: 1.00% du capital
Maximum 1 position XAUUSD simultanée
```

**Par Jour**:
```
Perte maximale réalisée: 2.00% du capital
(Le flottant ne compte PAS)

Si 2% atteint:
→ Bloque ouverture de nouvelles positions jusqu'à minuit
→ Les positions existantes continuent normalement
→ Reset à minuit (serveur time)
```

**Drawdown (Capital Total)**:
```
DD < 8%  → Trading normal (100% position size)
DD ≥ 8%  → Réduit toutes positions futures à 50%
DD ≥ 15% → Réduit toutes positions futures à 25%
DD ≥ 20% → STOP TOTAL (redémarrage manuel requis)
```

### Exemple Concret Position Sizing

```
Capital: 100 000 €
Win Rate historique: 60%
Kelly fraction: 0.20 (cappé)
Base risk: 0.7%

Situation du trade:
- Score global: 18/21 (86%) → Confidence ×0.86
- Session: London-NY Overlap → ×1.3
- Regime: Strong Trend → ×1.2
- Sequence: 1 loss récent → ×1.0
- Drawdown: 5% actuel → ×1.0
- COT: Commercials long → ×1.2
- Spread: 1.8 pips (normal) → ×1.0

Calcul:
Kelly risk = 0.7% × 0.20 = 0.14%
Ajusté = 0.14% × 0.86 × 1.3 × 1.2 × 1.0 × 1.0 × 1.2 × 1.0 = 0.22%

Risk final: 0.22% du capital = 220 €

ATR M15 = 2.5 pips
SL = 2.5 × 1.5 = 3.75 pips
Lot size = 220 / (3.75 × 10) = 5.87 → Arrondi 0.06 lot

Trade:
- Entry: 2050.50
- SL: 2046.75 (3.75 pips)
- Risk: 220 € (0.22%)
- TP: Aucun (trailing seulement)
```

---

## 🎯 GESTION DES POSITIONS

### Entrée

```
Type d'ordre: Market Order
Entry: Prix du marché au moment du signal validé
Stop Loss: ATR M15 × 1.5 sous dernier swing low (BUY)
Take Profit: AUCUN (trailing stop seulement)
Slippage anticipé: +0.5 pips
```

### Stop Loss Initial

```
Formule: Entry - (ATR M15 × 1.5)  [pour BUY]
        Entry + (ATR M15 × 1.5)  [pour SELL]

Exemple BUY:
ATR M15 = 2.0 pips
Entry = 2050.50
SL = 2050.50 - (2.0 × 1.5) = 2047.50
Distance = 3.0 pips = 1R (Risk unit)
```

### Take Profit

```
❌ AUCUN Take Profit fixe

Hermès utilise UNIQUEMENT le trailing stop progressif
La position peut courir aussi loin que possible
Objectif: Capturer les grandes tendances (+5R, +10R, +15R)
```

---

## 🔄 TRAILING STOP PROGRESSIF (7 PALIERS)

**Principe**: Le stop loss se déplace automatiquement pour protéger les gains au fur et à mesure.

### Les 7 Paliers

| Prix Atteint | Action SL | Gain Sécurisé | % du Max |
|--------------|-----------|---------------|----------|
| **+0.5R** | SL → Entry - 0.3R | -0.3R (réduit risque) | - |
| **+1.0R** | SL → Entry | 0R (Breakeven) | 0% |
| **+1.5R** | SL → Entry + 1.0R | +1.0R | 25% |
| **+2.0R** | SL → Entry + 1.5R | +1.5R | 37.5% |
| **+2.5R** | SL → Entry + 2.0R | +2.0R | 50% |
| **+3.0R** | SL → Entry + 2.5R | +2.5R | 62.5% |
| **+3.5R** | SL → Entry + 3.0R | +3.0R | **75%** 🔒 |

**Après +3.5R**: Le trailing stop continue à suivre avec un offset constant de +0.5R

### Exemple Complet

```
Entry: 2050.00 €
SL initial: 2045.00 € (5 pips = 1R)

📈 Prix monte à 2052.50 (+0.5R = 2.5 pips)
└─ SL → 2048.50 (-0.3R) ✅ Risque réduit de 70%

📈 Prix monte à 2055.00 (+1.0R = 5 pips)
└─ SL → 2050.00 (0R) ✅ BREAKEVEN - Trade sans risque

📈 Prix monte à 2057.50 (+1.5R = 7.5 pips)
└─ SL → 2055.00 (+1R) ✅ +1R verrouillé (25% du gain potentiel)

📈 Prix monte à 2060.00 (+2.0R = 10 pips)
└─ SL → 2057.50 (+1.5R) ✅ +1.5R verrouillé (37.5%)

📈 Prix monte à 2062.50 (+2.5R = 12.5 pips)
└─ SL → 2060.00 (+2R) ✅ +2R verrouillé (50%)

📈 Prix monte à 2065.00 (+3.0R = 15 pips)
└─ SL → 2062.50 (+2.5R) ✅ +2.5R verrouillé (62.5%)

📈 Prix monte à 2067.50 (+3.5R = 17.5 pips)
└─ SL → 2065.00 (+3R) 🔒 +3R VERROUILLÉ (75%) ← Sécurité maximale

📈 Prix continue à monter vers 2075.00 (+5R = 25 pips)
└─ SL suit à 2072.50 (+4.5R) ✅ Toujours +0.5R derrière

📉 Prix retrace et touche SL à 2072.50
└─ Position fermée: +4.5R de gain = +22.5 pips ! 💰

Résultat final:
Entry: 2050.00
Exit: 2072.50
Gain: 22.5 pips = +4.5R
Si risque = 220 €, gain = 990 € (4.5× le risque)
```

### Avantages de ce Système

✅ Pas de TP fixe qui limite les gains
✅ Laisse courir les grandes tendances
✅ Sécurise 75% des profits à +3.5R
✅ Peut capturer +5R, +10R, voire +15R dans les super trends
✅ Élimine les trades qui "redeviennent perdants"
✅ Psychologiquement rassurant (gains verrouillés progressivement)

---

## 📅 SESSION AWARENESS (Timing de Trading)

### Sessions et Multiplicateurs

| Session | Heures Paris (UTC+1) | Trading Autorisé | Multiplicateur | Caractéristiques |
|---------|---------------------|------------------|----------------|------------------|
| **Asian** | 01h00 - 09h00 | ⛔ **INTERDIT** | ×0.0 | Slippage +5 pips, spread élargi |
| **London** | 09h00 - 14h00 | ✅ OUI | ×1.0 | Liquidité normale |
| **Overlap L-NY** | 14h00 - 17h00 | 🔥 **MEILLEUR** | ×1.3 | Liquidité + volatilité max |
| **New York** | 17h00 - 22h00 | ✅ OUI | ×1.0 | Liquidité normale |
| **Dead Zone** | 22h00 - 01h00 | ⛔ INTERDIT | ×0.0 | Zéro liquidité |

### Fenêtre de Trading

```
✅ Trading autorisé: 09h00 - 22h00 (heure Paris)
❌ Trading interdit: 22h00 - 09h00 (heure Paris)

🔥 Meilleure fenêtre: 14h00 - 17h00 (Overlap London-NY)
→ 70% des trades devraient être concentrés ici
```

### Pourquoi Asian Session Interdite?

**Problèmes majeurs**:
```
1. Slippage énorme: 2-5 pips (vs 0.5 pips normal)
2. Spread élargi: 3-8 pips (vs 1.5-3 pips normal)
3. Faible volume: Faux mouvements, pas de vraie tendance
4. Marché qui attend London: Prix stagne

Impact financier:
- 10 trades Asian/mois
- Slippage moyen -3 pips par trade
- Coût total: -30 pips/mois = -3R
- Sur 1 an: -36R perdus !

→ En interdisant Asian, on ÉCONOMISE -36R par an
```

---

## 📰 NEWS BLACKOUT (Protection Événements Économiques)

### Événements à Fort Impact

```
✅ Non-Farm Payrolls (NFP) - 1er vendredi du mois, 14h30 Paris
✅ FOMC Rate Decision - 8 fois/an, 20h00 Paris
✅ CPI (Inflation USA) - Mensuel, 14h30 Paris
✅ GDP (Croissance) - Trimestriel
✅ Retail Sales USA - Mensuel
✅ Unemployment Rate USA - Mensuel, 14h30 Paris
✅ ECB Rate Decision - 8 fois/an, 13h45 ou 14h30 Paris
✅ Discours Fed/ECB (Powell, Lagarde)
```

### Règles de Blackout

```
🚫 1 HEURE AVANT l'annonce:
   → Pas de nouvelles positions
   → Attente absorption volatilité

🚫 1 HEURE APRÈS l'annonce:
   → Pas de nouvelles positions
   → Attente stabilisation marché

✅ Positions existantes:
   → Continuent normalement
   → Trailing stop actif
   → Pas de fermeture forcée
```

**Exemple NFP (vendredi 14h30)**:
```
13h30 → Blackout commence (pas de nouveau trade)
14h30 → NFP publié (volatilité extrême possible)
15h30 → Blackout termine (nouveaux trades autorisés si validations OK)
```

**Pourquoi c'est critique**:
L'or peut bouger de 30-50 pips en quelques secondes pendant ces annonces. C'est du casino, pas du trading professionnel.

---

## 🌍 WEEKEND RISK MANAGEMENT

### Vendredi Soir

**18h00 - 20h00**:
```
✅ Nouvelles positions: Autorisées mais réduites (×0.5)
⚠️ Minimum votes requis: 17/21 (très sélectif)
✅ Positions existantes: Continuent normalement
📝 Raison: Approche du weekend, prudence
```

**20h00 - 23h59**:
```
❌ Nouvelles positions: INTERDITES
✅ Positions existantes: Continuent normalement avec trailing stop
📝 Raison: Gap risk weekend

⚠️ IMPORTANT:
Hermès NE ferme PAS les positions de force le vendredi
Il empêche seulement d'en ouvrir de nouvelles
```

### Dimanche Soir (Réouverture)

**22h00 - 23h00**:
```
❌ Nouvelles positions: INTERDITES
👁️ Action: Observer le marché
📝 Raison: Attente absorption gap éventuel (si présent)
```

**23h00+**:
```
✅ Nouvelles positions: Autorisées
⚠️ Position size: ×0.8 (prudence)
📝 Raison: Marché stabilisé après réouverture
```

---

## 🚫 RÈGLES D'INTERDICTION ABSOLUES

### Jamais de Trade si:

**Validations Techniques**:
- ❌ Score H4 < 3/5 votes
- ❌ Score H1 < 5/8 votes
- ❌ Score M15 < 4/6 votes
- ❌ Score Macro < 1/2 votes
- ❌ Score global < 14/21 votes

**Protections Risk**:
- ❌ Perte journalière réalisée ≥ 2%
- ❌ Drawdown ≥ 20%
- ❌ Position déjà ouverte sur XAUUSD

**Protections Temporelles**:
- ❌ Session Asian (01h-09h Paris)
- ❌ Dead Zone (22h-01h Paris)
- ❌ Vendredi après 20h00 (nouveaux trades)
- ❌ Dimanche avant 23h00
- ❌ 1h avant et 1h après annonce économique majeure
- ❌ Gap détecté > 2× ATR (attente 2-3h stabilisation)

**Protections Qualité Exécution**:
- ❌ Spread > 6 pips
- ❌ Spread > 30% de l'ATR M15
- ❌ Spread > 2.5× moyenne des 20 dernières bougies

### Jamais:

- ❌ Hedging (position LONG et SHORT simultanées sur XAUUSD)
- ❌ Fermer une position pour en ouvrir une inverse immédiatement (attendre 1 bougie)
- ❌ Dépasser 1.00% de risk par trade
- ❌ Trader sans les 3 timeframes validés (H4+H1+M15)
- ❌ Ignorer le trailing stop
- ❌ Mettre un Take Profit fixe
- ❌ Trader sur émotion, "feeling", ou intuition
- ❌ Modifier manuellement les paramètres pendant le trading

---

## 🔄 TRADE SEQUENCING (Anti-Revenge Trading)

**Hermès réduit automatiquement après des losing streaks**:

| Losing Streak | Position Size | Min Votes | Cooldown | Message |
|---------------|---------------|-----------|----------|---------|
| **0-1 loss** | 100% (×1.0) | 14/21 | 0 signal | Normal |
| **2 losses** | 75% (×0.75) | 15/21 | 0 signal | ⚠️ Prudence |
| **3 losses** | 50% (×0.50) | 16/21 | Skip 1 signal | ⚠️ Réduction forte |
| **4+ losses** | 30% (×0.30) | 17/21 | Skip 2 signaux | 🚨 Mode survie |

**Win Rate Récent (20 derniers trades)**:
```
Si Win Rate < 40% sur les 20 derniers trades:
→ Position size ×0.6
→ Minimum votes: 16/21
→ Message: "⚠️ Review strategy - Low performance"
```

**Pourquoi c'est professionnel**:
Les meilleurs traders institutionnels réduisent automatiquement leur exposition après des pertes pour **survivre** aux périodes difficiles et revenir plus fort. C'est la différence entre un trader qui explose son compte et un trader qui dure 10 ans.

---

## 🎲 MOMENTUM REGIME DETECTION

**Hermès détecte automatiquement le régime de marché actuel.**

### 4 Métriques Combinées

1. **ADX** (déjà utilisé dans les indicateurs)
2. **ATR Ratio** (ATR actuel vs moyenne 50 périodes)
3. **R² Régression Linéaire** (force de la tendance)
4. **Efficiency Ratio Kaufman** (directionnalité vs noise)

### Score Composite et Classification

| Régime | Score | Position Size | Min Votes | Caractéristiques |
|--------|-------|---------------|-----------|------------------|
| **STRONG TREND** | ≥6/8 | +20% (×1.2) | 13/21 | 🔥 Conditions idéales trend-following |
| **WEAK TREND** | 4-5/8 | Normal (×1.0) | 14/21 | Conditions normales |
| **RANGING** | <4/8 | -50% (×0.5) | 17/21 | ⚠️ Conditions difficiles, ultra-sélectif |

**Impact**:
- **Strong Trend** → Hermès plus agressif (boost +20%, moins exigeant)
- **Weak Trend** → Hermès normal
- **Ranging** → Hermès ultra-prudent (réduit 50%, très sélectif, skip beaucoup de signaux)

---

## 📊 COT (COMMITMENT OF TRADERS)

### Mise à Jour et Source

```
Fréquence: Hebdomadaire
Publication: Chaque VENDREDI 15h30 EST (21h30 Paris)
Source: CFTC.gov (gratuit)
Contrat: Gold Futures (GC) COMEX
Données disponibles depuis: 1986
Retard: Données du MARDI publié le VENDREDI (3 jours de retard)
```

### Les 3 Catégories d'Acteurs

**1. Commercials (Producteurs/Banques)** 🏦
- Mineurs d'or, bijoutiers, banques centrales
- **"Smart Money"**: Hedgent leur production/exposition
- **Contrarians**: Achètent quand tout le monde vend
- **Les plus fiables**

**2. Large Speculators (Hedge Funds)** 🏢
- Fonds spéculatifs, CTA
- Suivent les tendances (trend followers)
- **Dangereux en extrêmes**: Surexposés = reversal proche

**3. Small Speculators (Retail)** 🤑
- Traders particuliers
- **Toujours du mauvais côté** statistiquement
- **Contrarian indicator**: Fait l'inverse !

### Interprétation pour Hermès

| Commercials Net Position | COT Vote | Position Size Adjustment | Signification |
|--------------------------|----------|--------------------------|---------------|
| **> +80 000 contrats** | +1.0 | +20% (×1.2) | STRONG BULLISH - Smart money très long |
| **+30k à +80k** | +0.5 | +10% (×1.1) | BULLISH - Smart money modérément long |
| **-30k à +30k** | 0 | Normal (×1.0) | NEUTRAL |
| **-80k à -30k** | -0.5 | -10% (×0.9) | BEARISH - Smart money modérément short |
| **< -80 000 contrats** | -1.0 | -20% (×0.8) | STRONG BEARISH - Smart money très short |

### COT N'est PAS Éliminatoire

**Important: Le COT influence SEULEMENT**:
1. Le score global (vote +1, 0, ou -1)
2. La taille de position (multiplicateur)

**Il ne peut PAS annuler un signal à lui seul.**

**Exemple 1**:
```
Votes techniques: 15/21
COT contre: -1
TOTAL: 14/21 ✅ (= minimum)

→ Signal ACCEPTÉ
→ Mais position réduite de 20% (COT contre)
```

**Exemple 2**:
```
Votes techniques: 13/21
COT pour: +1
TOTAL: 14/21 ✅ (= minimum)

→ Signal ACCEPTÉ
→ Et position boostée de 20% (COT aligné)
```

**Exemple 3**:
```
Votes techniques: 13/21
COT contre: -1
TOTAL: 12/21 ❌ (< 14 minimum)

→ Signal REFUSÉ
→ Mais c'est le score global insuffisant, pas un "veto COT"
```

---

## 🔬 ANALYSE SHAP (Optimisation Continue)

### Principe

**SHAP (SHapley Additive exPlanations)** est une méthode de Machine Learning qui calcule la **contribution réelle** de chaque indicateur à la performance finale.

**Implémentation**: SHAP est intégré directement dans le code MQL5 et génère automatiquement des fichiers CSV.

### Fichiers CSV Générés Automatiquement

#### 1. `hermes_trades_detailed.csv`

**Après chaque trade fermé**, Hermès enregistre:

```csv
trade_id,entry_date,entry_time,direction,entry_price,sl,exit_price,result,r_multiple,duration_hours,adx_h4,ema_cross_h4,ema_50_200_h4,price_ema21_h4,supertrend_h4,ema_cross_h1,macd_h1,rsi_h1,sar_h1,stoch_h1,bollinger_h1,vol_momentum_h1,donchian_h1,vwap_m15,orderflow_m15,volatility_m15,tick_m15,eurusd_m15,spread_m15,cot,atr_percentile,votes_h4,votes_h1,votes_m15,votes_macro,votes_total
```

**Colonnes**:
- Infos du trade (entry, exit, result, R multiple, durée...)
- **Les 21 indicateurs**: 1 = présent/voté OUI, 0 = absent/voté NON
- Votes par niveau et total

#### 2. `hermes_shap_analysis.csv`

**Tous les 50 trades fermés**, Hermès recalcule et génère:

```csv
date,total_trades,indicator,weight_current,participated_count,participated_percent,win_count,loss_count,win_rate,avg_r_when_present,avg_r_when_absent,contribution_delta,shap_value,recommended_weight,status
```

**Colonnes détaillées**:

| Colonne | Description | Exemple |
|---------|-------------|---------|
| `date` | Date de l'analyse | 2025-12-15 |
| `total_trades` | Nombre de trades analysés | 250 |
| `indicator` | Nom de l'indicateur | vwap_m15 |
| `weight_current` | Poids actuel | 1.0 |
| `participated_count` | Nombre de trades où indicateur a voté OUI | 198 |
| `participated_percent` | % de participation | 79.2% |
| `win_count` | Gagnants quand présent | 135 |
| `loss_count` | Perdants quand présent | 63 |
| `win_rate` | Win rate quand présent | 68.2% |
| `avg_r_when_present` | R moyen quand présent | +2.15 |
| `avg_r_when_absent` | R moyen quand absent | +0.85 |
| `contribution_delta` | Différence (présent - absent) | **+1.30** 🔥 |
| `shap_value` | Valeur SHAP (importance ML) | 0.245 |
| `recommended_weight` | Poids recommandé | 3.0 |
| `status` | Recommandation | CRITICAL |

**Status possibles**:
- **CRITICAL**: contribution > +0.8R → Poids recommandé 3.0
- **HIGH**: contribution > +0.5R → Poids recommandé 2.0-2.5
- **MEDIUM**: contribution > +0.2R → Poids recommandé 1.0-1.5
- **LOW**: contribution > +0.05R → Poids recommandé 0.5-1.0
- **NEUTRAL**: contribution -0.05 à +0.05R → Poids 0.5
- **WEAK**: contribution < -0.05R → Poids 0.0
- **REMOVE**: contribution < -0.15R → Supprimer du code

#### 3. `hermes_summary.csv`

**Résumé global** mis à jour avec SHAP:

```csv
metric,value
total_trades_analyzed,250
analysis_period_start,2025-06-15
analysis_period_end,2025-12-15
overall_win_rate,61.2%
overall_avg_r,+1.58
overall_profit_factor,2.14

indicators_total,21
indicators_critical,3
indicators_high,3
indicators_medium,7
indicators_low,4
indicators_neutral,2
indicators_remove,2

best_indicator,vwap_m15
best_contribution,+1.30
worst_indicator,stochastic_h1
worst_contribution,-0.27
```

### Comment Utiliser Ces CSV

**Étape 1: Ouvre `hermes_shap_analysis.csv` dans Excel**

Trie par colonne `contribution_delta` (du plus haut au plus bas).

**Tu vois immédiatement**:
```
VWAP M15: +1.30R → 🔥 SUPER IMPORTANT
  → Participé 198 fois, 135 wins / 63 losses
  → Quand présent: +2.15R moyen
  → Quand absent: +0.85R moyen
  → Ajoute +1.30R de performance !

Stochastic H1: -0.27R → ❌ NUISIBLE
  → Participé 188 fois, 108 wins / 80 losses
  → Quand présent: +1.48R moyen
  → Quand absent: +1.75R moyen
  → DÉTÉRIORE la performance de -0.27R !
```

**Étape 2: Décisions d'Ajustement**

**Indicateurs CRITICAL/HIGH**:
→ Augmente leur poids dans le code (2.0 à 3.0)

**Indicateurs MEDIUM/LOW**:
→ Garde poids 1.0 ou réduis légèrement à 0.5

**Indicateurs WEAK/REMOVE**:
→ Supprime-les complètement du code

**Étape 3: Applique dans MQL5**

```cpp
// AVANT (tous égaux)
double weights[21] = {1.0, 1.0, 1.0, ...};

// APRÈS analyse SHAP (exemple après 6 mois)
double weights[21] = {
    3.0, // ADX H4 (contribution +1.16R)
    2.5, // EMA Cross H4 (contribution +0.87R)
    2.0, // EMA 50/200 H4
    1.0, // Prix/EMA21 H4
    1.0, // Supertrend H4
    2.5, // EMA Cross H1 (contribution +0.61R)
    1.5, // MACD H1
    1.0, // RSI H1
    0.5, // SAR H1
    0.0, // Stochastic H1 (SUPPRIMÉ, contribution -0.27R)
    1.0, // Bollinger H1
    0.5, // Volume Momentum H1
    1.0, // Donchian H1
    3.0, // VWAP M15 (contribution +1.30R) 🔥
    3.0, // Order Flow M15 (contribution +1.03R)
    2.0, // Volatility M15
    1.0, // Tick Momentum M15
    2.5, // EURUSD M15 (contribution +0.73R)
    0.5, // Spread M15
    1.5, // COT
    0.5  // ATR Percentile
};

// Nouveaux seuils avec poids ajustés
// (recalculés proportionnellement)
```

### Timeline Optimisation

**Mois 0-6: Démarrage**
```
✅ Tous les indicateurs poids = 1.0
✅ Seuils: H4 3/5, H1 5/8, M15 4/6, Macro 1/2, Global 14/21
✅ Collecte données exhaustive
✅ Objectif: 300-500 trades minimum
```

**Mois 6: Première Analyse SHAP**
```
✅ Hermès génère automatiquement hermes_shap_analysis.csv
✅ Tu ouvres le CSV dans Excel
✅ Tu identifies les indicateurs critiques vs inutiles
✅ Tu ajustes manuellement les poids dans le code
✅ Tu supprimes les indicateurs nuisibles
✅ Backtest validation sur out-sample
✅ Deploy nouveaux poids si amélioration > 10%
```

**Mois 12, 18, 24...: Réanalyses**
```
✅ Tous les 6 mois, nouveau CSV SHAP généré
✅ Tu compares avec analyse précédente
✅ Tu ajustes si changement > 20%
✅ Le système s'affine progressivement
✅ Exemple: 21 indicateurs → 18 → 16 → 14 (garde les meilleurs)
```

---

## 🎯 OBJECTIFS DE PERFORMANCE (Sur 5 ans backtest)

### Statistiques Cibles

```
Win Rate: 55-65%
Profit Factor: > 1.8
Max Drawdown: < 15%
Daily Max Loss: < 3%
Sharpe Ratio: > 1.5
Sortino Ratio: > 2.0
Calmar Ratio: > 1.0
```

### Activité de Trading

```
Nombre de trades par an: 80-150
Moyenne par semaine: 2-3 trades
Avg R par trade: +1.5R à +3.0R
Best trade possible: +15R (grandes tendances)
Worst trade: -1R (SL initial)
Avg gagnant: +5.0R (trailing capture plus que TP fixe)
Avg perdant: -0.8R (trailing stop protège dès +0.5R)
```

### Séquences Attendues

```
Longest win streak: 8-12 trades
Longest lose streak: 4-6 trades
Recovery time après DD 10%: 2-4 semaines
Consistency (mois positifs): 70-80% des mois
```

---

## 🔄 WORKFLOW COMPLET (Chaque Bougie M15)

**Durée totale: 20-30 secondes par analyse**

### 1️⃣ CHECKS PRÉLIMINAIRES (Instant)

```
Position déjà ouverte sur XAUUSD ?
  → OUI: Gère trailing stop uniquement, skip nouvelle analyse
  → NON: Continue

Session actuelle ?
  → Dead Zone (22h-01h) ou Asian (01h-09h) → STOP
  → Sinon → Continue

Weekend proximity ?
  → Vendredi 20h+ ou Dimanche < 23h → STOP nouveaux trades
  → Sinon → Continue

Gap détecté ?
  → Gap > 2×ATR → STOP, attends 2-3h
  → Sinon → Continue

Perte journalière réalisée ?
  → ≥ 2% → STOP nouveaux trades
  → < 2% → Continue

Drawdown actuel ?
  → ≥ 20% → STOP total
  → < 20% → Continue (avec multiplicateur DD)

Spread acceptable ?
  → > 6 pips ou > 30% ATR → STOP
  → OK → Continue

News dans l'heure ?
  → OUI → STOP
  → NON → Continue
```

### 2️⃣ ANALYSE H4 MACRO (5-10 sec)

```
Calcule les 5 indicateurs H4:
  → ADX, EMA 21/55, EMA 50/200, Prix/EMA21, Supertrend

Compte votes H4:
  → Exemple: 4/5 votes

Vérifie seuil:
  → 4/5 ≥ 3/5 ? OUI ✅
  → Continue H1
  → Sinon → Signal rejeté, attends prochaine bougie
```

### 3️⃣ ANALYSE H1 SETUP (5-10 sec)

```
Calcule les 8 indicateurs H1:
  → EMA cross, MACD, RSI, SAR, Stoch, Bollinger, Volume, Donchian

Compte votes H1:
  → Exemple: 6/8 votes

Vérifie seuil:
  → 6/8 ≥ 5/8 ? OUI ✅
  → Continue M15
  → Sinon → Signal rejeté
```

### 4️⃣ ANALYSE M15 TIMING (5-10 sec)

```
Calcule les 6 indicateurs M15:
  → VWAP, OrderFlow, Volatility, Tick, EURUSD, Spread

Compte votes M15:
  → Exemple: 5/6 votes

Vérifie seuil:
  → 5/6 ≥ 4/6 ? OUI ✅
  → Continue Macro
  → Sinon → Signal rejeté
```

### 5️⃣ ANALYSE MACRO CONTEXT (Instant)

```
Calcule les 2 indicateurs Macro:
  → COT (hebdomadaire), ATR Percentile

Compte votes Macro:
  → Exemple: 2/2 votes

Vérifie seuil:
  → 2/2 ≥ 1/2 ? OUI ✅
  → Continue validation globale
  → Sinon → Signal rejeté
```

### 6️⃣ VALIDATION GLOBALE

```
Calcul score total:
  → H4: 4 + H1: 6 + M15: 5 + Macro: 2 = 17/21

Vérifie seuil global:
  → 17/21 ≥ 14/21 ? OUI ✅
  → Continue

Tous les niveaux validés ?
  → H4 ✅, H1 ✅, M15 ✅, Macro ✅, Global ✅
  → Signal VALIDÉ, continue position sizing
```

### 7️⃣ REGIME & SEQUENCE (Instant)

```
Détection momentum regime:
  → Strong Trend / Weak Trend / Ranging
  → Exemple: Strong Trend → Multiplicateur ×1.2

Vérification losing streak:
  → 0-1 loss → ×1.0
  → 2 losses → ×0.75
  → 3 losses → ×0.50
  → 4+ losses → ×0.30
  → Exemple: 1 loss récent → ×1.0
```

### 8️⃣ POSITION SIZING (1 sec)

```
Calcul Kelly base:
  → 0.7% × kelly_fraction (0.20) = 0.14%

Application 7 multiplicateurs:
  → Confidence: 17/21 = 0.81
  → Session: Overlap = ×1.3
  → Regime: Strong Trend = ×1.2
  → Sequence: 1 loss = ×1.0
  → Drawdown: 5% = ×1.0
  → COT: Aligned = ×1.2
  → Spread: Normal = ×1.0

Position finale:
  → 0.14% × 0.81 × 1.3 × 1.2 × 1.0 × 1.0 × 1.2 × 1.0 = 0.22%
  → 0.22% cappé entre 0.33% min et 1.00% max
  → Final: 0.33% (atteint minimum)

Calcul lot size:
  → Risk = 100 000 € × 0.0033 = 330 €
  → ATR M15 = 2.5 pips
  → SL = 2.5 × 1.5 = 3.75 pips
  → Lot = 330 / (3.75 × 10) = 8.8 → Arrondi 0.09 lot

Vérification broker minimum:
  → 0.09 ≥ 0.01 ? OUI ✅
```

### 9️⃣ EXÉCUTION (< 100ms)

```
Envoi Market Order BUY:
  → Lot size: 0.09
  → Entry: Prix du marché (ex: 2050.50)
  → SL: Entry - (ATR × 1.5) = 2046.75
  → TP: AUCUN (trailing seulement)

Logging dans CSV:
  → hermes_trades_detailed.csv
  → trade_id, entry_time, direction, entry, sl, les 21 indicateurs (1/0), votes...
```

### 🔟 GESTION POSITION (Chaque bougie M15)

```
Update trailing stop:
  → Vérifie paliers: +0.5R, +1R, +1.5R, +2R, +2.5R, +3R, +3.5R
  → Déplace SL si palier atteint

Monitoring votes:
  → Recalcule les 21 indicateurs
  → Si score tombe < 60% du score initial → Sortie anticipée
  → Exemple: Entré avec 17/21, si tombe à 10/21 → Close

Monitoring ADX:
  → Si ADX tombe < 20 → Fin de tendance probable → Close

Update statistiques:
  → R actuel, durée, flottant...
```

### 1️⃣1️⃣ CLÔTURE (Quand déclenchée)

```
Raisons de clôture possibles:
  ✅ Trailing stop touché (gain sécurisé)
  ❌ SL initial touché (perte limitée)
  ⚠️ Sortie anticipée (score < 60% initial ou ADX < 20)

Logging final dans CSV:
  → hermes_trades_detailed.csv
  → Ajoute: exit_price, result (WIN/LOSS), r_multiple, duration_hours

Update trade sequence:
  → Si WIN: Reset losing streak à 0, increment winning streak
  → Si LOSS: Increment losing streak, reset winning streak

Si 50 trades atteints:
  → Recalcule SHAP analysis
  → Génère hermes_shap_analysis.csv
  → Génère hermes_summary.csv
  → Log: "SHAP analysis updated - Check CSV files"
```

---

## 🎛️ PARAMÈTRES TECHNIQUES OPTIMAUX

### Indicateurs Techniques

```
EMAs: 21, 55, 50, 200
ADX: Période 14, Seuil 25 (pas obligatoire)
ATR: Période 14, Multiplicateur SL 1.5
RSI: Période 14, Zone 50-70 (BUY) ou 30-50 (SELL)
MACD: Fast 12, Slow 26, Signal 9
Bollinger Bands: Période 20, Std 2
Stochastic: K 14, D 3, Smooth 3
Donchian: Période 20
Parabolic SAR: Start 0.02, Max 0.2
Supertrend: ATR 10, Factor 3

VWAP: Reset daily (00h00)
Order Flow: Lookback 20 bougies
Volatility: Window 50 bougies, Expansion threshold 1.2×
Tick Momentum: Ratio upticks/downticks
EURUSD Correlation: Calcul rolling 20-50 périodes
Effective Spread: Moyenne 20 bougies
```

### Risk Management

```
Kelly Criterion: Cap 25% de la fraction Kelly complète
Base Risk: 0.7% du capital
Risk Range: 0.33% minimum, 1.00% maximum
Daily Loss Max: 2.00% réalisé (flottant exclu)
Drawdown Levels: 8%, 15%, 20%
Trailing Stop Paliers: 0.5R, 1.0R, 1.5R, 2.0R, 2.5R, 3.0R, 3.5R+
```

### Scoring & Seuils (Poids Égaux au Démarrage)

```
Poids de départ: Tous à 1.0

Seuils minimums:
H4: 3/5 votes (60%)
H1: 5/8 votes (63%)
M15: 4/6 votes (67%)
Macro: 1/2 votes (50%)
Global: 14/21 votes (67%)
```

### Sessions & Timing

```
Sessions autorisées: London (09h-14h), Overlap (14h-17h), New York (17h-22h)
Sessions interdites: Asian (01h-09h), Dead Zone (22h-01h)
Best session: London-NY Overlap (14h-17h) × 1.3
News blackout: 1h avant + 1h après événements majeurs
Weekend: Pas de nouveaux trades vendredi 20h+, dimanche < 23h
```

### Spread & Qualité

```
Spread max absolu: 6.0 pips
Spread max vs moyenne: 2.5×
Spread max vs ATR: 30%
Slippage budget: +0.5 pips par trade
```

---

## 🏆 COMPARAISON AMATEUR vs HERMÈS 2.5 PRO

| Critère | Trader Amateur | Hermès 2.5 Institutionnel |
|---------|----------------|---------------------------|
| **Indicateurs** | 2-3 figés, "feeling" | 21 techniques + 1 macro, vote objectif |
| **Timeframes** | 1 seul (souvent M15/M5) | 3 hiérarchiques (H4→H1→M15) |
| **Validation** | "Ça a l'air bien" | 5 niveaux, consensus 67% minimum |
| **Position Size** | Fixe (0.1 lot toujours) | Kelly adaptatif × 7 multiplicateurs (0.33-1%) |
| **Stop Loss** | Fixe (20 pips) ou "mental" | ATR × 1.5 (s'adapte à volatilité) |
| **Take Profit** | Fixe (40 pips) | ❌ AUCUN - Trailing sans limite |
| **Gain moyen** | +2R (TP fixe limite) | +5R (trailing capture grandes tendances) |
| **Risk/jour** | "Je gère", souvent >5% | 2% max réalisé, bloque auto nouveaux trades |
| **Drawdown** | Continue pareil à -20% | Circuit breakers 8%/15%/20% auto |
| **News** | Ignore ou panic trade | Blackout automatique 1h avant/après |
| **Sessions** | Trade 24/7 | Asian interdite, focus Overlap L-NY |
| **Losing Streak** | Continue ou revenge trade | Auto-réduit 50-70%, skip signaux |
| **Weekend** | Trade vendredi 22h | Block nouveaux trades 20h+ |
| **Spread** | Ignore (entre même à 10 pips) | Max 6 pips ou 30% ATR |
| **COT** | Ne connaît pas | Suit smart money hebdo |
| **Optimisation** | Sur-optimise sur passé | SHAP analysis évolutive tous les 6 mois |
| **Backtesting** | Irréaliste (pas de slippage) | Slippage +0.5 pips, spread variable, commission 7$ |
| **Discipline** | Émotions, fatigue, tilt | 100% automatique, 0 émotion |
| **Win Rate** | 45-50% | 55-65% |
| **Profit Factor** | 1.2-1.5 | 1.8-2.5 |
| **FTMO Success** | 5-10% passent | 40-60% objectif |
| **Survie long terme** | 90% échouent < 2 ans | Conçu pour durer 10+ ans |

---

## ✅ CHECKLIST COMPLÈTE IMPLÉMENTATION MQL5

### Code Principal

- [ ] 21 indicateurs calculés correctement sur H4/H1/M15
- [ ] Système de vote avec tous poids = 1.0 au démarrage
- [ ] Validation hiérarchique: H4≥3, H1≥5, M15≥4, Macro≥1, Global≥14
- [ ] Aucun indicateur obligatoire ou éliminatoire (pas de veto)
- [ ] Position sizing Kelly + 7 multiplicateurs (0.33-1.00%)
- [ ] Trailing stop 7 paliers (0.5R à 3.5R+)
- [ ] Pas de TP fixe

### Protections Temporelles

- [ ] Session Asian interdite (×0.0)
- [ ] Dead Zone interdite (×0.0)
- [ ] Overlap London-NY boosté (×1.3)
- [ ] News blackout 1h avant/après (liste événements majeurs)
- [ ] Weekend: block nouveaux trades vendredi 20h+, dimanche < 23h
- [ ] Gap detection > 2×ATR (attente 2-3h)

### Protections Risk

- [ ] Daily loss max 2% réalisé → block nouveaux trades
- [ ] Drawdown circuit breakers 8%/15%/20%
- [ ] Losing streak auto-réduction 2/3/4+ losses
- [ ] Win rate récent < 40% → alerte et réduction
- [ ] Max 1 position XAUUSD simultanée
- [ ] Pas de hedging

### Protections Qualité

- [ ] Spread filter: max 6 pips, max 30% ATR, max 2.5× moyenne
- [ ] Slippage budget: +0.5 pips par trade
- [ ] Vérification broker minimum (0.01 lot)

### Logging & SHAP

- [ ] Logging exhaustif chaque trade dans `hermes_trades_detailed.csv`
- [ ] 21 indicateurs enregistrés (1/0) à chaque trade
- [ ] Calcul SHAP tous les 50 trades
- [ ] Génération automatique `hermes_shap_analysis.csv`
- [ ] Génération automatique `hermes_summary.csv`
- [ ] Log dans journal MT5 quand SHAP mis à jour

### Fichiers CSV Générés

- [ ] `hermes_trades_detailed.csv` (toutes colonnes requises)
- [ ] `hermes_shap_analysis.csv` (14 colonnes par indicateur)
- [ ] `hermes_summary.csv` (métriques globales)

---

**🏛️ HERMÈS 2.5 - Spécifications Complètes**

*Document Version: 1.0*
*Date: 2025-01-19*
*Projet: Expert Advisor Institutionnel XAUUSD*
