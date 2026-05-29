# MonsterArrows V3 EA - MQL5 Audit Report

**Date:** May 29, 2026  
**File:** MonsterArrows_V3_EA.mq5 (1590 lines)  
**Status:** Compilation Fixed ✅ | Architecture Review ⚠️

---

## Executive Summary

EA compiles successfully but has **4 critical architectural issues** that could cause:
- Duplicate trades (no new bar check)
- Silent failures (no error handling)
- Memory leaks (manual array tracking)
- Performance degradation (uncached indicators)

**Recommendation:** Refactor with proper MQL5 structure before live trading.

---

## ✅ Strengths

1. **Proper CTrade class usage** - Using high-level trading API
2. **Organized input groups** - 30+ parameters well-structured
3. **TradeInfo struct** - Good attempt at trade tracking
4. **Magic number concept** - Prevents conflicts with other EAs
5. **Risk management** - Daily loss & drawdown limits implemented
6. **Multi-timeframe analysis** - HTF filter for confluence signals
7. **Comprehensive signal logic** - Liquidity sweep + FVG + SMC

---

## 🔴 Critical Issues (Must Fix Before Live Trading)

### 1. No OnInit() Validation
**Impact:** EA may start with invalid indicator handles  
**Current State:** OnInit() exists but doesn't validate handles  
**Fix:**
```mql5
int OnInit() {
    // Validate all indicator handles
    hEMA = iMA(_Symbol, htfTF, HTF_EMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
    if(hEMA == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA handle");
        return INIT_FAILED;
    }
    
    hATR = iATR(_Symbol, _Period, ATRPeriod);
    if(hATR == INVALID_HANDLE) {
        Print("ERROR: Failed to create ATR handle");
        return INIT_FAILED;
    }
    
    return INIT_SUCCEEDED;
}
```

### 2. No New Bar Check in OnTick()
**Impact:** May process multiple times per bar → duplicate trades  
**Current State:** OnTick() processes every tick  
**Fix:**
```mql5
static datetime lastBarTime = 0;

void OnTick() {
    // Only process on new bar
    if(iTime(_Symbol, _Period, 0) == lastBarTime) return;
    lastBarTime = iTime(_Symbol, _Period, 0);
    
    // Rest of logic here
}
```

### 3. Manual activeTrades[] Array Management
**Impact:** May lose track of positions, memory leaks  
**Current State:** Manually tracking trades in array  
**Fix:** Use CPositionInfo to query actual positions:
```mql5
void ManagePositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(!posInfo.SelectByIndex(i)) continue;
        if(posInfo.Symbol() != _Symbol) continue;
        if(posInfo.Magic() != MagicNumber) continue;
        
        // Now we have actual position data
        ulong ticket = posInfo.Ticket();
        double currentPrice = posInfo.PriceCurrent();
        // ... manage position
    }
}
```

### 4. No Error Handling for Trade Operations
**Impact:** Failed trades silently ignored, EA continues with wrong state  
**Current State:** No ResultRetcode() checks  
**Fix:**
```mql5
if(!trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot, ask, sl, tp, "Signal")) {
    Print("ERROR: Failed to open trade. Code: ", trade.ResultRetcode());
    Print("Reason: ", trade.ResultRetcodeDescription());
    return;
}
Print("Trade opened successfully. Ticket: ", trade.ResultOrder());
```

---

## 🟡 Medium Issues (Should Fix)

### 1. Indicator Handles Not Cached
**Impact:** Creating new handles every tick = performance hit  
**Current State:** Handles created in OnInit() but may be recreated  
**Fix:** Store handles as global variables, create once in OnInit()

### 2. Array Operations in OnTick() Loop
**Impact:** Slow with HistBars=1000  
**Current State:** Using iClose() in loops  
**Fix:** Use CopyBuffer() for batch operations:
```mql5
double closeBuf[];
ArraySetAsSeries(closeBuf, true);
if(CopyClose(_Symbol, _Period, 0, 100, closeBuf) == 100) {
    // Process 100 bars at once
}
```

### 3. No Position Verification Before Close
**Impact:** May try to close already-closed positions  
**Fix:**
```mql5
if(posInfo.SelectByTicket(ticket)) {
    if(!trade.PositionClose(ticket)) {
        Print("ERROR: Failed to close position");
    }
} else {
    Print("Position not found: ", ticket);
}
```

### 4. Trailing Stop Implementation
**Impact:** May not work correctly with multiple positions  
**Fix:** Verify position exists before modifying:
```mql5
if(posInfo.SelectByTicket(ticket)) {
    double newSL = CalculateNewSL(posInfo);
    if(!trade.PositionModify(ticket, newSL, posInfo.TakeProfit())) {
        Print("ERROR: Failed to modify position");
    }
}
```

---

## 📋 Code Quality Issues

### 1. Magic Number Hardcoded
**Current:** `const ulong MagicNumber = 20260529;`  
**Better:** `input ulong MagicNumber = 20260529;` (configurable)

### 2. Print Statements Instead of File Logging
**Current:** Using Print() for logging  
**Better:** Use FileOpen/FileWrite for persistent logs:
```mql5
int fileHandle = FileOpen("MonsterArrows_V3.log", FILE_READ|FILE_WRITE|FILE_TXT);
if(fileHandle != INVALID_HANDLE) {
    FileSeek(fileHandle, 0, SEEK_END);
    FileWrite(fileHandle, TimeToString(TimeCurrent()) + " - Trade opened");
    FileClose(fileHandle);
}
```

### 3. Complex Signal Logic Needs Comments
**Current:** DetectSignal() function lacks explanation  
**Better:** Add detailed comments explaining:
- Liquidity sweep detection
- FVG (Fair Value Gap) logic
- HTF filter confluence
- SMC (Smart Money Concepts) signals

---

## 🔧 Refactoring Priority

### Phase 1: Critical (Do First)
- [ ] Add OnInit() validation for all handles
- [ ] Add new bar check in OnTick()
- [ ] Replace manual array tracking with CPositionInfo
- [ ] Add error handling for all trade operations

### Phase 2: Medium (Do Next)
- [ ] Cache indicator handles properly
- [ ] Optimize array operations with CopyBuffer()
- [ ] Add position verification before close
- [ ] Fix trailing stop logic

### Phase 3: Polish (Do Last)
- [ ] Make magic number configurable input
- [ ] Implement file logging
- [ ] Add detailed comments
- [ ] Code cleanup and optimization

---

## Testing Checklist

Before live trading:
- [ ] Compile without errors ✅
- [ ] Backtest 6+ months
- [ ] Forward test on demo 1+ week
- [ ] Verify no duplicate trades
- [ ] Verify error handling works
- [ ] Check trailing stop behavior
- [ ] Monitor margin usage
- [ ] Verify position closing logic

---

## Next Steps

1. **Immediate:** Fix critical issues (Phase 1)
2. **Short-term:** Refactor with proper MQL5 structure
3. **Medium-term:** Backtest and optimize parameters
4. **Long-term:** Live trading with risk management

**Estimated Time:** 4-6 hours for refactoring + testing
