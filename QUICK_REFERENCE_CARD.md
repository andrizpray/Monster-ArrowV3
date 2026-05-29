# MonsterArrows V3 EA - Phase 7 Quick Reference Card

**Print this card and keep it handy during demo testing**

---

## 6-Step Deployment Process

### Step 1: COMPILE EA (1-2 hours)
**File:** DEPLOYMENT_GUIDE.md

```
1. Open MetaEditor (F4 in MT5)
2. Open: MonsterArrows_V3_EA.mq5
3. Click Compile (F5)
4. Verify: 0 error(s), 0 warning(s)
5. Check: .ex5 file created in MQL5\Experts\
6. Restart MT5 if needed
```

**Success:** EA appears in Navigator → Expert Advisors

---

### Step 2: SETUP DEMO ACCOUNT (30 minutes)
**File:** DEMO_ACCOUNT_SETUP.md

```
1. Open MT5 → File → Login
2. Create demo account (if needed)
3. Verify: Account shows "Demo"
4. Tools → Options → Expert Advisors
5. Check: Allow automated trading ✓
6. Select symbol: EURUSD
7. Select timeframe: H1
8. Verify balance: $10,000
```

**Success:** Demo account connected and ready

---

### Step 3: ATTACH EA (30 minutes)
**File:** EA_ATTACHMENT_GUIDE.md

```
1. Open EURUSD H1 chart
2. Navigator → Expert Advisors → MonsterArrows_V3_EA
3. Drag to chart (or right-click → Attach)
4. Set parameters:
   - EnableTrading: true
   - RiskPercent: 0.5% (Week 1)
   - MaxOpenTrades: 2
   - MaxTradesPerDay: 5
5. Click OK
6. Verify: EA icon in chart title
```

**Success:** EA running on chart, no errors

---

### Step 4: MONITOR FIRST WEEK (30-60 min/day)
**File:** MONITORING_CHECKLIST.md

```
DAILY ROUTINE:
Morning (5 min):
  □ Check connection status
  □ Verify account balance
  □ Check EA parameters

During Day (every 1-2 hours):
  □ Check open trades
  □ Verify equity
  □ Check for errors

Evening (10 min):
  □ Record daily P&L
  □ Count trades
  □ Check for red flags
```

**Success:** Complete monitoring logs for week

---

### Step 5: VALIDATE TRADES (Ongoing)
**File:** TRADE_VALIDATION_GUIDE.md

```
FOR EACH TRADE:
Entry:
  □ Entry price reasonable
  □ SL correctly calculated
  □ TP correctly calculated
  □ Lot size correct

Exit:
  □ Exit at SL or TP
  □ Exit price reasonable
  □ P&L calculation correct
  □ Logged in file
```

**Success:** All trades validated and verified

---

### Step 6: MAKE DECISION (1-2 hours)
**File:** GO_NO_GO_CRITERIA.md

```
EVALUATE 13 CRITERIA:

Tier 1 (ALL must pass):
  □ No critical errors
  □ Proper execution (< 2 pips)
  □ Accurate logging (100%)
  □ Risk limits respected

Tier 2 (MOST must pass):
  □ Min 10 trades
  □ Win rate ≥ 50%
  □ Profit factor ≥ 1.5
  □ Risk/Reward ≥ 1.5
  □ Net profit > 0

Tier 3 (ALL must pass):
  □ Max drawdown ≤ 5%
  □ Largest loss ≤ 2%
  □ Consecutive losses ≤ 5
  □ Margin level ≥ 500%

DECISION: [ ] GO [ ] NO-GO
```

**Success:** Clear decision with documentation

---

## Key Metrics to Track Daily

```
DAILY METRICS CHECKLIST
=======================

Opening:
  □ Balance: $________
  □ Equity: $________
  □ Margin Level: ____%

During Day:
  □ Trades opened: ___
  □ Trades closed: ___
  □ Current equity: $________
  □ Current drawdown: ____%

Closing:
  □ Balance: $________
  □ Daily P&L: $________
  □ Win rate: ____%
  □ Max drawdown: ____%
```

---

## Red Flags - STOP TRADING IF:

```
CRITICAL RED FLAGS
==================

STOP IMMEDIATELY IF:
  ✗ Margin level < 500%
  ✗ Daily loss > 5% ($500)
  ✗ Drawdown > 10% ($1,000)
  ✗ EA crashes or errors
  ✗ Connection lost > 5 min
  ✗ Win rate < 30%
  ✗ Consecutive losses > 5
  ✗ Largest loss > 3% ($300)
  ✗ Slippage > 5 pips
  ✗ Trades not logging

ACTION:
1. Stop EA immediately
2. Close open positions
3. Document issue
4. Investigate cause
5. Fix before restarting
```

---

## Parameter Quick Reference

```
WEEK 1 (CONSERVATIVE - RECOMMENDED)
====================================
EnableTrading:          true
MaxOpenTrades:          2
MaxTradesPerDay:        5
RiskPercent:            0.5%
BarsToConfirm:          2
RequireBothHTF:         true
EnableLogging:          true

WEEK 2+ (MODERATE)
==================
EnableTrading:          true
MaxOpenTrades:          3
MaxTradesPerDay:        10
RiskPercent:            1.0%
BarsToConfirm:          2
RequireBothHTF:         true
EnableLogging:          true

ADVANCED (ONLY AFTER SUCCESS)
==============================
EnableTrading:          true
MaxOpenTrades:          5
MaxTradesPerDay:        15
RiskPercent:            2.0%
BarsToConfirm:          1
RequireBothHTF:         false
EnableLogging:          true
```

---

## File Locations

```
EA SOURCE:
C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\
[TerminalID]\MQL5\Experts\MonsterArrows_V3_EA.mq5

EA COMPILED:
C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\
[TerminalID]\MQL5\Experts\MonsterArrows_V3_EA.ex5

LOG FILE:
C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\
[TerminalID]\MQL5\Logs\MonsterArrows_V3_EA.log

DOCUMENTATION:
/home/ubuntu/*.md
```

---

## Troubleshooting Quick Links

```
ISSUE                          SOLUTION
─────────────────────────────────────────────────
EA won't compile               → DEPLOYMENT_GUIDE.md Part 7
EA won't attach                → EA_ATTACHMENT_GUIDE.md Part 7
EA won't trade                 → EA_ATTACHMENT_GUIDE.md Part 7
Trades not logging             → TRADE_VALIDATION_GUIDE.md Part 6
Slippage issues                → TRADE_VALIDATION_GUIDE.md Part 6
Performance issues             → MONITORING_CHECKLIST.md Part 4
Decision uncertainty           → GO_NO_GO_CRITERIA.md Part 5
Account setup issues           → DEMO_ACCOUNT_SETUP.md Part 8
General questions              → PHASE_7_INDEX.md
```

---

## Weekly Performance Targets

```
WEEK 1 TARGETS (Conservative)
==============================
Minimum trades:         5-10
Target win rate:        > 50%
Target profit factor:   > 1.5
Target profit:          > 1% ($100+)
Max drawdown:           < 5% ($500)
Largest loss:           < 2% ($200)

DECISION CRITERIA:
If all targets met → GO to live trading
If targets missed → Adjust and retest
```

---

## Daily Checklist

```
MORNING (5 minutes)
  □ Check connection
  □ Verify account balance
  □ Check EA parameters
  □ Review overnight activity

DURING DAY (every 1-2 hours)
  □ Check open trades
  □ Verify equity
  □ Check for errors
  □ Monitor margin level

EVENING (10 minutes)
  □ Record daily P&L
  □ Count trades
  □ Check for red flags
  □ Update monitoring log

WEEKLY (Friday evening)
  □ Calculate weekly stats
  □ Review all trades
  □ Assess signal quality
  □ Evaluate risk management
  □ Make go/no-go decision
```

---

## Decision Framework

```
TIER 1: CRITICAL (ALL must pass)
  1. No critical errors
  2. Proper execution (< 2 pips)
  3. Accurate logging (100%)
  4. Risk limits respected

TIER 2: PERFORMANCE (MOST must pass)
  5. Min 10 trades
  6. Win rate ≥ 50%
  7. Profit factor ≥ 1.5
  8. Risk/Reward ≥ 1.5
  9. Net profit > 0

TIER 3: RISK (ALL must pass)
  10. Max drawdown ≤ 5%
  11. Largest loss ≤ 2%
  12. Consecutive losses ≤ 5
  13. Margin level ≥ 500%

DECISION:
  GO if: Tier 1 ✓ + Tier 2 (most) ✓ + Tier 3 ✓
  NO-GO if: Any Tier 1 ✗ OR Most Tier 2 ✗ OR Any Tier 3 ✗
```

---

## Contact & Support

```
FOR HELP:
1. Check relevant guide section
2. Review troubleshooting section
3. Consult checklists
4. Review decision criteria
5. Document findings

DOCUMENTS:
  DEPLOYMENT_GUIDE.md
  DEMO_ACCOUNT_SETUP.md
  EA_ATTACHMENT_GUIDE.md
  MONITORING_CHECKLIST.md
  TRADE_VALIDATION_GUIDE.md
  GO_NO_GO_CRITERIA.md
  PHASE_7_INDEX.md
```

---

## Important Reminders

```
✓ Start with CONSERVATIVE parameters (Week 1)
✓ Monitor DAILY - don't skip days
✓ VALIDATE every trade
✓ DOCUMENT everything
✓ STOP if red flags occur
✓ Use OBJECTIVE criteria for decision
✓ Don't make EMOTIONAL decisions
✓ FOLLOW the procedures exactly
✓ KEEP all logs and documentation
✓ BACKUP EA file before changes
```

---

## Next Steps After Phase 7

```
IF GO DECISION:
  1. Prepare live trading account
  2. Fund with initial capital
  3. Attach EA to live chart
  4. Start with 50% of demo lot size
  5. Monitor closely for first week
  6. Gradually increase lot size

IF NO-GO DECISION:
  1. Identify root cause
  2. Adjust parameters
  3. Run another week of demo testing
  4. Re-evaluate against criteria
  5. Make new go/no-go decision
```

---

## Quick Reference Summary

```
PHASE 7 QUICK REFERENCE
=======================

DOCUMENTS:        7 comprehensive guides
CHECKLISTS:       100+ templates
PROCEDURES:       400+ step-by-step
PAGES:            ~80 pages
CRITERIA:         13 objective criteria
PARAMETERS:       30+ configurable
METRICS:          13 key metrics
RED FLAGS:        10 critical flags

STATUS:           ✓ COMPLETE
READY FOR:        Demo account testing
NEXT PHASE:       Phase 8 - Live Trading

START HERE:       PHASE_7_INDEX.md
```

---

**Print this card and keep it with you during demo testing**

**Last Updated: May 29, 2026**

**Phase 7 Status: ✓ COMPLETE**
