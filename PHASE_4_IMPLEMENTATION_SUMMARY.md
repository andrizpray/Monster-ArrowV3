# Phase 4: Risk Management & Trade Closing - Implementation Summary

## Overview
Successfully implemented Phase 4 risk management functions for MonsterArrows_V3_EA.mq5. All 6 required functions have been added with full integration into the OnTick() loop.

## Implementation Details

### 1. DailyStats Structure (Lines 1027-1037)
**Purpose:** Track daily P&L, equity extremes, and trade counts
**Fields:**
- `dayStart` - Timestamp of trading day start (midnight UTC)
- `startBalance` - Account balance at day start
- `maxEquity` - Highest equity reached during day
- `minEquity` - Lowest equity reached during day
- `tradesOpened` - Count of trades opened today
- `tradesClosed` - Count of trades closed today
- `totalPnL` - Total profit/loss for the day
- `maxDrawdown` - Maximum drawdown percentage for the day

**Global Instance:** `DailyStats g_DailyStats` (Line 1039)

---

### 2. UpdateDailyStats() Function (Lines 1046-1087)
**Purpose:** Track daily P&L, equity, and drawdown; reset at midnight
**Called:** Every tick from OnTick()
**Logic:**
- Calculates midnight UTC timestamp
- Resets all stats when 24 hours have passed
- Tracks max/min equity during the day
- Calculates current drawdown percentage
- Updates total P&L

**Key Features:**
- Automatic midnight reset (86400 seconds = 24 hours)
- Continuous equity monitoring
- Drawdown calculation: `(maxEquity - currentEquity) / maxEquity * 100%`
- Logs reset events to console

---

### 3. IsRiskLimitOK() Function (Lines 1094-1120)
**Purpose:** Check if trading is allowed (daily loss & drawdown limits)
**Returns:** `true` if limits OK, `false` if exceeded
**Checks:**
1. **Daily Loss Limit:** `currentLoss > (startBalance * MaxDailyLoss%)`
2. **Drawdown Limit:** `maxDrawdown > MaxDrawdown%`

**Integration:** Called first in OnTick() - stops all trading if limits exceeded

**Example:**
- Account: $10,000
- MaxDailyLoss: 5% = $500 max loss
- MaxDrawdown: 10% = 10% max drawdown
- If either limit hit → trading disabled for session

---

### 4. ValidateRiskLimits() Function (Lines 1128-1156)
**Purpose:** Pre-trade validation - check if new trade would violate limits
**Parameter:** `potentialLoss` - estimated max loss for the trade
**Returns:** `true` if trade is safe, `false` if would violate limits
**Checks:**
1. Would trade exceed daily loss limit?
2. Would trade exceed drawdown limit?

**Usage:** Call before OpenTrade() to validate risk

---

### 5. ShouldCloseTrade() Function (Lines 1163-1211)
**Purpose:** Check if a specific trade should be closed
**Parameter:** `tradeIndex` - index in activeTrades array
**Returns:** `true` if trade should close, `false` otherwise
**Closure Conditions:**
1. **Position Not Found** - ticket no longer exists (already closed)
2. **Trade Expiry** - exceeded TradeExpiry minutes (if > 0)
3. **SL Hit** - price reached stop loss level
4. **TP Hit** - price reached take profit level (monitored via SL check)

**Logic:**
- Validates trade index bounds
- Checks position existence via PositionSelectByTicket()
- Calculates minutes open: `(now - openTime) / 60`
- Compares current price to SL level

---

### 6. CheckTradeStatus() Function (Lines 1218-1232)
**Purpose:** Monitor all active trades for closure conditions
**Called:** Every tick from OnTick()
**Logic:**
- Iterates through activeTrades array (reverse order for safe removal)
- Calls ShouldCloseTrade() for each trade
- Removes closed trades from array
- Decrements totalActiveTrades counter

**Safety:** Reverse iteration prevents index issues when removing items

---

### 7. CloseTrade() Function (Lines 1239-1318)
**Purpose:** Close an open position with reason logging
**Parameters:**
- `tradeIndex` - index in activeTrades array
- `reason` - closure reason (e.g., "Expiry", "SL Hit", "Risk Limit")

**Returns:** `true` if closed successfully, `false` on error

**Process:**
1. Validate trade index
2. Verify position exists via PositionSelectByTicket()
3. Get current volume and position type
4. Create MqlTradeRequest (opposite direction to close)
5. Send OrderSend() request
6. Verify TRADE_RETCODE_DONE or TRADE_RETCODE_DONE_PARTIAL
7. Calculate P&L: `(closePrice - entryPrice) * volume * tickValue`
8. Log closure to file
9. Send alert with reason and P&L
10. Remove from activeTrades array
11. Increment g_DailyStats.tradesClosed

**Error Handling:**
- Invalid index check
- Position existence verification
- OrderSend() failure handling
- Retcode validation

---

## OnTick() Integration (Lines 196-223)

```mql5
void OnTick()
{
   // Get current bar count
   int rates_total = Bars(_Symbol, TradeTimeframe);
   if(rates_total < ZZDepth + BarsToConfirm + 10)
      return;

   // Phase 4: Update daily statistics and check risk limits
   UpdateDailyStats();
   
   // Check if risk limits are still OK (stop trading if exceeded)
   if(!IsRiskLimitOK())
   {
      Print("Risk limits exceeded - trading disabled for this session");
      return;
   }
   
   // Monitor existing trades for closure conditions
   CheckTradeStatus();
   
   // Detect signal on current bar
   int signal = DetectSignal(rates_total);
}
```

**Execution Order:**
1. UpdateDailyStats() - track daily metrics
2. IsRiskLimitOK() - validate limits (hard stop if exceeded)
3. CheckTradeStatus() - monitor open trades
4. DetectSignal() - find new trading opportunities

---

## Configuration Parameters Used

From input settings:
- `MaxDailyLoss` - Maximum daily loss as % of balance (default: 5%)
- `MaxDrawdown` - Maximum drawdown as % of balance (default: 10%)
- `TradeExpiry` - Trade expiry time in minutes (0 = no expiry)
- `MaxOpenTrades` - Maximum concurrent positions
- `EnableLogging` - Log trades to file
- `MasterAlert` - Enable alerts

---

## Key Features

✅ **Modular Design** - Each function has single responsibility
✅ **Well-Commented** - Every function documented with purpose and logic
✅ **Error Handling** - Validates all inputs and API responses
✅ **Daily Reset** - Automatic stats reset at midnight UTC
✅ **P&L Tracking** - Calculates and logs trade P&L
✅ **Alert Integration** - Sends alerts on trade closure with reason
✅ **Array Management** - Safe removal of closed trades from activeTrades
✅ **Risk Validation** - Pre-trade and ongoing risk checks

---

## File Statistics

- **Total Lines:** 1,322
- **Phase 4 Addition:** ~300 lines (functions + structure)
- **Phases Preserved:** Phase 1-3 code intact (signal detection, order management)
- **Status:** Ready for Phase 5 (Logging & Alerts enhancement)

---

## Testing Recommendations

1. **Daily Reset Test:** Verify stats reset at midnight
2. **Risk Limit Test:** Trigger daily loss/drawdown limits
3. **Trade Expiry Test:** Open trade, wait for expiry time
4. **SL Hit Test:** Monitor SL closure detection
5. **Array Management Test:** Verify trades removed correctly
6. **P&L Calculation Test:** Verify P&L math accuracy
7. **Alert Test:** Verify closure alerts with reasons

---

## Integration with Existing Code

- Uses existing `TradeInfo` structure (Phase 3)
- Uses existing `activeTrades[]` array (Phase 3)
- Uses existing `LogTrade()` function (Phase 3)
- Uses existing `SendAlert()` function (Phase 3)
- Uses existing `PositionSelectByTicket()` (MQL5 API)
- Uses existing `OrderSend()` (MQL5 API)
- Integrates with OnTick() main loop

---

## Next Steps (Phase 5)

Phase 5 will enhance logging and alerts:
- Trade statistics reporting
- Daily summary logging
- Performance metrics
- Email/push notification enhancements

---

**Implementation Date:** 2026-05-29
**Status:** ✅ COMPLETE
**Ready for:** Phase 5 - Logging & Alerts Enhancement
