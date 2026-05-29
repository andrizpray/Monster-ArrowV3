# Phase 3 Functions - Quick Reference Guide

## Function Signatures

```mql5
// Get entry price (ASK for BUY, BID for SELL)
double GetEntryPrice(int signal);

// Calculate SL and TP levels based on ATR
bool CalculateSLTP(int signal, double entryPrice, double atr,
                   double &outSL, double &outTP1, double &outTP2, double &outTP3);

// Calculate position size (fixed or risk-based)
double CalculateLotSize(double atr);

// Validate all pre-trade conditions
bool ValidateOrderEntry(int signal, double lot, double entryPrice, double sl);

// Main order entry function (orchestrates all steps)
bool OpenTrade(int signal, double atr);

// Log trade to file
void LogTrade(string action, int signal, double price, double sl, double tp, double lot);

// Send multi-channel alerts
void SendAlert(string message);
```

---

## Function Call Hierarchy

```
OpenTrade(signal, atr)
├── GetEntryPrice(signal)
├── CalculateSLTP(signal, entryPrice, atr, sl, tp1, tp2, tp3)
├── CalculateLotSize(atr)
├── ValidateOrderEntry(signal, lot, entryPrice, sl)
│   ├── Check EnableTrading
│   ├── Count open positions
│   ├── Check daily trade limit
│   ├── Calculate required margin
│   └── Validate SL distance
├── OrderSend(request, result)
├── Store in activeTrades[]
├── LogTrade("OPEN", signal, ...)
└── SendAlert(message)
```

---

## Parameter Reference

### GetEntryPrice()
| Parameter | Type | Description |
|-----------|------|-------------|
| signal | int | 1=BUY (use ASK), -1=SELL (use BID) |
| **Returns** | double | Current ASK or BID price |

### CalculateSLTP()
| Parameter | Type | Description |
|-----------|------|-------------|
| signal | int | 1=BUY, -1=SELL |
| entryPrice | double | Entry price from GetEntryPrice() |
| atr | double | Current ATR value |
| outSL | double& | Output: Stop loss level |
| outTP1 | double& | Output: Take profit 1 level |
| outTP2 | double& | Output: Take profit 2 level |
| outTP3 | double& | Output: Take profit 3 level |
| **Returns** | bool | true=success, false=invalid ATR |

### CalculateLotSize()
| Parameter | Type | Description |
|-----------|------|-------------|
| atr | double | Current ATR value |
| **Returns** | double | Normalized lot size (0=error) |

**Uses Input Parameters:**
- `FixedLotSize` (if > 0, uses fixed mode)
- `RiskPercent` (if FixedLotSize == 0, uses risk % mode)
- `SL_ATR_Mult` (for SL distance calculation)
- `MaxLotSize` (maximum allowed lot)

### ValidateOrderEntry()
| Parameter | Type | Description |
|-----------|------|-------------|
| signal | int | 1=BUY, -1=SELL |
| lot | double | Lot size to validate |
| entryPrice | double | Entry price |
| sl | double | Stop loss level |
| **Returns** | bool | true=all checks pass, false=validation failed |

**Checks:**
- EnableTrading enabled
- Max open trades not exceeded
- Daily trade limit not exceeded
- Sufficient margin available
- SL distance meets minimum requirement

### OpenTrade()
| Parameter | Type | Description |
|-----------|------|-------------|
| signal | int | 1=BUY, -1=SELL |
| atr | double | Current ATR value |
| **Returns** | bool | true=order opened, false=failed |

**Side Effects:**
- Creates market order via OrderSend()
- Stores trade info in activeTrades[]
- Logs trade to file
- Sends alert
- Increments g_TradesThisDay

### LogTrade()
| Parameter | Type | Description |
|-----------|------|-------------|
| action | string | "OPEN" or "CLOSE" |
| signal | int | 1=BUY, -1=SELL, 0=N/A |
| price | double | Entry/exit price |
| sl | double | Stop loss level |
| tp | double | Take profit level |
| lot | double | Lot size |

**Output:** Appends line to LogFileName (if EnableLogging=true)

### SendAlert()
| Parameter | Type | Description |
|-----------|------|-------------|
| message | string | Alert message content |

**Channels (if enabled):**
- DoPopup: Alert() popup
- DoSound: PlaySound(AlertSound)
- DoEmail: SendMail()
- DoPush: SendNotification()

**Cooldown:** Respects AlertCooldown (seconds between alerts)

---

## Usage Examples

### Example 1: Simple Trade Entry
```mql5
void OnTick()
{
   int signal = DetectSignal(rates_total);
   if(signal != 0)
   {
      double atr[];
      ArraySetAsSeries(atr, true);
      CopyBuffer(hATR, 0, 0, 1, atr);
      
      if(OpenTrade(signal, atr[0]))
         Print("Trade opened");
      else
         Print("Trade failed");
   }
}
```

### Example 2: Manual SL/TP Calculation
```mql5
double entryPrice = GetEntryPrice(1);  // BUY
double sl, tp1, tp2, tp3;
double atr = 50.0;

if(CalculateSLTP(1, entryPrice, atr, sl, tp1, tp2, tp3))
{
   Print("Entry: ", entryPrice);
   Print("SL: ", sl);
   Print("TP1: ", tp1, " TP2: ", tp2, " TP3: ", tp3);
}
```

### Example 3: Lot Size Calculation
```mql5
double atr = 50.0;
double lot = CalculateLotSize(atr);

if(lot > 0)
   Print("Calculated lot: ", lot);
else
   Print("Lot calculation failed");
```

### Example 4: Pre-Trade Validation
```mql5
double entryPrice = GetEntryPrice(1);
double sl = entryPrice - 50.0;
double lot = 0.1;

if(ValidateOrderEntry(1, lot, entryPrice, sl))
   Print("All checks passed - ready to trade");
else
   Print("Validation failed - cannot trade");
```

---

## Error Codes & Messages

### GetEntryPrice()
- No errors (always returns valid price in OnTick)

### CalculateSLTP()
- `ERROR: Invalid ATR value for SL/TP calculation` → atr <= 0

### CalculateLotSize()
- `ERROR: Invalid account balance` → balance <= 0
- `ERROR: Invalid SL distance` → slDistance <= 0
- `ERROR: Invalid symbol parameters` → tickValue/minLot/lotStep invalid
- Returns 0 on any error

### ValidateOrderEntry()
- `ERROR: Invalid signal for order entry` → signal == 0
- `ERROR: Invalid lot size: X` → lot <= 0
- `WARNING: Trading is disabled` → EnableTrading == false
- `ERROR: Max open trades reached (X/Y)` → Too many open positions
- `ERROR: Daily trade limit reached (X/Y)` → Too many trades today
- `ERROR: Insufficient margin. Required: X Free: Y` → Not enough margin
- `ERROR: SL distance too small. Required: X Got: Y` → SL too close

### OpenTrade()
- `ERROR: Cannot open trade with no signal` → signal == 0
- `ERROR: Invalid entry price` → entryPrice <= 0
- `ERROR: Failed to calculate SL/TP` → CalculateSLTP() failed
- `ERROR: Invalid lot size calculated` → CalculateLotSize() returned 0
- `ERROR: Order entry validation failed` → ValidateOrderEntry() returned false
- `ERROR: OrderSend failed. Code: X Retcode: Y` → OrderSend() failed
- `ERROR: Order rejected. Retcode: X` → Order not accepted

### LogTrade()
- `ERROR: Cannot open log file: X` → File open failed (non-fatal)

### SendAlert()
- No errors (respects settings, skips if disabled)

---

## Global Variables Used

```mql5
// From Phase 1
CTrade trade;                    // Trade object for margin calculation
TradeInfo activeTrades[];        // Array of active trades
int totalActiveTrades = 0;       // Current count of active trades

// From Phase 3
datetime g_LastTradeDay = 0;     // Date of last trade (for daily reset)
int g_TradesThisDay = 0;         // Number of trades opened today
datetime g_LastAlert = 0;        // Timestamp of last alert (for cooldown)
```

---

## Input Parameters Used

### Trading Settings
```mql5
input bool   EnableTrading      = false;  // Must be true to trade
input int    MaxOpenTrades      = 3;      // Max concurrent positions
input int    MaxTradesPerDay    = 10;     // Max trades per calendar day
```

### Money Management
```mql5
input double RiskPercent        = 1.0;    // Risk % per trade
input double FixedLotSize       = 0.0;    // Fixed lot (0=use risk %)
input double MaxLotSize         = 10.0;   // Maximum lot size
input double TP1_ATR_Mult       = 1.5;    // TP1 distance (ATR mult)
input double TP2_ATR_Mult       = 3.0;    // TP2 distance (ATR mult)
input double TP3_ATR_Mult       = 6.0;    // TP3 distance (ATR mult)
input double SL_ATR_Mult        = 1.5;    // SL distance (ATR mult)
```

### Alerts & Logging
```mql5
input bool   MasterAlert        = true;   // Master alert switch
input bool   DoPopup            = false;  // Popup alerts
input bool   DoSound            = false;  // Sound alerts
input bool   DoEmail            = false;  // Email alerts
input bool   DoPush             = false;  // Push notifications
input string AlertSound         = "alert2.wav";
input int    AlertCooldown      = 60;     // Seconds between alerts
input bool   EnableLogging      = true;   // File logging
input string LogFileName        = "MonsterArrows_V3_EA.log";
```

---

## Performance Considerations

| Function | Complexity | Notes |
|----------|-----------|-------|
| GetEntryPrice() | O(1) | Very fast, just reads quotes |
| CalculateSLTP() | O(1) | Simple arithmetic |
| CalculateLotSize() | O(1) | Symbol info lookup + math |
| ValidateOrderEntry() | O(n) | n = PositionsTotal() |
| OpenTrade() | O(n) | Calls ValidateOrderEntry() + OrderSend() |
| LogTrade() | O(1) | File I/O (async in MT5) |
| SendAlert() | O(1) | Just sends notification |

**Recommendation:** Call OpenTrade() only on new signals, not every tick.

---

## Integration Checklist

- ✅ All functions added to MonsterArrows_V3_EA.mq5
- ✅ Phase 1 code preserved (CTrade, handles)
- ✅ Phase 2 code preserved (DetectSignal)
- ✅ Global variables initialized in OnInit()
- ✅ Input parameters defined in input groups
- ✅ Error handling throughout
- ✅ Ready for Phase 4 (Risk Management)

---

**Last Updated:** May 29, 2026
**Status:** Phase 3 Complete ✅
