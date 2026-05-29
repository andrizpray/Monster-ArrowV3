# Phase 4: Risk Management - Quick Reference

## Functions Added (6 Total)

| Function | Purpose | Returns | Called From |
|----------|---------|---------|-------------|
| `UpdateDailyStats()` | Track daily P&L, equity, drawdown | void | OnTick() |
| `IsRiskLimitOK()` | Check daily loss & drawdown limits | bool | OnTick() |
| `ValidateRiskLimits(potentialLoss)` | Pre-trade risk validation | bool | OpenTrade() |
| `ShouldCloseTrade(tradeIndex)` | Check if trade should close | bool | CheckTradeStatus() |
| `CheckTradeStatus()` | Monitor all trades for closure | void | OnTick() |
| `CloseTrade(tradeIndex, reason)` | Close position with reason | bool | Manual/CheckTradeStatus() |

## Data Structure Added

```mql5
struct DailyStats {
   datetime dayStart;        // Day start timestamp
   double   startBalance;    // Opening balance
   double   maxEquity;       // Peak equity
   double   minEquity;       // Lowest equity
   int      tradesOpened;    // Trades opened today
   int      tradesClosed;    // Trades closed today
   double   totalPnL;        // Daily P&L
   double   maxDrawdown;     // Max drawdown %
};
```

## Closure Conditions Monitored

1. **Trade Expiry** - Minutes open > TradeExpiry setting
2. **SL Hit** - Price reached stop loss level
3. **Position Not Found** - Already closed by broker
4. **Risk Limits** - Daily loss or drawdown exceeded

## Risk Limits Checked

- **Daily Loss Limit:** `(startBalance - currentEquity) > (startBalance * MaxDailyLoss%)`
- **Drawdown Limit:** `(maxEquity - currentEquity) / maxEquity * 100% > MaxDrawdown%`

## OnTick() Execution Flow

```
OnTick()
  ├─ UpdateDailyStats()      [Track metrics]
  ├─ IsRiskLimitOK()         [Hard stop if limits exceeded]
  ├─ CheckTradeStatus()      [Monitor open trades]
  └─ DetectSignal()          [Find new signals]
```

## Usage Examples

### Check if trading allowed:
```mql5
if(!IsRiskLimitOK()) {
   Print("Trading disabled - risk limits exceeded");
   return;
}
```

### Validate before opening trade:
```mql5
double potentialLoss = atr * SL_ATR_Mult * lot * tickValue;
if(!ValidateRiskLimits(potentialLoss)) {
   Print("Trade would violate risk limits");
   return false;
}
```

### Close a trade:
```mql5
CloseTrade(0, "Expiry");  // Close first trade due to expiry
CloseTrade(1, "SL Hit");  // Close second trade - SL hit
```

## Key Features

✅ Automatic daily reset at midnight UTC
✅ Continuous equity & drawdown monitoring
✅ Pre-trade risk validation
✅ Multiple closure condition checks
✅ P&L calculation on close
✅ Alert & logging integration
✅ Safe array management

## Configuration Parameters

- `MaxDailyLoss` - Max daily loss % (default: 5%)
- `MaxDrawdown` - Max drawdown % (default: 10%)
- `TradeExpiry` - Expiry minutes (0 = no expiry)
- `EnableLogging` - Log trades (default: true)
- `MasterAlert` - Send alerts (default: true)

## File Location
`/home/ubuntu/MonsterArrows_V3_EA.mq5` (Lines 1019-1322)

## Status
✅ Phase 4 Complete - Ready for Phase 5
