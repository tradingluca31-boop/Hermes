//+------------------------------------------------------------------+
//| Hermes_Logger.mqh                                                 |
//| Logging CSV - 3 fichiers                                          |
//| 1. trades_detailed  2. shap_analysis  3. summary                  |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#include "Hermes_Config.mqh"

//+------------------------------------------------------------------+
//| CSV PATHS                                                         |
//+------------------------------------------------------------------+
string GetCSVPath(string filename) {
    return "..\\..\\logs\\" + filename;
}

//+------------------------------------------------------------------+
//| 1. HERMES_TRADES_DETAILED.CSV                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialise fichier trades detailed (header si n'existe pas)      |
//+------------------------------------------------------------------+
bool InitTradesDetailedCSV() {
    string filepath = GetCSVPath(CSV_Trades_Detailed);

    // Check si fichier existe déjà
    int file_handle = FileOpen(filepath, FILE_READ|FILE_ANSI);

    if(file_handle != INVALID_HANDLE) {
        // Fichier existe déjà
        FileClose(file_handle);
        Print("✅ Trades detailed CSV already exists");
        return true;
    }

    // Créer nouveau fichier avec header
    file_handle = FileOpen(filepath, FILE_WRITE|FILE_ANSI|FILE_CSV, ',');

    if(file_handle == INVALID_HANDLE) {
        Print("❌ Cannot create trades detailed CSV: ", GetLastError());
        return false;
    }

    // Header
    string header = "trade_id,entry_date,entry_time,direction,entry_price,sl,exit_price,result,r_multiple,duration_hours,";

    // 21 indicateurs
    header += "adx_h4,ema_cross_h4,ema_50_200_h4,price_ema21_h4,supertrend_h4,";  // H4 (5)
    header += "ema_cross_h1,macd_h1,rsi_h1,sar_h1,stoch_h1,bollinger_h1,vol_momentum_h1,donchian_h1,";  // H1 (8)
    header += "vwap_m15,orderflow_m15,volatility_m15,tick_m15,eurusd_m15,spread_m15,";  // M15 (6)
    header += "cot,atr_percentile,";  // Macro (2)

    // Votes
    header += "votes_h4,votes_h1,votes_m15,votes_macro,votes_total";

    FileWriteString(file_handle, header + "\n");
    FileClose(file_handle);

    Print("✅ Trades detailed CSV created with header");

    return true;
}

//+------------------------------------------------------------------+
//| Log trade entry                                                   |
//+------------------------------------------------------------------+
void LogTradeEntry() {
    // Entry déjà loggé dans g_CurrentPosition
    // Rien à faire maintenant, on log à la clôture
}

//+------------------------------------------------------------------+
//| Log trade exit (écriture complète dans CSV)                      |
//+------------------------------------------------------------------+
void LogTradeExit(double exit_price, double r_multiple) {
    string filepath = GetCSVPath(CSV_Trades_Detailed);

    int file_handle = FileOpen(filepath, FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV, ',');

    if(file_handle == INVALID_HANDLE) {
        Print("❌ Cannot open trades detailed CSV: ", GetLastError());
        return;
    }

    // Aller à la fin du fichier
    FileSeek(file_handle, 0, SEEK_END);

    // Préparer ligne CSV
    string line = "";

    // trade_id
    line += IntegerToString(g_TotalTrades) + ",";

    // entry_date, entry_time
    MqlDateTime dt;
    TimeToStruct(g_CurrentPosition.entry_time, dt);
    line += StringFormat("%04d-%02d-%02d,", dt.year, dt.mon, dt.day);
    line += StringFormat("%02d:%02d:%02d,", dt.hour, dt.min, dt.sec);

    // direction
    line += (g_CurrentPosition.direction == 1 ? "BUY" : "SELL") + ",";

    // entry_price
    line += DoubleToString(g_CurrentPosition.entry_price, _Digits) + ",";

    // sl
    line += DoubleToString(g_CurrentPosition.initial_sl, _Digits) + ",";

    // exit_price
    line += DoubleToString(exit_price, _Digits) + ",";

    // result
    line += (r_multiple > 0 ? "WIN" : "LOSS") + ",";

    // r_multiple
    line += DoubleToString(r_multiple, 2) + ",";

    // duration_hours
    double duration_hours = (TimeCurrent() - g_CurrentPosition.entry_time) / 3600.0;
    line += DoubleToString(duration_hours, 1) + ",";

    // 21 indicateurs (1/0)
    for(int i = 0; i < NUM_INDICATORS_TOTAL; i++) {
        line += IntegerToString(g_CurrentPosition.indicators_state[i]) + ",";
    }

    // votes
    line += IntegerToString(g_CurrentPosition.votes_h4) + ",";
    line += IntegerToString(g_CurrentPosition.votes_h1) + ",";
    line += IntegerToString(g_CurrentPosition.votes_m15) + ",";
    line += IntegerToString(g_CurrentPosition.votes_macro) + ",";
    line += IntegerToString(g_CurrentPosition.votes_total);

    FileWriteString(file_handle, line + "\n");
    FileClose(file_handle);

    Print("✅ Trade logged to CSV: ", CSV_Trades_Detailed);
}

//+------------------------------------------------------------------+
//| 2. HERMES_SHAP_ANALYSIS.CSV                                      |
//+------------------------------------------------------------------+

// Noms indicateurs (pour SHAP analysis)
string indicator_names[NUM_INDICATORS_TOTAL] = {
    // H4 (5)
    "adx_h4", "ema_cross_h4", "ema_50_200_h4", "price_ema21_h4", "supertrend_h4",
    // H1 (8)
    "ema_cross_h1", "macd_h1", "rsi_h1", "sar_h1", "stoch_h1", "bollinger_h1", "vol_momentum_h1", "donchian_h1",
    // M15 (6)
    "vwap_m15", "orderflow_m15", "volatility_m15", "tick_m15", "eurusd_m15", "spread_m15",
    // Macro (2)
    "cot", "atr_percentile"
};

//+------------------------------------------------------------------+
//| Structure pour stocker stats indicateur                          |
//+------------------------------------------------------------------+
struct SIndicatorStats {
    string name;
    int    participated_count;
    int    win_count;
    int    loss_count;
    double sum_r_when_present;
    double sum_r_when_absent;
    int    count_when_absent;
};

//+------------------------------------------------------------------+
//| Calcule SHAP analysis (appelé tous les 50 trades)                |
//+------------------------------------------------------------------+
void RunSHAPAnalysis() {
    Print("🔬 Running SHAP analysis...");

    // Parse trades detailed CSV
    string filepath_trades = GetCSVPath(CSV_Trades_Detailed);
    int file_trades = FileOpen(filepath_trades, FILE_READ|FILE_ANSI|FILE_CSV, ',');

    if(file_trades == INVALID_HANDLE) {
        Print("❌ Cannot open trades CSV for SHAP analysis");
        return;
    }

    // Skip header
    string header = FileReadString(file_trades);

    // Parse tous les trades
    SIndicatorStats stats[NUM_INDICATORS_TOTAL];

    for(int i = 0; i < NUM_INDICATORS_TOTAL; i++) {
        stats[i].name = indicator_names[i];
        stats[i].participated_count = 0;
        stats[i].win_count = 0;
        stats[i].loss_count = 0;
        stats[i].sum_r_when_present = 0.0;
        stats[i].sum_r_when_absent = 0.0;
        stats[i].count_when_absent = 0;
    }

    int total_trades_analyzed = 0;

    while(!FileIsEnding(file_trades)) {
        // Parse ligne
        int trade_id = (int)StringToInteger(FileReadString(file_trades));
        string entry_date = FileReadString(file_trades);
        string entry_time = FileReadString(file_trades);
        string direction = FileReadString(file_trades);
        double entry_price = StringToDouble(FileReadString(file_trades));
        double sl = StringToDouble(FileReadString(file_trades));
        double exit_price = StringToDouble(FileReadString(file_trades));
        string result = FileReadString(file_trades);
        double r_multiple = StringToDouble(FileReadString(file_trades));
        double duration = StringToDouble(FileReadString(file_trades));

        if(trade_id == 0) continue;  // Ligne vide

        // Parse 21 indicateurs
        int indicators[NUM_INDICATORS_TOTAL];
        for(int i = 0; i < NUM_INDICATORS_TOTAL; i++) {
            indicators[i] = (int)StringToInteger(FileReadString(file_trades));
        }

        // Parse votes (skip)
        for(int i = 0; i < 5; i++) {
            FileReadString(file_trades);
        }

        // Update stats
        for(int i = 0; i < NUM_INDICATORS_TOTAL; i++) {
            if(indicators[i] == 1) {  // Indicateur présent
                stats[i].participated_count++;

                if(r_multiple > 0)
                    stats[i].win_count++;
                else
                    stats[i].loss_count++;

                stats[i].sum_r_when_present += r_multiple;
            }
            else {  // Indicateur absent
                stats[i].count_when_absent++;
                stats[i].sum_r_when_absent += r_multiple;
            }
        }

        total_trades_analyzed++;
    }

    FileClose(file_trades);

    // Génère SHAP CSV
    string filepath_shap = GetCSVPath(CSV_SHAP_Analysis);
    int file_shap = FileOpen(filepath_shap, FILE_WRITE|FILE_ANSI|FILE_CSV, ',');

    if(file_shap == INVALID_HANDLE) {
        Print("❌ Cannot create SHAP CSV");
        return;
    }

    // Header
    string shap_header = "date,total_trades,indicator,weight_current,participated_count,participated_percent,";
    shap_header += "win_count,loss_count,win_rate,avg_r_when_present,avg_r_when_absent,";
    shap_header += "contribution_delta,shap_value,recommended_weight,status";

    FileWriteString(file_shap, shap_header + "\n");

    // Pour chaque indicateur
    for(int i = 0; i < NUM_INDICATORS_TOTAL; i++) {
        double avg_r_present = (stats[i].participated_count > 0) ?
                               stats[i].sum_r_when_present / stats[i].participated_count : 0.0;

        double avg_r_absent = (stats[i].count_when_absent > 0) ?
                              stats[i].sum_r_when_absent / stats[i].count_when_absent : 0.0;

        double contribution_delta = avg_r_present - avg_r_absent;

        double win_rate = (stats[i].participated_count > 0) ?
                         (double)stats[i].win_count / stats[i].participated_count : 0.0;

        double participated_percent = (total_trades_analyzed > 0) ?
                                     (double)stats[i].participated_count / total_trades_analyzed * 100.0 : 0.0;

        // Recommandation poids et status
        double recommended_weight = 1.0;
        string status = "MEDIUM";

        if(contribution_delta > 0.8) {
            recommended_weight = 3.0;
            status = "CRITICAL";
        }
        else if(contribution_delta > 0.5) {
            recommended_weight = 2.5;
            status = "HIGH";
        }
        else if(contribution_delta > 0.2) {
            recommended_weight = 1.5;
            status = "MEDIUM";
        }
        else if(contribution_delta > 0.05) {
            recommended_weight = 1.0;
            status = "LOW";
        }
        else if(contribution_delta >= -0.05) {
            recommended_weight = 0.5;
            status = "NEUTRAL";
        }
        else if(contribution_delta >= -0.15) {
            recommended_weight = 0.0;
            status = "WEAK";
        }
        else {
            recommended_weight = 0.0;
            status = "REMOVE";
        }

        // SHAP value (simplification: = contribution_delta normalisé)
        double shap_value = contribution_delta / 10.0;  // Normalisé

        // Ligne CSV
        string line = "";
        line += TimeToString(TimeCurrent(), TIME_DATE) + ",";
        line += IntegerToString(total_trades_analyzed) + ",";
        line += stats[i].name + ",";
        line += DoubleToString(Indicator_Weights[i], 1) + ",";
        line += IntegerToString(stats[i].participated_count) + ",";
        line += DoubleToString(participated_percent, 1) + ",";
        line += IntegerToString(stats[i].win_count) + ",";
        line += IntegerToString(stats[i].loss_count) + ",";
        line += DoubleToString(win_rate * 100, 1) + ",";
        line += DoubleToString(avg_r_present, 2) + ",";
        line += DoubleToString(avg_r_absent, 2) + ",";
        line += DoubleToString(contribution_delta, 2) + ",";
        line += DoubleToString(shap_value, 3) + ",";
        line += DoubleToString(recommended_weight, 1) + ",";
        line += status;

        FileWriteString(file_shap, line + "\n");
    }

    FileClose(file_shap);

    Print("✅ SHAP analysis completed: ", total_trades_analyzed, " trades analyzed");
    Print("   CSV generated: ", CSV_SHAP_Analysis);
    Print("   🔍 Check file to identify best/worst indicators");

    // Génère summary
    GenerateSummaryCSV(total_trades_analyzed);
}

//+------------------------------------------------------------------+
//| 3. HERMES_SUMMARY.CSV                                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Génère summary CSV (métriques globales)                          |
//+------------------------------------------------------------------+
void GenerateSummaryCSV(int total_trades) {
    string filepath = GetCSVPath(CSV_Summary);
    int file_handle = FileOpen(filepath, FILE_WRITE|FILE_ANSI|FILE_CSV, ',');

    if(file_handle == INVALID_HANDLE) {
        Print("❌ Cannot create summary CSV");
        return;
    }

    // Header
    FileWriteString(file_handle, "metric,value\n");

    // Métriques trading
    FileWriteString(file_handle, "total_trades_analyzed," + IntegerToString(total_trades) + "\n");

    double overall_win_rate = (g_TotalTrades > 0) ?
                              (double)g_TotalWins / g_TotalTrades * 100.0 : 0.0;
    FileWriteString(file_handle, "overall_win_rate," + DoubleToString(overall_win_rate, 1) + "%\n");

    // TODO: Calculer avg_r et profit_factor depuis CSV

    // Comptage indicateurs par status (parse SHAP CSV)
    // TODO: Implémenter comptage

    FileClose(file_handle);

    Print("✅ Summary CSV generated: ", CSV_Summary);
}

//+------------------------------------------------------------------+
//| Check si time pour SHAP analysis                                 |
//+------------------------------------------------------------------+
void CheckSHAPTrigger() {
    if(!Enable_Auto_CSV_Export) return;

    // Trigger tous les X trades
    if(g_TotalTrades % SHAP_Analysis_Frequency == 0 && g_TotalTrades > 0) {
        if(g_TotalTrades >= SHAP_Min_Trades) {
            Print("🔬 SHAP ANALYSIS TRIGGER: ", g_TotalTrades, " trades reached");
            RunSHAPAnalysis();
        }
        else {
            Print("⏳ SHAP analysis pending: ", g_TotalTrades, "/", SHAP_Min_Trades, " trades (waiting for minimum)");
        }
    }
}

//+------------------------------------------------------------------+
