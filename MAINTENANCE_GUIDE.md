# MAINTENANCE GUIDE - MonsterArrows V3 EA
## Ongoing Support, Troubleshooting & Optimization

**Project:** MonsterArrows V3 Expert Advisor  
**Version:** 3.0  
**Status:** ✅ Production-Ready  
**Date:** May 29, 2026  

---

## Executive Summary

This guide provides comprehensive support for maintaining, troubleshooting, and optimizing the MonsterArrows V3 Expert Advisor after deployment. It covers common issues, solutions, parameter tuning, performance optimization, and ongoing maintenance procedures.

**Key Topics:**
- Common issues and solutions
- Parameter tuning guide
- Performance optimization
- Update procedures
- Troubleshooting workflows
- Support resources

---

## Common Issues & Solutions

### Issue 1: EA Not Attaching to Chart

**Symptoms:**
- EA doesn't appear in chart dropdown
- "Expert Advisor not found" error
- EA file not visible in Navigator

**Root Causes:**
- EA not compiled
- EA file in wrong location
- MetaTrader 5 not restarted
- Syntax errors in code

**Solutions:**

**Step 1: Verify Compilation**
1. Open MetaEditor
2. Open `MonsterArrows_V3_EA.mq5`
3. Press F7 to compile
4. Check for errors in Errors tab
5. Fix any errors and recompile

**Step 2: Verify File Location**
1. Open MetaTrader 5
2. Go to File → Open Data Folder
3. Navigate to: `MQL5/Experts/`
4. Verify `MonsterArrows_V3_EA.ex5` exists
5. If not, copy compiled file there

**Step 3: Restart MetaTrader 5**
1. Close MetaTrader 5 completely
2. Wait 10 seconds
3. Reopen MetaTrader 5
4. Check Navigator for EA

**Step 4: Verify EA Properties**
1. Right-click EA in Navigator
2. Select "Modify"
3. Check: `#property strict` is present
4. Check: No syntax errors
5. Recompile if needed

**Prevention:**
- Always compile before attaching
- Verify file location after compilation
- Restart MT5 after file changes
- Keep backup of EA file

---

### Issue 2: EA Attaches but Doesn't Trade

**Symptoms:**
- EA attached to chart
- No trades executed
- No errors in journal
- EA appears to be running

**Root Causes:**
- `EnableTrading` set to false
- Risk limits blocking trades
- No signals detected
- Insufficient account balance

**Solutions:**

**Step 1: Check EnableTrading Setting**
1. Right-click chart
2. Select "Expert Advisors" → "Edit"
3. Find `EnableTrading` parameter
4. Set to `true` (for live trading)
5. Click OK

**Step 2: Check Risk Limits**
1. Review account balance
2. Check daily loss limit (default: 5%)
3. Check drawdown limit (default: 10%)
4. Check margin level (should be > 500%)
5. Verify max open trades not exceeded

**Step 3: Check Signal Detection**
1. Open chart with EA attached
2. Look for signal indicators on chart
3. Check if signals are being generated
4. Review EA journal for signal messages
5. Verify indicator parameters

**Step 4: Check Account Balance**
1. Verify account has sufficient balance
2. Check minimum lot size requirements
3. Verify account currency matches symbol
4. Check for any account restrictions

**Step 5: Enable Logging**
1. Right-click chart
2. Select "Expert Advisors" → "Edit"
3. Set `LogTrades` to `true`
4. Set `SendAlerts` to `true`
5. Click OK
6. Check log file for details

**Prevention:**
- Always verify `EnableTrading` before live trading
- Monitor risk limits daily
- Keep account balance above minimum
- Review logs regularly

---

### Issue 3: Trades Executing but Closing Immediately

**Symptoms:**
- Trades open and close within seconds
- No profit/loss on trades
- Rapid entry and exit
- Confusing trade history

**Root Causes:**
- Stop loss too close to entry
- Take profit too close to entry
- Slippage causing immediate exit
- Signal confirmation issue

**Solutions:**

**Step 1: Check SL/TP Calculation**
1. Review recent trades in history
2. Calculate SL distance from entry
3. Calculate TP distance from entry
4. Compare to ATR value
5. Verify calculations are correct

**Step 2: Adjust ATR Multipliers**
1. Right-click chart
2. Select "Expert Advisors" → "Edit"
3. Find `SL_ATR_Mult` (default: 1.0)
4. Increase to 1.5 or 2.0
5. Find `TP1_ATR_Mult` (default: 1.5)
6. Increase to 2.0 or 2.5
7. Click OK

**Step 3: Check Slippage**
1. Review trade execution prices
2. Compare to market price at entry
3. Calculate slippage (pips)
4. If > 5 pips, check broker/connection
5. Consider adjusting order type

**Step 4: Verify Signal Confirmation**
1. Check `BarsToConfirm` setting (default: 2)
2. Increase to 3 or 4 for more confirmation
3. This prevents false signals
4. May reduce trade frequency

**Step 5: Review Trade Log**
1. Open log file: `MonsterArrows_EA.log`
2. Review entry and exit details
3. Check SL and TP prices
4. Verify calculations
5. Identify pattern

**Prevention:**
- Monitor first few trades carefully
- Adjust ATR multipliers gradually
- Test on demo before live
- Review logs regularly

---

### Issue 4: Excessive Losses or Negative Win Rate

**Symptoms:**
- More losing trades than winning
- Win rate < 50%
- Profit factor < 1.5
- Cumulative losses increasing

**Root Causes:**
- Signal parameters not optimized for market
- Risk parameters too aggressive
- Market conditions changed
- Slippage or execution issues

**Solutions:**

**Step 1: Analyze Trade History**
1. Export trade history to spreadsheet
2. Calculate win rate
3. Calculate profit factor
4. Identify losing trade patterns
5. Look for common characteristics

**Step 2: Review Signal Parameters**
1. Check `EnableHTFFilter` (should be true)
2. Check `RequireBothHTF` (should be true)
3. Check `BarsToConfirm` (increase if needed)
4. Review indicator parameters
5. Consider adjusting for market conditions

**Step 3: Adjust Risk Parameters**
1. Reduce `RiskPercent` (from 1.0 to 0.5)
2. Increase `SL_ATR_Mult` (from 1.0 to 1.5)
3. Increase `TP1_ATR_Mult` (from 1.5 to 2.0)
4. Increase `TP2_ATR_Mult` (from 3.0 to 4.0)
5. Test changes on demo

**Step 4: Check Market Conditions**
1. Review market volatility (ATR)
2. Check trend direction
3. Identify support/resistance levels
4. Look for ranging vs trending markets
5. Consider market session (London, NY, etc.)

**Step 5: Backtest Changes**
1. Open Strategy Tester in MT5
2. Load EA with new parameters
3. Run backtest on historical data
4. Review results
5. Compare to previous parameters

**Step 6: Paper Trade Changes**
1. Apply changes to demo account
2. Monitor for 1-2 weeks
3. Track metrics carefully
4. Compare to previous performance
5. Adjust further if needed

**Prevention:**
- Monitor win rate daily
- Review trades weekly
- Adjust parameters gradually
- Backtest before live changes
- Keep detailed records

---

### Issue 5: Margin Call or Account Depletion

**Symptoms:**
- Margin level dropping rapidly
- Account balance decreasing
- Broker warning about margin
- Positions being closed by broker

**Root Causes:**
- Position size too large
- Risk percentage too high
- Consecutive losses
- Slippage or execution issues

**Solutions:**

**Step 1: Immediate Action**
1. Stop EA immediately (detach from chart)
2. Close any losing positions manually
3. Review account status
4. Check margin level
5. Contact broker if needed

**Step 2: Analyze What Happened**
1. Review trade history
2. Calculate total loss
3. Identify losing trades
4. Check position sizes
5. Verify risk calculations

**Step 3: Adjust Risk Parameters**
1. Reduce `RiskPercent` significantly (to 0.5 or less)
2. Reduce `MaxOpenTrades` (from 3 to 1)
3. Increase `MaxDailyLoss` limit (to 2%)
4. Increase `MaxDrawdown` limit (to 5%)
5. Increase `SL_ATR_Mult` (to 2.0 or higher)

**Step 4: Verify Position Sizing**
1. Calculate lot size manually
2. Verify formula: Lot = (Risk $ / SL pips) / pip value
3. Check against account balance
4. Verify maximum lot size not exceeded
5. Test calculation with small trade

**Step 5: Resume Trading Carefully**
1. Attach EA with new parameters
2. Monitor first trade closely
3. Verify position size is correct
4. Check margin level after entry
5. Continue monitoring

**Step 6: Rebuild Account**
1. Trade with very small position sizes
2. Focus on consistency, not profit
3. Build confidence with small wins
4. Gradually increase position size
5. Monitor margin level constantly

**Prevention:**
- Monitor margin level daily
- Set daily loss limits
- Use position size calculator
- Never risk more than 1-2% per trade
- Keep emergency stop-loss in place

---

### Issue 6: EA Crashes or Stops Running

**Symptoms:**
- EA suddenly stops trading
- Chart shows "EA stopped"
- No error messages
- EA needs to be reattached

**Root Causes:**
- Critical error in code
- Indicator handle invalid
- Memory issue
- Connection lost

**Solutions:**

**Step 1: Check Journal for Errors**
1. Open MetaTrader 5 Journal tab
2. Look for error messages
3. Note error code and description
4. Search for error in documentation
5. Identify root cause

**Step 2: Verify Indicator Handles**
1. Check if indicators are still valid
2. Verify indicator parameters
3. Check if indicator data available
4. Restart MT5 if needed
5. Reattach EA

**Step 3: Check Connection**
1. Verify internet connection
2. Check broker connection status
3. Verify account is still connected
4. Check for any connection warnings
5. Reconnect if needed

**Step 4: Review Recent Changes**
1. Check if any parameters were changed
2. Verify parameter values are valid
3. Check if market conditions changed
4. Review recent trades
5. Identify any anomalies

**Step 5: Restart EA**
1. Detach EA from chart
2. Wait 10 seconds
3. Reattach EA to chart
4. Verify EA is running
5. Monitor for errors

**Step 6: Check System Resources**
1. Check available memory
2. Check CPU usage
3. Check disk space
4. Close unnecessary programs
5. Restart computer if needed

**Prevention:**
- Monitor EA status regularly
- Check journal for warnings
- Keep system resources available
- Maintain stable internet connection
- Restart MT5 daily

---

### Issue 7: Trades Not Logging to File

**Symptoms:**
- Log file not created
- Log file empty
- Trades executed but not logged
- No trade history available

**Root Causes:**
- `LogTrades` set to false
- File permissions issue
- Disk space issue
- File path incorrect

**Solutions:**

**Step 1: Verify LogTrades Setting**
1. Right-click chart
2. Select "Expert Advisors" → "Edit"
3. Find `LogTrades` parameter
4. Set to `true`
5. Click OK

**Step 2: Check File Location**
1. Open MetaTrader 5
2. Go to File → Open Data Folder
3. Navigate to: `MQL5/Files/`
4. Look for `MonsterArrows_EA.log`
5. If not found, check file permissions

**Step 3: Verify File Permissions**
1. Right-click log file
2. Select "Properties"
3. Check "Read-only" is NOT checked
4. Check user has write permissions
5. Change permissions if needed

**Step 4: Check Disk Space**
1. Open File Explorer
2. Right-click drive
3. Select "Properties"
4. Check available space
5. Free up space if needed

**Step 5: Verify File Path**
1. Right-click chart
2. Select "Expert Advisors" → "Edit"
3. Check `LogFileName` parameter
4. Verify path is correct
5. Use default path if unsure

**Step 6: Manually Create Log File**
1. Open Notepad
2. Save as: `MonsterArrows_EA.log`
3. Place in: `MQL5/Files/` folder
4. Reattach EA
5. Verify logging works

**Prevention:**
- Always enable logging
- Check log file regularly
- Verify file permissions
- Keep disk space available
- Use default file path

---

## Parameter Tuning Guide

### Understanding Parameters

**Signal Parameters:**
- Control how signals are detected
- Affect trade frequency and quality
- Should be adjusted for market conditions
- Backtest before applying

**Risk Parameters:**
- Control position sizing and risk
- Affect account drawdown
- Should match account size and risk tolerance
- Conservative settings recommended

**Money Management Parameters:**
- Control profit taking and stop loss
- Affect risk/reward ratio
- Should be optimized for market
- Test on demo before live

### Tuning Workflow

**Step 1: Baseline Testing**
1. Use default parameters
2. Run on demo for 1-2 weeks
3. Track performance metrics
4. Document results
5. Identify areas for improvement

**Step 2: Identify Issues**
1. Analyze trade history
2. Calculate win rate
3. Calculate profit factor
4. Identify losing patterns
5. Determine what to adjust

**Step 3: Make One Change**
1. Change ONE parameter only
2. Document the change
3. Run on demo for 1-2 weeks
4. Track performance
5. Compare to baseline

**Step 4: Evaluate Results**
1. Calculate new metrics
2. Compare to baseline
3. Determine if improvement
4. Keep change if better
5. Revert if worse

**Step 5: Repeat Process**
1. Identify next parameter to adjust
2. Make one change
3. Test for 1-2 weeks
4. Evaluate results
5. Keep or revert

**Step 6: Backtest Final Parameters**
1. Use Strategy Tester
2. Run on historical data
3. Verify results
4. Compare to live testing
5. Deploy if satisfied

### Conservative Parameter Set (Week 1)

```
EnableTrading:          false
RiskPercent:            1.0
MaxOpenTrades:          3
MaxTradesPerDay:        10
EnableHTFFilter:        true
RequireBothHTF:         true
BarsToConfirm:          2
SL_ATR_Mult:            1.0
TP1_ATR_Mult:           1.5
TP2_ATR_Mult:           3.0
MaxDailyLoss:           5.0
MaxDrawdown:            10.0
```

### Moderate Parameter Set (Week 2+)

```
EnableTrading:          false (until decision)
RiskPercent:            1.5
MaxOpenTrades:          5
MaxTradesPerDay:        15
EnableHTFFilter:        true
RequireBothHTF:         true
BarsToConfirm:          1
SL_ATR_Mult:            1.0
TP1_ATR_Mult:           1.5
TP2_ATR_Mult:           3.0
MaxDailyLoss:           5.0
MaxDrawdown:            10.0
```

### Aggressive Parameter Set (Advanced)

```
EnableTrading:          false (until decision)
RiskPercent:            2.0
MaxOpenTrades:          10
MaxTradesPerDay:        20
EnableHTFFilter:        false
RequireBothHTF:         false
BarsToConfirm:          0
SL_ATR_Mult:            0.8
TP1_ATR_Mult:           1.5
TP2_ATR_Mult:           3.0
MaxDailyLoss:           5.0
MaxDrawdown:            10.0
```

### Parameter Adjustment Guide

**To Increase Trade Frequency:**
- Decrease `BarsToConfirm` (from 2 to 1 or 0)
- Set `EnableHTFFilter` to false
- Set `RequireBothHTF` to false
- Decrease `ST_ATRMult` (from 1.0 to 0.8)

**To Decrease Trade Frequency:**
- Increase `BarsToConfirm` (from 2 to 3 or 4)
- Set `EnableHTFFilter` to true
- Set `RequireBothHTF` to true
- Increase `ST_ATRMult` (from 1.0 to 1.5)

**To Increase Profit Per Trade:**
- Increase `TP1_ATR_Mult` (from 1.5 to 2.0)
- Increase `TP2_ATR_Mult` (from 3.0 to 4.0)
- Increase `SL_ATR_Mult` (from 1.0 to 1.5)

**To Reduce Risk Per Trade:**
- Decrease `RiskPercent` (from 1.0 to 0.5)
- Increase `SL_ATR_Mult` (from 1.0 to 1.5)
- Decrease `MaxOpenTrades` (from 3 to 1)

**To Reduce Drawdown:**
- Decrease `RiskPercent` (from 1.0 to 0.5)
- Decrease `MaxOpenTrades` (from 3 to 1)
- Increase `MaxDailyLoss` limit (to 2%)
- Increase `MaxDrawdown` limit (to 5%)

---

## Performance Optimization

### Optimization Checklist

**Code Performance:**
- [ ] EA executes in < 20 ms per tick
- [ ] No memory leaks
- [ ] Indicator handles valid
- [ ] Data retrieval efficient

**Trading Performance:**
- [ ] Win rate > 50%
- [ ] Profit factor > 1.5
- [ ] Risk/Reward ratio > 1.5
- [ ] Drawdown < 5%

**System Performance:**
- [ ] CPU usage < 10%
- [ ] Memory usage < 500 MB
- [ ] Disk I/O minimal
- [ ] Network latency < 100 ms

### Optimization Procedures

**Optimize Signal Detection:**
1. Review signal parameters
2. Backtest different combinations
3. Identify best performing set
4. Deploy to demo
5. Monitor results

**Optimize Position Sizing:**
1. Calculate optimal position size
2. Test with different risk percentages
3. Monitor drawdown
4. Adjust for account size
5. Verify margin safety

**Optimize Entry/Exit:**
1. Analyze entry prices
2. Analyze exit prices
3. Calculate slippage
4. Optimize order type
5. Test on demo

**Optimize Risk Management:**
1. Review daily loss limits
2. Review drawdown limits
3. Adjust for account size
4. Test on demo
5. Monitor compliance

---

## Update Procedures

### Applying Updates

**Step 1: Backup Current Version**
1. Copy `MonsterArrows_V3_EA.mq5` to backup folder
2. Copy `MonsterArrows_V3_EA.ex5` to backup folder
3. Copy log file to backup folder
4. Document current version number
5. Document current parameters

**Step 2: Download New Version**
1. Obtain new EA file
2. Verify file integrity
3. Check version number
4. Review change log
5. Understand changes

**Step 3: Test New Version**
1. Compile new version
2. Test on demo account
3. Compare to old version
4. Verify improvements
5. Check for issues

**Step 4: Deploy New Version**
1. Stop old EA (detach from chart)
2. Replace EA file
3. Restart MetaTrader 5
4. Attach new EA
5. Verify it's running

**Step 5: Monitor New Version**
1. Track performance metrics
2. Compare to old version
3. Watch for issues
4. Keep backup available
5. Document results

### Rollback Procedure

**If New Version Has Issues:**
1. Detach new EA from chart
2. Restore backup EA file
3. Restart MetaTrader 5
4. Reattach old EA
5. Verify it's running
6. Document issue
7. Report to support

---

## Monitoring & Logging

### Daily Monitoring Checklist

**Morning (5 minutes):**
- [ ] Check overnight trades
- [ ] Review account balance
- [ ] Check margin level
- [ ] Review daily P&L
- [ ] Note any issues

**During Day (As needed):**
- [ ] Monitor active trades
- [ ] Watch for red flags
- [ ] Check connection status
- [ ] Verify EA is running

**Evening (10 minutes):**
- [ ] Log daily results
- [ ] Update tracking sheet
- [ ] Calculate daily metrics
- [ ] Note observations

### Weekly Monitoring Checklist

**Every Friday (30 minutes):**
- [ ] Calculate weekly metrics
- [ ] Review all trades
- [ ] Calculate win rate
- [ ] Calculate profit factor
- [ ] Calculate drawdown
- [ ] Compare to targets
- [ ] Document observations
- [ ] Plan adjustments

### Monthly Monitoring Checklist

**End of Month (1 hour):**
- [ ] Calculate monthly metrics
- [ ] Review all trades
- [ ] Analyze performance
- [ ] Identify trends
- [ ] Compare to targets
- [ ] Plan improvements
- [ ] Document results
- [ ] Archive logs

---

## Troubleshooting Workflow

### General Troubleshooting Process

**Step 1: Identify Problem**
1. Describe the issue clearly
2. Note when it started
3. Note what changed
4. Check journal for errors
5. Review recent trades

**Step 2: Gather Information**
1. Check EA parameters
2. Review account status
3. Check market conditions
4. Review trade history
5. Check system resources

**Step 3: Isolate Issue**
1. Detach EA from chart
2. Wait 10 seconds
3. Reattach EA
4. Monitor for issue
5. Note if issue persists

**Step 4: Research Solution**
1. Check this guide
2. Review relevant documentation
3. Search for similar issues
4. Check broker support
5. Consult community

**Step 5: Implement Solution**
1. Follow recommended steps
2. Make one change at a time
3. Test after each change
4. Document changes
5. Monitor results

**Step 6: Verify Solution**
1. Confirm issue is resolved
2. Monitor for side effects
3. Test thoroughly
4. Document solution
5. Update procedures

---

## Support Resources

### Documentation Files
- `PROJECT_SUMMARY.md` - Project overview
- `DELIVERY_PACKAGE.md` - What's included
- `QUICK_START_GUIDE.md` - 5-minute quick start
- `ARCHITECTURE_OVERVIEW.md` - Technical details
- `FINAL_CHECKLIST.md` - Verification checklist

### Deployment Guides
- `DEPLOYMENT_GUIDE.md` - Compilation & deployment
- `DEMO_ACCOUNT_SETUP.md` - Account setup
- `EA_ATTACHMENT_GUIDE.md` - EA attachment
- `MONITORING_CHECKLIST.md` - Daily monitoring
- `TRADE_VALIDATION_GUIDE.md` - Trade validation
- `GO_NO_GO_CRITERIA.md` - Decision framework

### Quick Reference
- `QUICK_REFERENCE_CARD.md` - Printable quick reference
- `PHASE_7_INDEX.md` - Master index

### Getting Help
1. Check relevant documentation file
2. Review troubleshooting section
3. Search for similar issues
4. Contact broker support
5. Consult community forums

---

## Conclusion

This maintenance guide provides comprehensive support for the MonsterArrows V3 Expert Advisor. Key points:

- **Common Issues:** 7 major issues with detailed solutions
- **Parameter Tuning:** Step-by-step tuning workflow
- **Performance Optimization:** Procedures for optimization
- **Update Procedures:** Safe update and rollback procedures
- **Monitoring:** Daily, weekly, and monthly checklists
- **Troubleshooting:** General troubleshooting workflow
- **Support Resources:** Links to all documentation

For additional support, refer to the relevant documentation files or contact your broker.

---

**Maintenance Status:** ✅ **COMPREHENSIVE SUPPORT AVAILABLE**  
**Last Updated:** May 29, 2026  
**Support Level:** Full  

