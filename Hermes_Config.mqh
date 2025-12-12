//+------------------------------------------------------------------+
//| Hermes_Config.mqh                                                 |
//| Configuration Centralisée - Hermès 2.5                            |
//| Expert Advisor Institutionnel XAUUSD                              |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#ifndef HERMES_CONFIG_MQH
#define HERMES_CONFIG_MQH

// Garde commun pour éviter double inclusion avec OPTI
#define HERMES_CONFIG_LOADED

//+------------------------------------------------------------------+
//| CONSTANTS                                                         |
//+------------------------------------------------------------------+
#define MAGIC_NUMBER 250125
#define EA_NAME "Hermes_2.5"
#define SYMBOL_TRADED "XAUUSD"

// Timeframes
#define TF_MACRO PERIOD_H4
#define TF_SETUP PERIOD_H1
#define TF_TIMING PERIOD_M15

// Nombre indicateurs par niveau
#define NUM_INDICATORS_H4 5
#define NUM_INDICATORS_H1 8
#define NUM_INDICATORS_M15 6
#define NUM_INDICATORS_MACRO 1    // COT removed, only ATR Percentile
#define NUM_INDICATORS_TOTAL 20   // Was 21, now 20 (COT removed)

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - VALIDATION                                    |
//+------------------------------------------------------------------+
input group "=== VALIDATION SYSTÈME ==="
input int Min_Votes_H4 = 3;           // Minimum votes H4 (sur 5)
input int Min_Votes_H1 = 6;           // Minimum votes H1 (sur 8)
input int Min_Votes_M15 = 3;          // Minimum votes M15 (sur 6)
input int Min_Votes_Macro = 0;        // Minimum votes Macro (sur 1)
input int Min_Votes_Total = 17;       // Minimum votes Global (sur 20) - 85%

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - RISK MANAGEMENT                               |
//+------------------------------------------------------------------+
input group "=== RISK MANAGEMENT ==="
input double Kelly_Cap = 0.25;                // Kelly fraction maximum (25%)
input double Base_Risk_Percent = 0.7;         // Base risk avant multiplicateurs (%)
input double Min_Risk_Percent = 0.33;         // Risk minimum par trade (%)
input double Max_Risk_Percent = 1.00;         // Risk maximum par trade (%)
input double Daily_Loss_Max = 2.0;            // Perte journalière max réalisée (%)

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - TRAILING STOP                                 |
//+------------------------------------------------------------------+
input group "=== TRAILING STOP ==="
input double ATR_Multiplier_SL = 3.0;         // ATR × 3.0 pour SL
input double Trailing_Offset_After_35R = 1.5; // Offset après palier +3.5R

input group "=== TRADE EXECUTION ==="
input double Risk_Reward_Ratio = 3.0;         // Ratio TP/SL (3.0 = 3:1)
input double Min_ATR_Filter = 7.0;            // ATR minimum $7 pour trader (filtre marchés calmes)
input double Max_Lot_Size = 0.5;              // Lot size maximum
input double Base_Lot_Per_10K = 0.02;         // Lot de base pour $10,000 (FIXE)
input int Slippage_Points = 20;               // Slippage max (points)
input int Max_Positions_Open = 1;             // Positions simultanées max
input int Max_Trades_Per_Day = 1;             // Trades max par jour
input int Trading_Start_Hour = 10;            // Heure début trading (0-23)
input int Trading_End_Hour = 22;              // Heure fin trading (0-23)
input int Max_Trade_Duration_Hours = 0;       // Durée max trade (heures) - 0 = désactivé

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - SESSIONS                                      |
//+------------------------------------------------------------------+
input group "=== SESSIONS TRADING ==="
input bool Enable_Asian_Session = false;      // Asian Session (01h-09h) - INTERDITE
input bool Enable_London_Session = true;      // London Session (09h-14h)
input bool Enable_Overlap_Session = true;     // Overlap L-NY (14h-17h) - MEILLEURE
input bool Enable_NY_Session = true;          // New York Session (17h-22h)

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - PROTECTIONS                                   |
//+------------------------------------------------------------------+
input group "=== PROTECTIONS QUALITÉ ==="
input double Max_Spread_Pips = 6.0;           // Spread max absolu (pips)
input double Max_Spread_vs_ATR = 0.30;        // Spread max vs ATR (30%)
input double Max_Spread_vs_Avg = 2.5;         // Spread max vs moyenne (2.5×)
input int News_Blackout_Hours = 1;            // Blackout avant/après news (heures)
input int Weekend_Block_Hour_Friday = 20;     // Vendredi block heure (20h Paris)
input int Weekend_Allow_Hour_Sunday = 23;     // Dimanche allow heure (23h Paris)
input double Gap_Detection_ATR_Mult = 2.0;    // Gap > ATR × 2.0 → Wait

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - REGIME DETECTION                              |
//+------------------------------------------------------------------+
input group "=== MOMENTUM REGIME ==="
input int Regime_Strong_Threshold = 6;        // ≥6/8 = Strong Trend (boost +20%)
input int Regime_Ranging_Threshold = 4;       // <4/8 = Ranging (réduction 50%)

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - SHAP ANALYSIS                                 |
//+------------------------------------------------------------------+
input group "=== SHAP ANALYSIS ==="
input int SHAP_Analysis_Frequency = 50;       // Recalcul tous les X trades
input int SHAP_Min_Trades = 300;              // Minimum pour 1ère optimisation
input bool Enable_Auto_CSV_Export = true;     // Export CSV automatique

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - INDICATEURS WEIGHTS                           |
//+------------------------------------------------------------------+
input group "=== POIDS INDICATEURS (Initial = 1.0) ==="
input double Weight_ADX_H4 = 1.0;             // 1. ADX H4
input double Weight_EMA_Cross_H4 = 1.0;       // 2. EMA 21/55 H4
input double Weight_EMA_50_200_H4 = 1.0;      // 3. EMA 50/200 H4
input double Weight_Price_EMA21_H4 = 1.0;     // 4. Prix vs EMA21 H4
input double Weight_Supertrend_H4 = 1.0;      // 5. Supertrend H4
input double Weight_EMA_Cross_H1 = 1.0;       // 6. EMA Cross Signal H1
input double Weight_MACD_H1 = 1.0;            // 7. MACD H1
input double Weight_RSI_H1 = 1.0;             // 8. RSI H1
input double Weight_SAR_H1 = 1.0;             // 9. Parabolic SAR H1
input double Weight_Stoch_H1 = 1.0;           // 10. Stochastic H1
input double Weight_Bollinger_H1 = 1.0;       // 11. Bollinger Width H1
input double Weight_Volume_H1 = 1.0;          // 12. Volume Momentum H1
input double Weight_Donchian_H1 = 1.0;        // 13. Donchian H1
input double Weight_VWAP_M15 = 1.0;           // 14. VWAP M15
input double Weight_OrderFlow_M15 = 1.0;      // 15. Order Flow Delta M15
input double Weight_Volatility_M15 = 1.0;     // 16. Volatility Regime M15
input double Weight_Tick_M15 = 1.0;           // 17. Tick Momentum M15
input double Weight_EURUSD_M15 = 1.0;         // 18. EURUSD Correlation M15
input double Weight_Spread_M15 = 1.0;         // 19. Effective Spread M15
input double Weight_COT = 1.0;                // 20. COT (Smart Money)
input double Weight_ATR_Percentile = 1.0;     // 21. ATR Percentile

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - ÉTAT TRADING                                  |
//+------------------------------------------------------------------+
// Statistiques globales
int g_TotalTrades = 0;
int g_TotalWins = 0;
int g_TotalLosses = 0;
int g_LosingStreak = 0;
int g_WinningStreak = 0;

// Risk tracking
double g_DailyRealizedPnL = 0.0;              // % du capital
double g_PeakBalance = 0.0;
double g_CurrentBalance = 0.0;
double g_CurrentDrawdown = 0.0;               // %
datetime g_LastDailyReset = 0;

// Position tracking
datetime g_LastCandleTime = 0;
bool g_PositionOpen = false;
ulong g_CurrentTicket = 0;

// Daily trade tracking (reset dans OnInit pour backtest/optimization)
datetime g_LastTradeDay = 0;
int g_TradesToday = 0;

// Historique trades récents (pour win rate)
double g_Last20Trades[20];
int g_Last20Index = 0;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - INDICATEURS HANDLES                           |
//+------------------------------------------------------------------+
// H4 Handles
int h_ADX_H4 = INVALID_HANDLE;
int h_EMA21_H4 = INVALID_HANDLE;
int h_EMA55_H4 = INVALID_HANDLE;
int h_EMA50_H4 = INVALID_HANDLE;
int h_EMA200_H4 = INVALID_HANDLE;
int h_ATR_H4 = INVALID_HANDLE;

// H1 Handles
int h_EMA21_H1 = INVALID_HANDLE;
int h_EMA55_H1 = INVALID_HANDLE;
int h_MACD_H1 = INVALID_HANDLE;
int h_RSI_H1 = INVALID_HANDLE;
int h_SAR_H1 = INVALID_HANDLE;
int h_Stoch_H1 = INVALID_HANDLE;
int h_BB_H1 = INVALID_HANDLE;
int h_ATR_H1 = INVALID_HANDLE;

// M15 Handles
int h_ATR_M15 = INVALID_HANDLE;
int h_EMA_EURUSD_M15 = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - FICHIERS CSV                                  |
//+------------------------------------------------------------------+
string CSV_Trades_Detailed = "hermes_trades_detailed.csv";
string CSV_SHAP_Analysis = "hermes_shap_analysis.csv";
string CSV_Summary = "hermes_summary.csv";

int g_FileHandle_Trades = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - POIDS INDICATEURS (Array)                     |
//+------------------------------------------------------------------+
double Indicator_Weights[NUM_INDICATORS_TOTAL];

//+------------------------------------------------------------------+
//| ENUMERATIONS                                                      |
//+------------------------------------------------------------------+
enum ENUM_SESSION {
    SESSION_ASIAN,      // 01h-09h Paris - INTERDITE
    SESSION_LONDON,     // 09h-14h Paris
    SESSION_OVERLAP,    // 14h-17h Paris - MEILLEURE (×1.3)
    SESSION_NY,         // 17h-22h Paris
    SESSION_DEAD        // 22h-01h Paris - INTERDITE
};

enum ENUM_REGIME {
    REGIME_RANGING,     // <4/8 - Marché range (réduit 50%)
    REGIME_WEAK_TREND,  // 4-5/8 - Tendance faible (normal)
    REGIME_STRONG_TREND // ≥6/8 - Tendance forte (boost +20%)
};

//+------------------------------------------------------------------+
//| STRUCTURES                                                        |
//+------------------------------------------------------------------+
// Structure position actuelle
struct SPositionInfo {
    ulong    ticket;
    int      direction;           // 1 = BUY, -1 = SELL
    double   entry_price;
    double   initial_sl;
    double   initial_risk_pips;
    int      current_trailing_level;  // 0-7
    datetime entry_time;

    // Validation entry
    int      votes_h4;
    int      votes_h1;
    int      votes_m15;
    int      votes_macro;
    int      votes_total;

    // Indicateurs état entry (1/0 pour les 21)
    int      indicators_state[NUM_INDICATORS_TOTAL];
};

SPositionInfo g_CurrentPosition;

// Structure événement économique
struct SEconomicEvent {
    datetime event_time;
    string   event_name;
    string   impact;              // HIGH/MEDIUM/LOW
};

SEconomicEvent g_EconomicCalendar[];
int g_NumEconomicEvents = 0;

// Structure COT data
struct SCOTData {
    datetime week_date;
    double   commercials_long;
    double   commercials_short;
    double   commercials_net;
    double   large_spec_long;
    double   large_spec_short;
    double   small_spec_long;
    double   small_spec_short;
};

SCOTData g_COTHistory[];
int g_NumCOTRecords = 0;

//+------------------------------------------------------------------+
//| FONCTIONS UTILITAIRES - INITIALISATION                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialise array poids indicateurs                               |
//+------------------------------------------------------------------+
void InitIndicatorWeights() {
    // H4 (5)
    Indicator_Weights[0] = Weight_ADX_H4;
    Indicator_Weights[1] = Weight_EMA_Cross_H4;
    Indicator_Weights[2] = Weight_EMA_50_200_H4;
    Indicator_Weights[3] = Weight_Price_EMA21_H4;
    Indicator_Weights[4] = Weight_Supertrend_H4;

    // H1 (8)
    Indicator_Weights[5] = Weight_EMA_Cross_H1;
    Indicator_Weights[6] = Weight_MACD_H1;
    Indicator_Weights[7] = Weight_RSI_H1;
    Indicator_Weights[8] = Weight_SAR_H1;
    Indicator_Weights[9] = Weight_Stoch_H1;
    Indicator_Weights[10] = Weight_Bollinger_H1;
    Indicator_Weights[11] = Weight_Volume_H1;
    Indicator_Weights[12] = Weight_Donchian_H1;

    // M15 (6)
    Indicator_Weights[13] = Weight_VWAP_M15;
    Indicator_Weights[14] = Weight_OrderFlow_M15;
    Indicator_Weights[15] = Weight_Volatility_M15;
    Indicator_Weights[16] = Weight_Tick_M15;
    Indicator_Weights[17] = Weight_EURUSD_M15;
    Indicator_Weights[18] = Weight_Spread_M15;

    // Macro (1) - COT removed
    Indicator_Weights[19] = Weight_ATR_Percentile;
}

//+------------------------------------------------------------------+
//| Reset variables position                                          |
//+------------------------------------------------------------------+
void ResetPositionInfo() {
    g_CurrentPosition.ticket = 0;
    g_CurrentPosition.direction = 0;
    g_CurrentPosition.entry_price = 0.0;
    g_CurrentPosition.initial_sl = 0.0;
    g_CurrentPosition.initial_risk_pips = 0.0;
    g_CurrentPosition.current_trailing_level = 0;
    g_CurrentPosition.entry_time = 0;
    g_CurrentPosition.votes_h4 = 0;
    g_CurrentPosition.votes_h1 = 0;
    g_CurrentPosition.votes_m15 = 0;
    g_CurrentPosition.votes_macro = 0;
    g_CurrentPosition.votes_total = 0;

    ArrayInitialize(g_CurrentPosition.indicators_state, 0);
}

//+------------------------------------------------------------------+
//| Reset daily statistics (minuit)                                  |
//+------------------------------------------------------------------+
void ResetDailyStats() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    // Reset à minuit
    if(dt.hour == 0 && TimeCurrent() != g_LastDailyReset) {
        g_DailyRealizedPnL = 0.0;
        g_LastDailyReset = TimeCurrent();

        Print("📊 Daily stats reset - New trading day");
    }
}

//+------------------------------------------------------------------+
//| Update drawdown                                                   |
//+------------------------------------------------------------------+
void UpdateDrawdown() {
    g_CurrentBalance = AccountInfoDouble(ACCOUNT_BALANCE);

    // Update peak
    if(g_CurrentBalance > g_PeakBalance)
        g_PeakBalance = g_CurrentBalance;

    // Calcul DD%
    if(g_PeakBalance > 0) {
        g_CurrentDrawdown = ((g_PeakBalance - g_CurrentBalance) / g_PeakBalance) * 100.0;
    }
}

//+------------------------------------------------------------------+
//| Point value calculation - FIXED for XAUUSD                        |
//| For Gold: 1 lot = 100 oz, 1 pip ($0.01) = $1 per lot             |
//+------------------------------------------------------------------+
double GetPointValue() {
    // Correct calculation for pip value per lot
    double tick_value = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_TRADE_TICK_SIZE);
    double point = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_POINT);

    // pip_value = tick_value * (point / tick_size)
    // This gives the value of 1 point (pip) movement per 1 lot
    double pip_value = tick_value;
    if(tick_size > 0) {
        pip_value = tick_value * (point / tick_size);
    }

    // Safety: minimum $0.10 per pip per lot to avoid huge lot sizes
    if(pip_value < 0.10) pip_value = 1.0;  // Default to $1/pip for XAUUSD

    return pip_value;
}

//+------------------------------------------------------------------+
//| Current spread in pips                                            |
//+------------------------------------------------------------------+
double GetCurrentSpreadPips() {
    double ask = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
    double bid = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
    double point = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_POINT);

    return (ask - bid) / point;
}

//+------------------------------------------------------------------+
//| Normalize lot size selon broker                                  |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lot) {
    double min_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_STEP);

    // Arrondi au step
    lot = MathFloor(lot / lot_step) * lot_step;

    // Clamp min/max
    lot = MathMax(min_lot, MathMin(max_lot, lot));

    return lot;
}

//+------------------------------------------------------------------+
//| Normalize price selon digits                                     |
//+------------------------------------------------------------------+
double NormalizePrice(double price) {
    int digits = (int)SymbolInfoInteger(SYMBOL_TRADED, SYMBOL_DIGITS);
    return NormalizeDouble(price, digits);
}

//+------------------------------------------------------------------+
//| Check nouvelle bougie                                             |
//+------------------------------------------------------------------+
bool IsNewCandle() {
    datetime current_time = iTime(SYMBOL_TRADED, TF_TIMING, 0);

    if(current_time != g_LastCandleTime) {
        g_LastCandleTime = current_time;
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Calcul win rate récent (20 derniers trades)                      |
//+------------------------------------------------------------------+
double GetRecentWinRate() {
    if(g_TotalTrades < 20) return 0.50;  // Default avant historique

    int wins = 0;
    for(int i = 0; i < 20; i++) {
        if(g_Last20Trades[i] > 0)
            wins++;
    }

    return (double)wins / 20.0;
}

//+------------------------------------------------------------------+
//| Add trade to recent history                                       |
//+------------------------------------------------------------------+
void AddTradeToHistory(double r_multiple) {
    g_Last20Trades[g_Last20Index] = r_multiple;
    g_Last20Index = (g_Last20Index + 1) % 20;
}

//+------------------------------------------------------------------+
//| Print EA Info                                                     |
//+------------------------------------------------------------------+
void PrintEAInfo() {
    Print("╔════════════════════════════════════════════════════════════════╗");
    Print("║                   HERMÈS 2.5 - INITIALIZED                     ║");
    Print("╠════════════════════════════════════════════════════════════════╣");
    Print("║ Expert Advisor Institutionnel pour XAUUSD                      ║");
    Print("║ Version: 2.50                                                  ║");
    Print("║ Magic Number: ", MAGIC_NUMBER, "                                        ║");
    Print("╠════════════════════════════════════════════════════════════════╣");
    Print("║ VALIDATION:                                                    ║");
    Print("║   H4:  ", Min_Votes_H4, "/5 (", (Min_Votes_H4*100/5), "%)                                     ║");
    Print("║   H1:  ", Min_Votes_H1, "/8 (", (Min_Votes_H1*100/8), "%)                                     ║");
    Print("║   M15: ", Min_Votes_M15, "/6 (", (Min_Votes_M15*100/6), "%)                                     ║");
    Print("║   Macro: ", Min_Votes_Macro, "/2 (", (Min_Votes_Macro*100/2), "%)                                   ║");
    Print("║   GLOBAL: ", Min_Votes_Total, "/21 (", (Min_Votes_Total*100/21), "%)                                 ║");
    Print("╠════════════════════════════════════════════════════════════════╣");
    Print("║ RISK MANAGEMENT:                                               ║");
    Print("║   Base Risk: ", Base_Risk_Percent, "%                                           ║");
    Print("║   Range: ", Min_Risk_Percent, "% - ", Max_Risk_Percent, "%                                    ║");
    Print("║   Daily Loss Max: ", Daily_Loss_Max, "%                                      ║");
    Print("║   Kelly Cap: ", Kelly_Cap, "                                              ║");
    Print("╠════════════════════════════════════════════════════════════════╣");
    Print("║ PROTECTIONS:                                                   ║");
    Print("║   Asian Session: ", (Enable_Asian_Session ? "ENABLED" : "DISABLED"), "                                ║");
    Print("║   Overlap Boost: ×1.3                                          ║");
    Print("║   Max Spread: ", Max_Spread_Pips, " pips                                       ║");
    Print("║   News Blackout: ±", News_Blackout_Hours, "h                                        ║");
    Print("╠════════════════════════════════════════════════════════════════╣");
    Print("║ SHAP ANALYSIS:                                                 ║");
    Print("║   Frequency: Every ", SHAP_Analysis_Frequency, " trades                              ║");
    Print("║   Min trades for 1st optim: ", SHAP_Min_Trades, "                              ║");
    Print("╚════════════════════════════════════════════════════════════════╝");
}

//+------------------------------------------------------------------+

#endif // HERMES_CONFIG_MQH
