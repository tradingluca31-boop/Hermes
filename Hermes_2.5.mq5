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
    Print("+----------------------------------------------------------------+");
    Print("¦                                                                ¦");
    Print("¦                     HERMÈS 2.5 STARTING                        ¦");
    Print("¦                                                                ¦");
    Print("+----------------------------------------------------------------+");
    Print("");

    //===================================================================
    // 1. VÉRIFICATIONS BROKER & SYMBOLE
    //===================================================================
    Print("?? Checking broker and symbol compatibility...");

    if(_Symbol != SYMBOL_TRADED) {
        Alert("? ERROR: Hermès 2.5 is designed for XAUUSD only!");
        Print("   Current symbol: ", _Symbol);
        Print("   Required symbol: ", SYMBOL_TRADED);
        return INIT_FAILED;
    }

    if(!SymbolInfoInteger(SYMBOL_TRADED, SYMBOL_TRADE_MODE)) {
        Alert("? ERROR: Trading not allowed for ", SYMBOL_TRADED);
        return INIT_FAILED;
    }

    if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
        Alert("? ERROR: Automated trading is disabled!");
        Print("   Enable 'Allow Automated Trading' in MetaTrader 5");
        return INIT_FAILED;
    }

    Print("? Broker and symbol compatibility OK");

    //===================================================================
    // 2. INITIALISATION INDICATEURS
    //===================================================================
    Print("?? Initializing 21 technical indicators...");

    if(!InitIndicators()) {
        Alert("? ERROR: Failed to initialize indicators!");
        return INIT_FAILED;
    }

    //===================================================================
    // 3. INITIALISATION POIDS INDICATEURS
    //===================================================================
    InitIndicatorWeights();
    Print("?? Indicator weights initialized (all = 1.0 by default)");

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

    Print("? Global variables initialized");

    //===================================================================
    // 5. CHARGEMENT DONNÉES EXTERNES (DISABLED)
    //===================================================================
    // COT Data - DISABLED (always returns TRUE now)
    // if(!LoadCOTData()) {
    //     Print("?? COT data not loaded - COT indicator will be neutral");
    // }

    // Economic Calendar - DISABLED (no news blackout)
    // if(!LoadEconomicCalendar()) {
    //     Print("?? Economic calendar not loaded - News blackout disabled");
    // }
    Print("?? COT and Economic Calendar DISABLED for simplified trading");

    //===================================================================
    // 6. INITIALISATION LOGGING CSV
    //===================================================================
    if(Enable_Auto_CSV_Export) {
        if(!InitTradesDetailedCSV()) {
            Print("?? Warning: Trades detailed CSV initialization failed");
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
    Print("+----------------------------------------------------------------+");
    Print("¦                                                                ¦");
    Print("¦               HERMÈS 2.5 READY FOR TRADING ??                 ¦");
    Print("¦                                                                ¦");
    Print("+----------------------------------------------------------------+");
    Print("");

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("");
    Print("+----------------------------------------------------------------+");
    Print("¦              HERMÈS 2.5 STOPPING                               ¦");
    Print("+----------------------------------------------------------------+");

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
    Print("?? FINAL STATISTICS:");
    Print("   Total Trades: ", g_TotalTrades);
    Print("   Wins: ", g_TotalWins, " | Losses: ", g_TotalLosses);
    if(g_TotalTrades > 0) {
        Print("   Win Rate: ", DoubleToString((double)g_TotalWins / g_TotalTrades * 100, 1), "%");
    }
    Print("   Current DD: ", DoubleToString(g_CurrentDrawdown, 2), "%");
    Print("");
    Print("? Hermès 2.5 stopped successfully");
    Print("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    //===================================================================
    // MAX TRADE DURATION - Ferme les trades > 72h
    //===================================================================
    CheckMaxTradeDuration();

    //===================================================================
    // TRAILING STOP - Appele a CHAQUE tick
    //===================================================================
    if(g_PositionOpen) {
        UpdateTrailingStop();
    }

    //===================================================================
    // STEP 1: CHECK NEW H1 CANDLE (reduce noise)
    //===================================================================
    static datetime last_h1_candle = 0;
    datetime current_h1 = iTime(SYMBOL_TRADED, PERIOD_H1, 0);

    if(current_h1 == last_h1_candle) return;
    last_h1_candle = current_h1;

    //===================================================================
    // STEP 2: CHECK TRADING HOURS (éviter 22h-4h)
    //===================================================================
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    int hour = dt.hour;

    // Pas de trading entre 22h et 10h (nuit)
    if(hour >= Trading_End_Hour || hour < Trading_Start_Hour) return;

    //===================================================================
    // STEP 3: CHECK POSITION LIMITS
    //===================================================================
    // Compter les positions ouvertes sur XAUUSD
    int open_positions = 0;
    for(int i = 0; i < PositionsTotal(); i++) {
        if(PositionGetTicket(i) > 0) {
            if(PositionGetString(POSITION_SYMBOL) == SYMBOL_TRADED &&
               PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
                open_positions++;
            }
        }
    }

    // LIMITE 1: Maximum 2 positions simultanées
    if(open_positions >= Max_Positions_Open) return;

    // LIMITE 2: Maximum 3 trades par jour
    // Utilise g_LastTradeDay (global, reset dans OnInit)
    // Utilise g_TradesToday (global, reset dans OnInit)

    datetime current_day = iTime(SYMBOL_TRADED, PERIOD_D1, 0);
    if(current_day != g_LastTradeDay) {
        g_LastTradeDay = current_day;
        g_TradesToday = 0;  // Reset au nouveau jour
    }

    if(g_TradesToday >= Max_Trades_Per_Day) return;

    //===================================================================
    // STEP 3: ANALYSE INDICATEURS
    //===================================================================
    ENUM_REGIME regime = DetectMomentumRegime();
    int direction = AnalyzeMarket(regime);

    if(direction == 0) return;  // Pas de signal


    //===================================================================
    // FILTRE RSI MOMENTUM H1
    //===================================================================
    double rsi_val[];
    ArraySetAsSeries(rsi_val, true);
    int rsi_handle = iRSI(SYMBOL_TRADED, PERIOD_H1, 14, PRICE_CLOSE);
    if(CopyBuffer(rsi_handle, 0, 0, 1, rsi_val) > 0) {
        if(direction == 1 && rsi_val[0] < 50) { IndicatorRelease(rsi_handle); return; }
        if(direction == -1 && rsi_val[0] > 50) { IndicatorRelease(rsi_handle); return; }
    }
    IndicatorRelease(rsi_handle);

    //===================================================================
    // FILTRE ADX H1: Tendance forte > 25
    //===================================================================
    double adx_val[];
    ArraySetAsSeries(adx_val, true);
    int adx_handle = iADX(SYMBOL_TRADED, PERIOD_H1, 14);
    if(CopyBuffer(adx_handle, 0, 0, 1, adx_val) > 0) {
        if(adx_val[0] < 25.0) { IndicatorRelease(adx_handle); return; }
    }
    IndicatorRelease(adx_handle);

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
    if(OpenTradeWithTP(direction, lot_size, votes_total)) {
        g_TradesToday++;  // Incrémenter le compteur journalier
    }
}

//+------------------------------------------------------------------+
//| Open Trade avec Take Profit (4:1 RR) et 1% Risk                  |
//+------------------------------------------------------------------+
bool OpenTradeWithTP(int direction, double lot_size_ignored, int votes_total) {
    Print("=== TEST CLAUDE 123 === ATR_Mult=", ATR_Multiplier_SL, " MinATR=", Min_ATR_Filter, " RR=", Risk_Reward_Ratio);
    double entry_price = 0.0;
    ENUM_ORDER_TYPE order_type;

    if(direction == 1) {
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
        order_type = ORDER_TYPE_BUY;
    } else {
        entry_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
        order_type = ORDER_TYPE_SELL;
    }

    // SL et TP bases sur ATR H1 (dynamique via inputs)
    double atr_h1[];
    ArraySetAsSeries(atr_h1, true);
    if(CopyBuffer(h_ATR_H1, 0, 0, 1, atr_h1) <= 0) {
        Print("Erreur lecture ATR H1");
        return false;
    }

    // Filtre ATR minimum (si active)
    if(Min_ATR_Filter > 0 && atr_h1[0] < Min_ATR_Filter) {
        Print("ATR trop bas");
        return false;
    }

    double sl_distance = atr_h1[0] * ATR_Multiplier_SL;
    double tp_distance = sl_distance * Risk_Reward_Ratio;

    Print("ATR=", DoubleToString(atr_h1[0],2), " SL=", DoubleToString(sl_distance,2), " TP=", DoubleToString(tp_distance,2));

    double sl_price, tp_price;
    if(direction == 1) {
        sl_price = entry_price - sl_distance;
        tp_price = entry_price + tp_distance;
    } else {
        sl_price = entry_price + sl_distance;
        tp_price = entry_price - tp_distance;
    }

    //===================================================================
    // CALCUL LOT SIZE - RISQUE FIXE $150 PAR TRADE
    //===================================================================
    double risk_amount = 150.0;  // $150 fixe par trade

    // Lot = Risk$ / (SL$ x 100) - XAUUSD: 1 lot = $100 par $1
    double lot_size = risk_amount / (sl_distance * 100.0);

    // Limites broker
    double min_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_STEP);

    // Arrondir au lot_step
    lot_size = MathFloor(lot_size / lot_step) * lot_step;
    lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));

    // HARD CAP
    if(lot_size > Max_Lot_Size) {
        lot_size = Max_Lot_Size;
    }

    Print("💰 $150 RISK: SL=$", DoubleToString(sl_distance, 2),
          " | Lot=", DoubleToString(lot_size, 2));

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
            Print("? TRADE: ", (direction == 1 ? "BUY" : "SELL"),
                  " | Votes: ", votes_total, "/20",
                  " | Entry: ", DoubleToString(entry_price, 2),
                  " | SL: ", DoubleToString(sl_price, 2),
                  " | TP: ", DoubleToString(tp_price, 2));
            g_TotalTrades++;

            // ACTIVER TRAILING STOP
            g_PositionOpen = true;
            g_CurrentPosition.ticket = result.order;
            g_CurrentPosition.direction = direction;
            g_CurrentPosition.entry_price = entry_price;
            g_CurrentPosition.initial_sl = sl_price;
            g_CurrentPosition.initial_risk_pips = sl_distance;
            g_CurrentPosition.current_trailing_level = 0;
            g_CurrentPosition.entry_time = TimeCurrent();
            return true;
        }
    } else {
        Print("? Trade failed: ", GetLastError(), " RetCode: ", result.retcode);
    }
    return false;
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

    // VALIDATION PAR TIMEFRAME (inputs dynamiques)

    bool buy_valid = (votes_h4_buy >= Min_Votes_H4) && (votes_h1_buy >= Min_Votes_H1) && (votes_m15_buy >= Min_Votes_M15) && (votes_macro_buy >= Min_Votes_Macro) && (votes_total_buy >= min_votes_adjusted);

    //===================================================================
    // TEST SELL
    //===================================================================
    int votes_h4_sell = CountVotes_H4(-1);
    int votes_h1_sell = CountVotes_H1(-1);
    int votes_m15_sell = CountVotes_M15(-1);
    int votes_macro_sell = CountVotes_Macro(-1);
    int votes_total_sell = votes_h4_sell + votes_h1_sell + votes_m15_sell + votes_macro_sell;

    // VALIDATION PAR TIMEFRAME (inputs dynamiques)
    bool sell_valid = (votes_h4_sell >= Min_Votes_H4) && (votes_h1_sell >= Min_Votes_H1) && (votes_m15_sell >= Min_Votes_M15) && (votes_macro_sell >= Min_Votes_Macro) && (votes_total_sell >= min_votes_adjusted);

    //===================================================================
    // DÉCISION
    //===================================================================
    if(buy_valid && !sell_valid) {
        Print("? SIGNAL BUY VALIDATED:");
        Print("   Votes: H4=", votes_h4_buy, "/5, H1=", votes_h1_buy, "/8, M15=", votes_m15_buy, "/6, Macro=", votes_macro_buy, "/2");
        Print("   Total: ", votes_total_buy, "/21 (min required: ", min_votes_adjusted, ")");
        return 1;  // BUY
    }
    else if(sell_valid && !buy_valid) {
        Print("? SIGNAL SELL VALIDATED:");
        Print("   Votes: H4=", votes_h4_sell, "/5, H1=", votes_h1_sell, "/8, M15=", votes_m15_sell, "/6, Macro=", votes_macro_sell, "/2");
        Print("   Total: ", votes_total_sell, "/21 (min required: ", min_votes_adjusted, ")");
        return -1;  // SELL
    }
    else if(buy_valid && sell_valid) {
        // Both valid - pick the one with MORE votes
        if(votes_total_buy > votes_total_sell) {
            Print("? SIGNAL BUY (conflict resolved - BUY has more votes):");
            Print("   BUY=", votes_total_buy, " vs SELL=", votes_total_sell);
            return 1;
        }
        else if(votes_total_sell > votes_total_buy) {
            Print("? SIGNAL SELL (conflict resolved - SELL has more votes):");
            Print("   SELL=", votes_total_sell, " vs BUY=", votes_total_buy);
            return -1;
        }
        else {
            Print("?? Exact tie BUY=SELL=", votes_total_buy, " - skipping");
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

    Print("?? OPENING TRADE...");

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
        Print("? Cannot calculate SL - aborting trade");
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

    Print("?? Sending order to broker...");
    Print("   Type: ", (direction == 1 ? "BUY" : "SELL"));
    Print("   Lot: ", DoubleToString(lot_size, 2));
    Print("   Entry: ", DoubleToString(entry_price, _Digits));
    Print("   SL: ", DoubleToString(sl_price, _Digits));

    if(OrderSend(request, result)) {
        if(result.retcode == TRADE_RETCODE_DONE) {
            Print("? TRADE OPENED SUCCESSFULLY!");
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
            Print("?? Trade execution warning: ", result.retcode, " - ", result.comment);
        }
    }
    else {
        Print("? TRADE FAILED: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| CHECK MAX TRADE DURATION - Ferme apres X heures                   |
//+------------------------------------------------------------------+
void CheckMaxTradeDuration() {
    if(Max_Trade_Duration_Hours <= 0) return;

    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        if(PositionGetString(POSITION_SYMBOL) != SYMBOL_TRADED) continue;
        if(PositionGetInteger(POSITION_MAGIC) != MAGIC_NUMBER) continue;

        datetime open_time = (datetime)PositionGetInteger(POSITION_TIME);
        int hours_open = (int)((TimeCurrent() - open_time) / 3600);

        if(hours_open >= Max_Trade_Duration_Hours) {
            double profit = PositionGetDouble(POSITION_PROFIT);
            Print("MAX DURATION: Trade #", ticket, " ouvert ", hours_open, "h - Fermeture");

            MqlTradeRequest request = {};
            MqlTradeResult result = {};
            request.action = TRADE_ACTION_DEAL;
            request.symbol = SYMBOL_TRADED;
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.deviation = Slippage_Points;
            request.magic = MAGIC_NUMBER;
            request.comment = "MaxDuration";

            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                request.type = ORDER_TYPE_SELL;
                request.price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
            } else {
                request.type = ORDER_TYPE_BUY;
                request.price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
            }

            if(OrderSend(request, result)) {
                if(result.retcode == TRADE_RETCODE_DONE) {
                    Print("Trade #", ticket, " ferme apres ", hours_open, "h");
                    g_PositionOpen = false;
                    g_CurrentTicket = 0;
                    if(profit > 0) g_TotalWins++; else g_TotalLosses++;
                }
            }
        }
    }
}
