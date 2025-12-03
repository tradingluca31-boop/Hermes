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
    // DEBUG: Log every 1000 ticks to avoid spam
    static int tick_count = 0;
    tick_count++;
    bool debug_tick = (tick_count % 1000 == 0);

    //===================================================================
    // STEP 1: GESTION POSITION EXISTANTE
    //===================================================================
    if(PositionExists()) {
        ManageOpenPosition();
        return;  // Pas de nouvelle position tant qu'une existe
    }

    //===================================================================
    // STEP 2: NOUVELLE BOUGIE M15 ? (DISABLED - Trade immediately)
    //===================================================================
    // IsNewCandle check REMOVED - EA now trades on every tick when conditions are met
    // if(!IsNewCandle()) {
    //     return;
    // }

    //===================================================================
    // STEP 3: RESET DAILY (MINUIT)
    //===================================================================
    ResetDailyStats();

    //===================================================================
    // STEP 4: UPDATE DRAWDOWN
    //===================================================================
    UpdateDrawdown();

    //===================================================================
    // STEP 5: DÉTECTION SESSION & RÉGIME
    //===================================================================
    ENUM_SESSION session = GetCurrentSession();
    ENUM_REGIME regime = DetectMomentumRegime();

    //===================================================================
    // STEP 6: CHECKS PRÉLIMINAIRES
    //===================================================================
    // 6.1 Protections temporelles
    if(!CanTradeNow()) {
        if(debug_tick) Print("DEBUG: CanTradeNow() = FALSE");
        return;
    }

    // 6.2 Protections risk
    if(!CanOpenNewTrade(session)) {
        if(debug_tick) Print("DEBUG: CanOpenNewTrade() = FALSE");
        return;
    }

    //===================================================================
    // STEP 7: ANALYSE MULTI-TIMEFRAME
    //===================================================================
    int direction = AnalyzeMarket(regime);

    if(direction == 0) {
        // DEBUG: Show vote counts when no signal
        if(debug_tick) {
            int buy_votes = CountVotes_H4(1) + CountVotes_H1(1) + CountVotes_M15(1) + CountVotes_Macro(1);
            int sell_votes = CountVotes_H4(-1) + CountVotes_H1(-1) + CountVotes_M15(-1) + CountVotes_Macro(-1);
            int min_votes = GetAdjustedMinVotes(regime);
            Print("DEBUG: No signal - BUY=", buy_votes, "/20, SELL=", sell_votes, "/20, MIN=", min_votes);
        }
        return;
    }

    //===================================================================
    // STEP 8: POSITION SIZING
    //===================================================================
    int votes_h4 = CountVotes_H4(direction);
    int votes_h1 = CountVotes_H1(direction);
    int votes_m15 = CountVotes_M15(direction);
    int votes_macro = CountVotes_Macro(direction);
    int votes_total = votes_h4 + votes_h1 + votes_m15 + votes_macro;

    double lot_size = CalculatePositionSize(direction, votes_total, session, regime);

    if(lot_size < SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN)) {
        Print("⚠️ Lot size too small: ", DoubleToString(lot_size, 2), " - skipping trade");
        return;
    }

    //===================================================================
    // STEP 9: EXÉCUTION TRADE
    //===================================================================
    OpenTrade(direction, lot_size, votes_h4, votes_h1, votes_m15, votes_macro, votes_total);
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
        Print("⚠️ Conflicting signals (both BUY and SELL valid) - skipping");
        return 0;
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

