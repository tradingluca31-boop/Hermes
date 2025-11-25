//+------------------------------------------------------------------+
//|                                          Hermes_Diagnostic.mq5   |
//|                                  Diagnostic Script for Hermes EA |
//|                          Identifies why EA is not opening trades |
//+------------------------------------------------------------------+
#property copyright "Hermes Diagnostic Tool"
#property version   "1.0"
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
    Print("=================================================================");
    Print("          HERMES DIAGNOSTIC TOOL - TRADE BLOCKER ANALYSIS        ");
    Print("=================================================================");

    // Initialize
    InitIndicatorWeights();
    Print("[OK] Indicator weights initialized");

    if(!InitIndicators()) {
        Print("[ERROR] Indicator handles failed!");
        return;
    }
    Print("[OK] Indicator handles initialized");

    if(!LoadCOTData()) {
        Print("[WARNING] COT data not loaded");
    } else {
        Print("[OK] COT data loaded: ", g_NumCOTRecords, " records");
    }

    if(!LoadEconomicCalendar()) {
        Print("[WARNING] Economic calendar not loaded");
    } else {
        Print("[OK] Economic calendar loaded: ", g_NumEconomicEvents, " events");
    }

    Print("");
    Print("=== ANALYZING CURRENT BAR ===");
    Print("");

    AnalyzeCurrentBar();
}

//+------------------------------------------------------------------+
//| Analyze current bar in detail                                    |
//+------------------------------------------------------------------+
void AnalyzeCurrentBar() {
    ENUM_REGIME regime = REGIME_WEAK_TREND;
    int min_votes = GetAdjustedMinVotes(regime);

    Print("=================================================================");
    Print("               INDICATOR VOTES BREAKDOWN                         ");
    Print("=================================================================");

    //--- H4 INDICATORS
    Print("");
    Print("=== H4 TIMEFRAME (5 indicators) ===");
    int h4_buy = 0, h4_sell = 0;

    if(Indicator_EMA_Cross_H4(1)) { h4_buy++; Print("  [BUY]  EMA Cross H4"); }
    else if(Indicator_EMA_Cross_H4(-1)) { h4_sell++; Print("  [SELL] EMA Cross H4"); }
    else Print("  [ - ]  EMA Cross H4");

    if(Indicator_ADX_H4(1)) { h4_buy++; Print("  [BUY]  ADX H4"); }
    else if(Indicator_ADX_H4(-1)) { h4_sell++; Print("  [SELL] ADX H4"); }
    else Print("  [ - ]  ADX H4");

    if(Indicator_EMA_50_200_H4(1)) { h4_buy++; Print("  [BUY]  EMA 50/200 H4"); }
    else if(Indicator_EMA_50_200_H4(-1)) { h4_sell++; Print("  [SELL] EMA 50/200 H4"); }
    else Print("  [ - ]  EMA 50/200 H4");

    if(Indicator_Price_EMA21_H4(1)) { h4_buy++; Print("  [BUY]  Price vs EMA21 H4"); }
    else if(Indicator_Price_EMA21_H4(-1)) { h4_sell++; Print("  [SELL] Price vs EMA21 H4"); }
    else Print("  [ - ]  Price vs EMA21 H4");

    if(Indicator_Supertrend_H4(1)) { h4_buy++; Print("  [BUY]  Supertrend H4"); }
    else if(Indicator_Supertrend_H4(-1)) { h4_sell++; Print("  [SELL] Supertrend H4"); }
    else Print("  [ - ]  Supertrend H4");

    Print("H4 TOTAL: BUY=", h4_buy, "/5  SELL=", h4_sell, "/5");

    //--- H1 INDICATORS
    Print("");
    Print("=== H1 TIMEFRAME (8 indicators) ===");
    int h1_buy = 0, h1_sell = 0;

    if(Indicator_EMA_Cross_H1(1)) { h1_buy++; Print("  [BUY]  EMA Cross H1"); }
    else if(Indicator_EMA_Cross_H1(-1)) { h1_sell++; Print("  [SELL] EMA Cross H1"); }
    else Print("  [ - ]  EMA Cross H1");

    if(Indicator_MACD_H1(1)) { h1_buy++; Print("  [BUY]  MACD H1"); }
    else if(Indicator_MACD_H1(-1)) { h1_sell++; Print("  [SELL] MACD H1"); }
    else Print("  [ - ]  MACD H1");

    if(Indicator_RSI_H1(1)) { h1_buy++; Print("  [BUY]  RSI H1 (widened)"); }
    else if(Indicator_RSI_H1(-1)) { h1_sell++; Print("  [SELL] RSI H1 (widened)"); }
    else Print("  [ - ]  RSI H1");

    if(Indicator_SAR_H1(1)) { h1_buy++; Print("  [BUY]  SAR H1"); }
    else if(Indicator_SAR_H1(-1)) { h1_sell++; Print("  [SELL] SAR H1"); }
    else Print("  [ - ]  SAR H1");

    if(Indicator_Stochastic_H1(1)) { h1_buy++; Print("  [BUY]  Stochastic H1 (widened)"); }
    else if(Indicator_Stochastic_H1(-1)) { h1_sell++; Print("  [SELL] Stochastic H1 (widened)"); }
    else Print("  [ - ]  Stochastic H1");

    if(Indicator_Bollinger_Width_H1(1)) { h1_buy++; Print("  [BUY]  Bollinger H1"); }
    else if(Indicator_Bollinger_Width_H1(-1)) { h1_sell++; Print("  [SELL] Bollinger H1"); }
    else Print("  [ - ]  Bollinger H1");

    if(Indicator_Volume_Momentum_H1(1)) { h1_buy++; Print("  [BUY]  Volume H1"); }
    else if(Indicator_Volume_Momentum_H1(-1)) { h1_sell++; Print("  [SELL] Volume H1"); }
    else Print("  [ - ]  Volume H1");

    if(Indicator_Donchian_H1(1)) { h1_buy++; Print("  [BUY]  Donchian H1"); }
    else if(Indicator_Donchian_H1(-1)) { h1_sell++; Print("  [SELL] Donchian H1"); }
    else Print("  [ - ]  Donchian H1");

    Print("H1 TOTAL: BUY=", h1_buy, "/8  SELL=", h1_sell, "/8");

    //--- M15 INDICATORS
    Print("");
    Print("=== M15 TIMEFRAME (6 indicators) ===");
    int m15_buy = 0, m15_sell = 0;

    if(Indicator_VWAP_M15(1)) { m15_buy++; Print("  [BUY]  VWAP M15"); }
    else if(Indicator_VWAP_M15(-1)) { m15_sell++; Print("  [SELL] VWAP M15"); }
    else Print("  [ - ]  VWAP M15");

    if(Indicator_OrderFlow_M15(1)) { m15_buy++; Print("  [BUY]  OrderFlow M15"); }
    else if(Indicator_OrderFlow_M15(-1)) { m15_sell++; Print("  [SELL] OrderFlow M15"); }
    else Print("  [ - ]  OrderFlow M15");

    if(Indicator_Volatility_M15(1)) { m15_buy++; Print("  [BUY]  Volatility M15"); }
    else if(Indicator_Volatility_M15(-1)) { m15_sell++; Print("  [SELL] Volatility M15"); }
    else Print("  [ - ]  Volatility M15");

    if(Indicator_Tick_Momentum_M15(1)) { m15_buy++; Print("  [BUY]  Tick Momentum M15"); }
    else if(Indicator_Tick_Momentum_M15(-1)) { m15_sell++; Print("  [SELL] Tick Momentum M15"); }
    else Print("  [ - ]  Tick Momentum M15");

    if(Indicator_EURUSD_Corr_M15(1)) { m15_buy++; Print("  [BUY]  EURUSD Corr M15"); }
    else if(Indicator_EURUSD_Corr_M15(-1)) { m15_sell++; Print("  [SELL] EURUSD Corr M15"); }
    else Print("  [ - ]  EURUSD Corr M15 (optional)");

    if(Indicator_Effective_Spread_M15(1)) { m15_buy++; Print("  [OK]   Spread M15 valid"); }
    else Print("  [ - ]  Spread M15");

    Print("M15 TOTAL: BUY=", m15_buy, "/6  SELL=", m15_sell, "/6");

    //--- MACRO INDICATORS
    Print("");
    Print("=== MACRO INDICATORS (2 total) ===");
    int macro_buy = 0, macro_sell = 0;

    if(Indicator_COT(1)) { macro_buy++; Print("  [BUY]  COT"); }
    else if(Indicator_COT(-1)) { macro_sell++; Print("  [SELL] COT"); }
    else Print("  [ - ]  COT (", g_NumCOTRecords, " records)");

    if(Indicator_ATR_Percentile(1)) { macro_buy++; Print("  [OK]   ATR Percentile valid"); }
    else Print("  [ - ]  ATR Percentile");

    Print("MACRO TOTAL: BUY=", macro_buy, "/2  SELL=", macro_sell, "/2");

    //--- TOTAL VOTES
    int total_buy = h4_buy + h1_buy + m15_buy + macro_buy;
    int total_sell = h4_sell + h1_sell + m15_sell + macro_sell;

    Print("");
    Print("=================================================================");
    Print("                     VALIDATION LOGIC                            ");
    Print("=================================================================");
    Print("");
    Print("TOTAL VOTES:");
    Print("  BUY:  ", total_buy, "/21");
    Print("  SELL: ", total_sell, "/21");
    Print("  REQUIRED: ", min_votes, "/21");
    Print("");

    Print("OLD LOGIC (BEFORE FIX #1) - Requires ALL:");
    Print("  H4:    ", h4_buy, " >= ", Min_Votes_H4);
    if(h4_buy >= Min_Votes_H4) Print("         [OK]");
    else Print("         [FAIL]");

    Print("  H1:    ", h1_buy, " >= ", Min_Votes_H1);
    if(h1_buy >= Min_Votes_H1) Print("         [OK]");
    else Print("         [FAIL]");

    Print("  M15:   ", m15_buy, " >= ", Min_Votes_M15);
    if(m15_buy >= Min_Votes_M15) Print("         [OK]");
    else Print("         [FAIL]");

    Print("  Macro: ", macro_buy, " >= ", Min_Votes_Macro);
    if(macro_buy >= Min_Votes_Macro) Print("         [OK]");
    else Print("         [FAIL]");

    Print("  Total: ", total_buy, " >= ", min_votes);
    if(total_buy >= min_votes) Print("         [OK]");
    else Print("         [FAIL]");

    bool old_valid = (h4_buy >= Min_Votes_H4) && (h1_buy >= Min_Votes_H1) &&
                     (m15_buy >= Min_Votes_M15) && (macro_buy >= Min_Votes_Macro) &&
                     (total_buy >= min_votes);

    if(old_valid) Print("  >>> OLD LOGIC: BUY VALID");
    else Print("  >>> OLD LOGIC: BLOCKED");

    Print("");
    Print("NEW LOGIC (AFTER FIX #1) - Progressive only:");
    Print("  Total: ", total_buy, " >= ", min_votes);
    if(total_buy >= min_votes) Print("         [OK]");
    else Print("         [FAIL]");

    bool new_valid = (total_buy >= min_votes);

    if(new_valid) Print("  >>> NEW LOGIC: BUY VALID");
    else Print("  >>> NEW LOGIC: BLOCKED");

    Print("");
    Print("=================================================================");
    Print("                     FINAL DECISION                              ");
    Print("=================================================================");

    if(total_buy >= min_votes && total_sell < min_votes) {
        Print("  >>> SIGNAL: BUY (", total_buy, " votes)");
    }
    else if(total_sell >= min_votes && total_buy < min_votes) {
        Print("  >>> SIGNAL: SELL (", total_sell, " votes)");
    }
    else if(total_buy >= min_votes && total_sell >= min_votes) {
        Print("  >>> CONFLICT: Both BUY and SELL valid - SKIPPED");
    }
    else {
        Print("  >>> NO SIGNAL: Insufficient votes");
        Print("      BUY needs:  ", min_votes - total_buy, " more votes");
        Print("      SELL needs: ", min_votes - total_sell, " more votes");
    }

    Print("");
    Print("=================================================================");
    Print("                  ADDITIONAL CHECKS                              ");
    Print("=================================================================");

    bool can_trade = CanTradeNow();
    if(can_trade) Print("Session allowed:  YES (24/7)");
    else Print("Session allowed:  BLOCKED");

    bool spread_ok = IsSpreadAcceptable();
    if(spread_ok) Print("Spread OK:        YES (bypassed)");
    else Print("Spread OK:        BLOCKED");

    int positions = PositionsTotal();
    Print("Positions:        ", positions, "/", Max_Positions);

    Print("=================================================================");
    Print("                     DIAGNOSTIC COMPLETE                         ");
    Print("=================================================================");
}
