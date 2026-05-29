# MonsterArrows V3 EA - Trade Validation Guide

## Overview
This guide provides detailed procedures for validating that trades are executing correctly, with proper entry/exit logic, stop loss/take profit levels, and accurate logging. Use this during the first week of demo testing to ensure the EA is functioning as designed.

---

## Part 1: Trade Entry Validation

### Step 1: Verify Signal Generation

#### What to Check
When a trade opens, verify:
1. **Signal Type**: BUY or SELL
2. **Signal Timing**: When signal occurred
3. **Signal Conditions**: What triggered the signal
4. **Entry Price**: Price where trade opened
5. **Entry Time**: Time of entry

#### How to Validate
1. Open **Account History** (Ctrl+H)
2. Find the trade that just opened
3. Note:
   - [ ] Trade ticket number
   - [ ] Entry time
   - [ ] Entry price
   - [ ] Trade type (BUY/SELL)
   - [ ] Lot size

4. Check chart at entry time:
   - [ ] Look at candle where trade opened
   - [ ] Verify price matches entry price
   - [ ] Check if signal conditions are present (liquidity sweep, FVG, etc.)

5. Review log file:
   - [ ] Open `MonsterArrows_V3_EA.log`
   - [ ] Find entry message for this trade
   - [ ] Verify log shows: `OPEN | [Symbol] | [BUY/SELL] | Price: [Price] | SL: [SL] | TP: [TP]`

#### Validation Checklist
```
TRADE ENTRY VALIDATION
======================
Trade Ticket: [#]
Entry Time: [Time]
Entry Price: [Price]
Trade Type: [BUY/SELL]
Lot Size: [Size]

SIGNAL VALIDATION
[ ] Signal type matches trade type
[ ] Entry price is reasonable
[ ] Entry time is during market hours
[ ] Signal conditions visible on chart
[ ] Log file shows entry message

ENTRY QUALITY
[ ] Entry at logical price level
[ ] Entry not at extreme price
[ ] Entry has clear support/resistance
[ ] Entry has reasonable risk/reward setup
```

---

### Step 2: Verify Stop Loss Placement

#### What to Check
Stop loss should be:
1. **Correctly Calculated**: Based on ATR and SL_ATR_Mult parameter
2. **Logically Placed**: Below entry for BUY, above entry for SELL
3. **Reasonable Distance**: Not too close (whipsawed) or too far (excessive risk)
4. **Set in System**: Visible in trade details

#### How to Validate

**For BUY Trades:**
1. Calculate expected SL:
   ```
   Current ATR (14): [Value]
   SL_ATR_Mult: 1.5
   Expected SL = Entry Price - (ATR × 1.5)
   Expected SL = [Entry] - ([ATR] × 1.5) = [SL]
   ```

2. Verify in trade:
   - [ ] Open **Account History**
   - [ ] Find trade
   - [ ] Check SL level
   - [ ] Compare to calculated SL
   - [ ] Difference should be < 1 pip

3. Check on chart:
   - [ ] Look at chart at entry time
   - [ ] SL should be below entry price
   - [ ] SL should be below recent swing low
   - [ ] SL should not be at exact low (some buffer)

**For SELL Trades:**
1. Calculate expected SL:
   ```
   Current ATR (14): [Value]
   SL_ATR_Mult: 1.5
   Expected SL = Entry Price + (ATR × 1.5)
   Expected SL = [Entry] + ([ATR] × 1.5) = [SL]
   ```

2. Verify in trade:
   - [ ] Open **Account History**
   - [ ] Find trade
   - [ ] Check SL level
   - [ ] Compare to calculated SL
   - [ ] Difference should be < 1 pip

3. Check on chart:
   - [ ] Look at chart at entry time
   - [ ] SL should be above entry price
   - [ ] SL should be above recent swing high
   - [ ] SL should not be at exact high (some buffer)

#### Validation Checklist
```
STOP LOSS VALIDATION
====================
Trade Type: [BUY/SELL]
Entry Price: [Price]
Actual SL: [Price]
Expected SL: [Price]
Difference: [Pips]

SL QUALITY
[ ] SL matches expected calculation (< 1 pip difference)
[ ] SL is logically placed (below entry for BUY, above for SELL)
[ ] SL is reasonable distance from entry
[ ] SL is not at extreme price level
[ ] SL provides adequate protection
[ ] SL is set in trade details
```

---

### Step 3: Verify Take Profit Placement

#### What to Check
Take profit should be:
1. **Correctly Calculated**: Based on ATR and TP_ATR_Mult parameters
2. **Logically Placed**: Above entry for BUY, below entry for SELL
3. **Reasonable Risk/Reward**: Typically 1.5:1 or better
4. **Set in System**: Visible in trade details

#### How to Validate

**For BUY Trades:**
1. Calculate expected TP:
   ```
   Current ATR (14): [Value]
   TP1_ATR_Mult: 1.5
   Expected TP1 = Entry Price + (ATR × 1.5)
   Expected TP1 = [Entry] + ([ATR] × 1.5) = [TP1]
   
   TP2_ATR_Mult: 3.0
   Expected TP2 = Entry Price + (ATR × 3.0)
   Expected TP2 = [Entry] + ([ATR] × 3.0) = [TP2]
   
   TP3_ATR_Mult: 6.0
   Expected TP3 = Entry Price + (ATR × 6.0)
   Expected TP3 = [Entry] + ([ATR] × 6.0) = [TP3]
   ```

2. Verify in trade:
   - [ ] Open **Account History**
   - [ ] Find trade
   - [ ] Check TP level
   - [ ] Compare to calculated TP
   - [ ] Difference should be < 1 pip

3. Check risk/reward:
   ```
   Risk = Entry - SL = [Amount]
   Reward = TP - Entry = [Amount]
   Risk/Reward Ratio = Reward / Risk = [Ratio]
   ```
   - [ ] Ratio should be > 1.0 (at least 1:1)
   - [ ] Ratio should be close to 1.5 (1.5:1)

**For SELL Trades:**
1. Calculate expected TP:
   ```
   Current ATR (14): [Value]
   TP1_ATR_Mult: 1.5
   Expected TP1 = Entry Price - (ATR × 1.5)
   Expected TP1 = [Entry] - ([ATR] × 1.5) = [TP1]
   
   TP2_ATR_Mult: 3.0
   Expected TP2 = Entry Price - (ATR × 3.0)
   Expected TP2 = [Entry] - ([ATR] × 3.0) = [TP2]
   
   TP3_ATR_Mult: 6.0
   Expected TP3 = Entry Price - (ATR × 6.0)
   Expected TP3 = [Entry] - ([ATR] × 6.0) = [TP3]
   ```

2. Verify in trade:
   - [ ] Open **Account History**
   - [ ] Find trade
   - [ ] Check TP level
   - [ ] Compare to calculated TP
   - [ ] Difference should be < 1 pip

3. Check risk/reward:
   ```
   Risk = SL - Entry = [Amount]
   Reward = Entry - TP = [Amount]
   Risk/Reward Ratio = Reward / Risk = [Ratio]
   ```
   - [ ] Ratio should be > 1.0 (at least 1:1)
   - [ ] Ratio should be close to 1.5 (1.5:1)

#### Validation Checklist
```
TAKE PROFIT VALIDATION
======================
Trade Type: [BUY/SELL]
Entry Price: [Price]
Actual TP: [Price]
Expected TP: [Price]
Difference: [Pips]

TP QUALITY
[ ] TP matches expected calculation (< 1 pip difference)
[ ] TP is logically placed (above entry for BUY, below for SELL)
[ ] TP is reasonable distance from entry
[ ] Risk/Reward ratio is > 1.0
[ ] Risk/Reward ratio is close to 1.5
[ ] TP is set in trade details
```

---

### Step 4: Verify Lot Size Calculation

#### What to Check
Lot size should be:
1. **Risk-Based**: Calculated from RiskPercent parameter
2. **Correctly Sized**: Based on account balance and SL distance
3. **Within Limits**: Between minimum and maximum lot sizes
4. **Normalized**: Rounded to broker's lot step

#### How to Validate

1. Calculate expected lot size:
   ```
   Account Balance: $10,000
   RiskPercent: 1.0%
   Risk Amount = Balance × (RiskPercent / 100)
   Risk Amount = $10,000 × (1.0 / 100) = $100
   
   SL Distance (in pips): [Distance]
   Tick Value: [Value per pip]
   Lot Size = Risk Amount / (SL Distance × Tick Value)
   Lot Size = $100 / ([Distance] × [Tick Value]) = [Lot]
   ```

2. Verify in trade:
   - [ ] Open **Account History**
   - [ ] Find trade
   - [ ] Check lot size
   - [ ] Compare to calculated lot size
   - [ ] Difference should be minimal (rounding only)

3. Check limits:
   - [ ] Lot size >= Minimum lot (usually 0.01)
   - [ ] Lot size <= Maximum lot (usually 100)
   - [ ] Lot size is multiple of lot step (usually 0.01)

#### Validation Checklist
```
LOT SIZE VALIDATION
===================
Account Balance: $10,000
RiskPercent: 1.0%
Risk Amount: $100
SL Distance: [Pips]
Actual Lot Size: [Size]
Expected Lot Size: [Size]
Difference: [%]

LOT SIZE QUALITY
[ ] Lot size matches expected calculation (< 5% difference)
[ ] Lot size >= Minimum lot
[ ] Lot size <= Maximum lot
[ ] Lot size is multiple of lot step
[ ] Lot size is reasonable for account size
```

---

## Part 2: Trade Exit Validation

### Step 1: Verify Stop Loss Execution

#### What to Check
When trade closes at stop loss:
1. **Exit Price**: Should be at or very close to SL level
2. **Exit Reason**: Should show "Stop Loss" or similar
3. **Exit Time**: Should be when price touched SL
4. **Loss Amount**: Should match calculated risk

#### How to Validate

1. Find closed trade in **Account History**:
   - [ ] Note exit price
   - [ ] Note exit time
   - [ ] Note exit reason (if shown)

2. Verify exit price:
   ```
   Expected SL: [Price]
   Actual Exit Price: [Price]
   Difference: [Pips]
   ```
   - [ ] Difference should be < 2 pips (slippage)
   - [ ] If difference > 2 pips, note as potential slippage issue

3. Verify loss amount:
   ```
   Entry Price: [Price]
   Exit Price: [Price]
   Lot Size: [Size]
   Expected Loss = (Entry - Exit) × Lot Size × Tick Value
   Expected Loss = [Calculation] = $[Amount]
   Actual Loss: $[Amount]
   ```
   - [ ] Actual loss should match expected loss (within 1%)

4. Check chart:
   - [ ] Look at chart at exit time
   - [ ] Verify price touched SL level
   - [ ] Check if SL was hit cleanly or with slippage

#### Validation Checklist
```
STOP LOSS EXIT VALIDATION
=========================
Trade Ticket: [#]
Entry Price: [Price]
SL Level: [Price]
Exit Price: [Price]
Exit Time: [Time]
Slippage: [Pips]

EXIT QUALITY
[ ] Exit price is at or near SL level (< 2 pips)
[ ] Exit reason is "Stop Loss" or similar
[ ] Exit time is when price touched SL
[ ] Loss amount matches expected risk
[ ] No excessive slippage
[ ] Trade closed properly
```

---

### Step 2: Verify Take Profit Execution

#### What to Check
When trade closes at take profit:
1. **Exit Price**: Should be at or very close to TP level
2. **Exit Reason**: Should show "Take Profit" or similar
3. **Exit Time**: Should be when price touched TP
4. **Profit Amount**: Should match calculated reward

#### How to Validate

1. Find closed trade in **Account History**:
   - [ ] Note exit price
   - [ ] Note exit time
   - [ ] Note exit reason (if shown)

2. Verify exit price:
   ```
   Expected TP: [Price]
   Actual Exit Price: [Price]
   Difference: [Pips]
   ```
   - [ ] Difference should be < 2 pips (slippage)
   - [ ] If difference > 2 pips, note as potential slippage issue

3. Verify profit amount:
   ```
   Entry Price: [Price]
   Exit Price: [Price]
   Lot Size: [Size]
   Expected Profit = (Exit - Entry) × Lot Size × Tick Value
   Expected Profit = [Calculation] = $[Amount]
   Actual Profit: $[Amount]
   ```
   - [ ] Actual profit should match expected profit (within 1%)

4. Check chart:
   - [ ] Look at chart at exit time
   - [ ] Verify price touched TP level
   - [ ] Check if TP was hit cleanly or with slippage

#### Validation Checklist
```
TAKE PROFIT EXIT VALIDATION
===========================
Trade Ticket: [#]
Entry Price: [Price]
TP Level: [Price]
Exit Price: [Price]
Exit Time: [Time]
Slippage: [Pips]

EXIT QUALITY
[ ] Exit price is at or near TP level (< 2 pips)
[ ] Exit reason is "Take Profit" or similar
[ ] Exit time is when price touched TP
[ ] Profit amount matches expected reward
[ ] No excessive slippage
[ ] Trade closed properly
```

---

### Step 3: Verify Manual Exit (if applicable)

#### What to Check
If trade closes manually (not at SL or TP):
1. **Exit Reason**: Why was trade closed manually
2. **Exit Price**: Price where trade was closed
3. **Exit Time**: When trade was closed
4. **P&L**: Profit or loss at exit

#### How to Validate

1. Find closed trade in **Account History**:
   - [ ] Note exit price
   - [ ] Note exit time
   - [ ] Note exit reason

2. Verify exit was intentional:
   - [ ] Check if there was a specific reason (e.g., news event)
   - [ ] Check if exit was at logical price level
   - [ ] Check if exit was during normal trading hours

3. Verify P&L:
   ```
   Entry Price: [Price]
   Exit Price: [Price]
   Lot Size: [Size]
   P&L = (Exit - Entry) × Lot Size × Tick Value
   P&L = [Calculation] = $[Amount]
   ```
   - [ ] P&L calculation is correct

#### Validation Checklist
```
MANUAL EXIT VALIDATION
======================
Trade Ticket: [#]
Entry Price: [Price]
Exit Price: [Price]
Exit Time: [Time]
Exit Reason: [Reason]
P&L: $[Amount]

EXIT QUALITY
[ ] Exit reason is documented
[ ] Exit price is reasonable
[ ] Exit time is during trading hours
[ ] P&L calculation is correct
[ ] Manual exit was justified
```

---

## Part 3: Trade Logging Validation

### Step 1: Verify Log File Entries

#### What to Check
Log file should contain:
1. **Entry Messages**: When trades open
2. **Exit Messages**: When trades close
3. **Error Messages**: Any errors encountered
4. **Timestamps**: Accurate time for each entry

#### How to Validate

1. Open log file:
   - [ ] Location: `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Logs\MonsterArrows_V3_EA.log`
   - [ ] Open with text editor (Notepad, VS Code, etc.)

2. Check for entry messages:
   ```
   Expected format:
   [Date Time] | OPEN | [Symbol] | [BUY/SELL] | Price: [Price] | SL: [SL] | TP: [TP] | Lot: [Lot]
   
   Example:
   2026-05-29 10:30:45 | OPEN | EURUSD | BUY | Price: 1.0850 | SL: 1.0820 | TP: 1.0880 | Lot: 0.10
   ```
   - [ ] Entry message exists for each trade
   - [ ] Format is correct
   - [ ] All fields are populated

3. Check for exit messages:
   ```
   Expected format:
   [Date Time] | CLOSE | [Symbol] | [BUY/SELL] | Price: [Price] | Reason: [Reason] | P&L: $[Amount]
   
   Example:
   2026-05-29 11:45:30 | CLOSE | EURUSD | BUY | Price: 1.0880 | Reason: Take Profit | P&L: $30.00
   ```
   - [ ] Exit message exists for each closed trade
   - [ ] Format is correct
   - [ ] All fields are populated

4. Check for error messages:
   - [ ] Look for lines starting with "ERROR"
   - [ ] Document any errors found
   - [ ] Investigate error causes

#### Validation Checklist
```
LOG FILE VALIDATION
===================
Log File Location: [Path]
Log File Size: [KB]
Number of Entries: [#]

ENTRY MESSAGES
[ ] Entry message exists for each trade
[ ] Format is correct
[ ] All fields populated (Date, Time, Symbol, Type, Price, SL, TP, Lot)
[ ] Timestamps are accurate

EXIT MESSAGES
[ ] Exit message exists for each closed trade
[ ] Format is correct
[ ] All fields populated (Date, Time, Symbol, Type, Price, Reason, P&L)
[ ] Timestamps are accurate

ERROR MESSAGES
[ ] No critical errors
[ ] Any warnings documented
[ ] Error messages are understandable
```

---

### Step 2: Verify Log File Accuracy

#### What to Check
Log entries should match actual trades:
1. **Trade Count**: Log entries match Account History
2. **Prices**: Log prices match actual trade prices
3. **Times**: Log times match actual trade times
4. **P&L**: Log P&L matches actual P&L

#### How to Validate

1. Compare log entries to Account History:
   - [ ] Open **Account History** (Ctrl+H)
   - [ ] Open log file
   - [ ] For each trade in Account History:
     - [ ] Find corresponding entry in log
     - [ ] Verify prices match
     - [ ] Verify times match
     - [ ] Verify P&L matches

2. Count trades:
   ```
   Trades in Account History: [#]
   Entry Messages in Log: [#]
   Exit Messages in Log: [#]
   ```
   - [ ] Entry messages should equal number of trades
   - [ ] Exit messages should equal number of closed trades

3. Verify data accuracy:
   - [ ] Prices in log match Account History (within 1 pip)
   - [ ] Times in log match Account History (within 1 minute)
   - [ ] P&L in log matches Account History (within $1)

#### Validation Checklist
```
LOG ACCURACY VALIDATION
=======================
Total Trades: [#]
Entry Messages: [#]
Exit Messages: [#]

ACCURACY CHECK
[ ] Entry message count matches trade count
[ ] Exit message count matches closed trade count
[ ] Prices in log match Account History
[ ] Times in log match Account History
[ ] P&L in log matches Account History
[ ] No missing entries
[ ] No duplicate entries
```

---

## Part 4: Overall Trade Quality Assessment

### Step 1: Entry Quality Assessment

Rate each trade's entry quality:

```
ENTRY QUALITY RATING
====================
Trade 1: [Good/Fair/Poor]
  - Entry at logical level: [Yes/No]
  - Entry has clear signal: [Yes/No]
  - Entry has good risk/reward: [Yes/No]
  - Entry timing is good: [Yes/No]

Trade 2: [Good/Fair/Poor]
  - Entry at logical level: [Yes/No]
  - Entry has clear signal: [Yes/No]
  - Entry has good risk/reward: [Yes/No]
  - Entry timing is good: [Yes/No]

[Continue for all trades]

OVERALL ENTRY QUALITY: [Good/Fair/Poor]
```

### Step 2: Exit Quality Assessment

Rate each trade's exit quality:

```
EXIT QUALITY RATING
===================
Trade 1: [Good/Fair/Poor]
  - Exit at logical level: [Yes/No]
  - Exit reason is clear: [Yes/No]
  - Exit timing is good: [Yes/No]
  - No excessive slippage: [Yes/No]

Trade 2: [Good/Fair/Poor]
  - Exit at logical level: [Yes/No]
  - Exit reason is clear: [Yes/No]
  - Exit timing is good: [Yes/No]
  - No excessive slippage: [Yes/No]

[Continue for all trades]

OVERALL EXIT QUALITY: [Good/Fair/Poor]
```

### Step 3: Risk Management Assessment

```
RISK MANAGEMENT ASSESSMENT
==========================
Risk Per Trade: 1.0% ($100)
Actual Risk Per Trade: $[Average]
Difference: [%]

Max Daily Loss Limit: 5.0% ($500)
Actual Max Daily Loss: $[Amount] ([%])
Limit Respected: [Yes/No]

Max Drawdown Limit: 10.0% ($1,000)
Actual Max Drawdown: $[Amount] ([%])
Limit Respected: [Yes/No]

Max Open Trades: 3
Actual Max Open Trades: [#]
Limit Respected: [Yes/No]

OVERALL RISK MANAGEMENT: [Excellent/Good/Fair/Poor]
```

---

## Part 5: Trade Validation Checklist

### Complete Trade Validation Checklist

For each trade, verify:

```
TRADE VALIDATION CHECKLIST
==========================

TRADE #[Number]
Ticket: [#]
Symbol: [Symbol]
Type: [BUY/SELL]
Entry Time: [Time]
Exit Time: [Time]

ENTRY VALIDATION
[ ] Signal type matches trade type
[ ] Entry price is reasonable
[ ] Entry time is during market hours
[ ] SL is correctly calculated
[ ] TP is correctly calculated
[ ] Lot size is correctly calculated
[ ] Risk/Reward ratio is > 1.0
[ ] Log file shows entry message

EXIT VALIDATION
[ ] Exit price is at or near SL/TP (< 2 pips)
[ ] Exit reason is clear
[ ] Exit time is accurate
[ ] P&L calculation is correct
[ ] No excessive slippage
[ ] Log file shows exit message

OVERALL TRADE QUALITY: [Good/Fair/Poor]
NOTES: [Any observations]
```

---

## Part 6: Troubleshooting Trade Issues

### Issue: Entry Price Doesn't Match Expected Price

**Cause**: Slippage or price movement between signal and execution

**Solution**:
1. Check market conditions at entry time
2. Verify spread was normal
3. Check if price was moving rapidly
4. Document slippage amount
5. If slippage > 5 pips, investigate further

### Issue: SL/TP Not Set Correctly

**Cause**: Calculation error or rounding issue

**Solution**:
1. Recalculate expected SL/TP manually
2. Compare to actual SL/TP
3. Check if difference is within 1 pip
4. If difference > 1 pip, check EA code
5. Recompile EA if needed

### Issue: Lot Size Too Large or Too Small

**Cause**: Risk calculation error or account balance change

**Solution**:
1. Recalculate expected lot size
2. Compare to actual lot size
3. Check account balance at time of trade
4. Verify RiskPercent parameter
5. If error > 5%, investigate EA code

### Issue: Trade Closes at Wrong Price

**Cause**: Slippage or price gap

**Solution**:
1. Check market conditions at exit time
2. Verify spread was normal
3. Check if price gapped
4. Document slippage amount
5. If slippage > 5 pips, note as issue

### Issue: Log File Missing Entry/Exit

**Cause**: Logging disabled or file write error

**Solution**:
1. Verify EnableLogging is true
2. Check log file location
3. Verify file permissions
4. Check for disk space issues
5. Restart EA if needed

---

## Summary

**Trade Validation Complete When:**
1. ✓ Entry prices verified and reasonable
2. ✓ Stop loss levels verified and correctly calculated
3. ✓ Take profit levels verified and correctly calculated
4. ✓ Lot sizes verified and correctly calculated
5. ✓ Exit prices verified and at SL/TP
6. ✓ P&L calculations verified and accurate
7. ✓ Log file entries verified and complete
8. ✓ Overall trade quality assessed
9. ✓ All issues documented

**Next Step**: Proceed to Go/No-Go Decision Criteria
