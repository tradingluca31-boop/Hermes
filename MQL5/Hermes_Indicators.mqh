//+------------------------------------------------------------------+
//| Hermes_Indicators.mqh                                             |
//| 21 Indicateurs Techniques Multi-Timeframe                         |
//| H4 (5) + H1 (8) + M15 (6) + Macro (2)                             |
//+------------------------------------------------------------------+
#property copyright "Hermès Trading System"
#property version   "2.50"
#property strict

#ifndef HERMES_INDICATORS_MQH
#define HERMES_INDICATORS_MQH

#include "Hermes_Config.mqh"

//+------------------------------------------------------------------+
//| INDICATEUR 1: ADX H4                                             |
//| Filtre trend vs range - ADX > 25                                 |
//+------------------------------------------------------------------+
bool Indicator_ADX_H4(int direction) {
    double adx_buffer[];
    ArraySetAsSeries(adx_buffer, true);

    if(CopyBuffer(h_ADX_H4, 0, 0, 2, adx_buffer) <= 0) {
        Print("❌ Error copying ADX H4 buffer");
        return false;
    }

    // Condition: ADX > 25 (pour BUY et SELL)
    bool valid = (adx_buffer[0] > 25.0);

    return valid;
}

//+------------------------------------------------------------------+
//| INDICATEUR 2: EMA 21/55 Cross H4                                 |
//| Direction principale du marché                                   |
//+------------------------------------------------------------------+
bool Indicator_EMA_Cross_H4(int direction) {
    double ema21[], ema55[];
    ArraySetAsSeries(ema21, true);
    ArraySetAsSeries(ema55, true);

    if(CopyBuffer(h_EMA21_H4, 0, 0, 2, ema21) <= 0) return false;
    if(CopyBuffer(h_EMA55_H4, 0, 0, 2, ema55) <= 0) return false;

    if(direction == 1) {  // BUY
        return (ema21[0] > ema55[0]);
    }
    else if(direction == -1) {  // SELL
        return (ema21[0] < ema55[0]);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 3: EMA 50/200 H4                                      |
//| Trend long terme (Golden/Death Cross)                            |
//+------------------------------------------------------------------+
bool Indicator_EMA_50_200_H4(int direction) {
    double ema50[], ema200[];
    ArraySetAsSeries(ema50, true);
    ArraySetAsSeries(ema200, true);

    if(CopyBuffer(h_EMA50_H4, 0, 0, 2, ema50) <= 0) return false;
    if(CopyBuffer(h_EMA200_H4, 0, 0, 2, ema200) <= 0) return false;

    if(direction == 1) {  // BUY
        return (ema50[0] > ema200[0]);
    }
    else if(direction == -1) {  // SELL
        return (ema50[0] < ema200[0]);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 4: Prix vs EMA21 H4                                   |
//| Force haussière/baissière immédiate                              |
//+------------------------------------------------------------------+
bool Indicator_Price_EMA21_H4(int direction) {
    double ema21[], close[];
    ArraySetAsSeries(ema21, true);
    ArraySetAsSeries(close, true);

    if(CopyBuffer(h_EMA21_H4, 0, 0, 2, ema21) <= 0) return false;
    if(CopyClose(SYMBOL_TRADED, TF_MACRO, 0, 2, close) <= 0) return false;

    if(direction == 1) {  // BUY
        return (close[0] > ema21[0]);
    }
    else if(direction == -1) {  // SELL
        return (close[0] < ema21[0]);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 5: Supertrend H4                                      |
//| Confirmation visuelle trend (ATR 10, Factor 3)                   |
//+------------------------------------------------------------------+
bool Indicator_Supertrend_H4(int direction) {
    // Calcul Supertrend custom
    double high[], low[], close[], atr[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(atr, true);

    if(CopyHigh(SYMBOL_TRADED, TF_MACRO, 0, 3, high) <= 0) return false;
    if(CopyLow(SYMBOL_TRADED, TF_MACRO, 0, 3, low) <= 0) return false;
    if(CopyClose(SYMBOL_TRADED, TF_MACRO, 0, 3, close) <= 0) return false;
    if(CopyBuffer(h_ATR_H4, 0, 0, 3, atr) <= 0) return false;

    // Supertrend formula
    double factor = 3.0;
    double hl_avg = (high[0] + low[0]) / 2.0;

    double upperband = hl_avg + (factor * atr[0]);
    double lowerband = hl_avg - (factor * atr[0]);

    // Signal basique: prix vs bandes
    if(direction == 1) {  // BUY
        return (close[0] > lowerband);
    }
    else if(direction == -1) {  // SELL
        return (close[0] < upperband);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 6: EMA Cross Signal H1                                |
//| FIXED: Position relative OU croisement récent (10 bougies)       |
//| Valide si EMA21 > EMA55 (BUY) ou croisement récent               |
//+------------------------------------------------------------------+
bool Indicator_EMA_Cross_H1(int direction) {
    double ema21[], ema55[];
    ArraySetAsSeries(ema21, true);
    ArraySetAsSeries(ema55, true);

    if(CopyBuffer(h_EMA21_H1, 0, 0, 11, ema21) <= 0) return false;
    if(CopyBuffer(h_EMA55_H1, 0, 0, 11, ema55) <= 0) return false;

    // CONDITION 1: Position relative actuelle (tendance établie)
    bool position_valid = false;
    if(direction == 1) {  // BUY
        position_valid = (ema21[0] > ema55[0]);
    }
    else if(direction == -1) {  // SELL
        position_valid = (ema21[0] < ema55[0]);
    }

    // CONDITION 2: Croisement récent (bonus, lookback étendu à 10 bougies)
    bool cross_detected = false;
    for(int i = 0; i < 10; i++) {
        if(direction == 1) {  // BUY - Cross up
            if(ema21[i] > ema55[i] && ema21[i+1] <= ema55[i+1]) {
                cross_detected = true;
                break;
            }
        }
        else if(direction == -1) {  // SELL - Cross down
            if(ema21[i] < ema55[i] && ema21[i+1] >= ema55[i+1]) {
                cross_detected = true;
                break;
            }
        }
    }

    // Valide si position correcte OU croisement récent
    return (position_valid || cross_detected);
}

//+------------------------------------------------------------------+
//| INDICATEUR 7: MACD H1                                            |
//| Momentum haussier/baissier (12/26/9)                             |
//+------------------------------------------------------------------+
bool Indicator_MACD_H1(int direction) {
    double macd_main[], macd_signal[];
    ArraySetAsSeries(macd_main, true);
    ArraySetAsSeries(macd_signal, true);

    // MACD: buffer 0 = main, buffer 1 = signal
    if(CopyBuffer(h_MACD_H1, 0, 0, 2, macd_main) <= 0) return false;
    if(CopyBuffer(h_MACD_H1, 1, 0, 2, macd_signal) <= 0) return false;

    // Histogram = main - signal
    double histogram = macd_main[0] - macd_signal[0];

    if(direction == 1) {  // BUY
        return (histogram > 0);
    }
    else if(direction == -1) {  // SELL
        return (histogram < 0);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 8: RSI H1                                             |
//| INSTITUTIONAL VERSION: Wider zones for trend capture             |
//| BUY: RSI > 40 (bullish lean, catches trends + recoveries)        |
//| SELL: RSI < 60 (bearish lean, catches trends + rejections)       |
//+------------------------------------------------------------------+
bool Indicator_RSI_H1(int direction) {
    double rsi[];
    ArraySetAsSeries(rsi, true);

    if(CopyBuffer(h_RSI_H1, 0, 0, 2, rsi) <= 0) return false;

    if(direction == 1) {  // BUY
        // WIDENED: Was 50-70, now >40 (captures trending + oversold recovery)
        return (rsi[0] > 40.0);
    }
    else if(direction == -1) {  // SELL
        // WIDENED: Was 30-50, now <60 (captures trending + overbought rejection)
        return (rsi[0] < 60.0);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 9: Parabolic SAR H1                                   |
//| Confirmation trend (SAR < prix = BUY)                            |
//+------------------------------------------------------------------+
bool Indicator_SAR_H1(int direction) {
    double sar[], close[];
    ArraySetAsSeries(sar, true);
    ArraySetAsSeries(close, true);

    if(CopyBuffer(h_SAR_H1, 0, 0, 2, sar) <= 0) return false;
    if(CopyClose(SYMBOL_TRADED, TF_SETUP, 0, 2, close) <= 0) return false;

    if(direction == 1) {  // BUY
        return (sar[0] < close[0]);
    }
    else if(direction == -1) {  // SELL
        return (sar[0] > close[0]);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 10: Stochastic H1                                     |
//| INSTITUTIONAL VERSION: Trending + Cross + Extremes               |
//| BUY: %K > %D (trending bullish) OR oversold bounce (<20)         |
//| SELL: %K < %D (trending bearish) OR overbought rejection (>80)   |
//+------------------------------------------------------------------+
bool Indicator_Stochastic_H1(int direction) {
    double stoch_main[], stoch_signal[];
    ArraySetAsSeries(stoch_main, true);
    ArraySetAsSeries(stoch_signal, true);

    // Stochastic: buffer 0 = %K (main), buffer 1 = %D (signal)
    if(CopyBuffer(h_Stoch_H1, 0, 0, 3, stoch_main) <= 0) return false;
    if(CopyBuffer(h_Stoch_H1, 1, 0, 3, stoch_signal) <= 0) return false;

    if(direction == 1) {  // BUY
        // WIDENED: Accept trending (K>D) + oversold bounces
        bool trending_bullish = (stoch_main[0] > stoch_signal[0]);
        bool oversold_bounce = (stoch_main[0] < 20.0 && stoch_main[0] > stoch_main[1]);
        return (trending_bullish || oversold_bounce);
    }
    else if(direction == -1) {  // SELL
        // WIDENED: Accept trending (K<D) + overbought rejections
        bool trending_bearish = (stoch_main[0] < stoch_signal[0]);
        bool overbought_reject = (stoch_main[0] > 80.0 && stoch_main[0] < stoch_main[1]);
        return (trending_bearish || overbought_reject);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 11: Bollinger Width H1                                |
//| FIXED: Seuil réduit à 0.9× (volatilité normale ou expansion)     |
//| Valide si volatilité >= 90% de la moyenne (pas squeeze extrême)  |
//+------------------------------------------------------------------+
bool Indicator_Bollinger_Width_H1(int direction) {
    double bb_upper[], bb_lower[], bb_middle[];
    ArraySetAsSeries(bb_upper, true);
    ArraySetAsSeries(bb_lower, true);
    ArraySetAsSeries(bb_middle, true);

    // BB: buffer 0 = middle, 1 = upper, 2 = lower
    if(CopyBuffer(h_BB_H1, 1, 0, 21, bb_upper) <= 0) return false;
    if(CopyBuffer(h_BB_H1, 2, 0, 21, bb_lower) <= 0) return false;
    if(CopyBuffer(h_BB_H1, 0, 0, 21, bb_middle) <= 0) return false;

    // Calcul width actuel
    double current_width = (bb_upper[0] - bb_lower[0]) / bb_middle[0];

    // Moyenne width sur 20 périodes
    double sum_width = 0.0;
    for(int i = 1; i < 21; i++) {
        double width = (bb_upper[i] - bb_lower[i]) / bb_middle[i];
        sum_width += width;
    }
    double avg_width = sum_width / 20.0;

    // Valide si width >= 90% de la moyenne (évite seulement les squeezes extrêmes)
    bool valid_volatility = (current_width >= avg_width * 0.9);

    return valid_volatility;  // Valide pour BUY et SELL
}

//+------------------------------------------------------------------+
//| INDICATEUR 12: Volume Momentum H1                                |
//| FIXED: Simplifié - Volume × ΔPrice dans la bonne direction       |
//| OU volume supérieur à la moyenne (conviction institutionnelle)   |
//+------------------------------------------------------------------+
bool Indicator_Volume_Momentum_H1(int direction) {
    double close[];
    long volume[];
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(volume, true);

    if(CopyClose(SYMBOL_TRADED, TF_SETUP, 0, 21, close) <= 0) return false;
    if(CopyTickVolume(SYMBOL_TRADED, TF_SETUP, 0, 21, volume) <= 0) return false;

    // ΔPrice actuel
    double delta_price = close[0] - close[1];

    // Volume momentum actuel
    double vol_momentum_current = (double)volume[0] * delta_price;

    // Volume moyen sur 20 périodes
    double sum_vol = 0.0;
    for(int i = 1; i < 21; i++) {
        sum_vol += (double)volume[i];
    }
    double avg_vol = sum_vol / 20.0;

    // Volume actuel supérieur à 80% de la moyenne = conviction
    bool high_volume = ((double)volume[0] >= avg_vol * 0.8);

    if(direction == 1) {  // BUY
        // Momentum positif OU volume élevé avec mouvement haussier
        return (vol_momentum_current > 0 || (high_volume && delta_price > 0));
    }
    else if(direction == -1) {  // SELL
        // Momentum négatif OU volume élevé avec mouvement baissier
        return (vol_momentum_current < 0 || (high_volume && delta_price < 0));
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 13: Donchian Breakout H1                              |
//| FIXED: Période réduite à 10 + zone haute/basse (top/bottom 20%)  |
//| Valide si breakout OU dans la zone extrême du range              |
//+------------------------------------------------------------------+
bool Indicator_Donchian_H1(int direction) {
    double high[], low[], close[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);

    if(CopyHigh(SYMBOL_TRADED, TF_SETUP, 0, 11, high) <= 0) return false;
    if(CopyLow(SYMBOL_TRADED, TF_SETUP, 0, 11, low) <= 0) return false;
    if(CopyClose(SYMBOL_TRADED, TF_SETUP, 0, 2, close) <= 0) return false;

    // High(10) et Low(10) des 10 dernières bougies (période réduite)
    double highest = high[1];
    double lowest = low[1];

    for(int i = 2; i < 11; i++) {
        if(high[i] > highest) highest = high[i];
        if(low[i] < lowest) lowest = low[i];
    }

    double range = highest - lowest;
    double threshold_high = highest - (range * 0.20);  // Top 20%
    double threshold_low = lowest + (range * 0.20);    // Bottom 20%

    if(direction == 1) {  // BUY
        // Breakout OU dans la zone haute (top 20% du range)
        return (close[0] > highest || close[0] >= threshold_high);
    }
    else if(direction == -1) {  // SELL
        // Breakout OU dans la zone basse (bottom 20% du range)
        return (close[0] < lowest || close[0] <= threshold_low);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 14: VWAP M15 (🔥 CRITIQUE selon SHAP)                |
//| Contrôle acheteurs/vendeurs (reset daily)                        |
//+------------------------------------------------------------------+
// Variables globales VWAP
double g_VWAP_CumulPV = 0.0;
double g_VWAP_CumulVol = 0.0;
datetime g_VWAP_LastReset = 0;

bool Indicator_VWAP_M15(int direction) {
    // Reset à minuit (00h00)
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);

    datetime current_day = StringToTime(StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day));

    if(current_day != g_VWAP_LastReset) {
        g_VWAP_CumulPV = 0.0;
        g_VWAP_CumulVol = 0.0;
        g_VWAP_LastReset = current_day;
    }

    // Calcul VWAP intraday
    double high[], low[], close[];
    long volume[];

    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(volume, true);

    if(CopyHigh(SYMBOL_TRADED, TF_TIMING, 0, 1, high) <= 0) return false;
    if(CopyLow(SYMBOL_TRADED, TF_TIMING, 0, 1, low) <= 0) return false;
    if(CopyClose(SYMBOL_TRADED, TF_TIMING, 0, 1, close) <= 0) return false;
    if(CopyTickVolume(SYMBOL_TRADED, TF_TIMING, 0, 1, volume) <= 0) return false;

    // Typical price
    double typical_price = (high[0] + low[0] + close[0]) / 3.0;

    // Cumul
    g_VWAP_CumulPV += typical_price * (double)volume[0];
    g_VWAP_CumulVol += (double)volume[0];

    double vwap = (g_VWAP_CumulVol > 0) ? g_VWAP_CumulPV / g_VWAP_CumulVol : close[0];

    if(direction == 1) {  // BUY
        return (close[0] > vwap);
    }
    else if(direction == -1) {  // SELL
        return (close[0] < vwap);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 15: Order Flow Delta M15                              |
//| FIXED: Simplifié - Delta cumulatif positif/négatif suffit        |
//| Valide si pression achat/vente dans la bonne direction           |
//+------------------------------------------------------------------+
bool Indicator_OrderFlow_M15(int direction) {
    double close[];
    long volume[];

    ArraySetAsSeries(close, true);
    ArraySetAsSeries(volume, true);

    if(CopyClose(SYMBOL_TRADED, TF_TIMING, 0, 21, close) <= 0) return false;
    if(CopyTickVolume(SYMBOL_TRADED, TF_TIMING, 0, 21, volume) <= 0) return false;

    // Calcul delta cumulatif (simplification: uptick si close > close_prev)
    double delta_cumul = 0.0;

    for(int i = 0; i < 20; i++) {
        double delta_price = close[i] - close[i+1];

        if(delta_price > 0) {  // Uptick
            delta_cumul += (double)volume[i];
        }
        else if(delta_price < 0) {  // Downtick
            delta_cumul -= (double)volume[i];
        }
    }

    if(direction == 1) {  // BUY
        // Simplifié: delta positif = pression acheteuse
        return (delta_cumul > 0);
    }
    else if(direction == -1) {  // SELL
        // Simplifié: delta négatif = pression vendeuse
        return (delta_cumul < 0);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 16: Volatility Regime M15                             |
//| FIXED: Seuil réduit à 0.7× (évite seulement volatilité très basse)|
//| Valide si ATR >= 70% de la moyenne (conditions tradables)        |
//+------------------------------------------------------------------+
bool Indicator_Volatility_M15(int direction) {
    double atr[];
    ArraySetAsSeries(atr, true);

    if(CopyBuffer(h_ATR_M15, 0, 0, 51, atr) <= 0) return false;

    double atr_current = atr[0];

    // Moyenne ATR sur 50 périodes
    double sum_atr = 0.0;
    for(int i = 1; i < 51; i++) {
        sum_atr += atr[i];
    }
    double atr_avg = sum_atr / 50.0;

    // Valide si ATR >= 70% de la moyenne (évite seulement les marchés morts)
    bool valid_volatility = (atr_current >= atr_avg * 0.7);

    return valid_volatility;  // Valide pour BUY et SELL
}

//+------------------------------------------------------------------+
//| INDICATEUR 17: Tick Momentum M15                                 |
//| FIXED: Seuil réduit à 52% (majorité simple + petit biais)        |
//| Valide si légère majorité dans la direction du trade             |
//+------------------------------------------------------------------+
bool Indicator_Tick_Momentum_M15(int direction) {
    double close[];
    ArraySetAsSeries(close, true);

    if(CopyClose(SYMBOL_TRADED, TF_TIMING, 0, 21, close) <= 0) return false;

    int upticks = 0;
    int downticks = 0;

    for(int i = 0; i < 20; i++) {
        double delta = close[i] - close[i+1];

        if(delta > 0)
            upticks++;
        else if(delta < 0)
            downticks++;
    }

    int total = upticks + downticks;
    if(total == 0) return false;

    double uptick_ratio = (double)upticks / total;
    double downtick_ratio = (double)downticks / total;

    if(direction == 1) {  // BUY
        // Seuil réduit: majorité simple avec léger biais (52%)
        return (uptick_ratio >= 0.52);
    }
    else if(direction == -1) {  // SELL
        // Seuil réduit: majorité simple avec léger biais (52%)
        return (downtick_ratio >= 0.52);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 18: EURUSD Correlation M15                            |
//| Macro alignment (EURUSD en hausse/baisse)                        |
//+------------------------------------------------------------------+
bool Indicator_EURUSD_Corr_M15(int direction) {
    double close_eurusd[];
    ArraySetAsSeries(close_eurusd, true);

    // Copy EURUSD M15 close
    if(CopyClose("EURUSD", TF_TIMING, 0, 3, close_eurusd) <= 0) {
        // ⚠️ OPTIONAL INDICATOR: EURUSD data not available
        // Returns FALSE (= 0 votes) which is NEUTRAL in progressive counting
        // This allows trading even without EURUSD correlation data
        //
        // TO ADD EURUSD DATA:
        // 1. In MetaTrader 5: View → Market Watch (Ctrl+M)
        // 2. Right-click → Symbols → Forex → EUR → EURUSD → Show
        // 3. Right-click EURUSD → Charts → Refresh historical data
        // 4. Restart backtest
        return false;  // Neutral vote (doesn't block trades)
    }

    // Direction EURUSD
    double delta_eurusd = close_eurusd[0] - close_eurusd[1];

    if(direction == 1) {  // BUY - Gold corrélé positivement avec EURUSD
        return (delta_eurusd > 0);
    }
    else if(direction == -1) {  // SELL
        return (delta_eurusd < 0);
    }

    return false;
}

//+------------------------------------------------------------------+
//| INDICATEUR 19: Effective Spread M15                              |
//| Liquidité élevée (spread < moyenne)                              |
//+------------------------------------------------------------------+
bool Indicator_Effective_Spread_M15(int direction) {
    // Calcul spread actuel
    double current_spread = GetCurrentSpreadPips();

    // Calcul spread moyen sur 20 bougies
    // (simplification: on suppose spread stable, sinon stocker historique)
    double avg_spread = current_spread;  // TODO: Implémenter historique spread

    // Condition: spread < moyenne (bonne liquidité)
    bool good_liquidity = (current_spread <= avg_spread);

    return good_liquidity;  // Valide pour BUY et SELL
}

//+------------------------------------------------------------------+
//| INDICATEUR 20: COT (Commitment of Traders)                       |
//| Smart money positioning (hebdomadaire)                           |
//+------------------------------------------------------------------+
double GetCOTVote() {
    if(g_NumCOTRecords == 0) return 0.0;  // Neutral si pas de data

    // Récupère dernier COT (le plus récent)
    SCOTData latest_cot = g_COTHistory[g_NumCOTRecords - 1];

    double commercials_net = latest_cot.commercials_net;

    // Classification selon net position
    if(commercials_net > 80000)
        return 1.0;   // STRONG BULLISH
    else if(commercials_net > 30000)
        return 0.5;   // BULLISH
    else if(commercials_net > -30000)
        return 0.0;   // NEUTRAL
    else if(commercials_net > -80000)
        return -0.5;  // BEARISH
    else
        return -1.0;  // STRONG BEARISH
}

bool Indicator_COT(int direction) {
    // ╔════════════════════════════════════════════════════════════════╗
    // ║  COT DISABLED - Always returns TRUE (1 vote)                   ║
    // ║  COT data loading removed to simplify EA                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    return true;  // Always vote YES

    /* ORIGINAL COT LOGIC (DISABLED):
    double cot_vote = GetCOTVote();

    // Alignement avec direction
    if(direction == 1) {  // BUY
        return (cot_vote >= 0.0);  // NEUTRAL ou BULLISH
    }
    else if(direction == -1) {  // SELL
        return (cot_vote <= 0.0);  // NEUTRAL ou BEARISH
    }

    return false;
    */
}

//+------------------------------------------------------------------+
//| INDICATEUR 21: ATR Percentile                                    |
//| FIXED: Élargi à top 60% (évite seulement volatilité très basse)  |
//| Valide si ATR pas dans le bottom 40%                             |
//+------------------------------------------------------------------+
bool Indicator_ATR_Percentile(int direction) {
    double atr_daily[];
    ArraySetAsSeries(atr_daily, true);

    // ATR Daily
    int h_ATR_D1 = iATR(SYMBOL_TRADED, PERIOD_D1, 14);
    if(h_ATR_D1 == INVALID_HANDLE) return false;

    if(CopyBuffer(h_ATR_D1, 0, 0, 201, atr_daily) <= 0) {
        IndicatorRelease(h_ATR_D1);
        return false;
    }

    double atr_current = atr_daily[0];

    // Percentile calculation (simplification: tri array et trouve position)
    double atr_sorted[];
    ArrayResize(atr_sorted, 200);
    ArrayCopy(atr_sorted, atr_daily, 0, 1, 200);  // Copie 200 derniers (excluant current)
    ArraySort(atr_sorted);

    // Top 60% = index > 80 (200 × 0.40) - évite seulement le bottom 40%
    double threshold_40 = atr_sorted[80];

    bool in_top_60 = (atr_current >= threshold_40);

    IndicatorRelease(h_ATR_D1);

    return in_top_60;  // Valide pour BUY et SELL
}

//+------------------------------------------------------------------+
//| FONCTION PRINCIPALE: Count Votes par Niveau                      |
//+------------------------------------------------------------------+
int CountVotes_H4(int direction) {
    int votes = 0;

    if(Indicator_ADX_H4(direction)) votes++;
    if(Indicator_EMA_Cross_H4(direction)) votes++;
    if(Indicator_EMA_50_200_H4(direction)) votes++;
    if(Indicator_Price_EMA21_H4(direction)) votes++;
    if(Indicator_Supertrend_H4(direction)) votes++;

    return votes;
}

int CountVotes_H1(int direction) {
    int votes = 0;

    if(Indicator_EMA_Cross_H1(direction)) votes++;
    if(Indicator_MACD_H1(direction)) votes++;
    if(Indicator_RSI_H1(direction)) votes++;
    if(Indicator_SAR_H1(direction)) votes++;
    if(Indicator_Stochastic_H1(direction)) votes++;
    if(Indicator_Bollinger_Width_H1(direction)) votes++;
    if(Indicator_Volume_Momentum_H1(direction)) votes++;
    if(Indicator_Donchian_H1(direction)) votes++;

    return votes;
}

int CountVotes_M15(int direction) {
    int votes = 0;

    if(Indicator_VWAP_M15(direction)) votes++;
    if(Indicator_OrderFlow_M15(direction)) votes++;
    if(Indicator_Volatility_M15(direction)) votes++;
    if(Indicator_Tick_Momentum_M15(direction)) votes++;
    if(Indicator_EURUSD_Corr_M15(direction)) votes++;
    if(Indicator_Effective_Spread_M15(direction)) votes++;

    return votes;
}

int CountVotes_Macro(int direction) {
    int votes = 0;

    // COT REMOVED from counting - only ATR Percentile remains
    // if(Indicator_COT(direction)) votes++;
    if(Indicator_ATR_Percentile(direction)) votes++;

    return votes;  // Now returns 0 or 1 (only ATR Percentile)
}

int CountVotes_Total(int direction) {
    return CountVotes_H4(direction) +
           CountVotes_H1(direction) +
           CountVotes_M15(direction) +
           CountVotes_Macro(direction);
}

//+------------------------------------------------------------------+
//| Store Indicator States (pour logging CSV)                        |
//+------------------------------------------------------------------+
void StoreIndicatorStates(int direction, int &states[]) {
    ArrayInitialize(states, 0);

    // H4 (0-4)
    states[0] = Indicator_ADX_H4(direction) ? 1 : 0;
    states[1] = Indicator_EMA_Cross_H4(direction) ? 1 : 0;
    states[2] = Indicator_EMA_50_200_H4(direction) ? 1 : 0;
    states[3] = Indicator_Price_EMA21_H4(direction) ? 1 : 0;
    states[4] = Indicator_Supertrend_H4(direction) ? 1 : 0;

    // H1 (5-12)
    states[5] = Indicator_EMA_Cross_H1(direction) ? 1 : 0;
    states[6] = Indicator_MACD_H1(direction) ? 1 : 0;
    states[7] = Indicator_RSI_H1(direction) ? 1 : 0;
    states[8] = Indicator_SAR_H1(direction) ? 1 : 0;
    states[9] = Indicator_Stochastic_H1(direction) ? 1 : 0;
    states[10] = Indicator_Bollinger_Width_H1(direction) ? 1 : 0;
    states[11] = Indicator_Volume_Momentum_H1(direction) ? 1 : 0;
    states[12] = Indicator_Donchian_H1(direction) ? 1 : 0;

    // M15 (13-18)
    states[13] = Indicator_VWAP_M15(direction) ? 1 : 0;
    states[14] = Indicator_OrderFlow_M15(direction) ? 1 : 0;
    states[15] = Indicator_Volatility_M15(direction) ? 1 : 0;
    states[16] = Indicator_Tick_Momentum_M15(direction) ? 1 : 0;
    states[17] = Indicator_EURUSD_Corr_M15(direction) ? 1 : 0;
    states[18] = Indicator_Effective_Spread_M15(direction) ? 1 : 0;

    // Macro (19-20)
    states[19] = Indicator_COT(direction) ? 1 : 0;
    states[20] = Indicator_ATR_Percentile(direction) ? 1 : 0;
}

//+------------------------------------------------------------------+
//| Initialize Indicator Handles                                     |
//+------------------------------------------------------------------+
bool InitIndicators() {
    Print("📊 Initializing 21 indicators...");

    // H4 Indicators
    h_ADX_H4 = iADX(SYMBOL_TRADED, TF_MACRO, 14);
    h_EMA21_H4 = iMA(SYMBOL_TRADED, TF_MACRO, 21, 0, MODE_EMA, PRICE_CLOSE);
    h_EMA55_H4 = iMA(SYMBOL_TRADED, TF_MACRO, 55, 0, MODE_EMA, PRICE_CLOSE);
    h_EMA50_H4 = iMA(SYMBOL_TRADED, TF_MACRO, 50, 0, MODE_EMA, PRICE_CLOSE);
    h_EMA200_H4 = iMA(SYMBOL_TRADED, TF_MACRO, 200, 0, MODE_EMA, PRICE_CLOSE);
    h_ATR_H4 = iATR(SYMBOL_TRADED, TF_MACRO, 10);

    // H1 Indicators
    h_EMA21_H1 = iMA(SYMBOL_TRADED, TF_SETUP, 21, 0, MODE_EMA, PRICE_CLOSE);
    h_EMA55_H1 = iMA(SYMBOL_TRADED, TF_SETUP, 55, 0, MODE_EMA, PRICE_CLOSE);
    h_MACD_H1 = iMACD(SYMBOL_TRADED, TF_SETUP, 12, 26, 9, PRICE_CLOSE);
    h_RSI_H1 = iRSI(SYMBOL_TRADED, TF_SETUP, 14, PRICE_CLOSE);
    h_SAR_H1 = iSAR(SYMBOL_TRADED, TF_SETUP, 0.02, 0.2);
    h_Stoch_H1 = iStochastic(SYMBOL_TRADED, TF_SETUP, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
    h_BB_H1 = iBands(SYMBOL_TRADED, TF_SETUP, 20, 0, 2.0, PRICE_CLOSE);
    h_ATR_H1 = iATR(SYMBOL_TRADED, TF_SETUP, 14);

    // M15 Indicators
    h_ATR_M15 = iATR(SYMBOL_TRADED, TF_TIMING, 14);

    // Check all handles
    bool all_ok = true;

    if(h_ADX_H4 == INVALID_HANDLE) { Print("❌ ADX H4 failed"); all_ok = false; }
    if(h_EMA21_H4 == INVALID_HANDLE) { Print("❌ EMA21 H4 failed"); all_ok = false; }
    if(h_EMA55_H4 == INVALID_HANDLE) { Print("❌ EMA55 H4 failed"); all_ok = false; }
    if(h_EMA50_H4 == INVALID_HANDLE) { Print("❌ EMA50 H4 failed"); all_ok = false; }
    if(h_EMA200_H4 == INVALID_HANDLE) { Print("❌ EMA200 H4 failed"); all_ok = false; }
    if(h_ATR_H4 == INVALID_HANDLE) { Print("❌ ATR H4 failed"); all_ok = false; }

    if(h_EMA21_H1 == INVALID_HANDLE) { Print("❌ EMA21 H1 failed"); all_ok = false; }
    if(h_EMA55_H1 == INVALID_HANDLE) { Print("❌ EMA55 H1 failed"); all_ok = false; }
    if(h_MACD_H1 == INVALID_HANDLE) { Print("❌ MACD H1 failed"); all_ok = false; }
    if(h_RSI_H1 == INVALID_HANDLE) { Print("❌ RSI H1 failed"); all_ok = false; }
    if(h_SAR_H1 == INVALID_HANDLE) { Print("❌ SAR H1 failed"); all_ok = false; }
    if(h_Stoch_H1 == INVALID_HANDLE) { Print("❌ Stochastic H1 failed"); all_ok = false; }
    if(h_BB_H1 == INVALID_HANDLE) { Print("❌ Bollinger H1 failed"); all_ok = false; }
    if(h_ATR_H1 == INVALID_HANDLE) { Print("❌ ATR H1 failed"); all_ok = false; }

    if(h_ATR_M15 == INVALID_HANDLE) { Print("❌ ATR M15 failed"); all_ok = false; }

    if(all_ok)
        Print("✅ All 21 indicators initialized successfully");

    return all_ok;
}

//+------------------------------------------------------------------+
//| Release Indicator Handles                                        |
//+------------------------------------------------------------------+
void ReleaseIndicators() {
    if(h_ADX_H4 != INVALID_HANDLE) IndicatorRelease(h_ADX_H4);
    if(h_EMA21_H4 != INVALID_HANDLE) IndicatorRelease(h_EMA21_H4);
    if(h_EMA55_H4 != INVALID_HANDLE) IndicatorRelease(h_EMA55_H4);
    if(h_EMA50_H4 != INVALID_HANDLE) IndicatorRelease(h_EMA50_H4);
    if(h_EMA200_H4 != INVALID_HANDLE) IndicatorRelease(h_EMA200_H4);
    if(h_ATR_H4 != INVALID_HANDLE) IndicatorRelease(h_ATR_H4);

    if(h_EMA21_H1 != INVALID_HANDLE) IndicatorRelease(h_EMA21_H1);
    if(h_EMA55_H1 != INVALID_HANDLE) IndicatorRelease(h_EMA55_H1);
    if(h_MACD_H1 != INVALID_HANDLE) IndicatorRelease(h_MACD_H1);
    if(h_RSI_H1 != INVALID_HANDLE) IndicatorRelease(h_RSI_H1);
    if(h_SAR_H1 != INVALID_HANDLE) IndicatorRelease(h_SAR_H1);
    if(h_Stoch_H1 != INVALID_HANDLE) IndicatorRelease(h_Stoch_H1);
    if(h_BB_H1 != INVALID_HANDLE) IndicatorRelease(h_BB_H1);
    if(h_ATR_H1 != INVALID_HANDLE) IndicatorRelease(h_ATR_H1);

    if(h_ATR_M15 != INVALID_HANDLE) IndicatorRelease(h_ATR_M15);

    Print("🗑️ Indicators released");
}

//+------------------------------------------------------------------+

#endif // HERMES_INDICATORS_MQH
