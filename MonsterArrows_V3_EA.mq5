//+------------------------------------------------------------------+
//|                                          MonsterArrows_V3_EA.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Monster Arrows V3 EA"
#property version     "3.0"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| INPUT GROUPS
//+------------------------------------------------------------------+

//=== TRADING SETTINGS ===
input group "=== TRADING SETTINGS ==="
input string           TradeSymbol = "";                      // Trade symbol (empty = current)
input ENUM_TIMEFRAMES  TradeTimeframe = PERIOD_H1;            // Trading timeframe
input bool             EnableTrading = false;                 // Enable live trading
input bool             OnlyOneTrade = false;                  // Only 1 trade per signal bar
input int              MaxOpenTrades = 3;                     // Maximum concurrent trades
input int              MaxTradesPerDay = 10;                  // Max trades per calendar day
input int              TradeExpiry = 0;                       // Trade expiry (minutes, 0=no expiry)

//=== SIGNAL SETTINGS ===
input group "=== SIGNAL SETTINGS ==="
input bool   EnableHTFFilter     = true;   // Enable Higher Timeframe Confluence Filter
input bool   RequireBothHTF      = true;   // Require BOTH HTF confirmations (Strict Mode)
input int    BarsToConfirm       = 2;      // Bars to wait to confirm signal (Non-Repaint)
input int    HTF_EMAPeriod       = 20;     // HTF EMA Period
input int    ST_RMA1Length       = 14;     // SuperTrend RMA 1 Length
input int    ST_RMA2Length       = 21;     // SuperTrend RMA 2 Length
input int    ST_ATRPeriod        = 14;     // SuperTrend ATR Period
input double ST_ATRMult          = 1.0;    // SuperTrend ATR Multiplier
input bool   UseLiquiditySweep   = true;   // Liquidity Sweep (Stop Hunt)
input bool   UseFairValueGap     = true;   // Fair Value Gap (Displacement)
input int    ZZDepth             = 30;     // ZigZag Depth
input int    ZZDeviation         = 5;      // ZigZag Deviation
input int    ZZBackstep          = 3;      // ZigZag Backstep
input double FibLevel            = 0.618;  // Fibonacci Retracement Level
input int    HistBars            = 1000;   // Number of historical bars to analyze
input int    ATRPeriod           = 14;     // ATR Period
input int    RecentBars          = 50;     // Bars to scan for missed signals

//=== MONEY MANAGEMENT ===
input group "=== MONEY MANAGEMENT ==="
input double RiskPercent         = 1.0;    // Risk per trade (% of account)
input double FixedLotSize        = 0.0;    // Fixed lot size (0 = use risk %)
input double MaxLotSize          = 10.0;   // Maximum lot size
input double MaxDailyLoss        = 5.0;    // Max daily loss (% of account)
input double MaxDrawdown         = 10.0;   // Max drawdown (% of account)
input double TP1_ATR_Mult        = 1.5;    // TP1 distance (ATR multiplier)
input double TP2_ATR_Mult        = 3.0;    // TP2 distance (ATR multiplier)
input double TP3_ATR_Mult        = 6.0;    // TP3 distance (ATR multiplier)
input double SL_ATR_Mult         = 1.5;    // SL distance (ATR multiplier)
input bool   UseTrailingStop     = false;  // Enable trailing stop
input double TrailingStopPoints  = 50.0;   // Trailing stop distance (points)

//=== ALERTS & LOGGING ===
input group "=== ALERTS & LOGGING ==="
input bool   MasterAlert         = true;   // Master Alert Switch
input bool   DoPopup             = false;  // Popup Alert
input bool   DoSound             = false;  // Sound Alert
input bool   DoEmail             = false;  // Email Alert
input bool   DoPush              = false;  // Mobile Push Notification
input string AlertSound          = "alert2.wav"; // Sound file
input int    AlertCooldown       = 60;     // Seconds between alerts
input bool   EnableLogging       = true;   // Enable file logging
input string LogFileName         = "MonsterArrows_V3_EA.log"; // Log file name

//+------------------------------------------------------------------+
//| STRUCTURES & ENUMS
//+------------------------------------------------------------------+

// Trade information structure
struct TradeInfo
{
   ulong     ticket;           // Order ticket
   datetime  entryTime;        // Entry time
   double    entryPrice;       // Entry price
   double    stopLoss;         // Stop loss level
   double    takeProfit1;      // TP1 level
   double    takeProfit2;      // TP2 level
   double    takeProfit3;      // TP3 level
   double    lotSize;          // Lot size
   bool      isBuy;            // true = buy, false = sell
   int       signalBar;        // Bar index where signal occurred
   double    triggerType;      // 1=Sweep, 2=FVG, 3=Both
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES
//+------------------------------------------------------------------+

// Trade management
CTrade trade;
TradeInfo activeTrades[];
int totalActiveTrades = 0;

// Daily tracking
datetime g_LastTradeDay = 0;
int      g_TradesThisDay = 0;

// Indicator handles
int hATR       = INVALID_HANDLE;
int hATRDaily  = INVALID_HANDLE;
int hATRWeekly = INVALID_HANDLE;
int hHTF_EMA   = INVALID_HANDLE;
int hHTF_ATR   = INVALID_HANDLE;

// SuperTrend RMA state (computed on HTF bars)
double g_ST_rma1_hlc3v = 0, g_ST_rma1_vol = 0;
double g_ST_rma2_hlc3v = 0, g_ST_rma2_vol = 0;
bool   g_ST_initialized = false;
double g_ST_trendDir    = 1.0;   // last known SuperTrend direction on HTF

// State
datetime g_LastAlert = 0;
int      g_LastProcessedBar = -1;
datetime g_LastSignalBar = 0;  // Track last signal bar to prevent duplicate trades

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION
//+------------------------------------------------------------------+
int OnInit()
{
   // ===== STEP 1: Validate Input Parameters =====
   if(TradeTimeframe == PERIOD_MN1)
   {
      Print("ERROR: Monthly timeframe not supported for EA trading");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(RiskPercent <= 0 || RiskPercent > 100)
   {
      Print("ERROR: RiskPercent must be between 0 and 100");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(MaxOpenTrades <= 0)
   {
      Print("ERROR: MaxOpenTrades must be greater than 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(ATRPeriod <= 0 || HTF_EMAPeriod <= 0)
   {
      Print("ERROR: Indicator periods must be greater than 0");
      return INIT_PARAMETERS_INCORRECT;
   }

   // ===== STEP 2: Initialize Trade Object =====
   trade.SetExpertMagicNumber(20260529);  // Unique magic number
   trade.SetDeviationInPoints(10);
   trade.SetAsyncMode(false);

   // ===== STEP 3: Create Indicator Handles =====
   string symbol = (TradeSymbol == "") ? _Symbol : TradeSymbol;
   ENUM_TIMEFRAMES tf = TradeTimeframe;

   hATR = iATR(symbol, tf, ATRPeriod);
   if(hATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create ATR handle for ", symbol, " ", tf);
      return INIT_FAILED;
   }

   hATRDaily = iATR(symbol, PERIOD_D1, ATRPeriod);
   if(hATRDaily == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create Daily ATR handle");
      IndicatorRelease(hATR);
      return INIT_FAILED;
   }

   hATRWeekly = iATR(symbol, PERIOD_W1, ATRPeriod);
   if(hATRWeekly == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create Weekly ATR handle");
      IndicatorRelease(hATR);
      IndicatorRelease(hATRDaily);
      return INIT_FAILED;
   }

   hHTF_EMA = iMA(symbol, GetHTF(tf), HTF_EMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(hHTF_EMA == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create HTF EMA handle");
      IndicatorRelease(hATR);
      IndicatorRelease(hATRDaily);
      IndicatorRelease(hATRWeekly);
      return INIT_FAILED;
   }

   hHTF_ATR = iATR(symbol, GetHTF(tf), ST_ATRPeriod);
   if(hHTF_ATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create HTF ATR handle");
      IndicatorRelease(hATR);
      IndicatorRelease(hATRDaily);
      IndicatorRelease(hATRWeekly);
      IndicatorRelease(hHTF_EMA);
      return INIT_FAILED;
   }

   // ===== STEP 4: Initialize State Variables =====
   g_ST_initialized = false;
   g_ST_trendDir    = 1.0;
   g_LastAlert      = 0;
   g_LastProcessedBar = -1;

   // Initialize daily tracking
   g_LastTradeDay = 0;
   g_TradesThisDay = 0;

   // Initialize active trades array
   ArrayResize(activeTrades, MaxOpenTrades);
   totalActiveTrades = 0;

   // ===== STEP 5: Log Initialization Success =====
   Print("✅ MonsterArrows V3 EA initialized successfully");
   Print("   Symbol: ", symbol);
   Print("   Timeframe: ", tf);
   Print("   Risk: ", RiskPercent, "%");
   Print("   Max Trades: ", MaxOpenTrades);
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release all indicator handles
   if(hATR != INVALID_HANDLE)
      IndicatorRelease(hATR);
   if(hATRDaily != INVALID_HANDLE)
      IndicatorRelease(hATRDaily);
   if(hATRWeekly != INVALID_HANDLE)
      IndicatorRelease(hATRWeekly);
   if(hHTF_EMA != INVALID_HANDLE)
      IndicatorRelease(hHTF_EMA);
   if(hHTF_ATR != INVALID_HANDLE)
      IndicatorRelease(hHTF_ATR);

   Print("MonsterArrows V3 EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| EXPERT TICK HANDLER - MAIN TRADING LOOP
//| Phase 5: Complete OnTick() with full trading loop integration
//+------------------------------------------------------------------+
// Static variable to track last processed bar
static datetime lastBarTime = 0;

void OnTick()
{
   // ===== NEW BAR CHECK (CRITICAL) =====
   // Only process once per bar to prevent duplicate trades
   datetime currentBarTime = iTime(_Symbol, TradeTimeframe, 0);
   if(currentBarTime == lastBarTime)
      return;  // Same bar as last tick, skip processing
   lastBarTime = currentBarTime;
   
   // Validate minimum bars available
   int rates_total = Bars(_Symbol, TradeTimeframe);
   if(rates_total < ZZDepth + BarsToConfirm + 10)
      return;

   // ===== STEP 1: Get Price Data =====
   double high[], low[], close[], open[];
   if(!GetPriceData(high, low, close, open, rates_total))
   {
      HandleErrors("Failed to retrieve price data");
      return;
   }

   // ===== STEP 2: Get ATR Value =====
   double atr = GetATRValue();
   if(atr <= 0)
   {
      HandleErrors("Invalid ATR value retrieved");
      return;
   }

   // ===== STEP 3: Update Daily Statistics =====
   UpdateDailyStats();

   // ===== STEP 4: Check Risk Limits =====
   if(!IsRiskLimitOK())
   {
      HandleErrors("Risk limits exceeded - trading disabled");
      return;
   }

   // ===== STEP 5: Monitor Existing Trades =====
   CheckTradeStatus();
   
   // ===== STEP 5b: Trailing Stop =====
   if(UseTrailingStop)
      ManageTrailingStop();
   
   // ===== STEP 6: Detect New Signal =====
   int signal = DetectSignal(rates_total);
   
   // signal: 1=BUY, -1=SELL, 0=NO SIGNAL
   if(signal == 0)
      return;  // No signal detected

   // ===== STEP 7: Check if Can Open New Trade =====
   // Conditions: signal detected + no open position + trading enabled
   
   // Check if already have open position on this symbol
   if(PositionSelect(_Symbol))
   {
      // Position already open, skip
      return;
   }

   // Check if we already traded this signal bar (OnlyOneTrade mode)
   if(OnlyOneTrade)
   {
      datetime currentBarTime = iTime(_Symbol, TradeTimeframe, 0);
      if(g_LastSignalBar == currentBarTime)
      {
         // Already traded on this bar
         return;
      }
   }

   // ===== STEP 8: Validate Risk Before Opening =====
   // Calculate potential loss: ATR * SL_mult * contract_value_per_point
   double riskPerPoint = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE) * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double potentialLoss = atr * SL_ATR_Mult * riskPerPoint;
   if(potentialLoss > 0 && !ValidateRiskLimits(potentialLoss))
   {
      HandleErrors("Risk limit validation failed");
      return;
   }
   
   // ===== STEP 9: Open New Trade =====
   if(OpenTrade(signal, atr))
   {
      // Trade opened successfully - record signal bar time
      g_LastSignalBar = iTime(_Symbol, TradeTimeframe, 0);
      g_DailyStats.tradesOpened++;
   }
   else
   {
      HandleErrors("Failed to open trade on signal");
   }
}

//+------------------------------------------------------------------+
//| PHASE 5: HELPER FUNCTIONS FOR ONTICK()
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Price Data (OHLC Arrays)
//| Fetches current OHLC price data for signal detection
//| Returns: true if data retrieved successfully, false on error
//+------------------------------------------------------------------+
bool GetPriceData(double &high[], double &low[], double &close[], double &open[], int rates_total)
{
   // Set arrays as series (index 0 = current/newest bar)
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);

   // Copy OHLC data from chart
   int copied = 0;
   
   copied = CopyHigh(_Symbol, TradeTimeframe, 0, rates_total, high);
   if(copied <= 0)
   {
      HandleErrors("CopyHigh failed. Error: " + IntegerToString(GetLastError()));
      return false;
   }

   copied = CopyLow(_Symbol, TradeTimeframe, 0, rates_total, low);
   if(copied <= 0)
   {
      HandleErrors("CopyLow failed. Error: " + IntegerToString(GetLastError()));
      return false;
   }

   copied = CopyClose(_Symbol, TradeTimeframe, 0, rates_total, close);
   if(copied <= 0)
   {
      HandleErrors("CopyClose failed. Error: " + IntegerToString(GetLastError()));
      return false;
   }

   copied = CopyOpen(_Symbol, TradeTimeframe, 0, rates_total, open);
   if(copied <= 0)
   {
      HandleErrors("CopyOpen failed. Error: " + IntegerToString(GetLastError()));
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Get ATR Value
//| Fetches current ATR value from indicator handle
//| Returns: ATR value (> 0 if valid, <= 0 if error)
//+------------------------------------------------------------------+
double GetATRValue()
{
   double atr[];
   ArraySetAsSeries(atr, true);

   // Copy current ATR value (bar 1 = previous bar to avoid current bar noise)
   int copied = CopyBuffer(hATR, 0, 1, 1, atr);
   
   if(copied <= 0)
   {
      HandleErrors("CopyBuffer(ATR) failed. Error: " + IntegerToString(GetLastError()));
      return 0;
   }

   // Validate ATR value
   if(atr[0] <= 0)
   {
      HandleErrors("ATR value is invalid or zero");
      return 0;
   }

   return atr[0];
}

//+------------------------------------------------------------------+
//| Handle Errors
//| Centralized error logging and reporting
//| Logs to file, prints to terminal, and optionally sends alerts
//+------------------------------------------------------------------+
void HandleErrors(string errorMessage)
{
   // Get current error code
   int errorCode = GetLastError();
   
   // Build full error message with timestamp
   string fullMessage = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + 
                       " | ERROR | " + _Symbol + " | " + errorMessage;
   
   if(errorCode != 0)
   {
      fullMessage += " | Code: " + IntegerToString(errorCode);
   }

   // Print to terminal
   Print(fullMessage);

   // Log to file if enabled
   if(EnableLogging)
   {
      int handle = FileOpen(LogFileName, FILE_READ | FILE_WRITE | FILE_TXT);
      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, fullMessage);
         FileClose(handle);
      }
   }

   // Send alert if enabled (only for critical errors)
   if(MasterAlert && (errorCode != 0 || StringFind(errorMessage, "Risk limits") >= 0))
   {
      SendAlert("ERROR: " + errorMessage);
   }

   // Reset error code
   ResetLastError();
}

//+------------------------------------------------------------------+
//| PHASE 2: SIGNAL DETECTION FUNCTIONS
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Main Signal Detection Function
//| Returns: 1=BUY, -1=SELL, 0=NONE
//| Combines liquidity sweeps, FVG, and HTF bias filters
//+------------------------------------------------------------------+
int DetectSignal(int rates_total)
{
   // Ensure we have enough bars
   if(rates_total < ZZDepth + BarsToConfirm + 10)
      return 0;

   // Get price arrays
   double close[], open[], high[], low[];
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(CopyClose(_Symbol, TradeTimeframe, 0, rates_total, close) <= 0 ||
      CopyOpen(_Symbol, TradeTimeframe, 0, rates_total, open) <= 0 ||
      CopyHigh(_Symbol, TradeTimeframe, 0, rates_total, high) <= 0 ||
      CopyLow(_Symbol, TradeTimeframe, 0, rates_total, low) <= 0)
      return 0;

   // Get ATR
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(hATR, 0, 0, rates_total, atr) <= 0)
      return 0;

   double curATR = atr[1];  // Previous bar ATR (avoid current bar noise)
   if(curATR <= 0)
      curATR = atr[2];
   if(curATR <= 0)
      return 0;

   // Check HTF bias filters
   bool htfBull = false, htfBear = false;
   if(EnableHTFFilter)
      CheckHTFBias(htfBull, htfBear);

   // Analyze previous bar (bar 1, since bar 0 is current/forming)
   int barIdx = 1;
   if(barIdx < ZZDepth + 2)
      return 0;

   // Find pivots for liquidity sweep detection
   double pivotLow = 0, pivotHigh = 0;
   FindPivots(low, high, barIdx, pivotLow, pivotHigh);

   // Check liquidity sweep (stop hunt)
   bool lsBuy = false, lsSell = false;
   if(UseLiquiditySweep)
      CheckLiquiditySweep(low, high, close, barIdx, pivotLow, pivotHigh, lsBuy, lsSell);

   // Check Fair Value Gap
   bool fvgBuy = false, fvgSell = false;
   if(UseFairValueGap && barIdx >= 2)
      CheckFairValueGap(low, high, open, close, barIdx, curATR, fvgBuy, fvgSell);

   // Local pivot check (3-bar confirmation)
   bool isLocalLow = true, isLocalHigh = true;
   int chk = MathMin(3, MathMin(barIdx, rates_total - 1 - barIdx));
   for(int k = 1; k <= chk; k++)
   {
      if(low[barIdx] >= low[barIdx - k] || low[barIdx] >= low[barIdx + k])
         isLocalLow = false;
      if(high[barIdx] <= high[barIdx - k] || high[barIdx] <= high[barIdx + k])
         isLocalHigh = false;
   }

   // Combine conditions
   bool buySignal = (lsBuy || fvgBuy) && isLocalLow && close[barIdx] > open[barIdx];
   bool sellSignal = (lsSell || fvgSell) && isLocalHigh && close[barIdx] < open[barIdx];

   // Apply HTF filter
   if(EnableHTFFilter)
   {
      if(RequireBothHTF)
      {
         if(buySignal && !htfBull)
            buySignal = false;
         if(sellSignal && !htfBear)
            sellSignal = false;
      }
      else
      {
         if(buySignal && htfBear)
            buySignal = false;
         if(sellSignal && htfBull)
            sellSignal = false;
      }
   }

   if(buySignal)
      return 1;
   if(sellSignal)
      return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| Find Pivot High and Low for Liquidity Sweep Detection
//| Looks left only (no lookahead bias)
//| A pivot low = bar whose low is lower than ZZDepth bars each side
//| A pivot high = bar whose high is higher than ZZDepth bars each side
//+------------------------------------------------------------------+
void FindPivots(const double &low[], const double &high[], int barIdx,
                double &outPivotLow, double &outPivotHigh)
{
   outPivotLow = 0;
   outPivotHigh = 0;

   int scanFrom = barIdx - 1;  // Look left only
   int scanTo = MathMax(ZZDepth + 1, barIdx - HistBars);

   // Scan backwards to find most recent confirmed pivots
   for(int k = scanFrom; k >= scanTo; k--)
   {
      // Check pivot low
      if(outPivotLow == 0)
      {
         bool isPivLow = true;
         int leftLim = MathMax(0, k - ZZDepth);
         for(int m = leftLim; m < k; m++)
         {
            if(low[m] <= low[k])
            {
               isPivLow = false;
               break;
            }
         }
         if(isPivLow)
            outPivotLow = low[k];
      }

      // Check pivot high
      if(outPivotHigh == 0)
      {
         bool isPivHigh = true;
         int leftLim = MathMax(0, k - ZZDepth);
         for(int m = leftLim; m < k; m++)
         {
            if(high[m] >= high[k])
            {
               isPivHigh = false;
               break;
            }
         }
         if(isPivHigh)
            outPivotHigh = high[k];
      }

      // Stop once we found both
      if(outPivotLow > 0 && outPivotHigh > 0)
         break;
   }

   // Fallback to simple window min/max if no pivot found
   if(outPivotLow == 0)
   {
      int lb = MathMax(0, barIdx - ZZDepth);
      outPivotLow = low[lb];
      for(int k = lb + 1; k < barIdx; k++)
         if(low[k] < outPivotLow)
            outPivotLow = low[k];
   }

   if(outPivotHigh == 0)
   {
      int lb = MathMax(0, barIdx - ZZDepth);
      outPivotHigh = high[lb];
      for(int k = lb + 1; k < barIdx; k++)
         if(high[k] > outPivotHigh)
            outPivotHigh = high[k];
   }
}

//+------------------------------------------------------------------+
//| Check Liquidity Sweep (Stop Hunt)
//| Buy: wick below pivot low + close back above = stops hunted below
//| Sell: wick above pivot high + close back below = stops hunted above
//+------------------------------------------------------------------+
void CheckLiquiditySweep(const double &low[], const double &high[],
                         const double &close[], int barIdx,
                         double pivotLow, double pivotHigh,
                         bool &outBuy, bool &outSell)
{
   outBuy = false;
   outSell = false;

   // Buy sweep: current low wicks below pivot, close reclaims above
   if(low[barIdx] < pivotLow && close[barIdx] > pivotLow)
      outBuy = true;

   // Sell sweep: current high wicks above pivot, close reclaims below
   if(high[barIdx] > pivotHigh && close[barIdx] < pivotHigh)
      outSell = true;
}

//+------------------------------------------------------------------+
//| Check Fair Value Gap (FVG)
//| Buy FVG: current low > 2 bars ago high, previous candle bullish,
//|          gap size > 0.5 ATR (not just tiny gaps)
//| Sell FVG: current high < 2 bars ago low, previous candle bearish,
//|           gap size > 0.5 ATR
//+------------------------------------------------------------------+
void CheckFairValueGap(const double &low[], const double &high[],
                       const double &open[], const double &close[],
                       int barIdx, double curATR,
                       bool &outBuy, bool &outSell)
{
   outBuy = false;
   outSell = false;

   if(barIdx < 2)
      return;

   // FVG Buy: current low > 2 bars ago high
   double gapSizeBuy = low[barIdx] - high[barIdx - 2];
   if(gapSizeBuy > curATR * 0.5 && close[barIdx - 1] > open[barIdx - 1])
      outBuy = true;

   // FVG Sell: current high < 2 bars ago low
   double gapSizeSell = low[barIdx - 2] - high[barIdx];
   if(gapSizeSell > curATR * 0.5 && close[barIdx - 1] < open[barIdx - 1])
      outSell = true;
}

//+------------------------------------------------------------------+
//| Check Higher Timeframe Bias
//| Dual filter approach:
//| Filter 1: HTF 20 EMA (close > EMA + rising = BULL, close < EMA + falling = BEAR)
//| Filter 2: SuperTrend Dual RMA (last arrow flip direction + RMA alignment)
//| HTF BULLISH = Filter1 Bull AND Filter2 Bull
//| HTF BEARISH = Filter1 Bear AND Filter2 Bear
//+------------------------------------------------------------------+
void CheckHTFBias(bool &outHTFBull, bool &outHTFBear)
{
   outHTFBull = false;
   outHTFBear = false;

   if(!EnableHTFFilter)
      return;

   ENUM_TIMEFRAMES htfTF = GetHTF(TradeTimeframe);
   bool ema20Bull = false, ema20Bear = false;
   bool stBull = false, stBear = false;

   // --- Filter 1: HTF 20 EMA ---
   {
      double emaBuf[];
      double htfClose[];
      ArrayResize(emaBuf, 3);
      ArrayResize(htfClose, 3);
      ArraySetAsSeries(emaBuf, true);
      ArraySetAsSeries(htfClose, true);

      if(CopyBuffer(hHTF_EMA, 0, 0, 3, emaBuf) == 3 &&
         CopyClose(_Symbol, htfTF, 0, 3, htfClose) == 3)
      {
         // Check EMA slope strength
         double emaSlope = emaBuf[0] - emaBuf[2];  // 2-bar slope
         double htfATRVal = 0;
         double tmpATR[];
         ArrayResize(tmpATR, 1);
         ArraySetAsSeries(tmpATR, true);
         if(CopyBuffer(hHTF_ATR, 0, 0, 1, tmpATR) > 0)
            htfATRVal = tmpATR[0];

         double minSlope = (htfATRVal > 0) ? htfATRVal * 0.3 : 0.0001;

         ema20Bull = (htfClose[0] > emaBuf[0] && emaBuf[0] > emaBuf[1] && emaSlope > minSlope);
         ema20Bear = (htfClose[0] < emaBuf[0] && emaBuf[0] < emaBuf[1] && emaSlope < -minSlope);
      }
   }

   // --- Filter 2: SuperTrend Dual RMA direction on HTF ---
   {
      int htfBars = MathMax(ST_RMA1Length, ST_RMA2Length) + ST_ATRPeriod + 50;

      double htfHigh[], htfLow[], htfClose[], htfATR[];
      ArrayResize(htfHigh, htfBars);
      ArrayResize(htfLow, htfBars);
      ArrayResize(htfClose, htfBars);
      ArrayResize(htfATR, htfBars);
      ArraySetAsSeries(htfHigh, true);
      ArraySetAsSeries(htfLow, true);
      ArraySetAsSeries(htfClose, true);
      ArraySetAsSeries(htfATR, true);

      int copied = CopyHigh(_Symbol, htfTF, 0, htfBars, htfHigh);
      copied += CopyLow(_Symbol, htfTF, 0, htfBars, htfLow);
      copied += CopyClose(_Symbol, htfTF, 0, htfBars, htfClose);
      copied += CopyBuffer(hHTF_ATR, 0, 0, htfBars, htfATR);

      if(copied == htfBars * 4)
      {
         // Compute RMA values in forward order
         double rma1_hlc3v = 0, rma1_vol = 0;
         double rma2_hlc3v = 0, rma2_vol = 0;
         bool rmaInit = false;
         double prevTrend = 1.0;
         double lastFlipDir = g_ST_trendDir;

         double finalRMA1 = 0, finalRMA2 = 0;

         // Process from oldest to newest (reverse iteration)
         for(int k = htfBars - 1; k >= 0; k--)
         {
            double vol = 1.0;
            double hlc3 = (htfHigh[k] + htfLow[k] + htfClose[k]) / 3.0;
            double hlc3v = hlc3 * vol;

            if(!rmaInit)
            {
               rma1_hlc3v = hlc3v;
               rma1_vol = vol;
               rma2_hlc3v = hlc3v;
               rma2_vol = vol;
               rmaInit = true;
            }
            else
            {
               rma1_hlc3v = (rma1_hlc3v * (ST_RMA1Length - 1) + hlc3v) / ST_RMA1Length;
               rma1_vol = (rma1_vol * (ST_RMA1Length - 1) + vol) / ST_RMA1Length;
               rma2_hlc3v = (rma2_hlc3v * (ST_RMA2Length - 1) + hlc3v) / ST_RMA2Length;
               rma2_vol = (rma2_vol * (ST_RMA2Length - 1) + vol) / ST_RMA2Length;
            }

            double rma1val = (rma1_vol != 0) ? rma1_hlc3v / rma1_vol : hlc3;
            double rma2val = (rma2_vol != 0) ? rma2_hlc3v / rma2_vol : hlc3;
            double basis = (rma1val + rma2val) / 2.0;
            double atrVal = htfATR[k];
            double upper = basis + ST_ATRMult * atrVal;
            double lower = basis - ST_ATRMult * atrVal;

            double trendDir;
            if(htfClose[k] > upper)
               trendDir = 1.0;
            else if(htfClose[k] < lower)
               trendDir = -1.0;
            else
               trendDir = prevTrend;

            // Track arrow flips
            if(k < htfBars - 1)
            {
               bool bullFlip = (prevTrend == -1.0 && trendDir == 1.0);
               bool bearFlip = (prevTrend == 1.0 && trendDir == -1.0);
               if(bullFlip)
                  lastFlipDir = 1.0;
               if(bearFlip)
                  lastFlipDir = -1.0;
            }

            prevTrend = trendDir;

            // Capture most recent bar's RMA values (k=0 = newest HTF bar)
            if(k == 0)
            {
               finalRMA1 = rma1val;
               finalRMA2 = rma2val;
            }
         }

         // Save flip direction for next tick
         g_ST_trendDir = lastFlipDir;

         // ST BULLISH = last arrow was BUY flip AND RMA1 currently above RMA2
         // ST BEARISH = last arrow was SELL flip AND RMA1 currently below RMA2
         bool rma1AboveRMA2 = (finalRMA1 > finalRMA2);
         bool rma1BelowRMA2 = (finalRMA1 < finalRMA2);

         stBull = (lastFlipDir == 1.0 && rma1AboveRMA2);
         stBear = (lastFlipDir == -1.0 && rma1BelowRMA2);
      }
   }

   // Combine both filters
   outHTFBull = (ema20Bull && stBull);
   outHTFBear = (ema20Bear && stBear);
}

//+------------------------------------------------------------------+
//| Trailing Stop Manager
//| Moves SL in profit direction when price moves favorably
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionGetSymbol(i) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != 20260529)
         continue;
      
      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double price = (posType == POSITION_TYPE_BUY) ? bid : ask;
      
      double trailDistance = TrailingStopPoints * _Point;
      double newSL = 0;
      bool shouldModify = false;
      
      if(posType == POSITION_TYPE_BUY)
      {
         double profit = price - openPrice;
         if(profit > trailDistance)
         {
            newSL = price - trailDistance;
            if(newSL > currentSL || currentSL == 0)
               shouldModify = true;
         }
      }
      else // SELL
      {
         double profit = openPrice - price;
         if(profit > trailDistance)
         {
            newSL = price + trailDistance;
            if(newSL < currentSL || currentSL == 0)
               shouldModify = true;
         }
      }
      
      if(shouldModify && newSL > 0)
      {
         MqlTradeRequest request = {};
         MqlTradeResult result = {};
         
         request.action = TRADE_ACTION_SLTP;
         request.symbol = _Symbol;
         request.sl = newSL;
         request.tp = 0;  // Don't modify TP
         request.position = ticket;
         request.volume = volume;
         request.deviation = 10;
         request.magic = 20260529;
         request.comment = "Trailing Stop";
         
         if(OrderSend(request, result))
         {
            Print("Trailing stop updated for ticket ", ticket, " to ", DoubleToString(newSL, _Digits));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| HELPER FUNCTION: Get Higher Timeframe
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetHTF(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:  return PERIOD_M15;
      case PERIOD_M5:  return PERIOD_H1;
      case PERIOD_M15: return PERIOD_H1;
      case PERIOD_M30: return PERIOD_H4;
      case PERIOD_H1:  return PERIOD_H4;
      case PERIOD_H4:  return PERIOD_D1;
      default:         return PERIOD_W1;
   }
}

//+------------------------------------------------------------------+
//| PHASE 3: ORDER MANAGEMENT FUNCTIONS
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get Current Entry Price (ASK for BUY, BID for SELL)
//| Returns the appropriate price for order entry
//+------------------------------------------------------------------+
double GetEntryPrice(int signal)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(signal == 1)  // BUY order uses ASK
      return ask;
   else  // SELL order uses BID
      return bid;
}

//+------------------------------------------------------------------+
//| Calculate Stop Loss and Take Profit Levels
//| Uses ATR-based calculation with configurable multipliers
//| Returns: true if SL/TP calculated successfully
//+------------------------------------------------------------------+
bool CalculateSLTP(int signal, double entryPrice, double atr,
                   double &outSL, double &outTP1, double &outTP2, double &outTP3)
{
   if(atr <= 0)
   {
      Print("ERROR: Invalid ATR value for SL/TP calculation");
      return false;
   }
   
   double slDistance = atr * SL_ATR_Mult;
   double tp1Distance = atr * TP1_ATR_Mult;
   double tp2Distance = atr * TP2_ATR_Mult;
   double tp3Distance = atr * TP3_ATR_Mult;
   
   if(signal == 1)  // BUY
   {
      outSL = entryPrice - slDistance;
      outTP1 = entryPrice + tp1Distance;
      outTP2 = entryPrice + tp2Distance;
      outTP3 = entryPrice + tp3Distance;
   }
   else  // SELL
   {
      outSL = entryPrice + slDistance;
      outTP1 = entryPrice - tp1Distance;
      outTP2 = entryPrice - tp2Distance;
      outTP3 = entryPrice - tp3Distance;
   }
   
   // Normalize to symbol's digits
   outSL = NormalizeDouble(outSL, _Digits);
   outTP1 = NormalizeDouble(outTP1, _Digits);
   outTP2 = NormalizeDouble(outTP2, _Digits);
   outTP3 = NormalizeDouble(outTP3, _Digits);
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size Based on Risk Management Settings
//| Supports: Risk % mode or Fixed lot mode
//| Returns: Normalized lot size, or 0 if calculation fails
//+------------------------------------------------------------------+
double CalculateLotSize(double atr)
{
   // Use fixed lot if enabled
   if(FixedLotSize > 0)
   {
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      double lot = FixedLotSize;
      lot = MathFloor(lot / lotStep) * lotStep;
      lot = MathMax(lot, minLot);
      lot = MathMin(lot, MathMin(maxLot, MaxLotSize));
      
      return lot;
   }
   
   // Risk-based lot calculation
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0)
   {
      Print("ERROR: Invalid account balance");
      return 0;
   }
   
   double riskAmount = balance * (RiskPercent / 100.0);
   
   // SL distance in points (convert from price distance to points)
   double slDistancePoints = (atr * SL_ATR_Mult) / _Point;
   if(slDistancePoints <= 0)
   {
      Print("ERROR: Invalid SL distance");
      return 0;
   }
   
   // Get symbol info
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(tickValue <= 0 || tickSize <= 0 || minLot <= 0 || lotStep <= 0)
   {
      Print("ERROR: Invalid symbol parameters");
      return 0;
   }
   
   // Lot size = risk amount / (SL distance in points * tick value / tick size)
   double lot = riskAmount / (slDistancePoints * tickValue / tickSize);
   
   // Normalize to symbol's lot step
   lot = MathFloor(lot / lotStep) * lotStep;
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, MathMin(maxLot, MaxLotSize));
   
   return lot;
}

//+------------------------------------------------------------------+
//| Validate Order Entry Conditions
//| Checks: max trades, margin, daily trade limit, risk limits
//| Returns: true if trade can be opened
//+------------------------------------------------------------------+
bool ValidateOrderEntry(int signal, double lot, double entryPrice, double sl)
{
   if(signal == 0)
   {
      Print("ERROR: Invalid signal for order entry");
      return false;
   }
   
   if(lot <= 0)
   {
      Print("ERROR: Invalid lot size: ", lot);
      return false;
   }
   
   // Check if trading is enabled
   if(!EnableTrading)
   {
      Print("WARNING: Trading is disabled");
      return false;
   }
   
   // Check max open trades limit
   int openCount = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionGetSymbol(i) == _Symbol)
         openCount++;
   }
   
   if(openCount >= MaxOpenTrades)
   {
      Print("ERROR: Max open trades reached (", openCount, "/", MaxOpenTrades, ")");
      return false;
   }
   
   // Check daily trade limit
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   datetime todayStart = StructToTime(dt) - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   
   if(g_LastTradeDay != todayStart)
   {
      g_LastTradeDay = todayStart;
      g_TradesThisDay = 0;
   }
   
   if(g_TradesThisDay >= MaxTradesPerDay)
   {
      Print("ERROR: Daily trade limit reached (", g_TradesThisDay, "/", MaxTradesPerDay, ")");
      return false;
   }
   
   // Check available margin
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   if(freeMargin <= 0)
   {
      Print("ERROR: Insufficient margin. Free margin: ", freeMargin);
      return false;
   }
   
   // Check SL distance (must be at least min stop distance)
   double minStopDistance = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double slDistance = MathAbs(entryPrice - sl);
   
   if(slDistance < minStopDistance)
   {
      Print("ERROR: SL distance too small. Required: ", minStopDistance, 
            " Got: ", slDistance);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Open Trade with Full Risk Management
//| Creates BUY/SELL order with SL and multiple TP levels
//| Stores trade info in activeTrades array
//| Returns: true if order opened successfully
//+------------------------------------------------------------------+
bool OpenTrade(int signal, double atr)
{
   if(signal == 0)
   {
      Print("ERROR: Cannot open trade with no signal");
      return false;
   }
   
   // Get entry price
   double entryPrice = GetEntryPrice(signal);
   if(entryPrice <= 0)
   {
      Print("ERROR: Invalid entry price");
      return false;
   }
   
   // Calculate SL/TP levels
   double sl, tp1, tp2, tp3;
   if(!CalculateSLTP(signal, entryPrice, atr, sl, tp1, tp2, tp3))
   {
      Print("ERROR: Failed to calculate SL/TP");
      return false;
   }
   
   // Calculate lot size
   double lot = CalculateLotSize(atr);
   if(lot <= 0)
   {
      Print("ERROR: Invalid lot size calculated");
      return false;
   }
   
   // Validate order entry conditions
   if(!ValidateOrderEntry(signal, lot, entryPrice, sl))
   {
      Print("ERROR: Order entry validation failed");
      return false;
   }
   
   // Prepare trade request
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lot;
   request.type = (signal == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = entryPrice;
   request.sl = sl;
   request.tp = tp1;  // Use TP1 as initial TP (can be modified for multi-level exits)
   request.deviation = 10;
   request.magic = 20260529;  // EA magic number
   request.comment = "MonsterArrows V3 EA";
   
   // Send order
   if(!OrderSend(request, result))
   {
      Print("ERROR: OrderSend failed. Code: ", GetLastError(), 
            " Retcode: ", result.retcode);
      return false;
   }
   
   // Verify order was accepted
   if(result.retcode != TRADE_RETCODE_DONE && result.retcode != TRADE_RETCODE_DONE_PARTIAL)
   {
      Print("ERROR: Order rejected. Retcode: ", result.retcode);
      return false;
   }
   
   // Store trade info in active trades array
   if(totalActiveTrades < MaxOpenTrades)
   {
      activeTrades[totalActiveTrades].ticket = result.order;
      activeTrades[totalActiveTrades].entryTime = TimeCurrent();
      activeTrades[totalActiveTrades].entryPrice = entryPrice;
      activeTrades[totalActiveTrades].stopLoss = sl;
      activeTrades[totalActiveTrades].takeProfit1 = tp1;
      activeTrades[totalActiveTrades].takeProfit2 = tp2;
      activeTrades[totalActiveTrades].takeProfit3 = tp3;
      activeTrades[totalActiveTrades].lotSize = lot;
      activeTrades[totalActiveTrades].isBuy = (signal == 1);
      activeTrades[totalActiveTrades].signalBar = 1;  // Current bar index
      activeTrades[totalActiveTrades].triggerType = 1;  // Will be set by caller
      
      totalActiveTrades++;
   }
   
   // Log trade
   LogTrade("OPEN", signal, entryPrice, sl, tp1, lot);
   
   // Send alert
   SendAlert((signal == 1 ? "BUY" : "SELL") + 
            " opened @ " + DoubleToString(entryPrice, _Digits) +
            " | SL: " + DoubleToString(sl, _Digits) +
            " | TP1: " + DoubleToString(tp1, _Digits) +
            " | Lot: " + DoubleToString(lot, 2));
   
   // Increment daily trade counter
   g_TradesThisDay++;
   
   return true;
}

//+------------------------------------------------------------------+
//| Log Trade to File
//| Appends trade action to log file with timestamp and details
//+------------------------------------------------------------------+
void LogTrade(string action, int signal, double price, double sl, double tp, double lot)
{
   if(!EnableLogging)
      return;
   
   int handle = FileOpen(LogFileName, FILE_READ | FILE_WRITE | FILE_TXT);
   if(handle == INVALID_HANDLE)
   {
      Print("ERROR: Cannot open log file: ", LogFileName);
      return;
   }
   
   FileSeek(handle, 0, SEEK_END);
   
   string signalStr = (signal == 1) ? "BUY" : (signal == -1) ? "SELL" : "N/A";
   string logLine = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " | " +
                    action + " | " +
                    _Symbol + " | " +
                    signalStr + " | " +
                    "Price: " + DoubleToString(price, _Digits) + " | " +
                    "SL: " + DoubleToString(sl, _Digits) + " | " +
                    "TP: " + DoubleToString(tp, _Digits) + " | " +
                    "Lot: " + DoubleToString(lot, 2);
   
   FileWrite(handle, logLine);
   FileClose(handle);
}

//+------------------------------------------------------------------+
//| Send Alert (Popup, Sound, Email, Push)
//| Respects alert cooldown to avoid spam
//+------------------------------------------------------------------+
void SendAlert(string message)
{
   if(!MasterAlert)
      return;
   
   // Check alert cooldown
   datetime now = TimeCurrent();
   if(now - g_LastAlert < AlertCooldown)
      return;
   
   g_LastAlert = now;
   
   string fullMsg = "MonsterArrows V3 EA | " + _Symbol + " | " + message;
   
   // Popup alert
   if(DoPopup)
      Alert(fullMsg);
   
   // Sound alert
   if(DoSound)
      PlaySound(AlertSound);
   
   // Email alert
   if(DoEmail)
      SendMail("MonsterArrows V3 EA Alert", fullMsg);
   
   // Push notification
   if(DoPush)
      SendNotification(fullMsg);
}

//+------------------------------------------------------------------+
//| PHASE 4: RISK MANAGEMENT & TRADE CLOSING
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Daily Statistics Structure
//| Tracks P&L, trades, and limits for the current trading day
//+------------------------------------------------------------------+
struct DailyStats
{
   datetime dayStart;           // Start of trading day (midnight)
   double   startBalance;       // Balance at day start
   double   maxEquity;          // Highest equity during day
   double   minEquity;          // Lowest equity during day
   int      tradesOpened;       // Number of trades opened today
   int      tradesClosed;       // Number of trades closed today
   double   totalPnL;           // Total P&L for the day
   double   maxDrawdown;        // Max drawdown % for the day
};

DailyStats g_DailyStats = {0, 0, 0, 0, 0, 0, 0, 0};

//+------------------------------------------------------------------+
//| Update Daily Statistics
//| Called every tick to track daily P&L, equity, and drawdown
//| Resets at midnight (24:00 UTC)
//+------------------------------------------------------------------+
void UpdateDailyStats()
{
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   
   // Calculate today's start (midnight UTC)
   datetime todayStart = StructToTime(dt) - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   
   // Reset stats at midnight
   if(g_DailyStats.dayStart == 0 || now - g_DailyStats.dayStart >= 86400)
   {
      g_DailyStats.dayStart = todayStart;
      g_DailyStats.startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_DailyStats.maxEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_DailyStats.minEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_DailyStats.tradesOpened = 0;
      g_DailyStats.tradesClosed = 0;
      g_DailyStats.totalPnL = 0;
      g_DailyStats.maxDrawdown = 0;
      
      Print("Daily stats reset. New day started at ", TimeToString(todayStart));
   }
   
   // Update equity tracking
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(currentEquity > g_DailyStats.maxEquity)
      g_DailyStats.maxEquity = currentEquity;
   if(currentEquity < g_DailyStats.minEquity)
      g_DailyStats.minEquity = currentEquity;
   
   // Calculate current drawdown
   double currentDrawdown = 0;
   if(g_DailyStats.maxEquity > 0)
      currentDrawdown = (g_DailyStats.maxEquity - currentEquity) / g_DailyStats.maxEquity * 100.0;
   
   if(currentDrawdown > g_DailyStats.maxDrawdown)
      g_DailyStats.maxDrawdown = currentDrawdown;
   
   // Update total P&L
   g_DailyStats.totalPnL = AccountInfoDouble(ACCOUNT_EQUITY) - g_DailyStats.startBalance;
}

//+------------------------------------------------------------------+
//| Check if Risk Limits are OK
//| Validates: daily loss limit, max drawdown, account equity
//| Returns: true if trading is allowed, false if limits exceeded
//+------------------------------------------------------------------+
bool IsRiskLimitOK()
{
   // Update daily stats first
   UpdateDailyStats();
   
   // Check daily loss limit
   double dailyLoss = g_DailyStats.startBalance - AccountInfoDouble(ACCOUNT_EQUITY);
   double maxDailyLoss = g_DailyStats.startBalance * (MaxDailyLoss / 100.0);
   
   if(dailyLoss > maxDailyLoss)
   {
      Print("WARNING: Daily loss limit exceeded. Loss: ", 
            DoubleToString(dailyLoss, 2), " / Limit: ", 
            DoubleToString(maxDailyLoss, 2));
      return false;
   }
   
   // Check drawdown limit
   if(g_DailyStats.maxDrawdown > MaxDrawdown)
   {
      Print("WARNING: Drawdown limit exceeded. Drawdown: ", 
            DoubleToString(g_DailyStats.maxDrawdown, 2), "% / Limit: ", 
            DoubleToString(MaxDrawdown, 2), "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Validate Risk Limits Before Opening Trade
//| Pre-trade validation: checks if new trade would violate limits
//| Returns: true if trade can be opened safely
//+------------------------------------------------------------------+
bool ValidateRiskLimits(double potentialLoss)
{
   // Check if daily loss limit would be exceeded
   double currentDailyLoss = g_DailyStats.startBalance - AccountInfoDouble(ACCOUNT_EQUITY);
   double maxDailyLoss = g_DailyStats.startBalance * (MaxDailyLoss / 100.0);
   
   if(currentDailyLoss + potentialLoss > maxDailyLoss)
   {
      Print("WARNING: Trade would exceed daily loss limit. ",
            "Current loss: ", DoubleToString(currentDailyLoss, 2),
            " + Potential: ", DoubleToString(potentialLoss, 2),
            " > Limit: ", DoubleToString(maxDailyLoss, 2));
      return false;
   }
   
   // Check if drawdown limit would be exceeded
   double potentialEquity = AccountInfoDouble(ACCOUNT_EQUITY) - potentialLoss;
   double potentialDrawdown = (g_DailyStats.maxEquity - potentialEquity) / g_DailyStats.maxEquity * 100.0;
   
   if(potentialDrawdown > MaxDrawdown)
   {
      Print("WARNING: Trade would exceed drawdown limit. ",
            "Potential drawdown: ", DoubleToString(potentialDrawdown, 2),
            "% > Limit: ", DoubleToString(MaxDrawdown, 2), "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Trade Should Be Closed
//| Validates: trade expiry time, TP/SL hit, trade status
//| Returns: true if trade should be closed, false otherwise
//+------------------------------------------------------------------+
bool ShouldCloseTrade(int tradeIndex)
{
   if(tradeIndex < 0 || tradeIndex >= totalActiveTrades)
      return false;
   
   TradeInfo &trade = activeTrades[tradeIndex];
   
   // Check if position still exists
   if(!PositionSelectByTicket(trade.ticket))
   {
      Print("Trade ticket ", trade.ticket, " not found - already closed");
      return true;  // Position already closed
   }
   
   // Check trade expiry time
   if(TradeExpiry > 0)
   {
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      datetime now = TimeCurrent();
      int minutesOpen = (int)((now - openTime) / 60);
      
      if(minutesOpen > TradeExpiry)
      {
         Print("Trade expired after ", minutesOpen, " minutes (limit: ", TradeExpiry, ")");
         return true;
      }
   }
   
   // Check if SL or TP has been hit (position closed by broker)
   double currentPrice = trade.isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                                       SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // SL hit check
   if(trade.isBuy && currentPrice <= trade.stopLoss)
   {
      Print("SL hit for BUY trade. Price: ", DoubleToString(currentPrice, _Digits),
            " SL: ", DoubleToString(trade.stopLoss, _Digits));
      return true;
   }
   
   if(!trade.isBuy && currentPrice >= trade.stopLoss)
   {
      Print("SL hit for SELL trade. Price: ", DoubleToString(currentPrice, _Digits),
            " SL: ", DoubleToString(trade.stopLoss, _Digits));
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Check Trade Status and Monitor for Closure Conditions
//| Iterates through all active trades and checks closure conditions
//| Removes closed trades from active trades array
//+------------------------------------------------------------------+
void CheckTradeStatus()
{
   for(int i = totalActiveTrades - 1; i >= 0; i--)
   {
      if(ShouldCloseTrade(i))
      {
         // Get reason for closing
         string reason = "Auto-close";
         if(!PositionSelectByTicket(activeTrades[i].ticket))
            reason = "Position not found";
         
         // Close the trade
         if(!CloseTrade(i, reason))
         {
            Print("ERROR: Failed to close trade at index ", i);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close Trade with Reason
//| Closes an open position and logs the closure reason
//| Returns: true if trade closed successfully
//+------------------------------------------------------------------+
bool CloseTrade(int tradeIndex, string reason)
{
   if(tradeIndex < 0 || tradeIndex >= totalActiveTrades)
   {
      Print("ERROR: Invalid trade index ", tradeIndex);
      return false;
   }
   
   TradeInfo &trade = activeTrades[tradeIndex];
   
   // Check if position still exists
   if(!PositionSelectByTicket(trade.ticket))
   {
      Print("Trade ticket ", trade.ticket, " already closed - removing from tracking");
      reason = "Already closed";
      // Fall through to remove from array
   }
   else
   {
      // Get current position details
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      // Prepare close request
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
      
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _Symbol;
      request.volume = volume;
      request.type = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      request.price = (posType == POSITION_TYPE_BUY) ? 
                      SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                      SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      request.deviation = 10;
      request.magic = 20260529;
      request.comment = "MonsterArrows V3 EA - " + reason;
      
      // Send close order
      if(!OrderSend(request, result))
      {
         Print("ERROR: Failed to close trade. Code: ", GetLastError(), 
               " Retcode: ", result.retcode);
         return false;
      }
      
      // Verify close was accepted
      if(result.retcode != TRADE_RETCODE_DONE && result.retcode != TRADE_RETCODE_DONE_PARTIAL)
      {
         Print("ERROR: Close order rejected. Retcode: ", result.retcode);
         return false;
      }
      
      // Calculate close P&L
      double closePrice = request.price;
      double pnl = 0;
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      
      if(trade.isBuy)
         pnl = (closePrice - trade.entryPrice) * volume * contractSize * tickValue / tickSize;
      else
         pnl = (trade.entryPrice - closePrice) * volume * contractSize * tickValue / tickSize;
      
      // Log trade closure
      LogTrade("CLOSE", trade.isBuy ? 1 : -1, closePrice, 0, 0, volume);
      
      // Send alert
      SendAlert((trade.isBuy ? "BUY" : "SELL") + 
               " closed @ " + DoubleToString(closePrice, _Digits) +
               " | Reason: " + reason +
               " | P&L: " + DoubleToString(pnl, 2));
   }
   
   // Remove from active trades array
   for(int j = tradeIndex; j < totalActiveTrades - 1; j++)
   {
      activeTrades[j] = activeTrades[j + 1];
   }
   totalActiveTrades--;
   
   // Increment daily closed trades counter
   g_DailyStats.tradesClosed++;
   
   return true;
}

//+------------------------------------------------------------------+
//| END OF FILE
//+------------------------------------------------------------------+
