//+------------------------------------------------------------------+
//| Hermes_TrailingStop.mqh                                           |
//| Trailing Stop Progressif 7 Paliers                                |
//| Sécurise 75% des gains à +3.5R, puis trailing continu            |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#ifndef HERMES_TRAILINGSTOP_MQH
#define HERMES_TRAILINGSTOP_MQH

// Config déjà chargée par le fichier .mq5 principal

//+------------------------------------------------------------------+
//| LES 7 PALIERS PROGRESSIFS                                        |
//+------------------------------------------------------------------+
/*
   +0.5R → SL Entry -0.3R (réduit risque 70%)
   +1.0R → SL Entry (BREAKEVEN)
   +1.5R → SL Entry +1.0R (25% sécurisé)
   +2.0R → SL Entry +1.5R (37.5% sécurisé)
   +2.5R → SL Entry +2.0R (50% sécurisé)
   +3.0R → SL Entry +2.5R (62.5% sécurisé)
   +3.5R → SL Entry +3.0R (75% SÉCURISÉ) 🔒

   Après +3.5R: Trailing continu avec offset +0.5R
*/

//+------------------------------------------------------------------+
//| Update Trailing Stop (appelé à chaque tick)                      |
//+------------------------------------------------------------------+
void UpdateTrailingStop() {
    // Vérifier position existe
    if(!PositionSelectByTicket(g_CurrentPosition.ticket)) {
        g_PositionOpen = false;
        return;
    }

    // Prix actuel
    double current_price = 0.0;
    if(g_CurrentPosition.direction == 1) {  // BUY
        current_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID);
    }
    else if(g_CurrentPosition.direction == -1) {  // SELL
        current_price = SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
    }

    // Calcul R actuel (profit en unités de risque)
    double r_current = 0.0;
    if(g_CurrentPosition.initial_risk_pips > 0) {
        if(g_CurrentPosition.direction == 1) {  // BUY
            r_current = (current_price - g_CurrentPosition.entry_price) /
                        g_CurrentPosition.initial_risk_pips;
        }
        else {  // SELL
            r_current = (g_CurrentPosition.entry_price - current_price) /
                        g_CurrentPosition.initial_risk_pips;
        }
    }

    // Variables pour nouveau SL
    double new_sl = 0.0;
    bool should_modify = false;
    int new_level = g_CurrentPosition.current_trailing_level;

    //==================================================================
    // PALIER 1: +0.5R - Réduit risque de 70%
    //==================================================================
    if(r_current >= 0.5 && g_CurrentPosition.current_trailing_level < 1) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price -
                     (0.3 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price +
                     (0.3 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 1;

        Print("✅ TRAILING +0.5R: Risk reduced 70% (SL -0.3R)");
    }

    //==================================================================
    // PALIER 2: +1.0R - BREAKEVEN
    //==================================================================
    else if(r_current >= 1.0 && g_CurrentPosition.current_trailing_level < 2) {
        new_sl = g_CurrentPosition.entry_price;

        should_modify = true;
        new_level = 2;

        Print("✅ TRAILING +1.0R: BREAKEVEN - Trade now RISK-FREE 🔒");
    }

    //==================================================================
    // PALIER 3: +1.5R - Sécurise +1.0R (25%)
    //==================================================================
    else if(r_current >= 1.5 && g_CurrentPosition.current_trailing_level < 3) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price +
                     (1.0 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price -
                     (1.0 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 3;

        Print("✅ TRAILING +1.5R: +1.0R locked (25% of max gain)");
    }

    //==================================================================
    // PALIER 4: +2.0R - Sécurise +1.5R (37.5%)
    //==================================================================
    else if(r_current >= 2.0 && g_CurrentPosition.current_trailing_level < 4) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price +
                     (1.5 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price -
                     (1.5 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 4;

        Print("✅ TRAILING +2.0R: +1.5R locked (37.5% of max gain)");
    }

    //==================================================================
    // PALIER 5: +2.5R - Sécurise +2.0R (50%)
    //==================================================================
    else if(r_current >= 2.5 && g_CurrentPosition.current_trailing_level < 5) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price +
                     (2.0 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price -
                     (2.0 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 5;

        Print("✅ TRAILING +2.5R: +2.0R locked (50% of max gain)");
    }

    //==================================================================
    // PALIER 6: +3.0R - Sécurise +2.5R (62.5%)
    //==================================================================
    else if(r_current >= 3.0 && g_CurrentPosition.current_trailing_level < 6) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price +
                     (2.5 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price -
                     (2.5 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 6;

        Print("✅ TRAILING +3.0R: +2.5R locked (62.5% of max gain)");
    }

    //==================================================================
    // PALIER 7: +1.5R - Active le trailing continu 🔒
    //==================================================================
    else if(r_current >= 1.5 && g_CurrentPosition.current_trailing_level < 7) {
        if(g_CurrentPosition.direction == 1) {
            new_sl = g_CurrentPosition.entry_price +
                     (1.0 * g_CurrentPosition.initial_risk_pips);
        }
        else {
            new_sl = g_CurrentPosition.entry_price -
                     (1.0 * g_CurrentPosition.initial_risk_pips);
        }

        should_modify = true;
        new_level = 7;

        Print("🔒 TRAILING +1.5R: +1.0R LOCKED - Trailing actif!");
        Print("   Trailing suit avec offset de ", Trailing_Offset_After_35R, "R");
    }

    //==================================================================
    // APRÈS +1.5R: TRAILING CONTINU (offset configurable)
    //==================================================================
    else if(r_current > 1.5 && g_CurrentPosition.current_trailing_level == 7) {
        double offset = Trailing_Offset_After_35R * g_CurrentPosition.initial_risk_pips;

        if(g_CurrentPosition.direction == 1) {  // BUY
            new_sl = current_price - offset;
        }
        else {  // SELL
            new_sl = current_price + offset;
        }

        // Vérifie que nouveau SL est meilleur que l'ancien
        double current_sl = PositionGetDouble(POSITION_SL);

        bool better_sl = false;
        if(g_CurrentPosition.direction == 1) {
            better_sl = (new_sl > current_sl);
        }
        else {
            better_sl = (new_sl < current_sl);
        }

        if(better_sl) {
            should_modify = true;
            // Level reste à 7

            // Log seulement tous les 0.5R pour éviter spam
            static double last_logged_r = 1.5;
            if(r_current >= last_logged_r + 0.5) {
                Print("📈 TRAILING CONTINU: +", DoubleToString(r_current, 1),
                      "R | SL suit à ", Trailing_Offset_After_35R, "R derrière");
                last_logged_r = MathFloor(r_current / 0.5) * 0.5;
            }
        }
    }

    //==================================================================
    // MODIFICATION DU STOP LOSS
    //==================================================================
    if(should_modify) {
        new_sl = NormalizePrice(new_sl);

        MqlTradeRequest request;
        MqlTradeResult result;
        ZeroMemory(request);
        ZeroMemory(result);

        request.action = TRADE_ACTION_SLTP;
        request.symbol = SYMBOL_TRADED;
        request.position = g_CurrentPosition.ticket;
        request.sl = new_sl;
        request.tp = PositionGetDouble(POSITION_TP);  // Garder le TP original

        if(OrderSend(request, result)) {
            if(result.retcode == TRADE_RETCODE_DONE) {
                g_CurrentPosition.current_trailing_level = new_level;

                Print("✅ Trailing Stop MODIFIED successfully");
                Print("   New SL: ", DoubleToString(new_sl, _Digits));
                Print("   Current R: +", DoubleToString(r_current, 2), "R");
                Print("   Level: ", new_level, "/7");
            }
            else {
                Print("⚠️ Trailing Stop modification warning: ", result.retcode, " - ", result.comment);
            }
        }
        else {
            Print("❌ Trailing Stop modification FAILED: ", GetLastError());
        }
    }
}

//+------------------------------------------------------------------+
//| Sortie anticipée si conditions se détériorent                    |
//+------------------------------------------------------------------+
bool ShouldExitEarly() {
    // Recalcule les votes actuels
    int votes_current = CountVotes_Total(g_CurrentPosition.direction);

    // Si score tombe en-dessous de 60% du score initial
    double score_ratio = (double)votes_current / g_CurrentPosition.votes_total;

    if(score_ratio < 0.60) {
        Print("⚠️ EARLY EXIT: Vote score dropped to ", votes_current, "/21 (from ", g_CurrentPosition.votes_total, "/21)");
        Print("   Score ratio: ", DoubleToString(score_ratio * 100, 0), "% (< 60% threshold)");
        return true;
    }

    // Si ADX tombe sous 20 (fin de tendance)
    double adx[];
    ArraySetAsSeries(adx, true);

    if(CopyBuffer(h_ADX_H4, 0, 0, 1, adx) > 0) {
        if(adx[0] < 20.0) {
            Print("⚠️ EARLY EXIT: ADX dropped to ", DoubleToString(adx[0], 1), " (< 20) - Trend ending");
            return true;
        }
    }

    return false;
}

//+------------------------------------------------------------------+
//| Gestion complète position ouverte                                |
//+------------------------------------------------------------------+
void ManageOpenPosition() {
    if(!PositionSelectByTicket(g_CurrentPosition.ticket)) {
        Print("⚠️ Position not found - resetting state");
        g_PositionOpen = false;
        ResetPositionInfo();
        return;
    }

    // 1. Update trailing stop
    UpdateTrailingStop();

    // 2. Check early exit conditions
    if(ShouldExitEarly()) {
        ClosePosition("Early exit - conditions deteriorated");
    }

    // 3. Update display info (optionnel)
    // DisplayPositionInfo();
}

//+------------------------------------------------------------------+
//| Ferme position avec raison                                       |
//+------------------------------------------------------------------+
void ClosePosition(string reason) {
    if(!PositionSelectByTicket(g_CurrentPosition.ticket)) {
        Print("❌ Cannot close position - not found");
        return;
    }

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.position = g_CurrentPosition.ticket;
    request.symbol = SYMBOL_TRADED;
    request.volume = PositionGetDouble(POSITION_VOLUME);
    request.type = (g_CurrentPosition.direction == 1) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
    request.price = (g_CurrentPosition.direction == 1) ?
                    SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_BID) :
                    SymbolInfoDouble(SYMBOL_TRADED, SYMBOL_ASK);
    request.deviation = 10;
    request.magic = MAGIC_NUMBER;
    request.comment = reason;

    if(OrderSend(request, result)) {
        if(result.retcode == TRADE_RETCODE_DONE) {
            Print("✅ Position CLOSED: ", reason);

            // Calcul profit
            double exit_price = result.price;
            double profit_pips = 0.0;
            double r_multiple = 0.0;

            if(g_CurrentPosition.direction == 1) {
                profit_pips = exit_price - g_CurrentPosition.entry_price;
            }
            else {
                profit_pips = g_CurrentPosition.entry_price - exit_price;
            }

            if(g_CurrentPosition.initial_risk_pips > 0) {
                r_multiple = profit_pips / g_CurrentPosition.initial_risk_pips;
            }

            Print("   Entry: ", DoubleToString(g_CurrentPosition.entry_price, _Digits));
            Print("   Exit: ", DoubleToString(exit_price, _Digits));
            Print("   Profit: ", DoubleToString(profit_pips, 1), " pips");
            Print("   R Multiple: ", (r_multiple > 0 ? "+" : ""), DoubleToString(r_multiple, 2), "R");

            // Update statistics
            UpdateTradeStatistics(r_multiple);

            // Log to CSV
            LogTradeExit(exit_price, r_multiple);

            // Check SHAP trigger
            CheckSHAPTrigger();

            // Reset position info
            g_PositionOpen = false;
            ResetPositionInfo();
        }
        else {
            Print("⚠️ Close position warning: ", result.retcode, " - ", result.comment);
        }
    }
    else {
        Print("❌ Close position FAILED: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Initialize position info après ouverture                         |
//+------------------------------------------------------------------+
void InitializePositionInfo(ulong ticket, int direction, double entry_price,
                           double sl_price, int votes_h4, int votes_h1,
                           int votes_m15, int votes_macro, int votes_total) {
    g_CurrentPosition.ticket = ticket;
    g_CurrentPosition.direction = direction;
    g_CurrentPosition.entry_price = entry_price;
    g_CurrentPosition.initial_sl = sl_price;
    g_CurrentPosition.current_trailing_level = 0;
    g_CurrentPosition.entry_time = TimeCurrent();

    // Calcul initial risk en pips
    g_CurrentPosition.initial_risk_pips = MathAbs(entry_price - sl_price);

    // Sauvegarde votes entry
    g_CurrentPosition.votes_h4 = votes_h4;
    g_CurrentPosition.votes_h1 = votes_h1;
    g_CurrentPosition.votes_m15 = votes_m15;
    g_CurrentPosition.votes_macro = votes_macro;
    g_CurrentPosition.votes_total = votes_total;

    // Store indicator states
    StoreIndicatorStates(direction, g_CurrentPosition.indicators_state);

    g_PositionOpen = true;

    Print("📍 POSITION INFO INITIALIZED:");
    Print("   Ticket: ", ticket);
    Print("   Direction: ", (direction == 1 ? "BUY" : "SELL"));
    Print("   Entry: ", DoubleToString(entry_price, _Digits));
    Print("   SL: ", DoubleToString(sl_price, _Digits));
    Print("   Risk: ", DoubleToString(g_CurrentPosition.initial_risk_pips, 1), " pips = 1R");
    Print("   Votes: H4=", votes_h4, "/5, H1=", votes_h1, "/8, M15=", votes_m15, "/6, Macro=", votes_macro, "/2, Total=", votes_total, "/21");
}

//+------------------------------------------------------------------+

#endif // HERMES_TRAILINGSTOP_MQH
