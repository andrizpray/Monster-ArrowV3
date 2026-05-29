# MQL5 Best Practices for Expert Advisors

**Reference:** Official MQL5 Documentation  
**Last Updated:** May 29, 2026

---

## 1. EA Code Structure

### Minimal EA Template
```mql5
#property strict
#include <Trade\Trade.mqh>

// Global objects
CTrade trade;
CPositionInfo posInfo;
CSymbolInfo symInfo;
CAccountInfo accInfo;

// Indicator handles
int hEMA = INVALID_HANDLE;
int hATR = INVALID_HANDLE;

// State tracking
static datetime lastBarTime = 0;

int OnInit() {
    // Initialize
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    // Cleanup
}

void OnTick() {
    // Main logic
}
```

### Required Functions
| Function | Called | Purpose |
|----------|--------|---------|
| `OnInit()` | Once at start | Initialize, create handles, validate inputs |
| `OnDeinit()` | Once at stop | Cleanup, release handles, close positions |
| `OnTick()` | Every tick | Main trading logic |

### Return Codes
```mql5
// OnInit() return values
INIT_SUCCEEDED              // Success
INIT_FAILED                 // General failure
INIT_PARAMETERS_INCORRECT   // Invalid input parameters
INIT_AGENT_NOT_SUITABLE     // EA not suitable for symbol/timeframe
```

---

## 2. Critical: New Bar Check

**Problem:** Without this, EA processes multiple times per bar → duplicate trades

**Solution:**
```mql5
static datetime lastBarTime = 0;

void OnTick() {
    // Check if new bar
    datetime currentBarTime = iTime(_Symbol, _Period, 0);
    if(currentBarTime == lastBarTime) return;
    lastBarTime = currentBarTime;
    
    // Process only once per bar
    DetectSignal();
    ManagePositions();
}
```

**Why it works:**
- `iTime(_Symbol, _Period, 0)` returns open time of current bar
- If same as last time, we're still in same bar → skip
- Only processes when bar time changes

---

## 3. Array Handling

### Static vs Dynamic Arrays

**WRONG - Static Array:**
```mql5
double buf[10];
ArraySetAsSeries(buf, true);  // ERROR! Cannot use with static array
```

**CORRECT - Dynamic Array:**
```mql5
double buf[];
ArrayResize(buf, 10);
ArraySetAsSeries(buf, true);  // OK
```

### Proper Array Usage
```mql5
// Copy indicator data
double emaBuf[];
ArraySetAsSeries(emaBuf, true);
if(CopyBuffer(hEMA, 0, 0, 3, emaBuf) != 3) {
    Print("ERROR: Failed to copy EMA buffer");
    return;
}

// Now emaBuf[0] = newest, emaBuf[1] = previous, emaBuf[2] = oldest
double currentEMA = emaBuf[0];
double previousEMA = emaBuf[1];
```

### CopyBuffer vs iClose Loop

**SLOW - Individual calls:**
```mql5
for(int i = 0; i < 100; i++) {
    double close = iClose(_Symbol, _Period, i);  // 100 function calls
    // process
}
```

**FAST - Batch copy:**
```mql5
double closeBuf[];
ArraySetAsSeries(closeBuf, true);
if(CopyClose(_Symbol, _Period, 0, 100, closeBuf) == 100) {
    for(int i = 0; i < 100; i++) {
        double close = closeBuf[i];  // Direct array access
        // process
    }
}
```

---

## 4. Trading with CTrade Class

### Basic Trade Operations

**Open Position:**
```mql5
ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
double volume = 0.1;
double price = symInfo.Ask();
double sl = price - 50 * _Point;
double tp = price + 100 * _Point;

if(!trade.PositionOpen(_Symbol, orderType, volume, price, sl, tp, "My Signal")) {
    Print("ERROR: Failed to open trade");
    Print("Code: ", trade.ResultRetcode());
    Print("Reason: ", trade.ResultRetcodeDescription());
    return;
}

Print("Trade opened. Ticket: ", trade.ResultOrder());
```

**Close Position:**
```mql5
if(!trade.PositionClose(ticket)) {
    Print("ERROR: Failed to close position");
    Print("Code: ", trade.ResultRetcode());
    return;
}
```

**Modify Position:**
```mql5
double newSL = currentPrice - 30 * _Point;
double newTP = currentPrice + 150 * _Point;

if(!trade.PositionModify(ticket, newSL, newTP)) {
    Print("ERROR: Failed to modify position");
    return;
}
```

### Error Handling

**Always check result:**
```mql5
if(!trade.PositionOpen(...)) {
    uint code = trade.ResultRetcode();
    
    switch(code) {
        case 10009:  // TRADE_RETCODE_OK
            Print("Trade successful");
            break;
        case 10015:  // TRADE_RETCODE_INVALID_VOLUME
            Print("ERROR: Invalid volume");
            break;
        case 10018:  // TRADE_RETCODE_MARKET_CLOSED
            Print("ERROR: Market closed");
            break;
        case 10019:  // TRADE_RETCODE_NO_MONEY
            Print("ERROR: Insufficient funds");
            break;
        default:
            Print("ERROR: Code ", code, " - ", trade.ResultRetcodeDescription());
    }
    return;
}
```

---

## 5. Position Management

### Query Positions

**Iterate all positions:**
```mql5
for(int i = PositionsTotal() - 1; i >= 0; i--) {
    if(!posInfo.SelectByIndex(i)) continue;
    
    // Filter by symbol and magic number
    if(posInfo.Symbol() != _Symbol) continue;
    if(posInfo.Magic() != MagicNumber) continue;
    
    // Now we have position data
    ulong ticket = posInfo.Ticket();
    ENUM_POSITION_TYPE type = posInfo.PositionType();
    double volume = posInfo.Volume();
    double openPrice = posInfo.PriceOpen();
    double currentPrice = posInfo.PriceCurrent();
    double sl = posInfo.StopLoss();
    double tp = posInfo.TakeProfit();
    
    // Process position
}
```

**Select by ticket:**
```mql5
if(posInfo.SelectByTicket(ticket)) {
    // Position exists
    double profit = posInfo.Profit();
    Print("Position profit: ", profit);
} else {
    // Position not found or closed
    Print("Position not found");
}
```

### Count Positions

**Count open positions:**
```mql5
int countBuy = 0, countSell = 0;

for(int i = 0; i < PositionsTotal(); i++) {
    if(!posInfo.SelectByIndex(i)) continue;
    if(posInfo.Symbol() != _Symbol) continue;
    if(posInfo.Magic() != MagicNumber) continue;
    
    if(posInfo.PositionType() == POSITION_TYPE_BUY) countBuy++;
    else countSell++;
}

Print("Open: ", countBuy, " BUY, ", countSell, " SELL");
```

---

## 6. Account & Symbol Information

### Account Info

```mql5
CAccountInfo accInfo;

double balance = accInfo.Balance();           // Account balance
double equity = accInfo.Equity();             // Current equity
double freeMargin = accInfo.FreeMargin();     // Available margin
double usedMargin = accInfo.Margin();         // Used margin
double marginLevel = accInfo.MarginLevel();   // Margin level %

Print("Balance: ", balance);
Print("Equity: ", equity);
Print("Free Margin: ", freeMargin);
Print("Margin Level: ", marginLevel, "%");
```

### Symbol Info

```mql5
CSymbolInfo symInfo;
symInfo.Name(_Symbol);

double bid = symInfo.Bid();                   // Current bid
double ask = symInfo.Ask();                   // Current ask
double point = symInfo.Point();               // Point value
int digits = symInfo.Digits();                // Decimal places
double contractSize = symInfo.ContractSize(); // Contract size
double tickValue = symInfo.TickValue();       // Tick value
double tickSize = symInfo.TickSize();         // Minimum price change

Print("Bid: ", bid);
Print("Ask: ", ask);
Print("Point: ", point);
Print("Digits: ", digits);
```

---

## 7. Indicator Handles

### Create Handles in OnInit()

**WRONG - Create every tick:**
```mql5
void OnTick() {
    int hEMA = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);  // SLOW!
    // ...
}
```

**CORRECT - Create once:**
```mql5
int hEMA = INVALID_HANDLE;

int OnInit() {
    hEMA = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
    if(hEMA == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA handle");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    if(hEMA != INVALID_HANDLE) IndicatorRelease(hEMA);
}

void OnTick() {
    // Use hEMA
}
```

### Common Indicators

```mql5
// Moving Average
int hMA = iMA(_Symbol, _Period, period, shift, method, price);

// ATR (Average True Range)
int hATR = iATR(_Symbol, _Period, period);

// RSI (Relative Strength Index)
int hRSI = iRSI(_Symbol, _Period, period, price);

// MACD
int hMACD = iMACD(_Symbol, _Period, fast, slow, signal, price);

// Bollinger Bands
int hBB = iBands(_Symbol, _Period, period, shift, deviation, price);

// Stochastic
int hStoch = iStochastic(_Symbol, _Period, k_period, d_period, slowing, method, price);
```

---

## 8. Common Pitfalls & Solutions

### Pitfall 1: Multiple Trades Per Bar
**Problem:** No new bar check → duplicate trades  
**Solution:** Add `if(iTime() == lastTime) return;`

### Pitfall 2: Static Arrays with ArraySetAsSeries
**Problem:** `double arr[10]; ArraySetAsSeries(arr, true);` → ERROR  
**Solution:** Use dynamic: `double arr[]; ArrayResize(arr, 10);`

### Pitfall 3: Deprecated Enums
**Problem:** `ACCOUNT_FREEMARGIN` doesn't exist  
**Solution:** Use `ACCOUNT_MARGIN_FREE`

### Pitfall 4: No Error Handling
**Problem:** Trade fails silently, EA continues with wrong state  
**Solution:** Check `trade.ResultRetcode()` after every operation

### Pitfall 5: Uncached Indicator Handles
**Problem:** Creating handles every tick = performance hit  
**Solution:** Create in `OnInit()`, store as global

### Pitfall 6: Manual Position Tracking
**Problem:** Array tracking loses sync with actual positions  
**Solution:** Use `CPositionInfo` to query real positions

### Pitfall 7: Not Verifying Position Exists
**Problem:** Try to close already-closed position → error  
**Solution:** Use `posInfo.SelectByTicket()` before closing

### Pitfall 8: Hardcoded Magic Numbers
**Problem:** Can't change without recompiling  
**Solution:** Use `input ulong MagicNumber = 12345;`

---

## 9. Performance Tips

1. **Process only on new bar** - Not every tick
2. **Cache indicator handles** - Create in OnInit()
3. **Use CopyBuffer()** - Not iClose() in loops
4. **Minimize array operations** - In OnTick()
5. **Use static variables** - For persistent data
6. **Batch operations** - Copy multiple bars at once
7. **Avoid nested loops** - In OnTick()
8. **Release resources** - In OnDeinit()

---

## 10. Testing Checklist

Before live trading:
- [ ] Compiles without errors
- [ ] OnInit() validates all inputs
- [ ] OnDeinit() releases all handles
- [ ] New bar check prevents duplicates
- [ ] Error handling catches failures
- [ ] Position management works correctly
- [ ] Trailing stop functions properly
- [ ] Backtest 6+ months successful
- [ ] Demo trading 1+ week stable
- [ ] All logs reviewed

---

## References

- **Official MQL5 Docs:** https://www.mql5.com/en/docs
- **CTrade Class:** https://www.mql5.com/en/docs/standardlibrary/trade
- **CPositionInfo:** https://www.mql5.com/en/docs/standardlibrary/trade/cpositioninfo
- **Indicator Functions:** https://www.mql5.com/en/docs/indicators
- **Account Functions:** https://www.mql5.com/en/docs/account
- **Symbol Functions:** https://www.mql5.com/en/docs/symbols
