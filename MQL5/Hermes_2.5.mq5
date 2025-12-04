//+------------------------------------------------------------------+
//| Hermes_2.5.mq5                                                    |
//| Expert Advisor Institutionnel pour XAUUSD                         |
//| Trend-Following Multi-Timeframe avec 21 Indicateurs               |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property link      "https://github.com/hermes-trading"
#property version   "2.50"
#property description "EA Institutionnel Hedge Fund Grade"
#property description "21 Indicateurs + Kelly Risk + Trailing 7 Paliers"
#property description "XAUUSD uniquement - Optimisé FTMO"

#property strict

//+------------------------------------------------------------------+
//| INCLUDES                                                          |
//+------------------------------------------------------------------+
#include "Hermes_Config.mqh"
#include "Hermes_Indicators.mqh"
#include "Hermes_SessionManager.mqh"
#include "Hermes_RiskManager.mqh"
#include "Hermes_Logger.mqh"
#include "Hermes_TrailingStop.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
    Print("");
    Print("╔════════════════════════════════════════════════════════════════╗");
    Print("║                                                                ║");
    Print("║                     HERMÈS 2.5 STARTING                        ║");
    Print("║                                                                ║");
    Print("╚════════════════════════════════════════════════════════════════╝");
    Print("");

    //===================================================================
    // 1. VÉRIFICATIONS BROKER & SYMBOLE
    //===================================================================
    Print("🔍 Checking broker and symbol compatibility...");

    if(_Symbol != SYMBOL_TRADED) {
        Alert("⛔ ERROR: Hermès 2.5 is designed for XAUUSD only!");
        Print("   Current symbol: ", _Symbol);
        Print("   Required symbol: ", SYMBOL_TRADED);
        return INIT_FAILED;
    }

    if(!SymbolInfoInteger(SYMBOL_TRADED, SYMBOL_TRADE_MODE)) {
        Alert("⛔ ERROR: Trading not allowed for ", SYMBOL_TRADED);
        return INIT_FAILED;
    }

    if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
        Alert("⛔ ERROR: Automated trading is disabled!");
        Print("   Enable 'Allow Automated Trading' in MetaTrader 5");
        return INIT_FAILED;
    }

    Print("✅ Broker and symbol compatibility OK");

    //===================================================================
    // 2. INITIALISATION INDICATEURS
    //===================================================================
    Print("📊 Initializing 21 technical indicators...");

    if(!InitIndicators()) {
        Alert("⛔ ERROR: Failed to initialize indicators!");
        return INIT_FAILED;
    }

    //===================================================================
    // 3. INITIALISATION POIDS INDICATEURS
    //===================================================================
    InitIndicatorWeights();
    Print("⚖️ Indicator weights initialized (all = 1.0 by default)");

    //===================================================================
    // 4. INITIALISATION VARIABLES GLOBALES
    //===================================================================
    g_TotalTrades = 0;
    g_TotalWins = 0;
    g_TotalLosses = 0;
    g_LosingStreak = 0;
    g_WinningStreak = 0;

    g_DailyRealizedPnL = 0.0;
    g_CurrentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    g_PeakBalance = g_CurrentBalance;
    g_CurrentDrawdown = 0.0;
    g_LastDailyReset = TimeCurrent();

    g_LastCandleTime = 0;
    g_PositionOpen = false;
    g_CurrentTicket = 0;

    ArrayInitialize(g_Last20Trades, 0);
    g_Last20Index = 0;

    ResetPositionInfo();

    Print("✅ Global variables initialized");

    //===================================================================
    // 5. CHARGEMENT DONNÉES EXTERNES (DISABLED)
    //===================================================================
    // COT Data - DISABLED (always returns TRUE now)
    // if(!LoadCOTData()) {
    //     Print("⚠️ COT data not loaded - COT indicator will be neutral");
    // }

    // Economic Calendar - DISABLED (no news blackout)
    // if(!LoadEconomicCalendar()) {
    //     Print("⚠️ Economic calendar not loaded - News blackout disabled");
    // }
    Print("ℹ️ COT and Economic Calendar DISABLED for simplified trading");

    //===================================================================
    // 6. INITIALISATION LOGGING CSV
    //===================================================================
    if(Enable_Auto_CSV_Export) {
        if(!InitTradesDetailedCSV()) {
            Print("⚠️ Warning: Trades detailed CSV initialization failed");
        }
    }

    //===================================================================
    // 7. AFFICHAGE INFOS EA
    //===================================================================
    PrintEAInfo();

    //===================================================================
    // 8. AFFICHAGE SESSION & REGIME
    //===================================================================
    PrintSessionInfo();

    //===================================================================
    // 9. READY
    //===================================================================
    Print("");
    Print("╔════════════════════════════════════════════════════════════════╗");
    Print("║                                                                ║");
    Print("║               HERMÈS 2.5 READY FOR TRADING 🚀                 ║");
    Print("║                                                                ║");
    Print("╚════════════════════════════════════════════════════════════════╝");
    Print("");

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("");
    Print("╔════════════════════════════════════════════════════════════════╗");
    Print("║              HERMÈS 2.5 STOPPING                               ║");
    Print("╚════════════════════════════════════════════════════════════════╝");

    string reason_text = "";
    switch(reason) {
        case REASON_PROGRAM:     reason_text = "Expert removed from chart"; break;
        case REASON_REMOVE:      reason_text = "Expert deleted"; break;
        case REASON_RECOMPILE:   reason_text = "Expert recompiled"; break;
        case REASON_CHARTCHANGE: reason_text = "Chart symbol/period changed"; break;
        case REASON_CHARTCLOSE:  reason_text = "Chart closed"; break;
        case REASON_PARAMETERS:  reason_text = "Input parameters changed"; break;
        case REASON_ACCOUNT:     reason_text = "Account changed"; break;
        case REASON_TEMPLATE:    reason_text = "New template applied"; break;
        case REASON_INITFAILED:  reason_text = "OnInit() failed"; break;
        case REASON_CLOSE:       reason_text = "Terminal closed"; break;
        default:                 reason_text = "Unknown reason"; break;
    }

    Print("Reason: ", reason_text);

    // Release indicateurs
    ReleaseIndicators();

    // Afficher statistiques finales
    Print("");
    Print("📊 FINAL STATISTICS:");
    Print("   Total Trades: ", g_TotalTrades);
    Print("   Wins: ", g_TotalWins, " | Losses: ", g_TotalLosses);
    if(g_TotalTrades > 0) {
        Print("   Win Rate: ", DoubleToString((double)g_TotalWins / g_TotalTrades * 100, 1), "%");
    }
    Print("   Current DD: ", DoubleToString(g_CurrentDrawdown, 2), "%");
    Print("");
    Print("✅ Hermès 2.5 stopped successfully");
    Print("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    //===================================================================
    // STEP 1: CHECK NEW H1 CANDLE (reduce noise)
    //===================================================================
    static datetime last_h1_candle = 0;
    datetime current_h1 = iTime(SYMBOL_TRADED, PERIOD_H1, 0);

    if(current_h1 == last_h1_candle) return;
    last_h1_candle = current_h1;

    //===================================================================
    // STEP 2: CHECK IF POSITION EXISTS
    //===================================================================
    bool has_position = false;
    for(int i = 0; i < PositionsTotal(); i++) {
        if(PositionGetTicket(i) > 0) {
            if(PositionGetString(POSITION_SYMBOL) == SYMBOL_TRADED) {
                has_position = true;
                break;
            }
        }
    }

    if(has_position) return;

    //===================================================================
    // STEP 3: ANALYSE INDICATEURS
    //===================================================================
    ENUM_REGIME regime = DetectMomentumRegime();
    int direction = AnalyzeMarket(regime);

    if(direction == 0) return;  // Pas de signal

    //===================================================================
    // STEP 4: CALCULER VOTES & LOT SIZE
    //===================================================================
    int votes_h4 = CountVotes_H4(direction);
    int votes_h1 = CountVotes_H1(direction);
    int votes_m15 = CountVotes_M15(direction);
    int votes_macro = CountVotes_Macro(direction);
    int votes_total = votes_h4 + votes_h1 + votes_m15 + votes_macro;

    // Lot size simple pour backtest (0.01 = risque minimal)
    double lot_size = 0.01;

    //===================================================================
    // STEP 5: EXÉCUTER TRADE AVEC TP
    //===================================================================
    OpenTradeWithTP(direction, lot_size, votes_total);
}

//+------------------------------------------------------------------+
//| Open Trade avec Take Profit (4:1 RR) et 1% Risk                  |
//+------------------------------------------------------------------+
void OpenTradeWithTP(int direction, double lot_size_ignored, int votes_total) {
    double entry_price = 0.0;
    ENUM_ORDER_TYPE order_type;

    if(direction == 1) {
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
        order_type = ORDER_TYPE_BUY;
    } else {
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
        order_type = ORDER_TYPE_SELL;
    }

    // SL et TP en dollars
    double sl_distance = 5.0;   // $5 SL
    double tp_distance = 20.0;  // $20 TP (4:1 RR)

    //===================================================================
    // CALCUL LOT SIZE POUR 1% RISK
    //===================================================================
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double risk_amount = account_balance * 0.01;  // 1% risk = $100 sur $10k

    // Pour XAUUSD: 1 lot = 100 oz, donc $1 move = $100 P/L
    // Si SL = $5, alors 1 lot perd $500
    // Pour perdre $100 sur SL $5: lot = risk / (sl_distance * 100)
    double lot_size = risk_amount / (sl_distance * 100.0);

    // Limites broker
    double min_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_STEP);

    // Arrondir au lot_step
    lot_size = MathFloor(lot_size / lot_step) * lot_step;
    lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));

    Print("📊 Risk Calc: Balance=", DoubleToString(account_balance, 0),
          " | 1% Risk=", DoubleToString(risk_amount, 0),
          " | Lot=", DoubleToString(lot_size, 2));

    double sl_price, tp_price;
    if(direction == 1) {
        sl_price = entry_price - sl_distance;
        tp_price = entry_price + tp_distance;
    } else {
        sl_price = entry_price + sl_distance;
        tp_price = entry_price - tp_distance;
    }

    MqlTradeRequest request = {};
    MqlTradeResult result = {};

    request.action = TRADE_ACTION_DEAL;
    request.symbol = SYMBOL_TRADED;
    request.volume = lot_size;
    request.type = order_type;
    request.price = entry_price;
    request.sl = sl_price;
    request.tp = tp_price;
    request.deviation = 50;
    request.magic = MAGIC_NUMBER;
    request.comment = StringFormat("Hermes|%d/20", votes_total);

    if(OrderSend(request, result)) {
        if(result.retcode == TRADE_RETCODE_DONE) {
            Print("✅ TRADE: ", (direction == 1 ? "BUY" : "SELL"),
                  " | Votes: ", votes_total, "/20",
                  " | Entry: ", DoubleToString(entry_price, 2),
                  " | SL: ", DoubleToString(sl_price, 2),
                  " | TP: ", DoubleToString(tp_price, 2));
            g_TotalTrades++;
        }
    } else {
        Print("❌ Trade failed: ", GetLastError(), " RetCode: ", result.retcode);
    }
}

//+------------------------------------------------------------------+
//| ANALYSE MARCHÉ (Validation multi-timeframe)                      |
//+------------------------------------------------------------------+
int AnalyzeMarket(ENUM_REGIME regime) {
    // Ajuster min votes selon régime
    int min_votes_adjusted = GetAdjustedMinVotes(regime);

    //===================================================================
    // TEST BUY
    //===================================================================
    int votes_h4_buy = CountVotes_H4(1);
    int votes_h1_buy = CountVotes_H1(1);
    int votes_m15_buy = CountVotes_M15(1);
    int votes_macro_buy = CountVotes_Macro(1);
    int votes_total_buy = votes_h4_buy + votes_h1_buy + votes_m15_buy + votes_macro_buy;

    // PROGRESSIVE VALIDATION: Only total votes matter (not AND across all levels)
    // This allows trades when total >= 14/21 (67%) regardless of individual timeframe distribution
    bool buy_valid = (votes_total_buy >= min_votes_adjusted);

    //===================================================================
    // TEST SELL
    //===================================================================
    int votes_h4_sell = CountVotes_H4(-1);
    int votes_h1_sell = CountVotes_H1(-1);
    int votes_m15_sell = CountVotes_M15(-1);
    int votes_macro_sell = CountVotes_Macro(-1);
    int votes_total_sell = votes_h4_sell + votes_h1_sell + votes_m15_sell + votes_macro_sell;

    // PROGRESSIVE VALIDATION: Only total votes matter (not AND across all levels)
    bool sell_valid = (votes_total_sell >= min_votes_adjusted);

    //===================================================================
    // DÉCISION
    //===================================================================
    if(buy_valid && !sell_valid) {
        Print("✅ SIGNAL BUY VALIDATED:");
        Print("   Votes: H4=", votes_h4_buy, "/5, H1=", votes_h1_buy, "/8, M15=", votes_m15_buy, "/6, Macro=", votes_macro_buy, "/2");
        Print("   Total: ", votes_total_buy, "/21 (min required: ", min_votes_adjusted, ")");
        return 1;  // BUY
    }
    else if(sell_valid && !buy_valid) {
        Print("✅ SIGNAL SELL VALIDATED:");
        Print("   Votes: H4=", votes_h4_sell, "/5, H1=", votes_h1_sell, "/8, M15=", votes_m15_sell, "/6, Macro=", votes_macro_sell, "/2");
        Print("   Total: ", votes_total_sell, "/21 (min required: ", min_votes_adjusted, ")");
        return -1;  // SELL
    }
    else if(buy_valid && sell_valid) {
        // Both valid - pick the one with MORE votes
        if(votes_total_buy > votes_total_sell) {
            Print("✅ SIGNAL BUY (conflict resolved - BUY has more votes):");
            Print("   BUY=", votes_total_buy, " vs SELL=", votes_total_sell);
            return 1;
        }
        else if(votes_total_sell > votes_total_buy) {
            Print("✅ SIGNAL SELL (conflict resolved - SELL has more votes):");
            Print("   SELL=", votes_total_sell, " vs BUY=", votes_total_buy);
            return -1;
        }
        else {
            Print("⚠️ Exact tie BUY=SELL=", votes_total_buy, " - skipping");
            return 0;
        }
    }
    else {
        // Aucun signal validé
        return 0;
    }
}

//+------------------------------------------------------------------+
//| OUVRIR TRADE                                                      |
//+------------------------------------------------------------------+
void OpenTrade(int direction, double lot_size, int votes_h4, int votes_h1,
               int votes_m15, int votes_macro, int votes_total) {

    Print("🚀 OPENING TRADE...");

    //===================================================================
    // PRÉPARATION
    //===================================================================
    double entry_price = 0.0;
    ENUM_ORDER_TYPE order_type;

    if(direction == 1) {  // BUY
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
        order_type = ORDER_TYPE_BUY;
    }
    else {  // SELL
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
        order_type = ORDER_TYPE_SELL;
    }

    double sl_price = CalculateStopLoss(direction, entry_price);

    if(sl_price == 0.0) {
        Print("❌ Cannot calculate SL - aborting trade");
        return;
    }

    //===================================================================
    // ENVOI ORDRE
    //===================================================================
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = SYMBOL_TRADED;
    request.volume = lot_size;
    request.type = order_type;
    request.price = entry_price;
    request.sl = sl_price;
    request.tp = 0;  // Pas de TP (trailing seulement)
    request.deviation = 10;
    request.magic = MAGIC_NUMBER;
    request.comment = StringFormat("Hermes_2.5 | %d/21", votes_total);

    Print("📤 Sending order to broker...");
    Print("   Type: ", (direction == 1 ? "BUY" : "SELL"));
    Print("   Lot: ", DoubleToString(lot_size, 2));
    Print("   Entry: ", DoubleToString(entry_price, _Digits));
    Print("   SL: ", DoubleToString(sl_price, _Digits));

    if(OrderSend(request, result)) {
        if(result.retcode == TRADE_RETCODE_DONE) {
            Print("✅ TRADE OPENED SUCCESSFULLY!");
            Print("   Ticket: ", result.order);
            Print("   Actual Entry: ", DoubleToString(result.price, _Digits));
            Print("   Slippage: ", DoubleToString(MathAbs(result.price - entry_price) / _Point, 1), " pips");

            // Initialiser position info
            InitializePositionInfo(result.order, direction, result.price, sl_price,
                                  votes_h4, votes_h1, votes_m15, votes_macro, votes_total);

            // Log entry
            LogTradeEntry();
        }
        else {
            Print("⚠️ Trade execution warning: ", result.retcode, " - ", result.comment);
        }
    }
    else {
        Print("❌ TRADE FAILED: ", GetLastError());
    }
}

