# MonsterArrows V3 EA - Attachment & Parameter Tuning Guide

## Overview
This guide covers attaching the MonsterArrows_V3_EA to a live chart and configuring parameters for optimal demo account testing.

---

## Part 1: EA Attachment to Chart

### Step 1: Prepare Chart
1. In MetaTrader 5, open chart for EURUSD H1
2. Verify chart displays correctly with price action
3. Ensure chart shows at least 100 candles of history
4. Check that bid/ask prices are updating in real-time

### Step 2: Attach EA to Chart
**Method 1: Drag & Drop**
1. Open **Navigator** (Ctrl+N)
2. Expand **Expert Advisors** folder
3. Find `MonsterArrows_V3_EA`
4. Drag and drop onto chart
5. EA Properties dialog opens

**Method 2: Right-Click Menu**
1. Right-click on chart
2. Click **Expert Advisors** → **Attach Expert Advisor**
3. Select `MonsterArrows_V3_EA` from list
4. Click **OK**
5. EA Properties dialog opens

**Method 3: Insert Menu**
1. Click **Insert** → **Expert Advisors** → **MonsterArrows_V3_EA**
2. EA Properties dialog opens

### Step 3: Verify EA Attachment
After attachment, verify:
- [ ] EA name appears in chart title bar (e.g., "EURUSD H1 - MonsterArrows_V3_EA")
- [ ] Small icon appears in top-left corner of chart (indicates EA is running)
- [ ] **Toolbox** panel shows EA initialization messages
- [ ] No error messages in Toolbox

### Step 4: Handle Attachment Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Expert Advisor not found" | EA not compiled | Recompile EA in MetaEditor |
| "Cannot load Expert Advisor" | File permission issue | Check file location and permissions |
| "Expert Advisor terminated" | Initialization failed | Check Toolbox for error messages |
| "Automated trading disabled" | Trading not enabled | Enable in Tools → Options → Expert Advisors |

---

## Part 2: EA Properties & Parameter Configuration

### Step 1: Open EA Properties
When EA Properties dialog appears after attachment:
1. Dialog shows all input parameters organized by groups
2. Parameters are grouped as:
   - **TRADING SETTINGS**
   - **SIGNAL SETTINGS**
   - **MONEY MANAGEMENT**
   - **ALERTS & LOGGING**

### Step 2: Configure Trading Settings

#### Parameter: SymbolMode
- **Default**: SYMBOLS_CURRENCY_BASE
- **For Demo**: Keep default
- **Purpose**: Determines which symbols EA can trade
- **Action**: Leave as default

#### Parameter: TradeSymbol
- **Default**: "" (empty = current chart symbol)
- **For Demo**: Leave empty (will use EURUSD from chart)
- **Purpose**: Override symbol if needed
- **Action**: Leave empty

#### Parameter: TradeTimeframe
- **Default**: PERIOD_H1
- **For Demo**: Keep PERIOD_H1
- **Purpose**: Timeframe for signal generation
- **Action**: Verify matches chart timeframe (H1)

#### Parameter: EnableTrading
- **Default**: false
- **For Demo**: **CHANGE TO TRUE**
- **Purpose**: Master switch for trading
- **Action**: Set to `true` to enable trading

#### Parameter: MaxOpenTrades
- **Default**: 3
- **For Demo**: Keep 3
- **Purpose**: Maximum simultaneous positions
- **Action**: Leave as 3 (conservative for testing)

#### Parameter: MaxTradesPerDay
- **Default**: 10
- **For Demo**: Keep 10
- **Purpose**: Maximum trades per calendar day
- **Action**: Leave as 10

### Step 3: Configure Signal Settings

#### Parameter: EnableHTFFilter
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Use higher timeframe confirmation
- **Action**: Leave enabled (reduces false signals)

#### Parameter: RequireBothHTF
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Require both HTF confirmations (strict mode)
- **Action**: Leave enabled (more reliable signals)

#### Parameter: BarsToConfirm
- **Default**: 2
- **For Demo**: Keep 2
- **Purpose**: Bars to wait for signal confirmation (non-repaint)
- **Action**: Leave as 2 (prevents repainting)

#### Parameter: HTF_EMAPeriod
- **Default**: 20
- **For Demo**: Keep 20
- **Purpose**: EMA period for higher timeframe
- **Action**: Leave as 20

#### Parameter: ST_RMA1Length
- **Default**: 14
- **For Demo**: Keep 14
- **Purpose**: SuperTrend RMA 1 length
- **Action**: Leave as 14

#### Parameter: ST_RMA2Length
- **Default**: 21
- **For Demo**: Keep 21
- **Purpose**: SuperTrend RMA 2 length
- **Action**: Leave as 21

#### Parameter: ST_ATRPeriod
- **Default**: 14
- **For Demo**: Keep 14
- **Purpose**: SuperTrend ATR period
- **Action**: Leave as 14

#### Parameter: ST_ATRMult
- **Default**: 1.0
- **For Demo**: Keep 1.0
- **Purpose**: SuperTrend ATR multiplier
- **Action**: Leave as 1.0

#### Parameter: UseLiquiditySweep
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Enable liquidity sweep detection
- **Action**: Leave enabled

#### Parameter: UseFairValueGap
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Enable fair value gap detection
- **Action**: Leave enabled

#### Parameter: ZZDepth
- **Default**: 30
- **For Demo**: Keep 30
- **Purpose**: ZigZag depth for pivot detection
- **Action**: Leave as 30

#### Parameter: ZZDeviation
- **Default**: 5
- **For Demo**: Keep 5
- **Purpose**: ZigZag deviation percentage
- **Action**: Leave as 5

#### Parameter: ZZBackstep
- **Default**: 3
- **For Demo**: Keep 3
- **Purpose**: ZigZag backstep value
- **Action**: Leave as 3

#### Parameter: FibLevel
- **Default**: 0.618
- **For Demo**: Keep 0.618
- **Purpose**: Fibonacci retracement level
- **Action**: Leave as 0.618

#### Parameter: HistBars
- **Default**: 1000
- **For Demo**: Keep 1000
- **Purpose**: Historical bars to analyze
- **Action**: Leave as 1000

#### Parameter: ATRPeriod
- **Default**: 14
- **For Demo**: Keep 14
- **Purpose**: ATR period for volatility
- **Action**: Leave as 14

#### Parameter: RecentBars
- **Default**: 50
- **For Demo**: Keep 50
- **Purpose**: Bars to scan for missed signals
- **Action**: Leave as 50

### Step 4: Configure Money Management

#### Parameter: RiskPercent
- **Default**: 1.0
- **For Demo**: Keep 1.0
- **Purpose**: Risk per trade (% of account)
- **Calculation**: 1.0% of $10,000 = $100 per trade
- **Action**: Leave as 1.0 (conservative)

#### Parameter: FixedLotSize
- **Default**: 0.0
- **For Demo**: Keep 0.0
- **Purpose**: Fixed lot size (0 = use risk %)
- **Action**: Leave as 0.0 (use risk-based sizing)

#### Parameter: MaxLotSize
- **Default**: 10.0
- **For Demo**: Keep 10.0
- **Purpose**: Maximum lot size cap
- **Action**: Leave as 10.0

#### Parameter: TP1_ATR_Mult
- **Default**: 1.5
- **For Demo**: Keep 1.5
- **Purpose**: TP1 distance (ATR multiplier)
- **Action**: Leave as 1.5

#### Parameter: TP2_ATR_Mult
- **Default**: 3.0
- **For Demo**: Keep 3.0
- **Purpose**: TP2 distance (ATR multiplier)
- **Action**: Leave as 3.0

#### Parameter: TP3_ATR_Mult
- **Default**: 6.0
- **For Demo**: Keep 6.0
- **Purpose**: TP3 distance (ATR multiplier)
- **Action**: Leave as 6.0

#### Parameter: SL_ATR_Mult
- **Default**: 1.5
- **For Demo**: Keep 1.5
- **Purpose**: Stop loss distance (ATR multiplier)
- **Action**: Leave as 1.5

#### Parameter: UseTrailingStop
- **Default**: false
- **For Demo**: Keep false
- **Purpose**: Enable trailing stop
- **Action**: Leave disabled (for demo testing)

#### Parameter: TrailingStopPoints
- **Default**: 50.0
- **For Demo**: Keep 50.0
- **Purpose**: Trailing stop distance (points)
- **Action**: Leave as 50.0 (not used if trailing stop disabled)

### Step 5: Configure Alerts & Logging

#### Parameter: MasterAlert
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Master alert switch
- **Action**: Leave enabled

#### Parameter: DoPopup
- **Default**: false
- **For Demo**: Keep false
- **Purpose**: Popup alert on trade
- **Action**: Leave disabled (can be distracting)

#### Parameter: DoSound
- **Default**: false
- **For Demo**: Keep false
- **Purpose**: Sound alert on trade
- **Action**: Leave disabled (optional)

#### Parameter: DoEmail
- **Default**: false
- **For Demo**: Keep false
- **Purpose**: Email alert on trade
- **Action**: Leave disabled (not needed for demo)

#### Parameter: DoPush
- **Default**: false
- **For Demo**: Keep false
- **Purpose**: Mobile push notification
- **Action**: Leave disabled (not needed for demo)

#### Parameter: AlertSound
- **Default**: "alert2.wav"
- **For Demo**: Keep default
- **Purpose**: Sound file for alerts
- **Action**: Leave as default

#### Parameter: AlertCooldown
- **Default**: 60
- **For Demo**: Keep 60
- **Purpose**: Seconds between alerts
- **Action**: Leave as 60

#### Parameter: EnableLogging
- **Default**: true
- **For Demo**: Keep true
- **Purpose**: Enable file logging
- **Action**: Leave enabled (essential for monitoring)

#### Parameter: LogFileName
- **Default**: "MonsterArrows_V3_EA.log"
- **For Demo**: Keep default
- **Purpose**: Log file name
- **Action**: Leave as default

---

## Part 3: Recommended Parameter Sets for Demo Testing

### Conservative Setup (Recommended for Week 1)
```
TRADING SETTINGS
EnableTrading:          true
MaxOpenTrades:          2
MaxTradesPerDay:        5

SIGNAL SETTINGS
EnableHTFFilter:        true
RequireBothHTF:         true
BarsToConfirm:          2

MONEY MANAGEMENT
RiskPercent:            0.5%
MaxLotSize:             5.0
TP1_ATR_Mult:           1.5
SL_ATR_Mult:            1.5

ALERTS & LOGGING
EnableLogging:          true
DoPopup:                false
DoSound:                false
```

### Moderate Setup (After Week 1 if Conservative Works)
```
TRADING SETTINGS
EnableTrading:          true
MaxOpenTrades:          3
MaxTradesPerDay:        10

SIGNAL SETTINGS
EnableHTFFilter:        true
RequireBothHTF:         true
BarsToConfirm:          2

MONEY MANAGEMENT
RiskPercent:            1.0%
MaxLotSize:             10.0
TP1_ATR_Mult:           1.5
SL_ATR_Mult:            1.5

ALERTS & LOGGING
EnableLogging:          true
DoPopup:                false
DoSound:                false
```

### Aggressive Setup (Only After Successful Testing)
```
TRADING SETTINGS
EnableTrading:          true
MaxOpenTrades:          5
MaxTradesPerDay:        15

SIGNAL SETTINGS
EnableHTFFilter:        true
RequireBothHTF:         false
BarsToConfirm:          1

MONEY MANAGEMENT
RiskPercent:            2.0%
MaxLotSize:             20.0
TP1_ATR_Mult:           1.5
SL_ATR_Mult:            1.5

ALERTS & LOGGING
EnableLogging:          true
DoPopup:                true
DoSound:                true
```

---

## Part 4: Parameter Tuning Workflow

### Step 1: Initial Setup (Week 1)
1. Use **Conservative Setup** parameters
2. Attach EA to chart
3. Monitor for 5-7 days
4. Document all trades in monitoring log
5. Evaluate performance

### Step 2: Evaluation Criteria
After 5-7 days, evaluate:
- [ ] Win rate: Target > 50%
- [ ] Profit factor: Target > 1.5
- [ ] Max drawdown: Should be < 5%
- [ ] Number of trades: At least 5-10 trades
- [ ] No major losses: No single trade > 2% loss

### Step 3: Adjustment Decision
**If performance is good:**
- Continue with same parameters for another week
- Gradually increase to Moderate Setup

**If performance is poor:**
- Increase BarsToConfirm to 3 (more confirmation)
- Decrease RiskPercent to 0.25% (lower risk)
- Enable RequireBothHTF (stricter signals)
- Run another 5-7 days

**If no trades generated:**
- Decrease BarsToConfirm to 1 (fewer bars to confirm)
- Disable RequireBothHTF (less strict)
- Verify EnableTrading is true
- Check chart timeframe matches TradeTimeframe

### Step 4: Parameter Change Procedure
1. Right-click on chart
2. Click **Expert Advisors** → **Edit Expert Advisor**
3. EA Properties dialog opens
4. Modify parameters
5. Click **OK**
6. EA reloads with new parameters
7. Document changes in monitoring log

---

## Part 5: Chart Setup for Monitoring

### Step 1: Arrange Windows
1. Position chart window prominently
2. Keep **Account History** visible (Ctrl+H)
3. Keep **Toolbox** visible (shows EA logs)
4. Arrange so you can see:
   - Price action on chart
   - Open positions
   - Account balance/equity
   - EA trade logs

### Step 2: Add Visual Indicators (Optional)
For reference during monitoring:
1. Right-click on chart → **Indicators** → **Insert Indicator**
2. Add:
   - **ATR** (14) - shows volatility
   - **EMA** (20) - shows trend
3. These help understand EA decisions

### Step 3: Configure Chart Alerts (Optional)
1. Right-click on chart → **Properties** (F8)
2. Go to **Events** tab
3. Configure:
   - [ ] **New Bar**: Checked (alerts on new candle)
   - [ ] **Ask/Bid Change**: Unchecked (too frequent)
4. Click **OK**

---

## Part 6: Attachment Checklist

### Pre-Attachment Verification
- [ ] Chart open for EURUSD H1
- [ ] Chart displays at least 100 candles
- [ ] Bid/Ask prices updating in real-time
- [ ] EA compiled successfully (0 errors)
- [ ] EA visible in Navigator
- [ ] Demo account connected and active
- [ ] Automated trading enabled

### Parameter Configuration
- [ ] EnableTrading: **true**
- [ ] TradeTimeframe: **PERIOD_H1** (matches chart)
- [ ] RiskPercent: **0.5%** (conservative for week 1)
- [ ] MaxOpenTrades: **2** (conservative)
- [ ] MaxTradesPerDay: **5** (conservative)
- [ ] EnableLogging: **true**
- [ ] RequireBothHTF: **true** (strict signals)
- [ ] BarsToConfirm: **2** (non-repaint)

### Post-Attachment Verification
- [ ] EA name appears in chart title
- [ ] EA icon visible in top-left corner
- [ ] Toolbox shows initialization messages
- [ ] No error messages in Toolbox
- [ ] Account balance visible
- [ ] Ready to monitor

---

## Part 7: Troubleshooting

### Issue: EA Won't Attach
**Solution**:
1. Verify EA is compiled (check for .ex5 file)
2. Restart MetaTrader 5
3. Try attaching again
4. Check Toolbox for error messages

### Issue: EA Attaches but Won't Trade
**Solution**:
1. Verify EnableTrading is set to **true**
2. Check Toolbox for error messages
3. Verify account has sufficient balance
4. Check symbol is correct (EURUSD)
5. Verify timeframe matches (H1)

### Issue: EA Generates Too Many Trades
**Solution**:
1. Increase BarsToConfirm to 3 or 4
2. Enable RequireBothHTF (stricter)
3. Decrease RiskPercent to 0.5%
4. Reduce MaxTradesPerDay

### Issue: EA Generates No Trades
**Solution**:
1. Decrease BarsToConfirm to 1
2. Disable RequireBothHTF (less strict)
3. Verify EnableTrading is true
4. Check chart has sufficient history (100+ candles)
5. Wait for signal conditions to align

### Issue: Trades Close Immediately
**Solution**:
1. Check SL/TP levels are reasonable
2. Verify spread is not too wide
3. Check for slippage issues
4. Verify execution mode is correct

---

## Summary

**EA Attachment Complete When:**
1. ✓ EA attached to EURUSD H1 chart
2. ✓ EA icon visible in chart title
3. ✓ EnableTrading set to true
4. ✓ Conservative parameters configured
5. ✓ Monitoring windows arranged
6. ✓ Toolbox shows no errors
7. ✓ Ready to monitor trades

**Next Step**: Proceed to Monitoring Checklist
