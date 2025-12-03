//+------------------------------------------------------------------+
//|                                          Hermes_DiagnosticV2.mq5 |
//|                       DIAGNOSTIC COMPLET - Version 2.0           |
//|      Identifie EXACTEMENT pourquoi l'EA n'ouvre pas de trades    |
//+------------------------------------------------------------------+
#property copyright "Hermes Diagnostic Tool V2"
#property version   "2.0"
#property script_show_inputs

//--- Include all Hermes modules
#include "Hermes_Config.mqh"
#include "Hermes_Indicators.mqh"
#include "Hermes_SessionManager.mqh"
#include "Hermes_RiskManager.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
    Print("");
    Print("╔════════════════════════════════════════════════════════════════════╗");
    Print("║          HERMES DIAGNOSTIC V2.0 - ANALYSE COMPLETE                 ║");
    Print("║   Ce script identifie EXACTEMENT pourquoi l'EA n'ouvre pas        ║");
    Print("╚════════════════════════════════════════════════════════════════════╝");
    Print("");

    //===================================================================
    // SECTION 1: VERIFICATION ENVIRONNEMENT
    //===================================================================
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                    SECTION 1: ENVIRONNEMENT                        ");
    Print("═══════════════════════════════════════════════════════════════════");

    Print("Symbol actuel: ", _Symbol);
    Print("Symbol requis: ", SYMBOL_TRADED);

    if(_Symbol != SYMBOL_TRADED) {
        Print("⛔ ERREUR CRITIQUE: Mauvais symbole!");
        Print("   L'EA est conçu pour ", SYMBOL_TRADED, " uniquement");
        Print("   >>> SOLUTION: Ouvrir graphique XAUUSD et relancer");
        return;
    }
    Print("✅ Symbol OK: ", _Symbol);

    // Vérifier mode backtest
    bool is_tester = MQLInfoInteger(MQL_TESTER);
    bool is_optimization = MQLInfoInteger(MQL_OPTIMIZATION);
    bool is_visual = MQLInfoInteger(MQL_VISUAL_MODE);

    Print("");
    Print("Mode execution:");
    Print("   MQL_TESTER: ", is_tester);
    Print("   MQL_OPTIMIZATION: ", is_optimization);
    Print("   MQL_VISUAL_MODE: ", is_visual);

    // Vérifier trading autorisé
    bool algo_trading = (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
    bool trade_allowed = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);

    Print("");
    Print("Permissions trading:");
    Print("   ACCOUNT_TRADE_EXPERT: ", algo_trading);
    Print("   ACCOUNT_TRADE_ALLOWED: ", trade_allowed);

    if(!algo_trading) {
        Print("⛔ ERREUR: Trading automatique désactivé!");
        Print("   >>> SOLUTION: Activer 'AutoTrading' dans MT5");
    }

    //===================================================================
    // SECTION 2: INITIALISATION INDICATEURS
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                  SECTION 2: INDICATEURS                            ");
    Print("═══════════════════════════════════════════════════════════════════");

    InitIndicatorWeights();
    Print("✅ Poids indicateurs initialisés");

    if(!InitIndicators()) {
        Print("⛔ ERREUR CRITIQUE: Indicateurs non initialisés!");
        Print("   >>> SOLUTION: Vérifier données historiques");
        return;
    }
    Print("✅ Tous les handles indicateurs OK");

    //===================================================================
    // SECTION 3: DONNEES EXTERNES
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                  SECTION 3: DONNEES EXTERNES                       ");
    Print("═══════════════════════════════════════════════════════════════════");

    bool cot_loaded = LoadCOTData();
    Print("COT Data: ", (cot_loaded ? "✅ Chargé (" + IntegerToString(g_NumCOTRecords) + " records)" : "⚠️ Non chargé (COT sera NEUTRAL)"));

    bool calendar_loaded = LoadEconomicCalendar();
    Print("Calendar: ", (calendar_loaded ? "✅ Chargé (" + IntegerToString(g_NumEconomicEvents) + " events)" : "⚠️ Non chargé"));

    //===================================================================
    // SECTION 4: VERIFICATIONS PRE-TRADE
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                  SECTION 4: CHECKS PRE-TRADE                       ");
    Print("═══════════════════════════════════════════════════════════════════");

    // 4.1 Position existante
    bool pos_exists = PositionExists();
    Print("Position existante: ", (pos_exists ? "⛔ OUI (bloque nouveaux trades)" : "✅ NON"));

    // 4.2 Session
    ENUM_SESSION session = GetCurrentSession();
    string session_name = GetSessionName(session);
    double session_mult = GetSessionMultiplier(session);

    Print("");
    Print("Session actuelle: ", session_name);
    Print("   Multiplicateur: ", session_mult);
    Print("   Check session désactivé: ✅ (mode 24/7)");

    // 4.3 CanTradeNow (devrait toujours être true maintenant)
    bool can_trade_now = CanTradeNow();
    Print("");
    Print("CanTradeNow(): ", (can_trade_now ? "✅ TRUE" : "⛔ FALSE"));

    // 4.4 CanOpenNewTrade
    bool can_open = CanOpenNewTrade(session);
    Print("CanOpenNewTrade(): ", (can_open ? "✅ TRUE" : "⛔ FALSE"));

    if(!can_open && !pos_exists) {
        // Diagnostiquer pourquoi
        Print("   >>> Diagnostic CanOpenNewTrade:");
        Print("   Daily Loss Max atteint: ", (IsDailyLossMaxReached() ? "⛔ OUI" : "✅ NON"));
        Print("   Drawdown Circuit Breaker: ", (IsDrawdownCircuitBreaker() ? "⛔ OUI" : "✅ NON"));
        Print("   Spread acceptable: ", (IsSpreadAcceptable() ? "✅ OUI" : "⛔ NON"));
    }

    // 4.5 Spread actuel
    double spread = GetCurrentSpreadPips();
    Print("");
    Print("Spread actuel: ", DoubleToString(spread, 1), " pips");
    Print("Spread max config: ", Max_Spread_Pips, " pips");

    //===================================================================
    // SECTION 5: REGIME MOMENTUM
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                  SECTION 5: REGIME MOMENTUM                        ");
    Print("═══════════════════════════════════════════════════════════════════");

    ENUM_REGIME regime = DetectMomentumRegime();
    int min_votes = GetAdjustedMinVotes(regime);

    string regime_name = "";
    if(regime == REGIME_STRONG_TREND) regime_name = "STRONG TREND";
    else if(regime == REGIME_WEAK_TREND) regime_name = "WEAK TREND";
    else regime_name = "RANGING";

    Print("");
    Print("Régime détecté: ", regime_name);
    Print("Votes minimum requis: ", min_votes, "/21");

    //===================================================================
    // SECTION 6: ANALYSE DETAILLEE DES 21 INDICATEURS
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("         SECTION 6: ANALYSE DETAILLEE DES 21 INDICATEURS           ");
    Print("═══════════════════════════════════════════════════════════════════");

    // Test BUY direction
    Print("");
    Print("╔═══════════════════════════════════════════════════════════════╗");
    Print("║                    DIRECTION: BUY (+1)                         ║");
    Print("╚═══════════════════════════════════════════════════════════════╝");

    int buy_votes = AnalyzeIndicatorsDetailed(1);

    // Test SELL direction
    Print("");
    Print("╔═══════════════════════════════════════════════════════════════╗");
    Print("║                   DIRECTION: SELL (-1)                         ║");
    Print("╚═══════════════════════════════════════════════════════════════╝");

    int sell_votes = AnalyzeIndicatorsDetailed(-1);

    //===================================================================
    // SECTION 7: DECISION FINALE
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                   SECTION 7: DECISION FINALE                      ");
    Print("═══════════════════════════════════════════════════════════════════");

    Print("");
    Print("RÉSUMÉ DES VOTES:");
    Print("   BUY:  ", buy_votes, "/21  (minimum requis: ", min_votes, ")");
    Print("   SELL: ", sell_votes, "/21 (minimum requis: ", min_votes, ")");
    Print("");

    bool buy_valid = (buy_votes >= min_votes);
    bool sell_valid = (sell_votes >= min_votes);

    if(buy_valid && !sell_valid) {
        Print("✅ SIGNAL VALIDE: BUY");
        Print("   L'EA DEVRAIT ouvrir un trade BUY");
    }
    else if(sell_valid && !buy_valid) {
        Print("✅ SIGNAL VALIDE: SELL");
        Print("   L'EA DEVRAIT ouvrir un trade SELL");
    }
    else if(buy_valid && sell_valid) {
        Print("⚠️ CONFLIT: BUY et SELL valides");
        Print("   L'EA va SKIP (pas de trade)");
    }
    else {
        Print("⛔ AUCUN SIGNAL VALIDE");
        Print("   BUY manque: ", min_votes - buy_votes, " votes");
        Print("   SELL manque: ", min_votes - sell_votes, " votes");
        Print("");
        Print(">>> C'EST LA RAISON PRINCIPALE: PAS ASSEZ DE VOTES!");
    }

    //===================================================================
    // SECTION 8: DIAGNOSTIC ISNECANDLE
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("               SECTION 8: TIMING (IsNewCandle)                     ");
    Print("═══════════════════════════════════════════════════════════════════");

    datetime candle_time = iTime(SYMBOL_TRADED, TF_TIMING, 0);
    Print("Heure bougie M15 actuelle: ", TimeToString(candle_time, TIME_DATE|TIME_MINUTES));
    Print("g_LastCandleTime: ", TimeToString(g_LastCandleTime, TIME_DATE|TIME_MINUTES));
    Print("");
    Print("NOTE: L'EA ne trade qu'à l'ouverture d'une NOUVELLE bougie M15");
    Print("      Si vous testez pendant une bougie, l'EA attend la suivante");

    //===================================================================
    // SECTION 9: POSITION SIZING TEST
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("               SECTION 9: POSITION SIZING TEST                     ");
    Print("═══════════════════════════════════════════════════════════════════");

    int direction_test = (buy_votes > sell_votes) ? 1 : -1;
    int votes_test = MathMax(buy_votes, sell_votes);

    double lot_size = CalculatePositionSize(direction_test, votes_test, session, regime);
    double min_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_STEP);

    Print("");
    Print("Test position sizing:");
    Print("   Lot calculé: ", DoubleToString(lot_size, 4));
    Print("   Lot minimum broker: ", DoubleToString(min_lot, 4));
    Print("   Lot maximum broker: ", DoubleToString(max_lot, 2));
    Print("   Lot step: ", DoubleToString(lot_step, 4));

    if(lot_size < min_lot) {
        Print("⛔ LOT TROP PETIT! Le trade serait SKIP");
        Print("   >>> SOLUTION: Augmenter capital ou risk %");
    }
    else {
        Print("✅ Lot size OK");
    }

    //===================================================================
    // SECTION 10: RECOMMANDATIONS
    //===================================================================
    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("               SECTION 10: RECOMMANDATIONS                         ");
    Print("═══════════════════════════════════════════════════════════════════");

    Print("");
    if(buy_votes < min_votes && sell_votes < min_votes) {
        Print("PROBLEME PRINCIPAL: Pas assez de votes pour BUY ni SELL");
        Print("");
        Print("SOLUTIONS POSSIBLES:");
        Print("1. Réduire Min_Votes_Total dans les inputs (actuellement ", Min_Votes_Total, ")");
        Print("2. Les seuils de régime sont:");
        Print("   - STRONG_TREND: 12 votes");
        Print("   - WEAK_TREND: 13 votes");
        Print("   - RANGING: 14 votes");
        Print("");
        Print("3. Pour que l'EA trade MAINTENANT, il faudrait:");
        Print("   - BUY: obtenir ", min_votes - buy_votes, " votes de plus");
        Print("   - SELL: obtenir ", min_votes - sell_votes, " votes de plus");
        Print("");
        Print("4. Le marché actuel n'a peut-être pas de tendance claire");
        Print("   Essayez un backtest sur une période avec forte tendance");
    }
    else {
        Print("Les conditions semblent OK pour trader");
        Print("Si l'EA n'ouvre toujours pas:");
        Print("1. Vérifier que c'est bien sur XAUUSD");
        Print("2. Vérifier le mode Every Tick dans Strategy Tester");
        Print("3. Vérifier les données historiques");
    }

    Print("");
    Print("═══════════════════════════════════════════════════════════════════");
    Print("                  DIAGNOSTIC TERMINE                               ");
    Print("═══════════════════════════════════════════════════════════════════");

    // Release indicators
    ReleaseIndicators();
}

//+------------------------------------------------------------------+
//| Analyse détaillée avec print de chaque indicateur                |
//+------------------------------------------------------------------+
int AnalyzeIndicatorsDetailed(int direction) {
    int total_votes = 0;
    string dir_str = (direction == 1) ? "BUY" : "SELL";

    Print("");
    Print("--- H4 INDICATORS (5) ---");

    bool ind1 = Indicator_ADX_H4(direction);
    Print("  1. ADX H4:          ", (ind1 ? "[✓] VOTE" : "[ ] -"));
    if(ind1) total_votes++;

    bool ind2 = Indicator_EMA_Cross_H4(direction);
    Print("  2. EMA 21/55 H4:    ", (ind2 ? "[✓] VOTE" : "[ ] -"));
    if(ind2) total_votes++;

    bool ind3 = Indicator_EMA_50_200_H4(direction);
    Print("  3. EMA 50/200 H4:   ", (ind3 ? "[✓] VOTE" : "[ ] -"));
    if(ind3) total_votes++;

    bool ind4 = Indicator_Price_EMA21_H4(direction);
    Print("  4. Price/EMA21 H4:  ", (ind4 ? "[✓] VOTE" : "[ ] -"));
    if(ind4) total_votes++;

    bool ind5 = Indicator_Supertrend_H4(direction);
    Print("  5. Supertrend H4:   ", (ind5 ? "[✓] VOTE" : "[ ] -"));
    if(ind5) total_votes++;

    int h4_votes = (ind1?1:0) + (ind2?1:0) + (ind3?1:0) + (ind4?1:0) + (ind5?1:0);
    Print("  H4 SUBTOTAL: ", h4_votes, "/5");

    Print("");
    Print("--- H1 INDICATORS (8) ---");

    bool ind6 = Indicator_EMA_Cross_H1(direction);
    Print("  6. EMA Cross H1:    ", (ind6 ? "[✓] VOTE" : "[ ] -"));
    if(ind6) total_votes++;

    bool ind7 = Indicator_MACD_H1(direction);
    Print("  7. MACD H1:         ", (ind7 ? "[✓] VOTE" : "[ ] -"));
    if(ind7) total_votes++;

    bool ind8 = Indicator_RSI_H1(direction);
    Print("  8. RSI H1:          ", (ind8 ? "[✓] VOTE" : "[ ] -"));
    if(ind8) total_votes++;

    bool ind9 = Indicator_SAR_H1(direction);
    Print("  9. SAR H1:          ", (ind9 ? "[✓] VOTE" : "[ ] -"));
    if(ind9) total_votes++;

    bool ind10 = Indicator_Stochastic_H1(direction);
    Print(" 10. Stochastic H1:   ", (ind10 ? "[✓] VOTE" : "[ ] -"));
    if(ind10) total_votes++;

    bool ind11 = Indicator_Bollinger_Width_H1(direction);
    Print(" 11. Bollinger H1:    ", (ind11 ? "[✓] VOTE" : "[ ] -"));
    if(ind11) total_votes++;

    bool ind12 = Indicator_Volume_Momentum_H1(direction);
    Print(" 12. Volume Mom H1:   ", (ind12 ? "[✓] VOTE" : "[ ] -"));
    if(ind12) total_votes++;

    bool ind13 = Indicator_Donchian_H1(direction);
    Print(" 13. Donchian H1:     ", (ind13 ? "[✓] VOTE" : "[ ] -"));
    if(ind13) total_votes++;

    int h1_votes = (ind6?1:0) + (ind7?1:0) + (ind8?1:0) + (ind9?1:0) + (ind10?1:0) + (ind11?1:0) + (ind12?1:0) + (ind13?1:0);
    Print("  H1 SUBTOTAL: ", h1_votes, "/8");

    Print("");
    Print("--- M15 INDICATORS (6) ---");

    bool ind14 = Indicator_VWAP_M15(direction);
    Print(" 14. VWAP M15:        ", (ind14 ? "[✓] VOTE" : "[ ] -"));
    if(ind14) total_votes++;

    bool ind15 = Indicator_OrderFlow_M15(direction);
    Print(" 15. OrderFlow M15:   ", (ind15 ? "[✓] VOTE" : "[ ] -"));
    if(ind15) total_votes++;

    bool ind16 = Indicator_Volatility_M15(direction);
    Print(" 16. Volatility M15:  ", (ind16 ? "[✓] VOTE" : "[ ] -"));
    if(ind16) total_votes++;

    bool ind17 = Indicator_Tick_Momentum_M15(direction);
    Print(" 17. Tick Mom M15:    ", (ind17 ? "[✓] VOTE" : "[ ] -"));
    if(ind17) total_votes++;

    bool ind18 = Indicator_EURUSD_Corr_M15(direction);
    Print(" 18. EURUSD Corr M15: ", (ind18 ? "[✓] VOTE" : "[ ] -"), (ind18 ? "" : " (EURUSD data?)"));
    if(ind18) total_votes++;

    bool ind19 = Indicator_Effective_Spread_M15(direction);
    Print(" 19. Spread M15:      ", (ind19 ? "[✓] VOTE" : "[ ] -"));
    if(ind19) total_votes++;

    int m15_votes = (ind14?1:0) + (ind15?1:0) + (ind16?1:0) + (ind17?1:0) + (ind18?1:0) + (ind19?1:0);
    Print("  M15 SUBTOTAL: ", m15_votes, "/6");

    Print("");
    Print("--- MACRO INDICATORS (2) ---");

    bool ind20 = Indicator_COT(direction);
    Print(" 20. COT:             ", (ind20 ? "[✓] VOTE" : "[ ] -"), " (", g_NumCOTRecords, " records)");
    if(ind20) total_votes++;

    bool ind21 = Indicator_ATR_Percentile(direction);
    Print(" 21. ATR Percentile:  ", (ind21 ? "[✓] VOTE" : "[ ] -"));
    if(ind21) total_votes++;

    int macro_votes = (ind20?1:0) + (ind21?1:0);
    Print("  MACRO SUBTOTAL: ", macro_votes, "/2");

    Print("");
    Print("═══════════════════════════════════════════════════════════════");
    Print("  TOTAL ", dir_str, ": ", total_votes, "/21");
    Print("═══════════════════════════════════════════════════════════════");

    return total_votes;
}
//+------------------------------------------------------------------+
