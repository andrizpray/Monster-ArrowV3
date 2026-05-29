# MonsterArrows V3 EA - Demo Account Setup Checklist

## Overview
This checklist ensures your demo account is properly configured for safe, controlled testing of the MonsterArrows_V3_EA before any live trading.

---

## Part 1: Demo Account Selection & Creation

### Step 1: Choose Demo Account Type
In MetaTrader 5, you have options:

| Account Type | Best For | Pros | Cons |
|--------------|----------|------|------|
| **Broker Demo** | Realistic testing | Real spreads, real execution | Limited time (30-90 days) |
| **MetaQuotes Demo** | Quick testing | Unlimited time, tight spreads | Not broker-specific |
| **Unlimited Demo** | Long-term testing | Persistent account | May have different conditions |

**Recommendation for Phase 7**: Use **Broker Demo** for most realistic conditions

### Step 2: Create/Access Demo Account
1. Open **MetaTrader 5**
2. Click **File** → **Login**
3. If no demo account exists:
   - Click **Open an Account**
   - Select broker
   - Choose **Demo Account**
   - Fill in details (name, email, country)
   - Select account type (Standard, Micro, etc.)
   - Click **Open Demo Account**
4. If demo account exists:
   - Select from dropdown
   - Enter password
   - Click **Login**

### Step 3: Verify Demo Account Connection
After login, verify:
- [ ] Account status shows **Demo** (bottom-right corner)
- [ ] Account number visible (e.g., `12345678`)
- [ ] Broker name displayed
- [ ] Connection status shows **Connected**
- [ ] Server time synchronized with local time

---

## Part 2: Account Settings Configuration

### Step 1: Account Information Review
1. Click **Tools** → **Account History** (or press Ctrl+H)
2. Verify these details:
   - **Account Type**: Demo
   - **Leverage**: Typically 1:100 or 1:500 (note this value)
   - **Currency**: USD or EUR (note this value)
   - **Balance**: Initial deposit amount (e.g., $10,000)
   - **Equity**: Should equal Balance initially
   - **Free Margin**: Should equal Balance initially

### Step 2: Configure Trading Settings
1. Click **Tools** → **Options** (or press Ctrl+O)
2. Go to **Trading** tab
3. Configure:
   - [ ] **Default Volume**: Set to 0.1 (will be overridden by EA)
   - [ ] **Deviation**: Set to 10 points (slippage tolerance)
   - [ ] **Execution Mode**: Select **Instant Execution** or **Market Execution**
   - [ ] **Order Expiration**: Set to **Good Till Cancel (GTC)**

### Step 3: Configure Expert Advisor Settings
1. In **Options** dialog, go to **Expert Advisors** tab
2. Verify these are **CHECKED**:
   - [ ] **Allow automated trading**
   - [ ] **Allow DLL imports** (if EA uses external libraries)
   - [ ] **Allow WebRequest** (if EA uses API calls)
3. Set **Timeout for Expert Advisor** to 5000 ms (5 seconds)
4. Click **OK**

### Step 4: Configure Notifications (Optional)
1. In **Options** dialog, go to **Notifications** tab
2. For demo testing, you can enable:
   - [ ] **Enable notifications** (if using mobile alerts)
   - [ ] **Show notifications in terminal** (for on-screen alerts)
3. Click **OK**

---

## Part 3: Initial Capital & Risk Settings

### Step 1: Determine Initial Demo Balance
**Recommended starting balances:**

| Trading Style | Recommended Balance | Rationale |
|---------------|-------------------|-----------|
| **Conservative** | $5,000 | Test with small positions, low risk |
| **Moderate** | $10,000 | Standard demo account size |
| **Aggressive** | $25,000 | Test larger positions, higher leverage |

**For Phase 7 (First Week Testing)**: Start with **$10,000**

### Step 2: Verify Account Balance
1. In MT5, check **Account History** (Ctrl+H)
2. Look for **Balance** row
3. If balance is insufficient:
   - Contact broker for additional demo funds
   - Or create new demo account with desired balance

### Step 3: Calculate Risk Parameters
Based on initial balance, set EA parameters:

**Example with $10,000 balance:**

```
Initial Balance: $10,000

Risk Per Trade (RiskPercent): 1.0%
  → Risk per trade: $100

Max Daily Loss (MaxDailyLoss): 5.0%
  → Max daily loss: $500

Max Drawdown (MaxDrawdown): 10.0%
  → Max account drawdown: $1,000

Max Open Trades (MaxOpenTrades): 3
  → Maximum 3 simultaneous positions

Max Trades Per Day (MaxTradesPerDay): 10
  → Maximum 10 trades in 24 hours
```

### Step 4: Document Risk Settings
Create a reference card:

```
DEMO ACCOUNT RISK SETTINGS
==========================
Account Balance:        $10,000
Risk Per Trade:         1.0% ($100)
Max Daily Loss:         5.0% ($500)
Max Drawdown:           10.0% ($1,000)
Max Open Trades:        3
Max Trades Per Day:     10
Trailing Stop:          Disabled (for demo)
```

---

## Part 4: Symbol & Timeframe Configuration

### Step 1: Select Trading Symbol
1. In MT5, right-click on **Market Watch** panel
2. Click **Symbols** (or press Ctrl+U)
3. Select symbol to trade:
   - **Recommended for demo**: EURUSD (most liquid, tight spreads)
   - **Alternative**: GBPUSD, USDJPY, AUDUSD
4. Click **Show** to add to Market Watch
5. Click **OK**

### Step 2: Verify Symbol Properties
1. Right-click symbol in Market Watch
2. Click **Specification**
3. Verify:
   - [ ] **Spread**: Typically 1-2 pips for EURUSD
   - [ ] **Minimum Lot**: Usually 0.01
   - [ ] **Maximum Lot**: Usually 100+
   - [ ] **Lot Step**: Usually 0.01
   - [ ] **Digits**: Usually 5 (for major pairs)

### Step 3: Select Trading Timeframe
1. Open chart for selected symbol (e.g., EURUSD)
2. Right-click on chart → **Timeframes**
3. Select timeframe:
   - **Recommended for demo**: H1 (1-hour) or H4 (4-hour)
   - **Rationale**: Fewer false signals, more stable trends
   - **Avoid**: M1, M5 (too noisy for initial testing)
4. Chart updates to selected timeframe

### Step 4: Document Symbol Settings
```
TRADING SYMBOL SETTINGS
=======================
Primary Symbol:         EURUSD
Trading Timeframe:      H1 (1-hour)
Spread (typical):       1-2 pips
Minimum Lot:            0.01
Maximum Lot:            100+
Lot Step:               0.01
Digits:                 5
```

---

## Part 5: Chart Preparation

### Step 1: Open Chart for Trading
1. In MT5, double-click symbol in Market Watch (e.g., EURUSD)
2. Chart window opens
3. Right-click on chart → **Timeframes** → Select **H1**
4. Chart displays 1-hour candles

### Step 2: Configure Chart Display
1. Right-click on chart → **Properties** (or press F8)
2. Go to **Common** tab
3. Configure:
   - [ ] **Show Grid**: Checked (helps read levels)
   - [ ] **Show Bid Line**: Checked (shows current price)
   - [ ] **Show Ask Line**: Checked (shows ask price)
   - [ ] **Show Last Line**: Unchecked (not needed)
4. Go to **Candles** tab
5. Configure:
   - [ ] **Candle Color (Up)**: Green or white
   - [ ] **Candle Color (Down)**: Red or black
   - [ ] **Wick Color**: Gray or white
6. Click **OK**

### Step 3: Add Key Indicators (Optional)
For visual reference during monitoring:
1. Right-click on chart → **Indicators** → **Insert Indicator**
2. Add (optional):
   - **ATR** (14 period) - shows volatility
   - **EMA** (20 period) - shows trend direction
   - **RSI** (14 period) - shows overbought/oversold
3. These are for reference only; EA uses its own calculations

### Step 4: Arrange Workspace
1. Position chart window for easy monitoring
2. Keep **Account History** visible (Ctrl+H)
3. Keep **Toolbox** visible (shows EA logs)
4. Arrange so you can see:
   - Chart with price action
   - Account balance/equity
   - EA trade logs

---

## Part 6: Pre-Deployment Verification

### Step 1: Verify Account Status
- [ ] Account type: **Demo**
- [ ] Connection status: **Connected**
- [ ] Balance: $10,000 (or your chosen amount)
- [ ] Equity: Equals Balance (no open trades yet)
- [ ] Free Margin: Equals Balance

### Step 2: Verify Trading Permissions
- [ ] Automated trading: **Enabled**
- [ ] DLL imports: **Enabled**
- [ ] WebRequest: **Enabled**
- [ ] Deviation: Set to 10 points
- [ ] Execution mode: **Instant** or **Market**

### Step 3: Verify Symbol & Timeframe
- [ ] Symbol: **EURUSD** (or chosen symbol)
- [ ] Timeframe: **H1** (or chosen timeframe)
- [ ] Chart displays correctly
- [ ] Bid/Ask prices visible
- [ ] Spread is reasonable (1-2 pips)

### Step 4: Verify EA File
- [ ] EA compiled successfully (0 errors)
- [ ] EA appears in Navigator → Expert Advisors
- [ ] EA file location: `MQL5\Experts\MonsterArrows_V3_EA.ex5`
- [ ] Log file directory exists and is writable

### Step 5: Verify Risk Settings
- [ ] RiskPercent: 1.0%
- [ ] MaxDailyLoss: 5.0%
- [ ] MaxDrawdown: 10.0%
- [ ] MaxOpenTrades: 3
- [ ] MaxTradesPerDay: 10

---

## Part 7: Demo Account Checklist

### Pre-Deployment Checklist
Complete this before attaching EA to chart:

```
DEMO ACCOUNT SETUP CHECKLIST
============================

ACCOUNT SETUP
[ ] Demo account created and logged in
[ ] Account type verified as "Demo"
[ ] Connection status shows "Connected"
[ ] Initial balance: $10,000
[ ] Leverage verified (typically 1:100 or 1:500)

TRADING SETTINGS
[ ] Automated trading enabled
[ ] DLL imports enabled
[ ] WebRequest enabled
[ ] Deviation set to 10 points
[ ] Execution mode set to Instant/Market

SYMBOL & TIMEFRAME
[ ] Symbol selected: EURUSD
[ ] Timeframe selected: H1
[ ] Chart displays correctly
[ ] Bid/Ask prices visible
[ ] Spread is 1-2 pips

EA CONFIGURATION
[ ] EA compiled (0 errors)
[ ] EA visible in Navigator
[ ] RiskPercent: 1.0%
[ ] MaxDailyLoss: 5.0%
[ ] MaxDrawdown: 10.0%
[ ] MaxOpenTrades: 3
[ ] MaxTradesPerDay: 10

MONITORING SETUP
[ ] Chart window positioned for viewing
[ ] Account History visible
[ ] Toolbox visible for logs
[ ] Log file directory ready
[ ] Backup of EA created

READY FOR DEPLOYMENT
[ ] All items checked
[ ] Risk parameters documented
[ ] Initial balance confirmed
[ ] Ready to attach EA to chart
```

---

## Part 8: Troubleshooting

### Issue: Can't Create Demo Account
**Solution**:
1. Verify internet connection
2. Try different broker
3. Use MetaQuotes demo account (unlimited)
4. Contact broker support

### Issue: Account Shows "Real" Instead of "Demo"
**Solution**:
1. Log out (File → Logout)
2. Log back in and select demo account
3. If still shows real, create new demo account

### Issue: Insufficient Balance
**Solution**:
1. Request additional demo funds from broker
2. Or create new demo account with higher initial balance
3. Or reduce risk parameters proportionally

### Issue: Symbol Not Available
**Solution**:
1. Verify symbol is available on broker
2. Check symbol spelling (e.g., EURUSD not EUR/USD)
3. Try alternative symbol (GBPUSD, USDJPY)
4. Contact broker if symbol unavailable

### Issue: Spread Too Wide
**Solution**:
1. Check market hours (spreads wider during off-hours)
2. Try different symbol with tighter spread
3. Verify connection quality
4. Contact broker about spread issues

---

## Summary

**Demo Account Setup Complete When:**
1. ✓ Demo account created and connected
2. ✓ Account balance verified ($10,000)
3. ✓ Trading permissions enabled
4. ✓ Symbol selected (EURUSD)
5. ✓ Timeframe selected (H1)
6. ✓ Risk parameters documented
7. ✓ Chart prepared and visible
8. ✓ EA compiled and ready
9. ✓ All checklist items verified

**Next Step**: Proceed to EA Attachment Guide
