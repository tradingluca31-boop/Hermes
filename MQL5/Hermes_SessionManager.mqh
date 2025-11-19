//+------------------------------------------------------------------+
//| Hermes_SessionManager.mqh                                         |
//| Gestion Sessions, News Blackout, Weekend Risk                     |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#include "Hermes_Config.mqh"

//+------------------------------------------------------------------+
//| SESSION DETECTION                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Détecte session actuelle (heure Paris UTC+1)                     |
//+------------------------------------------------------------------+
ENUM_SESSION GetCurrentSession() {
    datetime current = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current, dt);

    // Convertir en heure Paris (UTC+1)
    // NOTE: À ajuster pour DST (heure d'été/hiver)
    int hour_paris = dt.hour + 1;
    if(hour_paris >= 24) hour_paris -= 24;

    // Asian Session: 01h00 - 09h00
    if(hour_paris >= 1 && hour_paris < 9)
        return SESSION_ASIAN;

    // London Session: 09h00 - 14h00
    else if(hour_paris >= 9 && hour_paris < 14)
        return SESSION_LONDON;

    // Overlap London-NY: 14h00 - 17h00 (MEILLEURE FENÊTRE)
    else if(hour_paris >= 14 && hour_paris < 17)
        return SESSION_OVERLAP;

    // New York Session: 17h00 - 22h00
    else if(hour_paris >= 17 && hour_paris < 22)
        return SESSION_NY;

    // Dead Zone: 22h00 - 01h00
    else
        return SESSION_DEAD;
}

//+------------------------------------------------------------------+
//| Vérifie si session est autorisée                                 |
//+------------------------------------------------------------------+
bool IsSessionAllowed(ENUM_SESSION session) {
    switch(session) {
        case SESSION_ASIAN:
            return Enable_Asian_Session;  // Normalement FALSE

        case SESSION_LONDON:
            return Enable_London_Session;

        case SESSION_OVERLAP:
            return Enable_Overlap_Session;

        case SESSION_NY:
            return Enable_NY_Session;

        case SESSION_DEAD:
            return false;  // Toujours interdit
    }

    return false;
}

//+------------------------------------------------------------------+
//| Get session name string                                           |
//+------------------------------------------------------------------+
string GetSessionName(ENUM_SESSION session) {
    switch(session) {
        case SESSION_ASIAN:    return "Asian (01h-09h)";
        case SESSION_LONDON:   return "London (09h-14h)";
        case SESSION_OVERLAP:  return "Overlap L-NY (14h-17h)";
        case SESSION_NY:       return "New York (17h-22h)";
        case SESSION_DEAD:     return "Dead Zone (22h-01h)";
    }
    return "Unknown";
}

//+------------------------------------------------------------------+
//| NEWS BLACKOUT                                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Charge calendrier économique depuis CSV                          |
//+------------------------------------------------------------------+
bool LoadEconomicCalendar() {
    string filename = "macro_events.csv";
    string filepath = "..\\..\\data\\" + filename;

    int file_handle = FileOpen(filepath, FILE_READ|FILE_CSV|FILE_ANSI, ',');

    if(file_handle == INVALID_HANDLE) {
        Print("⚠️ Economic calendar file not found: ", filepath);
        Print("   News blackout will be DISABLED");
        return false;
    }

    // Clear existing data
    ArrayResize(g_EconomicCalendar, 0);
    g_NumEconomicEvents = 0;

    // Skip header
    string header = FileReadString(file_handle);

    // Parse CSV
    while(!FileIsEnding(file_handle)) {
        string date_str = FileReadString(file_handle);
        string time_str = FileReadString(file_handle);
        string event_name = FileReadString(file_handle);
        string impact = FileReadString(file_handle);

        if(StringLen(date_str) == 0) continue;

        // Filter: HIGH impact only
        if(impact != "HIGH") continue;

        // Parse datetime
        string datetime_str = date_str + " " + time_str;
        datetime event_time = StringToTime(datetime_str);

        // Add to array
        ArrayResize(g_EconomicCalendar, g_NumEconomicEvents + 1);

        g_EconomicCalendar[g_NumEconomicEvents].event_time = event_time;
        g_EconomicCalendar[g_NumEconomicEvents].event_name = event_name;
        g_EconomicCalendar[g_NumEconomicEvents].impact = impact;

        g_NumEconomicEvents++;
    }

    FileClose(file_handle);

    Print("✅ Economic calendar loaded: ", g_NumEconomicEvents, " HIGH impact events");

    return true;
}

//+------------------------------------------------------------------+
//| Vérifie si dans période news blackout                            |
//+------------------------------------------------------------------+
bool IsNewsBlackout() {
    if(g_NumEconomicEvents == 0) return false;  // Pas de data, pas de blackout

    datetime current = TimeCurrent();
    int blackout_seconds = News_Blackout_Hours * 3600;

    // Check tous les événements
    for(int i = 0; i < g_NumEconomicEvents; i++) {
        datetime event_time = g_EconomicCalendar[i].event_time;

        // Event dans le futur proche ?
        if(event_time > current + 7 * 24 * 3600) continue;  // Skip si > 1 semaine

        // Event dans le passé lointain ?
        if(event_time < current - 7 * 24 * 3600) continue;  // Skip si > 1 semaine passée

        datetime blackout_start = event_time - blackout_seconds;
        datetime blackout_end = event_time + blackout_seconds;

        if(current >= blackout_start && current <= blackout_end) {
            Print("🚫 NEWS BLACKOUT ACTIVE:");
            Print("   Event: ", g_EconomicCalendar[i].event_name);
            Print("   Time: ", TimeToString(event_time, TIME_DATE|TIME_MINUTES));
            Print("   Blackout: ", News_Blackout_Hours, "h before/after");

            return true;
        }
    }

    return false;
}

//+------------------------------------------------------------------+
//| WEEKEND RISK MANAGEMENT                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Vérifie si vendredi soir (block nouveaux trades)                 |
//+------------------------------------------------------------------+
bool IsFridayBlock() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    // Vendredi (5) après 20h00
    if(dt.day_of_week == 5 && dt.hour >= Weekend_Block_Hour_Friday) {
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Vérifie si dimanche matin (attente avant trading)                |
//+------------------------------------------------------------------+
bool IsSundayWait() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    // Dimanche (0) avant 23h00
    if(dt.day_of_week == 0 && dt.hour < Weekend_Allow_Hour_Sunday) {
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Vérifie weekend proximity (combine vendredi + dimanche)          |
//+------------------------------------------------------------------+
bool IsWeekendBlock() {
    if(IsFridayBlock()) {
        // Print("⚠️ Weekend block: Friday after ", Weekend_Block_Hour_Friday, "h");
        return true;
    }

    if(IsSundayWait()) {
        // Print("⚠️ Weekend block: Sunday before ", Weekend_Allow_Hour_Sunday, "h");
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| GAP DETECTION                                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Détecte gap weekend (prix open vs close précédent)               |
//+------------------------------------------------------------------+
bool DetectGap() {
    double close_prev = iClose(SYMBOL_TRADED, TF_TIMING, 1);
    double open_curr = iOpen(SYMBOL_TRADED, TF_TIMING, 0);

    if(close_prev == 0 || open_curr == 0) return false;

    double gap_size = MathAbs(open_curr - close_prev);

    // ATR H4 pour référence
    double atr_h4[];
    ArraySetAsSeries(atr_h4, true);

    if(CopyBuffer(h_ATR_H4, 0, 0, 1, atr_h4) <= 0) return false;

    double gap_threshold = atr_h4[0] * Gap_Detection_ATR_Mult;

    if(gap_size > gap_threshold) {
        Print("⚠️ GAP DETECTED:");
        Print("   Size: ", DoubleToString(gap_size, _Digits), " (", DoubleToString(gap_size / _Point, 1), " pips)");
        Print("   Threshold: ", DoubleToString(gap_threshold, _Digits), " (ATR × ", Gap_Detection_ATR_Mult, ")");
        Print("   Wait 2-3h for stabilization");

        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| MOMENTUM REGIME DETECTION                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Détecte régime momentum (4 métriques → score /8)                 |
//+------------------------------------------------------------------+
ENUM_REGIME DetectMomentumRegime() {
    int score = 0;

    //===================================================================
    // MÉTRIQUE 1: ADX (0-2 points)
    //===================================================================
    double adx[];
    ArraySetAsSeries(adx, true);

    if(CopyBuffer(h_ADX_H4, 0, 0, 1, adx) > 0) {
        if(adx[0] > 30.0)
            score += 2;  // Very strong
        else if(adx[0] > 25.0)
            score += 1;  // Strong
        // else 0 points (weak/range)
    }

    //===================================================================
    // MÉTRIQUE 2: ATR Ratio (0-2 points)
    //===================================================================
    double atr_h4[];
    ArraySetAsSeries(atr_h4, true);

    if(CopyBuffer(h_ATR_H4, 0, 0, 51, atr_h4) > 0) {
        double atr_current = atr_h4[0];

        // Moyenne ATR 50 périodes
        double sum_atr = 0.0;
        for(int i = 1; i < 51; i++) {
            sum_atr += atr_h4[i];
        }
        double atr_avg = sum_atr / 50.0;

        double atr_ratio = atr_current / atr_avg;

        if(atr_ratio > 1.3)
            score += 2;  // High volatility expansion
        else if(atr_ratio > 1.1)
            score += 1;  // Moderate expansion
        // else 0 points
    }

    //===================================================================
    // MÉTRIQUE 3: R² Regression (0-2 points)
    //===================================================================
    double close[];
    ArraySetAsSeries(close, true);

    if(CopyClose(SYMBOL_TRADED, TF_MACRO, 0, 21, close) > 0) {
        // Regression linéaire sur 20 périodes
        double sum_x = 0.0, sum_y = 0.0, sum_xy = 0.0, sum_x2 = 0.0, sum_y2 = 0.0;

        for(int i = 0; i < 20; i++) {
            double x = i;
            double y = close[20 - i - 1];  // Inverser ordre (plus ancien → récent)

            sum_x += x;
            sum_y += y;
            sum_xy += x * y;
            sum_x2 += x * x;
            sum_y2 += y * y;
        }

        double n = 20.0;
        double r_num = (n * sum_xy - sum_x * sum_y);
        double r_den = MathSqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y));

        double r = (r_den != 0) ? r_num / r_den : 0.0;
        double r_squared = r * r;

        if(r_squared > 0.7)
            score += 2;  // Strong trend
        else if(r_squared > 0.5)
            score += 1;  // Moderate trend
        // else 0 points
    }

    //===================================================================
    // MÉTRIQUE 4: Efficiency Ratio Kaufman (0-2 points)
    //===================================================================
    if(CopyClose(SYMBOL_TRADED, TF_MACRO, 0, 21, close) > 0) {
        // ER = Direction / Distance
        double direction = MathAbs(close[0] - close[20]);

        double distance = 0.0;
        for(int i = 0; i < 20; i++) {
            distance += MathAbs(close[i] - close[i + 1]);
        }

        double er = (distance > 0) ? direction / distance : 0.0;

        if(er > 0.7)
            score += 2;  // Very efficient (strong directional move)
        else if(er > 0.5)
            score += 1;  // Moderate efficiency
        // else 0 points
    }

    //===================================================================
    // CLASSIFICATION (Score /8)
    //===================================================================
    Print("📊 MOMENTUM REGIME: Score ", score, "/8");

    if(score >= Regime_Strong_Threshold) {  // ≥6/8
        Print("   → STRONG TREND (boost +20%, min votes 13/21)");
        return REGIME_STRONG_TREND;
    }
    else if(score >= Regime_Ranging_Threshold) {  // 4-5/8
        Print("   → WEAK TREND (normal, min votes 14/21)");
        return REGIME_WEAK_TREND;
    }
    else {  // <4/8
        Print("   → RANGING (réduction 50%, min votes 17/21)");
        return REGIME_RANGING;
    }
}

//+------------------------------------------------------------------+
//| Ajuste minimum votes selon régime                                |
//+------------------------------------------------------------------+
int GetAdjustedMinVotes(ENUM_REGIME regime) {
    switch(regime) {
        case REGIME_STRONG_TREND:
            return 13;  // Moins exigeant (conditions idéales)

        case REGIME_WEAK_TREND:
            return Min_Votes_Total;  // Normal (14/21)

        case REGIME_RANGING:
            return 17;  // Très sélectif (conditions difficiles)
    }

    return Min_Votes_Total;
}

//+------------------------------------------------------------------+
//| PROTECTIONS COMBINÉES                                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check toutes les protections temporelles                         |
//+------------------------------------------------------------------+
bool CanTradeNow() {
    // 1. Session
    ENUM_SESSION session = GetCurrentSession();

    if(!IsSessionAllowed(session)) {
        // Print("⛔ Session not allowed: ", GetSessionName(session));
        return false;
    }

    // 2. Weekend
    if(IsWeekendBlock()) {
        return false;
    }

    // 3. News blackout
    if(IsNewsBlackout()) {
        return false;
    }

    // 4. Gap detection (seulement premiers trades du lundi)
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    if(dt.day_of_week == 1 && dt.hour < 3) {  // Lundi avant 3h
        if(DetectGap()) {
            return false;
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Print session info (debug/monitoring)                            |
//+------------------------------------------------------------------+
void PrintSessionInfo() {
    ENUM_SESSION session = GetCurrentSession();
    ENUM_REGIME regime = DetectMomentumRegime();

    Print("╔════════════════════════════════════════════╗");
    Print("║         SESSION & REGIME STATUS            ║");
    Print("╠════════════════════════════════════════════╣");
    Print("║ Session: ", GetSessionName(session));
    Print("║ Allowed: ", (IsSessionAllowed(session) ? "YES ✅" : "NO ⛔"));
    Print("║ Multiplier: ×", DoubleToString(GetSessionMultiplier(session), 1));
    Print("╠════════════════════════════════════════════╣");

    string regime_str = "";
    if(regime == REGIME_STRONG_TREND)
        regime_str = "STRONG TREND 🔥";
    else if(regime == REGIME_WEAK_TREND)
        regime_str = "WEAK TREND";
    else
        regime_str = "RANGING ⚠️";

    Print("║ Regime: ", regime_str);
    Print("║ Multiplier: ×", DoubleToString(GetRegimeMultiplier(regime), 1));
    Print("║ Min Votes: ", GetAdjustedMinVotes(regime), "/21");
    Print("╠════════════════════════════════════════════╣");
    Print("║ News Blackout: ", (IsNewsBlackout() ? "YES 🚫" : "NO ✅"));
    Print("║ Weekend Block: ", (IsWeekendBlock() ? "YES ⚠️" : "NO ✅"));
    Print("╚════════════════════════════════════════════╝");
}

//+------------------------------------------------------------------+
