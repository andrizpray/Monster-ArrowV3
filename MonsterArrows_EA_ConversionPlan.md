# MonsterArrows V3 → EA Conversion Plan

> **Goal:** Convert MonsterArrows V3 indicator into a fully automated Expert Advisor with order management, risk control, and trade logging.

**Architecture:** Extract signal logic from indicator → wrap in EA framework → add order management layer → implement risk/money management → add trade logging & stats.

**Tech Stack:** MQL5, MetaTrader 5, OrderSend API, Account info functions

---

## Phase 1: Setup & Architecture (Prep Work)

### Task 1: Create EA skeleton structure
**Objective:** Create base EA file with proper headers and initialization

**Files:**
- Create: `MonsterArrows_V3_EA.mq5`

**Code:**
```mql5
//+------------------------------------------------------------------+
//|                                        MonsterArrows_V3_EA.mq5   |
//|                          Expert Advisor - Automated Trading      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Monster Arrows EA V1"
#property version     "1.0"
#property strict

//=== INPUT GROUPS ===
input group "=== TRADING SETTINGS ==="
input double   RiskPercent      = 2.0;      // Risk per trade (% of balance)
input double   RewardRatio      = 2.0;      // Risk:Reward ratio (TP/SL)
input int      MaxOpenTrades    = 3;        // Max simultaneous positions
input bool     OnlyOneTrade     = false;    // Only 1 trade per signal bar
input int      TradeExpiry      = 240;      // Trade expiry in minutes (0=no expiry)

input group "=== SIGNAL SETTINGS ==="
input bool     UseBuySignals    = true;     // Trade BUY signals
input bool     UseSellSignals   = true;     // Trade SELL signals
input int      ConfirmBars      = 2;        // Bars to wait for confirmation

input group "=== MONEY MANAGEMENT ==="
input double   MaxDailyLoss     = 5.0;      // Max daily loss (% of balance)
input double   MaxDrawdown      = 10.0;     // Max drawdown (% of balance)
input bool     UseFixedLot      = false;    // Use fixed lot size
input double   FixedLotSize     = 0.1;      // Fixed lot if enabled

input group "=== ALERTS & LOGGING ==="
input bool     LogTrades        = true;     // Log all trades to file
input bool     SendAlerts       = true;     // Send alerts on trade open/close
input bool     SendEmail        = false;    // Email on trade close
input string   LogFileName      = "MonsterArrows_EA.log";

//=== GLOBAL VARIABLES ===
struct TradeInfo
{
   ulong  ticket;
   double entry;
   double sl;
   double tp;
   datetime openTime;
   bool   isBuy;
};

TradeInfo g_CurrentTrade;
datetime  g_LastSignalBar = 0;
double    g_DailyStartBalance = 0;
datetime  g_DailyResetTime = 0;

//=== INDICATOR HANDLES ===
int hATR       = INVALID_HANDLE;
int hATRDaily  = INVALID_HANDLE;
int hATRWeekly = INVALID_HANDLE;
int hHTF_EMA   = INVALID_HANDLE;
int hHTF_ATR   = INVALID_HANDLE;

//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize indicator handles (same as indicator)
   hATR       = iATR(_Symbol, _Period, 14);
   hATRDaily  = iATR(_Symbol, PERIOD_D1, 14);
   hATRWeekly = iATR(_Symbol, PERIOD_W1, 14);
   hHTF_EMA   = iMA(_Symbol, GetHTF(_Period), 20, 0, MODE_EMA, PRICE_CLOSE);
   hHTF_ATR   = iATR(_Symbol, GetHTF(_Period), 14);

   if(hATR == INVALID_HANDLE || hATRDaily == INVALID_HANDLE ||
      hATRWeekly == INVALID_HANDLE || hHTF_EMA == INVALID_HANDLE ||
      hHTF_ATR == INVALID_HANDLE)
   {
      Print("ERROR: Handle creation failed");
      return INIT_FAILED;
   }

   g_DailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_DailyResetTime = TimeCurrent();

   Print("MonsterArrows EA initialized successfully");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(hATR != INVALID_HANDLE)       IndicatorRelease(hATR);
   if(hATRDaily != INVALID_HANDLE)  IndicatorRelease(hATRDaily);
   if(hATRWeekly != INVALID_HANDLE) IndicatorRelease(hATRWeekly);
   if(hHTF_EMA != INVALID_HANDLE)   IndicatorRelease(hHTF_EMA);
   if(hHTF_ATR != INVALID_HANDLE)   IndicatorRelease(hHTF_ATR);
}

//+------------------------------------------------------------------+
void OnTick()
{
   // Main EA loop — will be filled in next tasks
}

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
```

**Verification:**
- File created: `MonsterArrows_V3_EA.mq5`
- Compiles without errors
- OnInit() returns INIT_SUCCEEDED

---

## Phase 2: Signal Detection (Extract from Indicator)

### Task 2: Create signal detection function
**Objective:** Extract signal logic from indicator into reusable function

**Files:**
- Modify: `MonsterArrows_V3_EA.mq5` (add function)

**Code to add:**
```mql5
//+------------------------------------------------------------------+
// Signal detection — returns 1=BUY, -1=SELL, 0=NO SIGNAL
//+------------------------------------------------------------------+
int DetectSignal(const double &high[], const double &low[], 
                 const double &close[], const double &open[],
                 int rates_total, double atr)
{
   if(rates_total < 50) return 0;
   
   int i = rates_total - 1;  // Current bar
   
   // Find pivot high/low (simplified from indicator)
   double pivotLow = low[i];
   double pivotHigh = high[i];
   
   int depth = 30;
   for(int k = MathMax(0, i-depth); k < i; k++)
   {
      if(low[k] < pivotLow)   pivotLow = low[k];
      if(high[k] > pivotHigh) pivotHigh = high[k];
   }
   
   // Liquidity Sweep detection
   bool lsBuy  = (low[i] < pivotLow && close[i] > pivotLow);
   bool lsSell = (high[i] > pivotHigh && close[i] < pivotHigh);
   
   // FVG detection (3-candle check)
   bool fvgBuy = false, fvgSell = false;
   if(i >= 2)
   {
      double gapSizeBuy = low[i] - high[i-2];
      fvgBuy = (gapSizeBuy > atr * 0.5) && (close[i-1] > open[i-1]);
      
      double gapSizeSell = low[i-2] - high[i];
      fvgSell = (gapSizeSell > atr * 0.5) && (close[i-1] < open[i-1]);
   }
   
   // Combine conditions
   bool buySignal  = (lsBuy || fvgBuy) && close[i] > open[i];
   bool sellSignal = (lsSell || fvgSell) && close[i] < open[i];
   
   if(buySignal && UseBuySignals)   return 1;
   if(sellSignal && UseSellSignals) return -1;
   return 0;
}
```

**Verification:**
- Function compiles
- Returns 1, -1, or 0 correctly
- Called from OnTick() (will test in next task)

---

## Phase 3: Order Management

### Task 3: Create order opening function
**Objective:** Open BUY/SELL orders with calculated SL/TP

**Files:**
- Modify: `MonsterArrows_V3_EA.mq5` (add function)

**Code to add:**
```mql5
//+------------------------------------------------------------------+
// Open trade with risk management
//+------------------------------------------------------------------+
bool OpenTrade(int signal, double entry, double atr)
{
   // Check if already have open trade
   if(PositionSelect(_Symbol))
   {
      Print("Trade already open for ", _Symbol);
      return false;
   }
   
   // Check max open trades
   int openCount = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionGetSymbol(i) == _Symbol) openCount++;
   }
   if(openCount >= MaxOpenTrades)
   {
      Print("Max open trades reached: ", MaxOpenTrades);
      return false;
   }
   
   // Calculate lot size
   double lot = CalculateLotSize(atr);
   if(lot <= 0)
   {
      Print("Invalid lot size calculated");
      return false;
   }
   
   // Calculate SL/TP
   double sl, tp;
   if(signal == 1)  // BUY
   {
      sl = entry - atr * 1.5;
      tp = entry + atr * 1.5 * RewardRatio;
   }
   else  // SELL
   {
      sl = entry + atr * 1.5;
      tp = entry - atr * 1.5 * RewardRatio;
   }
   
   // Prepare trade request
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lot;
   request.type = (signal == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = 123456;  // EA magic number
   request.comment = "MonsterArrows EA";
   
   // Send order
   if(!OrderSend(request, result))
   {
      Print("OrderSend failed: ", GetLastError());
      return false;
   }
   
   // Store trade info
   g_CurrentTrade.ticket = result.order;
   g_CurrentTrade.entry = entry;
   g_CurrentTrade.sl = sl;
   g_CurrentTrade.tp = tp;
   g_CurrentTrade.openTime = TimeCurrent();
   g_CurrentTrade.isBuy = (signal == 1);
   
   LogTrade("OPEN", signal, entry, sl, tp, lot);
   SendAlert("Trade opened: " + (signal == 1 ? "BUY" : "SELL") + " @ " + DoubleToString(entry, _Digits));
   
   return true;
}

//+------------------------------------------------------------------+
// Calculate lot size based on risk
//+------------------------------------------------------------------+
double CalculateLotSize(double atr)
{
   if(UseFixedLot) return FixedLotSize;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercent / 100.0);
   
   // SL distance in points
   double slDistance = atr * 1.5 / _Point;
   if(slDistance <= 0) return 0;
   
   // Lot size = risk amount / (SL distance * point value)
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lot = riskAmount / (slDistance * tickValue);
   
   // Normalize to symbol's lot step
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / lotStep) * lotStep;
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);
   
   return lot;
}
```

**Verification:**
- Functions compile
- OrderSend() called with valid parameters
- Lot size calculated correctly

---

## Phase 4: Risk Management

### Task 4: Create risk control functions
**Objective:** Implement daily loss limit, drawdown check, trade expiry

**Files:**
- Modify: `MonsterArrows_V3_EA.mq5` (add functions)

**Code to add:**
```mql5
//+------------------------------------------------------------------+
// Check if trading allowed (risk limits)
//+------------------------------------------------------------------+
bool IsRiskLimitOK()
{
   // Reset daily stats at midnight
   datetime now = TimeCurrent();
   if(now - g_DailyResetTime > 86400)  // 24 hours
   {
      g_DailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_DailyResetTime = now;
   }
   
   // Check daily loss limit
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyLoss = g_DailyStartBalance - currentBalance;
   double maxDailyLoss = g_DailyStartBalance * (MaxDailyLoss / 100.0);
   
   if(dailyLoss > maxDailyLoss)
   {
      Print("Daily loss limit reached: ", DoubleToString(dailyLoss, 2), " / ", DoubleToString(maxDailyLoss, 2));
      return false;
   }
   
   // Check drawdown limit
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double drawdown = (g_DailyStartBalance - equity) / g_DailyStartBalance * 100.0;
   
   if(drawdown > MaxDrawdown)
   {
      Print("Drawdown limit reached: ", DoubleToString(drawdown, 2), "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
// Check if trade should be closed (expiry)
//+------------------------------------------------------------------+
bool ShouldCloseTrade()
{
   if(TradeExpiry <= 0) return false;  // No expiry
   if(!PositionSelect(_Symbol)) return false;
   
   datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
   datetime now = TimeCurrent();
   int minutesOpen = (int)((now - openTime) / 60);
   
   if(minutesOpen > TradeExpiry)
   {
      Print("Trade expired after ", minutesOpen, " minutes");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
// Close open trade
//+------------------------------------------------------------------+
bool CloseTrade(string reason)
{
   if(!PositionSelect(_Symbol))
   {
      Print("No open position to close");
      return false;
   }
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = PositionGetDouble(POSITION_VOLUME);
   request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                  ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   request.deviation = 10;
   request.magic = 123456;
   request.comment = "MonsterArrows EA - " + reason;
   
   if(!OrderSend(request, result))
   {
      Print("CloseTrade failed: ", GetLastError());
      return false;
   }
   
   LogTrade("CLOSE", 0, request.price, 0, 0, request.volume);
   SendAlert("Trade closed: " + reason);
   
   return true;
}
```

**Verification:**
- Risk limit functions compile
- Daily loss/drawdown calculated correctly
- Trade expiry logic works

---

## Phase 5: Logging & Alerts

### Task 5: Create logging and alert functions
**Objective:** Log trades to file and send alerts

**Files:**
- Modify: `MonsterArrows_V3_EA.mq5` (add functions)

**Code to add:**
```mql5
//+------------------------------------------------------------------+
// Log trade to file
//+------------------------------------------------------------------+
void LogTrade(string action, int signal, double price, double sl, double tp, double lot)
{
   if(!LogTrades) return;
   
   int handle = FileOpen(LogFileName, FILE_READ | FILE_WRITE | FILE_TXT);
   if(handle == INVALID_HANDLE)
   {
      Print("Cannot open log file: ", LogFileName);
      return;
   }
   
   FileSeek(handle, 0, SEEK_END);
   
   string logLine = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " | " +
                    action + " | " +
                    _Symbol + " | " +
                    (signal == 1 ? "BUY" : signal == -1 ? "SELL" : "N/A") + " | " +
                    "Price: " + DoubleToString(price, _Digits) + " | " +
                    "SL: " + DoubleToString(sl, _Digits) + " | " +
                    "TP: " + DoubleToString(tp, _Digits) + " | " +
                    "Lot: " + DoubleToString(lot, 2);
   
   FileWrite(handle, logLine);
   FileClose(handle);
}

//+------------------------------------------------------------------+
// Send alert
//+------------------------------------------------------------------+
void SendAlert(string message)
{
   if(!SendAlerts) return;
   
   string fullMsg = "MonsterArrows EA | " + _Symbol + " | " + message;
   
   Alert(fullMsg);
   
   if(SendEmail)
   {
      SendMail("MonsterArrows EA Alert", fullMsg);
   }
}
```

**Verification:**
- Log file created and written
- Alerts sent to terminal
- Email sent if enabled

---

## Phase 6: Main Loop Integration

### Task 6: Implement OnTick() main loop
**Objective:** Tie everything together in OnTick()

**Files:**
- Modify: `MonsterArrows_V3_EA.mq5` (fill OnTick function)

**Code to add:**
```mql5
void OnTick()
{
   // Get current price data
   double high[], low[], close[], open[];
   ArraySetAsSeries(high, false);
   ArraySetAsSeries(low, false);
   ArraySetAsSeries(close, false);
   ArraySetAsSeries(open, false);
   
   int copied = CopyHigh(_Symbol, _Period, 0, 100, high);
   copied += CopyLow(_Symbol, _Period, 0, 100, low);
   copied += CopyClose(_Symbol, _Period, 0, 100, close);
   copied += CopyOpen(_Symbol, _Period, 0, 100, open);
   
   if(copied < 100) return;
   
   // Get ATR
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(hATR, 0, 0, 1, atr) <= 0) return;
   
   int rates_total = Bars(_Symbol, _Period);
   
   // Check risk limits
   if(!IsRiskLimitOK())
   {
      Print("Risk limits exceeded - no new trades");
      return;
   }
   
   // Check if trade should be closed (expiry)
   if(ShouldCloseTrade())
   {
      CloseTrade("Expiry");
   }
   
   // Detect signal
   int signal = DetectSignal(high, low, close, open, rates_total, atr[0]);
   
   // Open trade if signal detected and no trade open
   if(signal != 0 && !PositionSelect(_Symbol))
   {
      if(OnlyOneTrade && g_LastSignalBar == iTime(_Symbol, _Period, 0))
      {
         return;  // Already traded this bar
      }
      
      double entry = (signal == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                                     SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(OpenTrade(signal, entry, atr[0]))
      {
         g_LastSignalBar = iTime(_Symbol, _Period, 0);
      }
   }
}
```

**Verification:**
- OnTick() compiles
- Calls all functions correctly
- No infinite loops

---

## Phase 7: Testing & Optimization

### Task 7: Backtest on historical data
**Objective:** Validate EA performance before live trading

**Steps:**
1. Open MetaTrader 5 Strategy Tester
2. Select MonsterArrows_V3_EA.mq5
3. Set symbol and timeframe
4. Run backtest from 2024-01-01 to 2026-05-29
5. Review results:
   - Win rate > 50%
   - Profit factor > 1.5
   - Max drawdown < 20%
   - Sharpe ratio > 1.0

**Verification:**
- Backtest completes without errors
- Results show positive expectancy
- Drawdown acceptable

---

## Phase 8: Live Trading Setup

### Task 8: Deploy to live account (DEMO first)
**Objective:** Run on demo account before real money

**Steps:**
1. Compile MonsterArrows_V3_EA.mq5
2. Attach to chart on DEMO account
3. Monitor for 1 week:
   - Check all trades execute correctly
   - Verify SL/TP levels
   - Monitor logs
   - Check alerts
4. If all OK → move to live account

**Verification:**
- EA runs without errors
- Trades execute as expected
- Logs record all activity

---

## Summary

| Phase | Tasks | Effort | Output |
|-------|-------|--------|--------|
| 1 | Setup | 1 task | EA skeleton |
| 2 | Signals | 1 task | Signal detection |
| 3 | Orders | 1 task | Order management |
| 4 | Risk | 1 task | Risk controls |
| 5 | Logging | 1 task | Trade logging |
| 6 | Integration | 1 task | Main loop |
| 7 | Testing | 1 task | Backtest validation |
| 8 | Deployment | 1 task | Live trading |

**Total: 8 tasks, ~2-3 hours of work**

---

## Next Steps

1. **Review this plan** — any changes needed?
2. **Approve architecture** — OK with this approach?
3. **Execute** — Ready to start coding?

Mau gua mulai implement task by task?
