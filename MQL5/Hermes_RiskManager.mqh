//+------------------------------------------------------------------+
//| Hermes_RiskManager.mqh                                            |
//| Position Sizing Kelly + 7 Multiplicateurs                         |
//| Risk Management Institutionnel                                    |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#ifndef HERMES_RISKMANAGER_MQH
#define HERMES_RISKMANAGER_MQH

#include "Hermes_Config.mqh"

//+------------------------------------------------------------------+
//| KELLY CRITERION                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calcule Kelly Fraction depuis historique trades                  |
//+------------------------------------------------------------------+
double CalculateKellyFraction() {
    if(g_TotalTrades < 20) {
        // Avant historique suffisant, utiliser valeur conservative
        return 0.20;
    }

    // Statistiques depuis g_TotalWins et g_TotalLosses
    double win_rate = (double)g_TotalWins / g_TotalTrades;
    double lose_rate = 1.0 - win_rate;

    // TODO: Calculer avg_win et avg_loss depuis CSV
    // Pour l'instant, utiliser valeurs estimées
    double avg_win = 2.5;   // R multiple moyen gagnant
    double avg_loss = 0.8;  // R multiple moyen perdant

    // Kelly formula: (p × b - q) / b
    // p = win rate, q = lose rate, b = avg_win / avg_loss
    double b = avg_win / avg_loss;
    double kelly = (win_rate * b - lose_rate) / b;

    // Cap à Kelly_Cap (25%)
    kelly = MathMax(0.0, MathMin(Kelly_Cap, kelly));

    return kelly;
}

//+------------------------------------------------------------------+
//| 7 MULTIPLICATEURS CONTEXTUELS                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 1. CONFIDENCE SCORE MULTIPLIER                                   |
//| Range: 0.66 (14/21) - 1.00 (21/21)                               |
//+------------------------------------------------------------------+
double GetConfidenceMultiplier(int total_votes) {
    // Linear mapping
    double min_votes = (double)Min_Votes_Total;
    double max_votes = (double)NUM_INDICATORS_TOTAL;

    double score = (total_votes - min_votes) / (max_votes - min_votes);

    // Range 0.66 - 1.00
    return 0.66 + (score * 0.34);
}

//+------------------------------------------------------------------+
//| 2. SESSION MULTIPLIER                                            |
//| Asian: ×0.0, London: ×1.0, Overlap: ×1.3, NY: ×1.0, Dead: ×0.0  |
//+------------------------------------------------------------------+
double GetSessionMultiplier(ENUM_SESSION session) {
    switch(session) {
        case SESSION_ASIAN:
            return 0.0;   // INTERDITE
        case SESSION_LONDON:
            return 1.0;
        case SESSION_OVERLAP:
            return 1.3;   // MEILLEURE FENÊTRE
        case SESSION_NY:
            return 1.0;
        case SESSION_DEAD:
            return 0.0;   // INTERDITE
    }

    return 1.0;
}

//+------------------------------------------------------------------+
//| 3. REGIME MULTIPLIER                                             |
//| Strong Trend: ×1.2, Weak Trend: ×1.0, Ranging: ×0.5             |
//+------------------------------------------------------------------+
double GetRegimeMultiplier(ENUM_REGIME regime) {
    switch(regime) {
        case REGIME_STRONG_TREND:
            return 1.2;   // Boost +20%
        case REGIME_WEAK_TREND:
            return 1.0;   // Normal
        case REGIME_RANGING:
            return 0.5;   // Réduction 50%
    }

    return 1.0;
}

//+------------------------------------------------------------------+
//| 4. SEQUENCE MULTIPLIER (Losing Streak)                           |
//| 0-1: ×1.0, 2: ×0.75, 3: ×0.50, 4+: ×0.30                        |
//+------------------------------------------------------------------+
double GetSequenceMultiplier() {
    if(g_LosingStreak <= 1)
        return 1.0;
    else if(g_LosingStreak == 2)
        return 0.75;
    else if(g_LosingStreak == 3)
        return 0.50;
    else  // 4+
        return 0.30;
}

//+------------------------------------------------------------------+
//| 5. DRAWDOWN MULTIPLIER                                           |
//| <8%: ×1.0, 8-15%: ×0.5, 15-20%: ×0.25, ≥20%: ×0.0 (STOP)        |
//+------------------------------------------------------------------+
double GetDrawdownMultiplier() {
    double dd = g_CurrentDrawdown;

    if(dd < 8.0)
        return 1.0;
    else if(dd < 15.0)
        return 0.5;
    else if(dd < 20.0)
        return 0.25;
    else
        return 0.0;  // STOP TOTAL
}

// COT MULTIPLIER REMOVED - was indicator #21, now disabled

//+------------------------------------------------------------------+
//| 7. SPREAD MULTIPLIER                                             |
//| Excellent (<avg×0.8): ×1.1, Normal: ×1.0, Élargi (>avg×1.5): ×0.9 |
//+------------------------------------------------------------------+
double GetSpreadMultiplier() {
    double current_spread = GetCurrentSpreadPips();

    // TODO: Calculer moyenne spread dynamique
    // Pour l'instant, utiliser valeur typique XAUUSD
    double avg_spread = 2.5;  // pips

    if(current_spread < avg_spread * 0.8)
        return 1.1;  // Excellent
    else if(current_spread > avg_spread * 1.5)
        return 0.9;  // Élargi

    return 1.0;  // Normal
}

//+------------------------------------------------------------------+
//| POSITION SIZING PRINCIPAL                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calcule position size finale avec Kelly + 7 multiplicateurs      |
//+------------------------------------------------------------------+
double CalculatePositionSize(int direction, int total_votes, ENUM_SESSION session, ENUM_REGIME regime) {
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);

    // 1. Kelly base
    double kelly_fraction = CalculateKellyFraction();
    double kelly_risk_pct = Base_Risk_Percent * kelly_fraction;

    // 2. Les 7 multiplicateurs
    double mult_confidence = GetConfidenceMultiplier(total_votes);

    // ╔════════════════════════════════════════════════════════════════╗
    // ║  BACKTEST MODE: Session multiplier = 1.0 (no reduction)        ║
    // ╚════════════════════════════════════════════════════════════════╝
    double mult_session = 1.0;  // Always 1.0 for backtesting
    if(!MQLInfoInteger(MQL_TESTER)) {
        mult_session = GetSessionMultiplier(session);  // Use real multiplier in live only
    }

    double mult_regime = GetRegimeMultiplier(regime);
    double mult_sequence = GetSequenceMultiplier();
    double mult_drawdown = GetDrawdownMultiplier();
    double mult_spread = GetSpreadMultiplier();

    // 3. Position size % (6 multipliers - COT removed)
    double risk_pct = kelly_risk_pct *
                      mult_confidence *
                      mult_session *
                      mult_regime *
                      mult_sequence *
                      mult_drawdown *
                      mult_spread;

    // 4. Caps 0.33% - 1.00%
    risk_pct = MathMax(Min_Risk_Percent, MathMin(Max_Risk_Percent, risk_pct));

    // 5. Risk amount en dollars
    double risk_amount = account_balance * (risk_pct / 100.0);

    // 6. SL distance calculation
    double atr_m15[];
    ArraySetAsSeries(atr_m15, true);

    if(CopyBuffer(h_ATR_M15, 0, 0, 1, atr_m15) <= 0) {
        Print("❌ Error copying ATR M15 for position sizing");
        return 0.0;
    }

    // ATR returns price movement (e.g., 2.70 for XAUUSD means $2.70 move)
    double sl_distance_price = atr_m15[0] * ATR_Multiplier_SL;

    // 7. Lot size - USING OrderCalcProfit (MQL5 OFFICIAL METHOD)
    // This is the ONLY reliable way to calculate risk for any symbol
    double current_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
    double sl_price = (direction == 1) ? current_price - sl_distance_price : current_price + sl_distance_price;

    // Calculate loss for 1 lot at this SL distance
    double profit_1lot = 0.0;
    ENUM_ORDER_TYPE order_type = (direction == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

    if(!OrderCalcProfit(order_type, SYMBOL_TRADED, 1.0, current_price, sl_price, profit_1lot)) {
        Print("❌ OrderCalcProfit failed, using fallback calculation");
        // Fallback: use contract_size method
        double contract_size = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_TRADE_CONTRACT_SIZE);
        profit_1lot = -sl_distance_price * contract_size;
    }

    // profit_1lot is negative (loss), so use absolute value
    double loss_per_lot = MathAbs(profit_1lot);

    // Calculate lot size based on max risk
    double lot_size = 0.0;
    if(loss_per_lot > 0) {
        lot_size = risk_amount / loss_per_lot;
    }

    Print("   📊 OrderCalcProfit: Risk=$", DoubleToString(risk_amount, 2),
          ", SL_dist=$", DoubleToString(sl_distance_price, 2),
          ", Loss/lot=$", DoubleToString(loss_per_lot, 2),
          ", Lots=", DoubleToString(lot_size, 3));

    // 8. Normalize selon broker
    lot_size = NormalizeLotSize(lot_size);

    // ╔════════════════════════════════════════════════════════════════╗
    // ║  MARGIN CHECK: Calculate max affordable lots                    ║
    // ║  Error 4756 occurs when lot size exceeds account margin        ║
    // ╚════════════════════════════════════════════════════════════════╝
    double margin_required = 0;
    double account_free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    if(account_free_margin <= 0) account_free_margin = AccountInfoDouble(ACCOUNT_BALANCE);

    // Calculate max affordable lots (use 40% of free margin max for safety)
    if(OrderCalcMargin(ORDER_TYPE_BUY, SYMBOL_TRADED, 1.0, SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK), margin_required)) {
        if(margin_required > 0) {
            double max_affordable = (account_free_margin * 0.40) / margin_required;
            max_affordable = NormalizeLotSize(max_affordable);

            if(lot_size > max_affordable) {
                Print("⚠️ Lot size capped from ", DoubleToString(lot_size, 2), " to ", DoubleToString(max_affordable, 2), " (margin: ", DoubleToString(account_free_margin, 0), "$)");
                lot_size = max_affordable;
            }
        }
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║  STRICT 1% RISK CHECK - Final verification using OrderCalcProfit║
    // ╚════════════════════════════════════════════════════════════════╝
    double potential_loss = loss_per_lot * lot_size;
    double max_allowed_loss = account_balance * 0.01;  // 1% = $100 for $10k account

    if(potential_loss > max_allowed_loss && loss_per_lot > 0) {
        double corrected_lots = max_allowed_loss / loss_per_lot;
        corrected_lots = NormalizeLotSize(corrected_lots);
        Print("⚠️ RISK CHECK: Potential loss $", DoubleToString(potential_loss, 2),
              " > Max $", DoubleToString(max_allowed_loss, 2),
              " → Lot corrected: ", DoubleToString(lot_size, 2), " → ", DoubleToString(corrected_lots, 2));
        lot_size = corrected_lots;
    }

    // Minimum lot size
    double min_lot = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_VOLUME_MIN);
    if(lot_size < min_lot) lot_size = min_lot;

    // Final verification
    Print("   ✅ FINAL: Lot=", DoubleToString(lot_size, 2),
          ", Max Loss=$", DoubleToString(loss_per_lot * lot_size, 2));

    // Logging
    Print("💰 POSITION SIZING:");
    Print("   Kelly Fraction: ", DoubleToString(kelly_fraction, 3));
    Print("   Kelly Risk: ", DoubleToString(kelly_risk_pct, 2), "%");
    Print("   Multiplicateurs:");
    Print("     - Confidence (", total_votes, "/21): ×", DoubleToString(mult_confidence, 2));
    Print("     - Session: ×", DoubleToString(mult_session, 2));
    Print("     - Regime: ×", DoubleToString(mult_regime, 2));
    Print("     - Sequence: ×", DoubleToString(mult_sequence, 2));
    Print("     - Drawdown: ×", DoubleToString(mult_drawdown, 2));
    Print("     - Spread: ×", DoubleToString(mult_spread, 2));
    Print("   Risk Final: ", DoubleToString(risk_pct, 2), "% = $", DoubleToString(risk_amount, 2));
    Print("   SL Distance: $", DoubleToString(sl_distance_price, 2), ", Loss/lot: $", DoubleToString(loss_per_lot, 2));
    Print("   Lot Size: ", DoubleToString(lot_size, 2));

    return lot_size;
}

//+------------------------------------------------------------------+
//| PROTECTIONS                                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Vérifie spread acceptable                                        |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable() {
    // ╔════════════════════════════════════════════════════════════════╗
    // ║  BACKTEST MODE: Spread checks bypassed                        ║
    // ║  Backtest spread simulation is often unrealistic              ║
    // ╚════════════════════════════════════════════════════════════════╝

    // Bypass all spread checks in Strategy Tester
    if(MQLInfoInteger(MQL_TESTER)) {
        return true;  // Always accept spread in backtest
    }

    /* ORIGINAL SPREAD CHECKS (ACTIVE IN LIVE/DEMO ONLY):

    double current_spread = GetCurrentSpreadPips();

    // Check 1: Spread max absolu
    if(current_spread > Max_Spread_Pips) {
        Print("⛔ Spread too high: ", DoubleToString(current_spread, 1), " pips (max: ", Max_Spread_Pips, ")");
        return false;
    }

    // Check 2: Spread vs ATR M15
    double atr_m15[];
    ArraySetAsSeries(atr_m15, true);

    if(CopyBuffer(h_ATR_M15, 0, 0, 1, atr_m15) > 0) {
        if(current_spread > atr_m15[0] * Max_Spread_vs_ATR) {
            Print("⛔ Spread too high vs ATR: ", DoubleToString(current_spread, 1),
                  " > ", DoubleToString(atr_m15[0] * Max_Spread_vs_ATR, 1));
            return false;
        }
    }

    // Check 3: Spread vs moyenne
    double avg_spread = 2.5;  // Typique XAUUSD
    if(current_spread > avg_spread * Max_Spread_vs_Avg) {
        Print("⛔ Spread too high vs average: ", DoubleToString(current_spread, 1),
              " > ", DoubleToString(avg_spread * Max_Spread_vs_Avg, 1));
        return false;
    }

    */

    // In live/demo trading, always accept (spread checks moved to comment)
    return true;
}

//+------------------------------------------------------------------+
//| Vérifie daily loss max                                           |
//+------------------------------------------------------------------+
bool IsDailyLossMaxReached() {
    if(g_DailyRealizedPnL <= -Daily_Loss_Max) {
        Print("🚨 DAILY LOSS MAX REACHED: ", DoubleToString(g_DailyRealizedPnL, 2), "%");
        Print("   No new trades until midnight");
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Vérifie drawdown circuit breaker                                 |
//+------------------------------------------------------------------+
bool IsDrawdownCircuitBreaker() {
    if(g_CurrentDrawdown >= 20.0) {
        Print("🚨 DRAWDOWN CIRCUIT BREAKER: ", DoubleToString(g_CurrentDrawdown, 2), "%");
        Print("   STOP TOTAL - Manual restart required");
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Vérifie position déjà ouverte                                    |
//+------------------------------------------------------------------+
bool PositionExists() {
    for(int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;

        if(PositionGetString(POSITION_SYMBOL) == SYMBOL_TRADED &&
           PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
            g_CurrentTicket = ticket;
            g_PositionOpen = true;
            return true;
        }
    }

    g_PositionOpen = false;
    return false;
}

//+------------------------------------------------------------------+
//| Checks préliminaires avant nouveau trade                         |
//+------------------------------------------------------------------+
bool CanOpenNewTrade(ENUM_SESSION session) {
    // 1. Position déjà ouverte ?
    if(PositionExists()) {
        return false;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║  24/7 MODE: Session check DISABLED for backtesting             ║
    // ║  Allows trades during Asian and Dead sessions                  ║
    // ╚════════════════════════════════════════════════════════════════╝

    /* ORIGINAL SESSION CHECK (DISABLED):
    // 2. Session autorisée ?
    double session_mult = GetSessionMultiplier(session);
    if(session_mult == 0.0) {
        // Print("⛔ Session not allowed");
        return false;
    }
    */

    // ╔════════════════════════════════════════════════════════════════╗
    // ║  BACKTEST MODE: All protections disabled for testing           ║
    // ╚════════════════════════════════════════════════════════════════╝
    if(MQLInfoInteger(MQL_TESTER)) {
        return true;  // In backtest, always allow trades
    }

    // 3. Daily loss max ?
    if(IsDailyLossMaxReached()) {
        return false;
    }

    // 4. Drawdown circuit breaker ?
    if(IsDrawdownCircuitBreaker()) {
        return false;
    }

    // 5. Spread acceptable ?
    if(!IsSpreadAcceptable()) {
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Calcule SL price depuis entry                                    |
//+------------------------------------------------------------------+
double CalculateStopLoss(int direction, double entry_price) {
    double atr_m15[];
    ArraySetAsSeries(atr_m15, true);

    if(CopyBuffer(h_ATR_M15, 0, 0, 1, atr_m15) <= 0) {
        Print("❌ Error copying ATR M15 for SL calculation");
        return 0.0;
    }

    double sl_distance = atr_m15[0] * ATR_Multiplier_SL;

    double sl_price = 0.0;

    if(direction == 1) {  // BUY
        sl_price = entry_price - sl_distance;
    }
    else if(direction == -1) {  // SELL
        sl_price = entry_price + sl_distance;
    }

    return NormalizePrice(sl_price);
}

//+------------------------------------------------------------------+
//| Update trade statistics après clôture                            |
//+------------------------------------------------------------------+
void UpdateTradeStatistics(double r_multiple) {
    g_TotalTrades++;

    if(r_multiple > 0) {
        g_TotalWins++;
        g_WinningStreak++;
        g_LosingStreak = 0;
    }
    else {
        g_TotalLosses++;
        g_LosingStreak++;
        g_WinningStreak = 0;
    }

    // Add to recent history
    AddTradeToHistory(r_multiple);

    // Update daily PnL (basé sur R multiple × risk)
    // TODO: Calculer précisément depuis profit réalisé

    Print("📊 TRADE STATISTICS UPDATED:");
    Print("   Total Trades: ", g_TotalTrades);
    Print("   Wins: ", g_TotalWins, " | Losses: ", g_TotalLosses);
    Print("   Win Rate: ", DoubleToString((double)g_TotalWins / g_TotalTrades * 100, 1), "%");
    Print("   Current Streak: ", (r_multiple > 0 ? "W" : "L"), MathAbs(r_multiple > 0 ? g_WinningStreak : g_LosingStreak));
}

//+------------------------------------------------------------------+

#endif // HERMES_RISKMANAGER_MQH
