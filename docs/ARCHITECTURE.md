# 🏗️ HERMÈS 2.5 - ARCHITECTURE TECHNIQUE MQL5

> **Guide Architecture Complète - Structure du Code**

---

## 📂 STRUCTURE FICHIERS

```
MQL5/
├── Hermes_2.5.mq5                    # EA principal (entry point)
├── Hermes_Config.mqh                 # Configuration centralisée
├── Hermes_Indicators.mqh             # 21 indicateurs techniques
├── Hermes_RiskManager.mqh            # Position sizing & risk
├── Hermes_TrailingStop.mqh           # Trailing stop 7 paliers
├── Hermes_SessionManager.mqh         # Sessions & news blackout
├── Hermes_Logger.mqh                 # Logging CSV
└── Hermes_SHAP.mqh                   # SHAP analysis
```

---

## 🎯 HERMES_2.5.MQ5 (Main EA)

### Structure Générale

```cpp
//+------------------------------------------------------------------+
//| Hermes_2.5.mq5                                                    |
//| Expert Advisor Institutionnel pour XAUUSD                         |
//| Version 2.5 - Trend Following Multi-Timeframe                     |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

// Includes
#include "Hermes_Config.mqh"
#include "Hermes_Indicators.mqh"
#include "Hermes_RiskManager.mqh"
#include "Hermes_TrailingStop.mqh"
#include "Hermes_SessionManager.mqh"
#include "Hermes_Logger.mqh"
#include "Hermes_SHAP.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
    // Vérifications broker
    // Initialisation indicateurs
    // Chargement données COT/News
    // Initialisation logging
    // Affichage paramètres
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Sauvegarde état
    // Fermeture fichiers CSV
    // Cleanup
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // 1. Gestion position existante (trailing stop)
    if (PositionExists()) {
        ManageOpenPosition();
        return;
    }

    // 2. Nouvelle bougie M15 ?
    if (!IsNewCandle()) return;

    // 3. Checks préliminaires
    if (!CanOpenNewTrade()) return;

    // 4. Analyse multi-timeframe
    int direction = AnalyzeMarket();
    if (direction == 0) return;  // Pas de signal

    // 5. Position sizing
    double lotSize = CalculatePositionSize(direction);
    if (lotSize < MinLot) return;

    // 6. Exécution trade
    OpenTrade(direction, lotSize);
}
```

---

## ⚙️ HERMES_CONFIG.MQH

### Variables Globales & Paramètres

```cpp
//+------------------------------------------------------------------+
//| Hermes_Config.mqh - Configuration Centralisée                     |
//+------------------------------------------------------------------+

// === MAGIC NUMBER ===
#define MAGIC_NUMBER 250125

// === SYMBOLE ===
#define SYMBOL "XAUUSD"

// === TIMEFRAMES ===
#define TF_MACRO PERIOD_H4
#define TF_SETUP PERIOD_H1
#define TF_TIMING PERIOD_M15

// === VALIDATION ===
input int Min_Votes_H4 = 3;           // Minimum votes H4 (sur 5)
input int Min_Votes_H1 = 5;           // Minimum votes H1 (sur 8)
input int Min_Votes_M15 = 4;          // Minimum votes M15 (sur 6)
input int Min_Votes_Macro = 1;        // Minimum votes Macro (sur 2)
input int Min_Votes_Total = 14;       // Minimum votes Global (sur 21)

// === RISK MANAGEMENT ===
input double Kelly_Cap = 0.25;                // Kelly fraction max
input double Base_Risk_Percent = 0.7;         // Base risk avant multiplicateurs
input double Min_Risk_Percent = 0.33;         // Risk minimum par trade
input double Max_Risk_Percent = 1.00;         // Risk maximum par trade
input double Daily_Loss_Max = 2.0;            // Daily loss max (% réalisé)

// === TRAILING STOP ===
input double ATR_Multiplier_SL = 1.5;         // ATR × 1.5 pour SL initial
input double Trailing_Offset_After_35R = 0.5; // Offset après +3.5R

// === SESSIONS ===
input bool Enable_Asian_Session = false;      // Asian INTERDITE
input bool Enable_London_Session = true;
input bool Enable_Overlap_Session = true;
input bool Enable_NY_Session = true;

// === PROTECTIONS ===
input double Max_Spread_Pips = 6.0;           // Spread max absolu
input double Max_Spread_vs_ATR = 0.30;        // 30% de l'ATR
input double Max_Spread_vs_Avg = 2.5;         // 2.5× moyenne
input int News_Blackout_Hours = 1;            // 1h avant/après news
input int Weekend_Block_Hour_Friday = 20;     // Vendredi 20h
input int Weekend_Allow_Hour_Sunday = 23;     // Dimanche 23h

// === REGIME DETECTION ===
input int Regime_Strong_Threshold = 6;        // ≥6/8 = Strong Trend
input int Regime_Ranging_Threshold = 4;       // <4/8 = Ranging

// === SHAP ANALYSIS ===
input int SHAP_Analysis_Frequency = 50;       // Recalcul tous les 50 trades
input int SHAP_Min_Trades = 300;              // Minimum pour 1ère optimisation
input bool Enable_Auto_CSV_Export = true;

// === INDICATEURS WEIGHTS (Initial = 1.0) ===
double Indicator_Weights[21] = {
    1.0, 1.0, 1.0, 1.0, 1.0,  // H4 (5)
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,  // H1 (8)
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0,  // M15 (6)
    1.0, 1.0  // Macro (2)
};

// === VARIABLES GLOBALES ===
int g_TotalTrades = 0;
int g_LosingStreak = 0;
int g_WinningStreak = 0;
double g_DailyRealizedPnL = 0.0;
double g_PeakBalance = 0.0;
double g_CurrentDrawdown = 0.0;
datetime g_LastCandleTime = 0;
double g_Last20Trades[20];  // Pour win rate récent

// === HANDLES INDICATEURS ===
int h_ADX_H4;
int h_EMA21_H4, h_EMA55_H4, h_EMA50_H4, h_EMA200_H4;
int h_MACD_H1;
int h_RSI_H1;
int h_SAR_H1;
int h_Stoch_H1;
int h_BB_H1;
int h_ATR_M15;
// ... etc pour tous les indicateurs

// === FICHIERS CSV ===
string CSV_Trades_Detailed = "hermes_trades_detailed.csv";
string CSV_SHAP_Analysis = "hermes_shap_analysis.csv";
string CSV_Summary = "hermes_summary.csv";
```

---

## 🔢 HERMES_INDICATORS.MQH

### Architecture Indicateurs

```cpp
//+------------------------------------------------------------------+
//| Hermes_Indicators.mqh - 21 Indicateurs Techniques                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe de base pour indicateurs                                  |
//+------------------------------------------------------------------+
class CIndicatorBase {
protected:
    string m_name;
    int    m_id;
    double m_weight;

public:
    CIndicatorBase(string name, int id, double weight = 1.0) {
        m_name = name;
        m_id = id;
        m_weight = weight;
    }

    virtual bool Calculate(int direction) = 0;  // Abstract

    string GetName() { return m_name; }
    int    GetID()   { return m_id; }
    double GetWeight() { return m_weight; }
    void   SetWeight(double w) { m_weight = w; }
};

//+------------------------------------------------------------------+
//| H4 INDICATORS (5)                                                |
//+------------------------------------------------------------------+

// Indicateur 1: ADX
class CADX_H4 : public CIndicatorBase {
private:
    int m_handle;
    int m_period;

public:
    CADX_H4() : CIndicatorBase("ADX_H4", 1) {
        m_period = 14;
        m_handle = iADX(SYMBOL, PERIOD_H4, m_period);
    }

    virtual bool Calculate(int direction) {
        double adx[];
        ArraySetAsSeries(adx, true);

        if(CopyBuffer(m_handle, 0, 0, 1, adx) <= 0)
            return false;

        // Condition: ADX > 25 (pour BUY et SELL)
        return (adx[0] > 25.0);
    }
};

// Indicateur 2: EMA 21/55 Cross
class CEMA_Cross_H4 : public CIndicatorBase {
private:
    int m_handle_ema21;
    int m_handle_ema55;

public:
    CEMA_Cross_H4() : CIndicatorBase("EMA_Cross_H4", 2) {
        m_handle_ema21 = iMA(SYMBOL, PERIOD_H4, 21, 0, MODE_EMA, PRICE_CLOSE);
        m_handle_ema55 = iMA(SYMBOL, PERIOD_H4, 55, 0, MODE_EMA, PRICE_CLOSE);
    }

    virtual bool Calculate(int direction) {
        double ema21[], ema55[];
        ArraySetAsSeries(ema21, true);
        ArraySetAsSeries(ema55, true);

        if(CopyBuffer(m_handle_ema21, 0, 0, 1, ema21) <= 0) return false;
        if(CopyBuffer(m_handle_ema55, 0, 0, 1, ema55) <= 0) return false;

        if(direction == 1)  // BUY
            return (ema21[0] > ema55[0]);
        else if(direction == -1)  // SELL
            return (ema21[0] < ema55[0]);

        return false;
    }
};

// Indicateur 3: EMA 50/200
class CEMA_50_200_H4 : public CIndicatorBase {
private:
    int m_handle_ema50;
    int m_handle_ema200;

public:
    CEMA_50_200_H4() : CIndicatorBase("EMA_50_200_H4", 3) {
        m_handle_ema50 = iMA(SYMBOL, PERIOD_H4, 50, 0, MODE_EMA, PRICE_CLOSE);
        m_handle_ema200 = iMA(SYMBOL, PERIOD_H4, 200, 0, MODE_EMA, PRICE_CLOSE);
    }

    virtual bool Calculate(int direction) {
        double ema50[], ema200[];
        ArraySetAsSeries(ema50, true);
        ArraySetAsSeries(ema200, true);

        if(CopyBuffer(m_handle_ema50, 0, 0, 1, ema50) <= 0) return false;
        if(CopyBuffer(m_handle_ema200, 0, 0, 1, ema200) <= 0) return false;

        if(direction == 1)  // BUY
            return (ema50[0] > ema200[0]);
        else if(direction == -1)  // SELL
            return (ema50[0] < ema200[0]);

        return false;
    }
};

// Indicateur 4: Prix vs EMA21
class CPrice_vs_EMA21_H4 : public CIndicatorBase {
private:
    int m_handle_ema21;

public:
    CPrice_vs_EMA21_H4() : CIndicatorBase("Price_EMA21_H4", 4) {
        m_handle_ema21 = iMA(SYMBOL, PERIOD_H4, 21, 0, MODE_EMA, PRICE_CLOSE);
    }

    virtual bool Calculate(int direction) {
        double ema21[], close[];
        ArraySetAsSeries(ema21, true);
        ArraySetAsSeries(close, true);

        if(CopyBuffer(m_handle_ema21, 0, 0, 1, ema21) <= 0) return false;
        if(CopyClose(SYMBOL, PERIOD_H4, 0, 1, close) <= 0) return false;

        if(direction == 1)  // BUY
            return (close[0] > ema21[0]);
        else if(direction == -1)  // SELL
            return (close[0] < ema21[0]);

        return false;
    }
};

// Indicateur 5: Supertrend
class CSupertrend_H4 : public CIndicatorBase {
    // Implementation custom Supertrend
    // (ATR 10, Factor 3)
    // Return: signal BUY/SELL
};

//+------------------------------------------------------------------+
//| H1 INDICATORS (8)                                                |
//+------------------------------------------------------------------+

// Indicateur 6: EMA Cross Detection H1
class CEMA_Cross_Signal_H1 : public CIndicatorBase {
    // Détecte croisement EMA 21/55 sur H1
    // Lookback 3 bougies
};

// Indicateur 7: MACD
class CMACD_H1 : public CIndicatorBase {
    // MACD (12/26/9)
    // Condition: histogram > 0 (BUY) ou < 0 (SELL)
};

// Indicateur 8: RSI
class CRSI_H1 : public CIndicatorBase {
    // RSI période 14
    // BUY: 50-70, SELL: 30-50
};

// Indicateur 9: Parabolic SAR
class CSAR_H1 : public CIndicatorBase {
    // SAR (0.02/0.2)
    // BUY: SAR < price, SELL: SAR > price
};

// Indicateur 10: Stochastic
class CStochastic_H1 : public CIndicatorBase {
    // Stochastic (14/3/3)
    // Détecte cross up/down
};

// Indicateur 11: Bollinger Width
class CBollinger_Width_H1 : public CIndicatorBase {
    // BB (20/2)
    // Width en expansion (> avg × 1.2)
};

// Indicateur 12: Volume Momentum
class CVolume_Momentum_H1 : public CIndicatorBase {
    // Volume × ΔPrice
    // Direction + croissance
};

// Indicateur 13: Donchian Breakout
class CDonchian_H1 : public CIndicatorBase {
    // High(20) / Low(20)
    // Breakout détection
};

//+------------------------------------------------------------------+
//| M15 INDICATORS (6)                                               |
//+------------------------------------------------------------------+

// Indicateur 14: VWAP (🔥 CRITIQUE selon SHAP)
class CVWAP_M15 : public CIndicatorBase {
private:
    double m_vwap_cumul_pv;
    double m_vwap_cumul_vol;
    datetime m_last_reset;

public:
    CVWAP_M15() : CIndicatorBase("VWAP_M15", 14) {
        m_vwap_cumul_pv = 0;
        m_vwap_cumul_vol = 0;
        m_last_reset = 0;
    }

    virtual bool Calculate(int direction) {
        // Reset daily à 00h00
        datetime current = TimeCurrent();
        MqlDateTime dt;
        TimeToStruct(current, dt);

        if(dt.hour == 0 && dt.min == 0 && current != m_last_reset) {
            m_vwap_cumul_pv = 0;
            m_vwap_cumul_vol = 0;
            m_last_reset = current;
        }

        // Calcul VWAP
        double typical_price = (iHigh(SYMBOL, PERIOD_M15, 0) +
                                iLow(SYMBOL, PERIOD_M15, 0) +
                                iClose(SYMBOL, PERIOD_M15, 0)) / 3.0;
        long volume = iVolume(SYMBOL, PERIOD_M15, 0);

        m_vwap_cumul_pv += typical_price * volume;
        m_vwap_cumul_vol += volume;

        double vwap = m_vwap_cumul_pv / m_vwap_cumul_vol;
        double close = iClose(SYMBOL, PERIOD_M15, 0);

        if(direction == 1)  // BUY
            return (close > vwap);
        else if(direction == -1)  // SELL
            return (close < vwap);

        return false;
    }
};

// Indicateur 15: Order Flow Delta
class COrderFlow_M15 : public CIndicatorBase {
    // Delta = Upticks - Downticks (lookback 20)
};

// Indicateur 16: Volatility Regime
class CVolatility_M15 : public CIndicatorBase {
    // ATR actuel vs ATR(50)
    // Expansion > 1.2×
};

// Indicateur 17: Tick Momentum
class CTick_Momentum_M15 : public CIndicatorBase {
    // Upticks/Total > 60%
};

// Indicateur 18: EURUSD Correlation
class CEURUSD_Corr_M15 : public CIndicatorBase {
    // Direction EURUSD
};

// Indicateur 19: Effective Spread
class CEffective_Spread_M15 : public CIndicatorBase {
    // Spread < moyenne(20)
};

//+------------------------------------------------------------------+
//| MACRO INDICATORS (2)                                             |
//+------------------------------------------------------------------+

// Indicateur 20: COT
class CCOT : public CIndicatorBase {
    // Commercials Net Position
    // Classification ±80k, ±30k
};

// Indicateur 21: ATR Percentile
class CATR_Percentile : public CIndicatorBase {
    // ATR daily vs historique 200j
    // Top 30%
};

//+------------------------------------------------------------------+
//| Manager Indicateurs                                              |
//+------------------------------------------------------------------+
class CIndicatorManager {
private:
    CIndicatorBase* m_indicators[21];

public:
    CIndicatorManager() {
        // Initialize tous les 21 indicateurs
        m_indicators[0] = new CADX_H4();
        m_indicators[1] = new CEMA_Cross_H4();
        m_indicators[2] = new CEMA_50_200_H4();
        // ... etc
    }

    ~CIndicatorManager() {
        // Cleanup
        for(int i = 0; i < 21; i++)
            delete m_indicators[i];
    }

    int CountVotes(int direction, ENUM_TIMEFRAME tf) {
        int votes = 0;

        // Range selon timeframe
        int start_idx = 0, end_idx = 21;

        if(tf == PERIOD_H4) {
            start_idx = 0; end_idx = 5;
        }
        else if(tf == PERIOD_H1) {
            start_idx = 5; end_idx = 13;
        }
        else if(tf == PERIOD_M15) {
            start_idx = 13; end_idx = 19;
        }
        else {  // MACRO
            start_idx = 19; end_idx = 21;
        }

        for(int i = start_idx; i < end_idx; i++) {
            if(m_indicators[i].Calculate(direction))
                votes++;
        }

        return votes;
    }

    int CountTotalVotes(int direction) {
        int votes = 0;
        for(int i = 0; i < 21; i++) {
            if(m_indicators[i].Calculate(direction))
                votes++;
        }
        return votes;
    }

    bool GetIndicatorState(int idx, int direction) {
        return m_indicators[idx].Calculate(direction);
    }
};

// Instance globale
CIndicatorManager* g_IndicatorManager = NULL;
```

---

## 💰 HERMES_RISKMANAGER.MQH

### Position Sizing & Risk

```cpp
//+------------------------------------------------------------------+
//| Hermes_RiskManager.mqh - Position Sizing & Protections            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Kelly Criterion                                                   |
//+------------------------------------------------------------------+
double CalculateKellyFraction() {
    if(g_TotalTrades < 20) return 0.20;  // Default avant historique

    // Calcul win rate et avg win/loss sur historique
    int wins = 0;
    double total_wins = 0.0, total_losses = 0.0;

    for(int i = 0; i < MathMin(g_TotalTrades, 100); i++) {
        // Parse hermes_trades_detailed.csv
        // ... (implementation)
    }

    double win_rate = (double)wins / g_TotalTrades;
    double avg_win = total_wins / wins;
    double avg_loss = total_losses / (g_TotalTrades - wins);

    // Kelly: (p × b - q) / b
    double kelly = (win_rate * avg_win - (1 - win_rate) * avg_loss) / avg_win;

    // Cap à 25%
    return MathMin(kelly, Kelly_Cap);
}

//+------------------------------------------------------------------+
//| 7 Multiplicateurs Contextuels                                    |
//+------------------------------------------------------------------+

// 1. Confidence Score
double GetConfidenceMultiplier(int total_votes) {
    // Linear mapping: 14/21 = 0.66, 21/21 = 1.00
    double score = (double)(total_votes - 14) / (21.0 - 14.0);
    return 0.66 + (score * 0.34);
}

// 2. Session Multiplier
double GetSessionMultiplier() {
    ENUM_SESSION session = GetCurrentSession();

    switch(session) {
        case SESSION_ASIAN:    return 0.0;   // INTERDIT
        case SESSION_LONDON:   return 1.0;
        case SESSION_OVERLAP:  return 1.3;
        case SESSION_NY:       return 1.0;
        case SESSION_DEAD:     return 0.0;   // INTERDIT
    }

    return 1.0;
}

// 3. Regime Multiplier
double GetRegimeMultiplier() {
    int regime_score = DetectMomentumRegime();

    if(regime_score >= Regime_Strong_Threshold)  // ≥6/8
        return 1.2;  // Strong Trend
    else if(regime_score >= Regime_Ranging_Threshold)  // 4-5/8
        return 1.0;  // Weak Trend
    else  // <4/8
        return 0.5;  // Ranging
}

// 4. Sequence Multiplier
double GetSequenceMultiplier() {
    if(g_LosingStreak == 0 || g_LosingStreak == 1)
        return 1.0;
    else if(g_LosingStreak == 2)
        return 0.75;
    else if(g_LosingStreak == 3)
        return 0.50;
    else  // 4+
        return 0.30;
}

// 5. Drawdown Multiplier
double GetDrawdownMultiplier() {
    double dd_percent = g_CurrentDrawdown;

    if(dd_percent < 8.0)
        return 1.0;
    else if(dd_percent < 15.0)
        return 0.5;
    else if(dd_percent < 20.0)
        return 0.25;
    else
        return 0.0;  // STOP TOTAL
}

// 6. COT Multiplier
double GetCOTMultiplier(int direction) {
    double cot_vote = GetCOTVote();

    // Si direction alignée avec COT
    bool aligned = (direction == 1 && cot_vote > 0) ||
                   (direction == -1 && cot_vote < 0);

    if(aligned) {
        if(MathAbs(cot_vote) >= 0.9)  // STRONG
            return 1.2;
        else if(MathAbs(cot_vote) >= 0.4)  // MODERATE
            return 1.1;
    }
    else {  // Contre COT
        if(MathAbs(cot_vote) >= 0.9)  // STRONG contre
            return 0.8;
        else if(MathAbs(cot_vote) >= 0.4)  // MODERATE contre
            return 0.9;
    }

    return 1.0;  // NEUTRAL
}

// 7. Spread Multiplier
double GetSpreadMultiplier() {
    double current_spread = GetCurrentSpreadPips();
    double avg_spread = GetAverageSpread(20);

    if(current_spread < avg_spread * 0.8)
        return 1.1;  // Excellent
    else if(current_spread > avg_spread * 1.5)
        return 0.9;  // Élargi

    return 1.0;  // Normal
}

//+------------------------------------------------------------------+
//| Position Sizing Final                                            |
//+------------------------------------------------------------------+
double CalculatePositionSize(int direction, int total_votes) {
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);

    // Kelly base
    double kelly_fraction = CalculateKellyFraction();
    double base_risk_pct = Base_Risk_Percent;
    double kelly_risk_pct = base_risk_pct * kelly_fraction;

    // 7 multiplicateurs
    double conf = GetConfidenceMultiplier(total_votes);
    double sess = GetSessionMultiplier();
    double regi = GetRegimeMultiplier();
    double sequ = GetSequenceMultiplier();
    double dd   = GetDrawdownMultiplier();
    double cot  = GetCOTMultiplier(direction);
    double sprd = GetSpreadMultiplier();

    // Position size %
    double risk_pct = kelly_risk_pct * conf * sess * regi * sequ * dd * cot * sprd;

    // Caps 0.33% - 1.00%
    risk_pct = MathMax(Min_Risk_Percent, MathMin(Max_Risk_Percent, risk_pct));

    // Risk amount
    double risk_amount = account_balance * (risk_pct / 100.0);

    // SL distance
    double atr_m15 = iATR(SYMBOL, PERIOD_M15, 14, 0);
    double sl_distance_pips = atr_m15 * ATR_Multiplier_SL;

    // Lot size
    double point_value = SymbolInfoDouble(SYMBOL, SYMBOL_TRADE_TICK_VALUE);
    double lot_size = risk_amount / (sl_distance_pips * point_value);

    // Normalize
    double min_lot = SymbolInfoDouble(SYMBOL, SYMBOL_VOLUME_MIN);
    double lot_step = SymbolInfoDouble(SYMBOL, SYMBOL_VOLUME_STEP);
    lot_size = MathFloor(lot_size / lot_step) * lot_step;
    lot_size = MathMax(min_lot, lot_size);

    return lot_size;
}

//+------------------------------------------------------------------+
//| Protections                                                       |
//+------------------------------------------------------------------+

bool CanOpenNewTrade() {
    // 1. Position déjà ouverte ?
    if(PositionExists()) return false;

    // 2. Session autorisée ?
    double sess_mult = GetSessionMultiplier();
    if(sess_mult == 0.0) return false;

    // 3. Daily loss max ?
    if(g_DailyRealizedPnL <= -Daily_Loss_Max) {
        Print("⛔ Daily loss max atteint: ", g_DailyRealizedPnL, "%");
        return false;
    }

    // 4. Drawdown circuit breaker ?
    if(g_CurrentDrawdown >= 20.0) {
        Print("🚨 DD ≥ 20% - STOP TOTAL");
        return false;
    }

    // 5. Spread acceptable ?
    if(!IsSpreadAcceptable()) return false;

    // 6. News blackout ?
    if(IsNewsBlackout()) return false;

    // 7. Weekend proximity ?
    if(IsWeekendBlock()) return false;

    // 8. Gap détecté ?
    if(DetectGap()) return false;

    return true;
}
```

---

## 🔄 HERMES_TRAILINGSTOP.MQH

### Trailing Stop 7 Paliers

```cpp
//+------------------------------------------------------------------+
//| Hermes_TrailingStop.mqh - Trailing Stop Progressif                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Variables Position                                                |
//+------------------------------------------------------------------+
struct STrailingInfo {
    ulong    ticket;
    int      direction;
    double   entry_price;
    double   initial_sl;
    double   initial_risk_pips;
    int      current_level;  // 0-7
    datetime entry_time;
};

STrailingInfo g_CurrentPosition;

//+------------------------------------------------------------------+
//| Paliers Trailing Stop                                            |
//+------------------------------------------------------------------+
void UpdateTrailingStop() {
    if(!PositionSelectByTicket(g_CurrentPosition.ticket)) return;

    double current_price;
    if(g_CurrentPosition.direction == 1)  // BUY
        current_price = SymbolInfoDouble(SYMBOL, SYMBOL_BID);
    else  // SELL
        current_price = SymbolInfoDouble(SYMBOL, SYMBOL_ASK);

    // Calcul R actuel
    double r_current = 0.0;
    if(g_CurrentPosition.direction == 1) {
        r_current = (current_price - g_CurrentPosition.entry_price) /
                    g_CurrentPosition.initial_risk_pips;
    }
    else {
        r_current = (g_CurrentPosition.entry_price - current_price) /
                    g_CurrentPosition.initial_risk_pips;
    }

    double new_sl = 0.0;
    bool should_modify = false;

    // Palier +0.5R
    if(r_current >= 0.5 && g_CurrentPosition.current_level < 1) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price - (0.3 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price + (0.3 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 1;
        Print("✅ Trailing +0.5R activated - Risk reduced 70%");
    }

    // Palier +1.0R (Breakeven)
    else if(r_current >= 1.0 && g_CurrentPosition.current_level < 2) {
        new_sl = g_CurrentPosition.entry_price;
        should_modify = true;
        g_CurrentPosition.current_level = 2;
        Print("✅ BREAKEVEN reached - Trade risk-free");
    }

    // Palier +1.5R
    else if(r_current >= 1.5 && g_CurrentPosition.current_level < 3) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price + (1.0 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price - (1.0 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 3;
        Print("✅ Trailing +1.5R - +1R locked (25%)");
    }

    // Palier +2.0R
    else if(r_current >= 2.0 && g_CurrentPosition.current_level < 4) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price + (1.5 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price - (1.5 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 4;
        Print("✅ Trailing +2.0R - +1.5R locked (37.5%)");
    }

    // Palier +2.5R
    else if(r_current >= 2.5 && g_CurrentPosition.current_level < 5) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price + (2.0 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price - (2.0 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 5;
        Print("✅ Trailing +2.5R - +2R locked (50%)");
    }

    // Palier +3.0R
    else if(r_current >= 3.0 && g_CurrentPosition.current_level < 6) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price + (2.5 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price - (2.5 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 6;
        Print("✅ Trailing +3.0R - +2.5R locked (62.5%)");
    }

    // Palier +3.5R (75% sécurisé)
    else if(r_current >= 3.5 && g_CurrentPosition.current_level < 7) {
        if(g_CurrentPosition.direction == 1)
            new_sl = g_CurrentPosition.entry_price + (3.0 * g_CurrentPosition.initial_risk_pips);
        else
            new_sl = g_CurrentPosition.entry_price - (3.0 * g_CurrentPosition.initial_risk_pips);

        should_modify = true;
        g_CurrentPosition.current_level = 7;
        Print("🔒 Trailing +3.5R - +3R locked (75% SECURED)");
    }

    // Après +3.5R: Trailing continu (offset +0.5R)
    else if(r_current > 3.5 && g_CurrentPosition.current_level == 7) {
        double offset = Trailing_Offset_After_35R * g_CurrentPosition.initial_risk_pips;

        if(g_CurrentPosition.direction == 1)
            new_sl = current_price - offset;
        else
            new_sl = current_price + offset;

        // Vérifie que nouveau SL > ancien SL
        double current_sl = PositionGetDouble(POSITION_SL);
        if((g_CurrentPosition.direction == 1 && new_sl > current_sl) ||
           (g_CurrentPosition.direction == -1 && new_sl < current_sl)) {
            should_modify = true;
        }
    }

    // Modification SL
    if(should_modify) {
        MqlTradeRequest request;
        MqlTradeResult result;
        ZeroMemory(request);
        ZeroMemory(result);

        request.action = TRADE_ACTION_SLTP;
        request.symbol = SYMBOL;
        request.position = g_CurrentPosition.ticket;
        request.sl = NormalizeDouble(new_sl, Digits());
        request.tp = 0;  // Pas de TP

        if(!OrderSend(request, result)) {
            Print("❌ Trailing stop failed: ", result.comment);
        }
    }
}
```

---

## 📅 HERMES_SESSIONMANAGER.MQH

### Sessions & News Blackout

```cpp
//+------------------------------------------------------------------+
//| Hermes_SessionManager.mqh - Sessions & News                       |
//+------------------------------------------------------------------+

enum ENUM_SESSION {
    SESSION_ASIAN,
    SESSION_LONDON,
    SESSION_OVERLAP,
    SESSION_NY,
    SESSION_DEAD
};

//+------------------------------------------------------------------+
//| Détection Session Actuelle                                       |
//+------------------------------------------------------------------+
ENUM_SESSION GetCurrentSession() {
    datetime current = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current, dt);

    // Convertir en heure Paris (UTC+1)
    int hour_paris = dt.hour + 1;  // Simplification

    if(hour_paris >= 1 && hour_paris < 9)
        return SESSION_ASIAN;    // 01h-09h
    else if(hour_paris >= 9 && hour_paris < 14)
        return SESSION_LONDON;   // 09h-14h
    else if(hour_paris >= 14 && hour_paris < 17)
        return SESSION_OVERLAP;  // 14h-17h
    else if(hour_paris >= 17 && hour_paris < 22)
        return SESSION_NY;       // 17h-22h
    else
        return SESSION_DEAD;     // 22h-01h
}

//+------------------------------------------------------------------+
//| News Blackout                                                     |
//+------------------------------------------------------------------+
struct SEconomicEvent {
    datetime event_time;
    string   event_name;
    string   impact;  // HIGH/MEDIUM/LOW
};

SEconomicEvent g_EconomicCalendar[];

bool LoadEconomicCalendar() {
    // Parse data/macro_events.csv
    // Store in g_EconomicCalendar[]
    // Return true si success
    return true;
}

bool IsNewsBlackout() {
    datetime current = TimeCurrent();
    int blackout_seconds = News_Blackout_Hours * 3600;

    for(int i = 0; i < ArraySize(g_EconomicCalendar); i++) {
        if(g_EconomicCalendar[i].impact != "HIGH") continue;

        datetime event_time = g_EconomicCalendar[i].event_time;
        datetime blackout_start = event_time - blackout_seconds;
        datetime blackout_end = event_time + blackout_seconds;

        if(current >= blackout_start && current <= blackout_end) {
            Print("🚫 News blackout: ", g_EconomicCalendar[i].event_name);
            return true;
        }
    }

    return false;
}

//+------------------------------------------------------------------+
//| Weekend Risk Management                                          |
//+------------------------------------------------------------------+
bool IsWeekendBlock() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    // Vendredi après 20h00
    if(dt.day_of_week == 5 && dt.hour >= Weekend_Block_Hour_Friday) {
        Print("⚠️ Weekend block: Friday after 20h");
        return true;
    }

    // Dimanche avant 23h00
    if(dt.day_of_week == 0 && dt.hour < Weekend_Allow_Hour_Sunday) {
        Print("⚠️ Weekend block: Sunday before 23h");
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Gap Detection                                                     |
//+------------------------------------------------------------------+
bool DetectGap() {
    double close_prev = iClose(SYMBOL, PERIOD_M15, 1);
    double open_curr = iOpen(SYMBOL, PERIOD_M15, 0);

    double gap_size = MathAbs(open_curr - close_prev);
    double atr_h4 = iATR(SYMBOL, PERIOD_H4, 14, 0);

    if(gap_size > atr_h4 * 2.0) {
        Print("⚠️ Gap detected: ", gap_size, " pips (> 2×ATR)");
        return true;
    }

    return false;
}
```

---

## 📊 HERMES_LOGGER.MQH & HERMES_SHAP.MQH

**Structure similaire pour**:
- Logging CSV trades détaillés
- SHAP analysis tous les 50 trades
- Génération hermes_summary.csv

---

## 🎯 WORKFLOW ONTICK()

```
OnTick()
  ├─ Position existe ?
  │   ├─ OUI → UpdateTrailingStop() → return
  │   └─ NON → Continue
  │
  ├─ Nouvelle bougie M15 ?
  │   └─ NON → return
  │
  ├─ CanOpenNewTrade() ?
  │   ├─ Check session
  │   ├─ Check daily loss
  │   ├─ Check DD
  │   ├─ Check spread
  │   ├─ Check news
  │   ├─ Check weekend
  │   └─ Check gap
  │
  ├─ AnalyzeMarket()
  │   ├─ BUY: CountVotes_H4(BUY), CountVotes_H1(BUY), etc
  │   ├─ Check H4 ≥ 3/5
  │   ├─ Check H1 ≥ 5/8
  │   ├─ Check M15 ≥ 4/6
  │   ├─ Check Macro ≥ 1/2
  │   ├─ Check Total ≥ 14/21
  │   └─ SELL: idem
  │
  ├─ CalculatePositionSize(direction, votes)
  │   ├─ Kelly
  │   ├─ 7 multiplicateurs
  │   └─ Return lot_size
  │
  └─ OpenTrade(direction, lot_size)
      ├─ OrderSend()
      ├─ LogTradeEntry()
      └─ Initialize trailing stop
```

---

**🏛️ ARCHITECTURE HERMÈS 2.5 - Version 1.0**

*Document Technique Complet - Prêt pour Implémentation*
