# Phase 5: Code Walkthrough - Main Loop Integration

## OnTick() Execution Flow

### Step 1: Validate Minimum Bars (Lines 199-202)
```mql5
int rates_total = Bars(_Symbol, TradeTimeframe);
if(rates_total < ZZDepth + BarsToConfirm + 10)
   return;
```
- Ensures enough historical data for signal detection
- Prevents false signals on insufficient data
- Early exit if conditions not met

### Step 2: Get Price Data (Lines 204-210)
```mql5
double high[], low[], close[], open[];
if(!GetPriceData(high, low, close, open, rates_total))
{
   HandleErrors("Failed to retrieve price data");
   return;
}
```
- Calls GetPriceData() helper to fetch OHLC
- Validates success before proceeding
- Logs error and exits if data fetch fails

### Step 3: Get ATR Value (Lines 212-218)
```mql5
double atr = GetATRValue();
if(atr <= 0)
{
   HandleErrors("Invalid ATR value retrieved");
   return;
}
```
- Calls GetATRValue() helper to fetch current ATR
- Validates ATR > 0 (must be positive)
- Used for SL/TP calculations and lot sizing

### Step 4: Update Daily Statistics (Lines 220-221)
```mql5
UpdateDailyStats();
```
- Tracks daily P&L, equity, drawdown
- Resets at midnight UTC
- Called every tick for real-time monitoring

### Step 5: Check Risk Limits (Lines 223-228)
```mql5
if(!IsRiskLimitOK())
{
   HandleErrors("Risk limits exceeded - trading disabled");
   return;
}
```
- Validates daily loss limit not exceeded
- Validates drawdown limit not exceeded
- Stops all trading if limits breached

### Step 6: Monitor Existing Trades (Lines 230-231)
```mql5
CheckTradeStatus();
```
- Iterates through active trades
- Checks for closure conditions (expiry, SL hit)
- Removes closed trades from active array

### Step 7: Detect New Signal (Lines 233-238)
```mql5
int signal = DetectSignal(rates_total);

if(signal == 0)
   return;  // No signal detected
```
- Calls DetectSignal() from Phase 2
- Returns: 1=BUY, -1=SELL, 0=NONE
- Early exit if no signal

### Step 8: Validate Trade Entry Conditions (Lines 240-259)
```mql5
// Check if already have open position
if(PositionSelect(_Symbol))
{
   return;  // Position already open, skip
}

// Check OnlyOneTrade mode
if(OnlyOneTrade)
{
   datetime currentBarTime = iTime(_Symbol, TradeTimeframe, 0);
   if(g_LastSignalBar == currentBarTime)
   {
      return;  // Already traded on this bar
   }
}
```
- Prevents multiple simultaneous positions
- Enforces OnlyOneTrade setting
- Ensures one trade per signal bar if enabled

### Step 9: Open New Trade (Lines 261-271)
```mql5
if(OpenTrade(signal, atr))
{
   g_LastSignalBar = iTime(_Symbol, TradeTimeframe, 0);
   g_DailyStats.tradesOpened++;
}
else
{
   HandleErrors("Failed to open trade on signal");
}
```
- Calls OpenTrade() to execute trades
- Records signal bar time on success
- Increments daily trade counter
- Logs error if trade fails

---

## Helper Function Details

### GetPriceData() - Fetch OHLC Arrays

**Purpose:** Centralized OHLC data retrieval with error handling

**Key Features:**
- Arrays set as series for index 0 = current bar
- Each copy validated separately
- Specific error messages for each component
- Returns false on any failure
- Prevents partial data usage

**Error Scenarios Handled:**
- Network disconnection
- Insufficient historical data
- Indicator not ready
- Symbol not available

---

### GetATRValue() - Fetch Current ATR

**Purpose:** Retrieve ATR value with noise reduction

**Key Features:**
- Uses bar 1 (previous bar) not bar 0 (current)
- Avoids current bar noise/volatility
- Validates ATR > 0
- Returns 0 on error (safe default)
- Used for SL/TP and lot sizing

**Why Bar 1 Instead of Bar 0:**
- Bar 0 is still forming (current candle)
- ATR on forming bar is unreliable
- Bar 1 is confirmed/closed
- More stable for risk calculations

---

### HandleErrors() - Centralized Error Logging

**Purpose:** Unified error handling, logging, and alerting

**Key Features:**
- Captures MQL5 error code
- Adds timestamp to all messages
- Includes symbol name for multi-symbol EAs
- Prints to terminal for immediate visibility
- Logs to file for post-analysis
- Sends alerts for critical errors only
- Resets error code to prevent stale errors

**Error Routing:**
1. **Terminal Print** - Immediate visibility
2. **File Log** - Persistent record
3. **Alert** - Critical errors only (prevents spam)

**Critical Error Triggers:**
- Non-zero error code
- Risk limit exceeded
- Data fetch failures
- Trade execution failures

---

## Data Flow Diagram

```
OnTick() Called Every Tick
    ↓
[Validate Bars] → Return if insufficient
    ↓
[GetPriceData()] → Fetch OHLC → HandleErrors() if fail
    ↓
[GetATRValue()] → Fetch ATR → HandleErrors() if fail
    ↓
[UpdateDailyStats()] → Track P&L/Equity
    ↓
[IsRiskLimitOK()] → Check limits → HandleErrors() if exceeded
    ↓
[CheckTradeStatus()] → Monitor existing trades
    ↓
[DetectSignal()] → Analyze price action
    ↓
[Signal == 0?] → Return if no signal
    ↓
[PositionSelect()] → Check if already open
    ↓
[OnlyOneTrade Check] → Prevent multiple per bar
    ↓
[OpenTrade()] → Execute trade → HandleErrors() if fail
    ↓
[Update Stats] → Record signal bar time
```

---

## Integration with Previous Phases

### Phase 1: Setup & Architecture
- Uses indicator handles (hATR, hHTF_EMA, etc.)
- Uses global variables (g_LastSignalBar, g_DailyStats)
- Uses CTrade object for order execution

### Phase 2: Signal Detection
- Calls DetectSignal() to get BUY/SELL signals
- Passes rates_total for bar count validation
- Receives 1=BUY, -1=SELL, 0=NONE

### Phase 3: Order Management
- Calls OpenTrade() to execute trades
- Passes signal and ATR for SL/TP calculation
- Receives true/false for success/failure

### Phase 4: Risk Management
- Calls UpdateDailyStats() for tracking
- Calls IsRiskLimitOK() for validation
- Calls CheckTradeStatus() for monitoring
- Uses DailyStats structure for P&L tracking

### Phase 5: Main Loop (NEW)
- Ties all phases together
- Implements 8-step trading loop
- Adds helper functions for modularity
- Provides error handling throughout

---

## Production Readiness Checklist

✅ **Error Handling**
- All data fetches validated
- Graceful degradation on errors
- No silent failures

✅ **Logging**
- Timestamped messages
- File-based persistence
- Terminal visibility

✅ **Modularity**
- Helper functions reusable
- Single responsibility principle
- Clear separation of concerns

✅ **Performance**
- Early returns prevent unnecessary processing
- Efficient array handling
- Minimal memory allocation

✅ **Robustness**
- Handles network disconnections
- Handles insufficient data
- Handles indicator failures
- Handles trade failures

✅ **Documentation**
- Function headers with purpose
- Inline comments for clarity
- Clear variable names
- Consistent formatting
