# MonsterArrows V3 EA - First Week Monitoring Checklist

## Overview
This checklist guides you through monitoring the MonsterArrows_V3_EA during its first week of demo trading. Proper monitoring ensures you catch issues early and validate the EA's performance before live trading.

---

## Part 1: Daily Monitoring Routine

### Morning Routine (Start of Trading Day)

**Time: 30 minutes before market open**

#### Step 1: System Check
- [ ] MetaTrader 5 running and connected
- [ ] Demo account shows "Connected" status
- [ ] Chart displays current price action
- [ ] EA icon visible in chart title bar
- [ ] No error messages in Toolbox

#### Step 2: Account Status Review
1. Open **Account History** (Ctrl+H)
2. Verify:
   - [ ] Balance: Should match previous day's closing balance
   - [ ] Equity: Should equal Balance (no open trades yet)
   - [ ] Free Margin: Should equal Balance
   - [ ] Margin Level: Should be > 1000% (no margin issues)
3. Document in daily log:
   ```
   DATE: [Date]
   OPENING BALANCE: $[Amount]
   OPENING EQUITY: $[Amount]
   OPENING MARGIN LEVEL: [%]
   ```

#### Step 3: EA Parameter Verification
1. Right-click on chart → **Expert Advisors** → **Edit Expert Advisor**
2. Verify parameters haven't changed:
   - [ ] EnableTrading: true
   - [ ] RiskPercent: 0.5% (or configured value)
   - [ ] MaxOpenTrades: 2 (or configured value)
   - [ ] EnableLogging: true
3. Click **OK** (don't change anything)

#### Step 4: Chart Preparation
1. Verify chart shows:
   - [ ] At least 100 candles of history
   - [ ] Current price action visible
   - [ ] Bid/Ask prices updating
   - [ ] No gaps or missing data
2. Note current price level:
   ```
   CURRENT PRICE: [Price]
   CURRENT TIME: [Time]
   ```

#### Step 5: Log File Check
1. Open log file: `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Logs\MonsterArrows_V3_EA.log`
2. Verify file exists and is readable
3. Note last entry time (should be from previous day)
4. Check for any error messages

---

### During Trading Hours (Continuous Monitoring)

**Frequency: Check every 1-2 hours during active trading**

#### Step 1: Trade Status Check (Every 1-2 Hours)
1. Look at chart for open positions
2. Check **Account History** for new trades
3. For each open trade, verify:
   - [ ] Entry price is reasonable
   - [ ] Stop loss is set
   - [ ] Take profit is set
   - [ ] Lot size is appropriate
4. Document in hourly log:
   ```
   TIME: [Time]
   OPEN TRADES: [Number]
   TRADE 1: [Symbol] [BUY/SELL] @ [Price] SL:[SL] TP:[TP]
   ACCOUNT EQUITY: $[Amount]
   ACCOUNT BALANCE: $[Amount]
   ```

#### Step 2: Price Action Review
1. Observe chart for:
   - [ ] Trending market or ranging market
   - [ ] Volatility level (high/normal/low)
   - [ ] Support/resistance levels
   - [ ] Any major news events affecting price
2. Note observations:
   ```
   MARKET CONDITION: [Trending/Ranging]
   VOLATILITY: [High/Normal/Low]
   NOTES: [Any observations]
   ```

#### Step 3: EA Activity Check
1. Check Toolbox for new messages
2. Look for:
   - [ ] Trade open messages
   - [ ] Trade close messages
   - [ ] Error messages
   - [ ] Signal detection messages
3. Document any unusual activity:
   ```
   EA ACTIVITY: [Description]
   MESSAGES: [Any errors or alerts]
   ```

#### Step 4: Risk Monitoring
1. Calculate current drawdown:
   ```
   OPENING BALANCE: $10,000
   CURRENT EQUITY: $[Amount]
   CURRENT DRAWDOWN: $[Amount] ([%])
   ```
2. Verify drawdown is within limits:
   - [ ] Daily drawdown < 5% ($500)
   - [ ] Total drawdown < 10% ($1,000)
3. If drawdown exceeds limits:
   - [ ] Note time and reason
   - [ ] Prepare to stop EA if needed
   - [ ] Document for analysis

#### Step 5: Margin Check
1. Verify margin level:
   - [ ] Margin Level > 1000% (safe)
   - [ ] Margin Level > 500% (caution)
   - [ ] Margin Level < 500% (danger - stop trading)
2. If margin level drops below 500%:
   - [ ] Close some positions manually
   - [ ] Reduce lot size
   - [ ] Stop EA if necessary

---

### End of Day Routine (After Market Close)

**Time: 30 minutes after market close**

#### Step 1: Trade Summary
1. Open **Account History** (Ctrl+H)
2. Review all trades from the day:
   - [ ] Number of trades opened
   - [ ] Number of trades closed
   - [ ] Winning trades
   - [ ] Losing trades
   - [ ] Total profit/loss
3. Document in daily summary:
   ```
   TRADES OPENED: [Number]
   TRADES CLOSED: [Number]
   WINNING TRADES: [Number]
   LOSING TRADES: [Number]
   DAILY P&L: $[Amount]
   WIN RATE: [%]
   ```

#### Step 2: Account Status Summary
1. Check final account status:
   - [ ] Closing Balance
   - [ ] Closing Equity
   - [ ] Daily Profit/Loss
   - [ ] Cumulative Profit/Loss
2. Document:
   ```
   CLOSING BALANCE: $[Amount]
   CLOSING EQUITY: $[Amount]
   DAILY P&L: $[Amount]
   CUMULATIVE P&L: $[Amount]
   ```

#### Step 3: Open Positions Review
1. Check for any open positions:
   - [ ] If trades are open, note entry price and time
   - [ ] Verify SL/TP are set correctly
   - [ ] Estimate when trade might close
2. Document:
   ```
   OPEN POSITIONS: [Number]
   POSITION 1: [Symbol] [BUY/SELL] @ [Price]
   EXPECTED CLOSE: [Time/Condition]
   ```

#### Step 4: Log File Review
1. Open log file: `MonsterArrows_V3_EA.log`
2. Review all entries from the day
3. Look for:
   - [ ] Any error messages
   - [ ] Unusual trade patterns
   - [ ] Signal detection issues
   - [ ] Risk limit violations
4. Document any issues:
   ```
   LOG REVIEW NOTES: [Any issues found]
   ```

#### Step 5: Daily Report
Create daily report:
```
DAILY MONITORING REPORT
=======================
DATE: [Date]
OPENING BALANCE: $[Amount]
CLOSING BALANCE: $[Amount]
DAILY P&L: $[Amount]
TRADES: [Number opened] / [Number closed]
WIN RATE: [%]
MAX DRAWDOWN: [%]
ISSUES: [Any issues encountered]
NOTES: [Any observations]
```

---

## Part 2: Weekly Monitoring Summary

### End of Week Review (Friday After Market Close)

#### Step 1: Weekly Performance Summary
Compile weekly statistics:
```
WEEKLY PERFORMANCE SUMMARY
==========================
WEEK: [Week 1 of Demo Testing]
STARTING BALANCE: $10,000
ENDING BALANCE: $[Amount]
WEEKLY P&L: $[Amount]
WEEKLY P&L %: [%]

TRADES SUMMARY
Total Trades: [Number]
Winning Trades: [Number]
Losing Trades: [Number]
Win Rate: [%]
Profit Factor: [Winning $ / Losing $]

RISK METRICS
Max Daily Loss: $[Amount] ([%])
Max Drawdown: $[Amount] ([%])
Largest Win: $[Amount]
Largest Loss: $[Amount]
Average Win: $[Amount]
Average Loss: $[Amount]
```

#### Step 2: Trade Quality Analysis
Review all trades from the week:
1. Identify best trades:
   - [ ] Highest profit trades
   - [ ] Best risk/reward trades
   - [ ] Cleanest entries/exits
2. Identify worst trades:
   - [ ] Largest loss trades
   - [ ] Worst risk/reward trades
   - [ ] Problematic entries/exits
3. Document patterns:
   ```
   BEST TRADES: [Description]
   WORST TRADES: [Description]
   PATTERNS OBSERVED: [Any patterns]
   ```

#### Step 3: Signal Quality Assessment
Evaluate signal generation:
1. Review signal detection:
   - [ ] Were signals generated consistently?
   - [ ] Did signals occur at logical price levels?
   - [ ] Were there false signals?
   - [ ] Were there missed signals?
2. Document:
   ```
   SIGNAL QUALITY: [Good/Fair/Poor]
   CONSISTENCY: [Consistent/Inconsistent]
   FALSE SIGNALS: [Number]
   MISSED SIGNALS: [Estimated number]
   ```

#### Step 4: Risk Management Assessment
Evaluate risk controls:
1. Check if risk limits were respected:
   - [ ] Daily loss limit: Never exceeded
   - [ ] Drawdown limit: Never exceeded
   - [ ] Max open trades: Never exceeded
   - [ ] Max trades per day: Never exceeded
2. Document:
   ```
   RISK LIMITS RESPECTED: [Yes/No]
   VIOLATIONS: [Any violations]
   MARGIN LEVEL: [Minimum level reached]
   ```

#### Step 5: Go/No-Go Decision
Based on weekly performance, decide:

**GO (Continue to Week 2):**
- [ ] Win rate > 50%
- [ ] Profit factor > 1.5
- [ ] No risk limit violations
- [ ] Max drawdown < 5%
- [ ] At least 5-10 trades generated
- [ ] No major errors or issues

**NO-GO (Adjust Parameters):**
- [ ] Win rate < 50%
- [ ] Profit factor < 1.5
- [ ] Risk limit violations occurred
- [ ] Max drawdown > 5%
- [ ] Too few trades generated
- [ ] Significant errors or issues

**Decision**: _______________

---

## Part 3: What to Monitor During Trading

### Key Metrics to Track

#### 1. Account Metrics
Track these daily:
- **Balance**: Starting capital
- **Equity**: Balance + open trade P&L
- **Free Margin**: Available margin for new trades
- **Margin Level**: Equity / Used Margin (%)
- **Daily P&L**: Profit/loss for the day
- **Cumulative P&L**: Total profit/loss since start

#### 2. Trade Metrics
For each trade, track:
- **Entry Price**: Price where trade opened
- **Entry Time**: Time of entry
- **Stop Loss**: SL level
- **Take Profit**: TP level
- **Lot Size**: Position size
- **Current P&L**: Unrealized profit/loss
- **Exit Price**: Price where trade closed (if closed)
- **Exit Time**: Time of exit
- **Exit Reason**: Why trade closed (TP/SL/Manual)

#### 3. Performance Metrics
Calculate daily:
- **Win Rate**: Winning trades / Total trades (%)
- **Profit Factor**: Total wins / Total losses
- **Average Win**: Total wins / Number of wins
- **Average Loss**: Total losses / Number of losses
- **Risk/Reward Ratio**: Average win / Average loss
- **Max Drawdown**: Largest peak-to-trough decline (%)
- **Sharpe Ratio**: Return / Volatility (advanced)

#### 4. Risk Metrics
Monitor continuously:
- **Daily Loss**: Current day's loss
- **Drawdown**: Current equity decline from peak
- **Margin Level**: Percentage of available margin
- **Open Trades**: Number of open positions
- **Trades Today**: Number of trades opened today

---

## Part 4: Red Flags & When to Stop Trading

### Stop Trading Immediately If:

#### Critical Issues
- [ ] **Margin Level < 500%**: Risk of forced liquidation
- [ ] **Daily Loss > 5%**: Risk limit exceeded
- [ ] **Drawdown > 10%**: Account drawdown limit exceeded
- [ ] **EA Errors**: Repeated error messages in Toolbox
- [ ] **Connection Lost**: Disconnected from broker
- [ ] **Unusual Slippage**: Trades executing far from expected price

#### Performance Issues
- [ ] **Win Rate < 30%**: Too many losing trades
- [ ] **Consecutive Losses > 5**: Losing streak
- [ ] **Largest Loss > 3%**: Single trade too large
- [ ] **No Trades for 24 Hours**: Signal generation issue

#### Technical Issues
- [ ] **EA Crashes**: EA stops running
- [ ] **Chart Freezes**: Price data not updating
- [ ] **Log File Errors**: Repeated error messages
- [ ] **Compilation Errors**: EA won't recompile

### Action When Red Flag Occurs:

1. **Immediate Actions**:
   - [ ] Stop EA (right-click chart → Expert Advisors → Remove)
   - [ ] Close any open positions manually
   - [ ] Document the issue
   - [ ] Take screenshot of account status

2. **Investigation**:
   - [ ] Check Toolbox for error messages
   - [ ] Review log file for issues
   - [ ] Check account balance and equity
   - [ ] Verify connection status

3. **Resolution**:
   - [ ] Identify root cause
   - [ ] Make necessary adjustments
   - [ ] Recompile EA if needed
   - [ ] Restart MetaTrader 5 if needed

4. **Restart**:
   - [ ] Reattach EA to chart
   - [ ] Verify parameters are correct
   - [ ] Resume monitoring

---

## Part 5: Daily Monitoring Log Template

Create a spreadsheet or document with this structure:

```
DAILY MONITORING LOG
====================

DATE: [Date]
DAY: [Monday/Tuesday/etc]

MORNING REPORT
Opening Balance: $[Amount]
Opening Equity: $[Amount]
Opening Margin Level: [%]
Market Condition: [Trending/Ranging]
Volatility: [High/Normal/Low]

HOURLY UPDATES
Time: [Time] | Trades: [#] | Equity: $[Amount] | Notes: [Any activity]
Time: [Time] | Trades: [#] | Equity: $[Amount] | Notes: [Any activity]
Time: [Time] | Trades: [#] | Equity: $[Amount] | Notes: [Any activity]

EVENING REPORT
Closing Balance: $[Amount]
Closing Equity: $[Amount]
Daily P&L: $[Amount]
Trades Opened: [#]
Trades Closed: [#]
Win Rate: [%]
Max Drawdown: [%]

ISSUES/NOTES
[Any issues or observations]

NEXT DAY ACTIONS
[Any actions needed for next day]
```

---

## Part 6: Weekly Monitoring Log Template

```
WEEKLY MONITORING LOG
=====================

WEEK: Week 1 (May 29 - June 2, 2026)

DAILY SUMMARY
Monday:   P&L: $[Amount] | Trades: [#] | Win Rate: [%]
Tuesday:  P&L: $[Amount] | Trades: [#] | Win Rate: [%]
Wednesday: P&L: $[Amount] | Trades: [#] | Win Rate: [%]
Thursday: P&L: $[Amount] | Trades: [#] | Win Rate: [%]
Friday:   P&L: $[Amount] | Trades: [#] | Win Rate: [%]

WEEKLY TOTALS
Starting Balance: $10,000
Ending Balance: $[Amount]
Weekly P&L: $[Amount]
Weekly P&L %: [%]
Total Trades: [#]
Win Rate: [%]
Profit Factor: [#]
Max Drawdown: [%]

BEST TRADE
Entry: [Price] | Exit: [Price] | Profit: $[Amount]

WORST TRADE
Entry: [Price] | Exit: [Price] | Loss: $[Amount]

ASSESSMENT
Signal Quality: [Good/Fair/Poor]
Risk Management: [Excellent/Good/Fair/Poor]
Overall Performance: [Excellent/Good/Fair/Poor]

GO/NO-GO DECISION
[ ] GO - Continue to Week 2
[ ] NO-GO - Adjust parameters and retry

NOTES
[Any observations or issues]
```

---

## Part 7: Monitoring Checklist

### Daily Checklist
- [ ] Morning system check completed
- [ ] Account status verified
- [ ] EA parameters verified
- [ ] Chart prepared and visible
- [ ] Hourly monitoring performed (every 1-2 hours)
- [ ] Trade status checked
- [ ] Risk limits verified
- [ ] End-of-day summary completed
- [ ] Daily log updated
- [ ] No red flags encountered

### Weekly Checklist
- [ ] All daily logs completed
- [ ] Weekly performance summary calculated
- [ ] Trade quality analysis performed
- [ ] Signal quality assessed
- [ ] Risk management reviewed
- [ ] Go/No-Go decision made
- [ ] Weekly log updated
- [ ] Screenshots taken (if needed)
- [ ] Backup of logs created

---

## Summary

**First Week Monitoring Complete When:**
1. ✓ Daily monitoring performed each day
2. ✓ Hourly checks completed during trading hours
3. ✓ Daily logs updated with all metrics
4. ✓ Weekly summary completed
5. ✓ Go/No-Go decision made
6. ✓ All red flags documented
7. ✓ Ready for Week 2 or parameter adjustment

**Next Step**: Proceed to Trade Validation Guide
