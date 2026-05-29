# MonsterArrows V3 EA - Go/No-Go Decision Criteria

## Overview
This guide provides clear, objective criteria for deciding whether to move the MonsterArrows_V3_EA from demo account testing to live account trading. Use this after completing the first week (or longer) of demo testing to make an informed decision.

---

## Part 1: Decision Framework

### Three-Tier Decision System

The go/no-go decision is based on three tiers of criteria:

**Tier 1: Critical Criteria** (Must Pass)
- If ANY critical criterion fails → **NO-GO**
- These are non-negotiable requirements

**Tier 2: Performance Criteria** (Should Pass)
- If MOST performance criteria pass → **GO**
- If MOST performance criteria fail → **NO-GO**
- These indicate EA is trading profitably

**Tier 3: Risk Criteria** (Must Pass)
- If ANY risk criterion fails → **NO-GO**
- These ensure account safety

---

## Part 2: Critical Criteria (Tier 1)

### Criterion 1: No Critical Errors

**Definition**: EA runs without crashes, disconnections, or unrecoverable errors

**How to Verify**:
1. Review Toolbox logs for entire testing period
2. Check for error messages like:
   - "Expert Advisor terminated"
   - "Cannot load Expert Advisor"
   - "OrderSend failed"
   - "Connection lost"
3. Count critical errors

**Pass Criteria**:
- [ ] Zero critical errors during testing period
- [ ] No EA crashes
- [ ] No connection losses > 5 minutes
- [ ] No unrecoverable errors

**Fail Criteria**:
- [ ] Any critical error that stops EA
- [ ] More than 1 connection loss
- [ ] Any unrecoverable error

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Fix errors before retesting

---

### Criterion 2: Proper Trade Execution

**Definition**: Trades execute at expected prices with minimal slippage

**How to Verify**:
1. Review all trades from testing period
2. For each trade, check:
   - Entry price vs. expected price
   - Exit price vs. expected price
   - Slippage amount
3. Calculate average slippage

**Pass Criteria**:
- [ ] Average slippage < 2 pips
- [ ] Maximum slippage < 5 pips
- [ ] No trades executed at extreme prices
- [ ] Entry/exit prices match log file

**Fail Criteria**:
- [ ] Average slippage > 3 pips
- [ ] Maximum slippage > 10 pips
- [ ] Trades executed at extreme prices
- [ ] Prices don't match log file

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Investigate execution issues

---

### Criterion 3: Accurate Logging

**Definition**: All trades are logged correctly with accurate data

**How to Verify**:
1. Open log file: `MonsterArrows_V3_EA.log`
2. Count entry messages
3. Count exit messages
4. Compare to Account History
5. Verify prices and times match

**Pass Criteria**:
- [ ] Entry messages = number of trades
- [ ] Exit messages = number of closed trades
- [ ] Prices in log match Account History (< 1 pip)
- [ ] Times in log match Account History (< 1 minute)
- [ ] P&L in log matches Account History (< $1)
- [ ] No missing entries
- [ ] No duplicate entries

**Fail Criteria**:
- [ ] Missing entry/exit messages
- [ ] Prices don't match (> 1 pip)
- [ ] Times don't match (> 1 minute)
- [ ] P&L doesn't match (> $1)
- [ ] Duplicate entries

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Fix logging before retesting

---

### Criterion 4: Risk Limits Respected

**Definition**: EA respects all configured risk limits

**How to Verify**:
1. Review daily P&L for entire testing period
2. Check maximum daily loss
3. Check maximum drawdown
4. Check max open trades
5. Check max trades per day

**Pass Criteria**:
- [ ] Daily loss never exceeded 5% limit
- [ ] Drawdown never exceeded 10% limit
- [ ] Max open trades never exceeded 3
- [ ] Max trades per day never exceeded 10
- [ ] No margin calls or forced liquidations

**Fail Criteria**:
- [ ] Daily loss exceeded 5% limit
- [ ] Drawdown exceeded 10% limit
- [ ] Max open trades exceeded 3
- [ ] Max trades per day exceeded 10
- [ ] Any margin call or forced liquidation

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust risk parameters and retest

---

## Part 3: Performance Criteria (Tier 2)

### Criterion 5: Minimum Trade Count

**Definition**: EA generates sufficient trades to validate strategy

**How to Verify**:
1. Count total trades during testing period
2. Calculate trades per day average
3. Note if trades are consistent

**Pass Criteria**:
- [ ] Minimum 10 total trades (for 1-week test)
- [ ] Minimum 2 trades per day average
- [ ] Trades distributed across multiple days
- [ ] At least 5 winning trades
- [ ] At least 5 losing trades

**Fail Criteria**:
- [ ] Fewer than 10 total trades
- [ ] Fewer than 2 trades per day average
- [ ] All trades in single day
- [ ] Fewer than 5 winning trades
- [ ] Fewer than 5 losing trades

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust signal parameters to generate more trades

---

### Criterion 6: Win Rate

**Definition**: Percentage of trades that are profitable

**How to Verify**:
1. Count winning trades
2. Count losing trades
3. Calculate win rate: Wins / (Wins + Losses) × 100%

**Pass Criteria**:
- [ ] Win rate ≥ 50%
- [ ] Winning trades ≥ losing trades
- [ ] Consistent win rate across days

**Fail Criteria**:
- [ ] Win rate < 40%
- [ ] Losing trades > winning trades
- [ ] Win rate varies wildly day to day

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust signal parameters to improve win rate

---

### Criterion 7: Profit Factor

**Definition**: Ratio of total wins to total losses

**How to Verify**:
1. Sum all winning trades: $[Total Wins]
2. Sum all losing trades: $[Total Losses]
3. Calculate profit factor: Total Wins / Total Losses

**Pass Criteria**:
- [ ] Profit factor ≥ 1.5
- [ ] Total wins > total losses
- [ ] Consistent profit factor across days

**Fail Criteria**:
- [ ] Profit factor < 1.0
- [ ] Total losses > total wins
- [ ] Profit factor varies wildly

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust parameters to improve profitability

---

### Criterion 8: Risk/Reward Ratio

**Definition**: Average profit per winning trade vs. average loss per losing trade

**How to Verify**:
1. Calculate average win: Total Wins / Number of Wins
2. Calculate average loss: Total Losses / Number of Losses
3. Calculate ratio: Average Win / Average Loss

**Pass Criteria**:
- [ ] Risk/Reward ratio ≥ 1.5
- [ ] Average win > average loss
- [ ] Ratio is consistent across trades

**Fail Criteria**:
- [ ] Risk/Reward ratio < 1.0
- [ ] Average loss > average win
- [ ] Ratio varies wildly

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust TP/SL parameters

---

### Criterion 9: Overall Profitability

**Definition**: Net profit for testing period

**How to Verify**:
1. Calculate: Ending Balance - Starting Balance
2. Calculate profit percentage: (Profit / Starting Balance) × 100%

**Pass Criteria**:
- [ ] Net profit > 0 (positive)
- [ ] Profit percentage ≥ 1% (for 1-week test)
- [ ] Profit is consistent (not from single lucky trade)

**Fail Criteria**:
- [ ] Net loss (negative profit)
- [ ] Profit percentage < 0%
- [ ] Profit from single trade (not repeatable)

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Adjust parameters and retest

---

## Part 4: Risk Criteria (Tier 3)

### Criterion 10: Maximum Drawdown

**Definition**: Largest peak-to-trough decline in account equity

**How to Verify**:
1. Track daily equity throughout testing period
2. Find highest equity point
3. Find lowest equity point after that
4. Calculate drawdown: (Peak - Trough) / Peak × 100%

**Pass Criteria**:
- [ ] Maximum drawdown ≤ 5%
- [ ] Drawdown recovered within 2-3 days
- [ ] No drawdown > 3% on any single day

**Fail Criteria**:
- [ ] Maximum drawdown > 10%
- [ ] Drawdown not recovered
- [ ] Multiple days with > 3% drawdown

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Reduce risk parameters

---

### Criterion 11: Largest Single Loss

**Definition**: Largest loss on any single trade

**How to Verify**:
1. Review all trades
2. Find trade with largest loss
3. Calculate loss as percentage of account

**Pass Criteria**:
- [ ] Largest loss ≤ 2% of account
- [ ] Largest loss ≤ 2× expected risk per trade
- [ ] No trade loss > $200 (for $10,000 account)

**Fail Criteria**:
- [ ] Largest loss > 3% of account
- [ ] Largest loss > 3× expected risk per trade
- [ ] Any trade loss > $300

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Verify SL placement and risk calculation

---

### Criterion 12: Consecutive Losses

**Definition**: Maximum number of losing trades in a row

**How to Verify**:
1. Review all trades in chronological order
2. Count consecutive losing trades
3. Find longest losing streak

**Pass Criteria**:
- [ ] Maximum consecutive losses ≤ 5
- [ ] Losing streaks are followed by winning trades
- [ ] No losing streak > 3 days

**Fail Criteria**:
- [ ] Maximum consecutive losses > 7
- [ ] Losing streaks not followed by wins
- [ ] Losing streak > 5 days

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Investigate signal quality

---

### Criterion 13: Margin Safety

**Definition**: Minimum margin level maintained during testing

**How to Verify**:
1. Track margin level throughout testing period
2. Find minimum margin level reached
3. Note if any margin calls occurred

**Pass Criteria**:
- [ ] Minimum margin level ≥ 500%
- [ ] No margin calls
- [ ] No forced liquidations
- [ ] Margin level never below 300%

**Fail Criteria**:
- [ ] Minimum margin level < 300%
- [ ] Any margin call occurred
- [ ] Any forced liquidation
- [ ] Margin level ever below 200%

**Decision**:
- **PASS**: Continue to next criteria
- **FAIL**: **NO-GO** - Reduce lot size or risk per trade

---

## Part 5: Decision Matrix

### Quick Reference Decision Table

Use this table to quickly determine go/no-go status:

```
DECISION MATRIX
===============

TIER 1: CRITICAL CRITERIA
┌─────────────────────────────────────┬────────┐
│ Criterion                           │ Status │
├─────────────────────────────────────┼────────┤
│ 1. No Critical Errors               │ [ ]    │
│ 2. Proper Trade Execution           │ [ ]    │
│ 3. Accurate Logging                 │ [ ]    │
│ 4. Risk Limits Respected            │ [ ]    │
└─────────────────────────────────────┴────────┘
Result: [ ] ALL PASS → Continue to Tier 2
        [ ] ANY FAIL → NO-GO

TIER 2: PERFORMANCE CRITERIA
┌─────────────────────────────────────┬────────┐
│ Criterion                           │ Status │
├─────────────────────────────────────┼────────┤
│ 5. Minimum Trade Count              │ [ ]    │
│ 6. Win Rate ≥ 50%                   │ [ ]    │
│ 7. Profit Factor ≥ 1.5              │ [ ]    │
│ 8. Risk/Reward Ratio ≥ 1.5          │ [ ]    │
│ 9. Overall Profitability > 0        │ [ ]    │
└─────────────────────────────────────┴────────┘
Result: [ ] MOST PASS → Continue to Tier 3
        [ ] MOST FAIL → NO-GO

TIER 3: RISK CRITERIA
┌─────────────────────────────────────┬────────┐
│ Criterion                           │ Status │
├─────────────────────────────────────┼────────┤
│ 10. Maximum Drawdown ≤ 5%           │ [ ]    │
│ 11. Largest Single Loss ≤ 2%        │ [ ]    │
│ 12. Consecutive Losses ≤ 5          │ [ ]    │
│ 13. Margin Safety ≥ 500%            │ [ ]    │
└─────────────────────────────────────┴────────┘
Result: [ ] ALL PASS → GO TO LIVE
        [ ] ANY FAIL → NO-GO
```

---

## Part 6: Go/No-Go Decision Process

### Step 1: Gather Data
1. Compile all monitoring logs from testing period
2. Calculate all performance metrics
3. Review all trades in Account History
4. Check log file for errors
5. Document all findings

### Step 2: Evaluate Tier 1 (Critical Criteria)
1. Check each critical criterion
2. Mark PASS or FAIL
3. If ANY fail → **DECISION: NO-GO**
4. If ALL pass → Continue to Step 3

### Step 3: Evaluate Tier 2 (Performance Criteria)
1. Check each performance criterion
2. Mark PASS or FAIL
3. Count passes and fails
4. If MOST pass → Continue to Step 4
5. If MOST fail → **DECISION: NO-GO**

### Step 4: Evaluate Tier 3 (Risk Criteria)
1. Check each risk criterion
2. Mark PASS or FAIL
3. If ANY fail → **DECISION: NO-GO**
4. If ALL pass → **DECISION: GO**

### Step 5: Document Decision
Create decision document:

```
GO/NO-GO DECISION DOCUMENT
==========================

TESTING PERIOD: [Start Date] to [End Date]
DURATION: [# Days]
ACCOUNT: Demo - EURUSD H1

TIER 1: CRITICAL CRITERIA
Criterion 1 (No Critical Errors): [ ] PASS [ ] FAIL
Criterion 2 (Proper Trade Execution): [ ] PASS [ ] FAIL
Criterion 3 (Accurate Logging): [ ] PASS [ ] FAIL
Criterion 4 (Risk Limits Respected): [ ] PASS [ ] FAIL
Tier 1 Result: [ ] ALL PASS [ ] ANY FAIL

TIER 2: PERFORMANCE CRITERIA
Criterion 5 (Minimum Trade Count): [ ] PASS [ ] FAIL
Criterion 6 (Win Rate ≥ 50%): [ ] PASS [ ] FAIL
Criterion 7 (Profit Factor ≥ 1.5): [ ] PASS [ ] FAIL
Criterion 8 (Risk/Reward Ratio ≥ 1.5): [ ] PASS [ ] FAIL
Criterion 9 (Overall Profitability > 0): [ ] PASS [ ] FAIL
Tier 2 Result: [ ] MOST PASS [ ] MOST FAIL

TIER 3: RISK CRITERIA
Criterion 10 (Maximum Drawdown ≤ 5%): [ ] PASS [ ] FAIL
Criterion 11 (Largest Single Loss ≤ 2%): [ ] PASS [ ] FAIL
Criterion 12 (Consecutive Losses ≤ 5): [ ] PASS [ ] FAIL
Criterion 13 (Margin Safety ≥ 500%): [ ] PASS [ ] FAIL
Tier 3 Result: [ ] ALL PASS [ ] ANY FAIL

FINAL DECISION: [ ] GO TO LIVE [ ] NO-GO

JUSTIFICATION:
[Explain decision based on criteria]

NEXT STEPS:
[If GO: Prepare for live trading]
[If NO-GO: Describe adjustments needed]

SIGNED: _________________ DATE: _________
```

---

## Part 7: If Decision is NO-GO

### Step 1: Identify Root Cause
Determine why criteria failed:
- [ ] Signal quality issue (too many false signals)
- [ ] Risk management issue (losses too large)
- [ ] Execution issue (slippage or errors)
- [ ] Logging issue (data not recorded properly)
- [ ] Technical issue (EA crashes or errors)

### Step 2: Adjust Parameters
Based on root cause, adjust:

**If signal quality is poor:**
- Increase BarsToConfirm (more confirmation)
- Enable RequireBothHTF (stricter signals)
- Adjust ZigZag parameters
- Adjust FVG/Sweep sensitivity

**If risk management is poor:**
- Reduce RiskPercent (lower risk per trade)
- Reduce MaxOpenTrades (fewer simultaneous trades)
- Reduce MaxTradesPerDay (fewer trades per day)
- Increase SL_ATR_Mult (wider stop loss)

**If execution is poor:**
- Check broker connection
- Verify symbol and timeframe
- Check for news events affecting spreads
- Try different symbol or timeframe

**If logging is poor:**
- Verify EnableLogging is true
- Check log file location
- Verify file permissions
- Restart EA

**If technical issues:**
- Recompile EA
- Restart MetaTrader 5
- Check for error messages
- Review EA code

### Step 3: Retest
1. Apply parameter adjustments
2. Run demo testing for another week
3. Collect new performance data
4. Re-evaluate against criteria
5. Make new go/no-go decision

### Step 4: Document Changes
```
PARAMETER ADJUSTMENT LOG
========================

ORIGINAL PARAMETERS:
RiskPercent: 1.0%
MaxOpenTrades: 3
BarsToConfirm: 2
[Other parameters]

ADJUSTED PARAMETERS:
RiskPercent: 0.5%
MaxOpenTrades: 2
BarsToConfirm: 3
[Other parameters]

REASON FOR ADJUSTMENT:
[Explain why each parameter was changed]

EXPECTED IMPACT:
[Describe expected improvement]
```

---

## Part 8: If Decision is GO

### Step 1: Prepare for Live Trading
1. Review all documentation
2. Verify all settings are correct
3. Create backup of EA and settings
4. Prepare live account

### Step 2: Live Account Setup
1. Create live trading account (if not already done)
2. Fund account with initial capital
3. Configure account settings
4. Verify connection

### Step 3: Transition to Live
1. Attach EA to live chart
2. Start with reduced lot size (50% of demo)
3. Monitor closely for first week
4. Gradually increase lot size if performance is good

### Step 4: Ongoing Monitoring
1. Continue daily monitoring
2. Track performance metrics
3. Compare to demo performance
4. Adjust if needed

---

## Part 9: Decision Criteria Summary

### Minimum Requirements for GO Decision

```
MINIMUM REQUIREMENTS FOR GO
============================

CRITICAL (ALL MUST PASS):
✓ Zero critical errors
✓ Proper trade execution (< 2 pips slippage)
✓ Accurate logging (100% of trades logged)
✓ Risk limits respected (no violations)

PERFORMANCE (MOST MUST PASS):
✓ Minimum 10 trades
✓ Win rate ≥ 50%
✓ Profit factor ≥ 1.5
✓ Risk/Reward ratio ≥ 1.5
✓ Net profit > 0

RISK (ALL MUST PASS):
✓ Maximum drawdown ≤ 5%
✓ Largest loss ≤ 2% of account
✓ Consecutive losses ≤ 5
✓ Margin level ≥ 500%
```

---

## Part 10: Final Checklist

### Pre-Decision Checklist
- [ ] All monitoring logs compiled
- [ ] All performance metrics calculated
- [ ] All trades reviewed
- [ ] All criteria evaluated
- [ ] Root causes identified (if NO-GO)
- [ ] Decision document completed
- [ ] Justification documented
- [ ] Next steps planned

### Post-Decision Checklist (if GO)
- [ ] Live account prepared
- [ ] EA settings verified
- [ ] Backup created
- [ ] Initial lot size reduced
- [ ] Monitoring plan ready
- [ ] Risk management confirmed

### Post-Decision Checklist (if NO-GO)
- [ ] Root causes documented
- [ ] Parameter adjustments planned
- [ ] Retest schedule set
- [ ] Backup of current settings saved
- [ ] Adjustment log created

---

## Summary

**Go/No-Go Decision Complete When:**
1. ✓ All 13 criteria evaluated
2. ✓ Tier 1 (Critical) criteria all pass
3. ✓ Tier 2 (Performance) criteria mostly pass
4. ✓ Tier 3 (Risk) criteria all pass
5. ✓ Decision clearly documented
6. ✓ Justification provided
7. ✓ Next steps planned
8. ✓ Ready for live trading (if GO) or retest (if NO-GO)

**Phase 7 Complete**: All deployment and monitoring documentation created. Ready for demo account testing and go/no-go decision.
