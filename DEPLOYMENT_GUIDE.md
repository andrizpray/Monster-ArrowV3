# MonsterArrows V3 EA - Compilation & Deployment Guide

## Overview
This guide covers compiling the MonsterArrows_V3_EA.mq5 Expert Advisor and deploying it to MetaTrader 5 for demo account testing.

---

## Part 1: Pre-Compilation Checklist

### System Requirements
- **MetaTrader 5** (latest version recommended)
- **MetaEditor** (included with MT5)
- **Windows OS** (MT5 runs on Windows; Mac/Linux use Wine or VM)
- **Disk Space**: ~500MB free (MT5 + EA files)
- **Internet**: Required for live data feeds

### File Verification
Before compilation, verify these files exist:
- `MonsterArrows_V3_EA.mq5` (main EA file, 1,496 lines)
- Location: `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\`

### Backup Strategy
1. Create backup folder: `C:\MT5_Backups\[Date]`
2. Copy entire `Experts` folder before compilation
3. Keep version history (e.g., `MonsterArrows_V3_EA_v1.0.mq5`)

---

## Part 2: Compilation Steps (MetaEditor)

### Step 1: Open MetaEditor
1. Launch **MetaTrader 5**
2. Click **Tools** → **MetaEditor** (or press `F4`)
3. MetaEditor window opens

### Step 2: Open EA File
1. In MetaEditor, click **File** → **Open**
2. Navigate to: `MQL5\Experts\`
3. Select `MonsterArrows_V3_EA.mq5`
4. File opens in editor

### Step 3: Verify Code Structure
Before compiling, scan for:
- **#include statements** at top (should include `<Trade\Trade.mqh>`)
- **Input parameters** defined (lines 17-67)
- **OnInit()** function present
- **OnTick()** function present
- **OnDeinit()** function present
- No syntax errors (red squiggles in editor)

### Step 4: Compile
1. Click **Compile** button (or press `F5`)
2. Watch **Toolbox** panel at bottom for compilation output
3. Expected output:
   ```
   0 error(s), 0 warning(s)
   ```

### Step 5: Handle Compilation Errors

**If errors appear:**

| Error | Cause | Solution |
|-------|-------|----------|
| `'Trade.mqh' - file not found` | Missing include file | Verify `#include <Trade\Trade.mqh>` is present |
| `Undeclared identifier` | Variable/function not defined | Check spelling, ensure function is declared before use |
| `Type mismatch` | Wrong data type | Verify parameter types match function signature |
| `Syntax error` | Missing semicolon or bracket | Check line numbers in error message |

**Common fixes:**
- Ensure all `{` have matching `}`
- All statements end with `;`
- All functions have return type specified
- No reserved keywords used as variable names

### Step 6: Verify Compilation Success
- **Toolbox** shows: `0 error(s), 0 warning(s)`
- **Compiled file** created: `MonsterArrows_V3_EA.ex5` (binary executable)
- Location: `MQL5\Experts\` folder

---

## Part 3: File Placement

### Correct Directory Structure
```
C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\
├── MQL5\
│   ├── Experts\
│   │   ├── MonsterArrows_V3_EA.mq5          ← Source file
│   │   └── MonsterArrows_V3_EA.ex5          ← Compiled executable
│   ├── Include\
│   │   └── Trade\
│   │       └── Trade.mqh                    ← Required library
│   └── Logs\
│       └── MonsterArrows_V3_EA.log          ← Trade log (auto-created)
```

### Verify File Placement
1. Open **File Explorer**
2. Navigate to: `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\`
3. Find your Terminal ID folder (e.g., `D0E8209F7D4F12345678901234567890`)
4. Check `MQL5\Experts\` contains both `.mq5` and `.ex5` files

### Enable Hidden Files (if needed)
If you can't see `AppData` folder:
1. Open **File Explorer**
2. Click **View** → **Options** → **Change folder and search options**
3. Click **View** tab
4. Check **Show hidden files, folders, and drives**
5. Click **OK**

---

## Part 4: MetaTrader 5 Configuration

### Step 1: Verify EA is Recognized
1. In **MetaTrader 5**, click **Navigator** (Ctrl+N)
2. Expand **Expert Advisors** folder
3. Look for `MonsterArrows_V3_EA`
4. If not visible, right-click → **Refresh** or restart MT5

### Step 2: Check EA Permissions
1. In MT5, click **Tools** → **Options**
2. Go to **Expert Advisors** tab
3. Verify:
   - ✓ **Allow automated trading** is checked
   - ✓ **Allow DLL imports** is checked (if using external libraries)
   - ✓ **Allow WebRequest** is checked (if using API calls)
4. Click **OK**

### Step 3: Verify Demo Account Connection
1. In MT5, check bottom-right corner for account status
2. Should show: `[Account Name] - Demo` or `[Account Name] - Real`
3. For testing, ensure it says **Demo**
4. If not connected, click **File** → **Login** and select demo account

---

## Part 5: Pre-Deployment Testing

### Step 1: Strategy Tester Compilation Check
1. In MT5, click **View** → **Strategy Tester** (Ctrl+R)
2. In **Expert Advisor** dropdown, select `MonsterArrows_V3_EA`
3. If EA appears in dropdown, compilation was successful
4. If not visible, check file placement and restart MT5

### Step 2: Syntax Validation
1. Open MetaEditor again
2. Click **Compile** (F5)
3. Verify: `0 error(s), 0 warning(s)`
4. Check **Toolbox** for any warnings (yellow text)
5. Address warnings before deployment

### Step 3: Log File Setup
1. Create log directory: `C:\MT5_Logs\`
2. Verify EA has write permissions to this folder
3. Test by running EA briefly (log file should be created)

---

## Part 6: Deployment Checklist

Before attaching EA to live chart, verify:

- [ ] EA file compiled successfully (0 errors)
- [ ] `MonsterArrows_V3_EA.ex5` exists in `MQL5\Experts\`
- [ ] EA appears in Navigator → Expert Advisors
- [ ] Demo account is active and connected
- [ ] Automated trading is enabled in Options
- [ ] Log file directory exists and is writable
- [ ] All input parameters reviewed and set appropriately
- [ ] Risk parameters set conservatively for demo testing
- [ ] Backup of original EA file created

---

## Part 7: Troubleshooting

### EA Won't Compile
**Symptom**: Compilation fails with errors
**Solution**:
1. Check for typos in function names
2. Verify all includes are correct
3. Ensure all brackets/braces are matched
4. Check for missing semicolons
5. Restart MetaEditor and try again

### EA Doesn't Appear in Navigator
**Symptom**: EA not visible in Expert Advisors list
**Solution**:
1. Verify file is in correct folder: `MQL5\Experts\`
2. Restart MetaTrader 5 completely
3. Check file extension is `.mq5` (not `.txt`)
4. Recompile EA to generate `.ex5` file

### EA Attaches but Won't Trade
**Symptom**: EA runs but no trades open
**Solution**:
1. Check `EnableTrading` parameter is set to `true`
2. Verify demo account has sufficient balance
3. Check EA logs for error messages
4. Verify symbol is correct (e.g., `EURUSD`)
5. Check timeframe matches `TradeTimeframe` setting

### Compilation Warnings
**Symptom**: Compilation shows warnings (yellow text)
**Solution**:
1. Review warning messages in Toolbox
2. Common warnings: unused variables, implicit type conversion
3. Address warnings to ensure clean compilation
4. Warnings don't prevent execution but indicate code quality issues

---

## Part 8: Version Control

### Naming Convention
Use this format for versioning:
```
MonsterArrows_V3_EA_v[Major].[Minor]_[Date].mq5
Example: MonsterArrows_V3_EA_v3.0_20260529.mq5
```

### Backup Schedule
- **Before each compilation**: Save current version
- **Before parameter changes**: Backup with new version number
- **After successful demo testing**: Archive as "stable" version
- **Before live deployment**: Create final backup

### Rollback Procedure
If EA malfunctions:
1. Stop EA immediately (remove from chart)
2. Restore previous version from backup
3. Recompile and test
4. Investigate issue in previous version
5. Fix and recompile

---

## Summary

**Compilation & Deployment Checklist:**
1. ✓ Open MetaEditor
2. ✓ Open `MonsterArrows_V3_EA.mq5`
3. ✓ Compile (F5) → verify 0 errors
4. ✓ Verify `.ex5` file created in `MQL5\Experts\`
5. ✓ Restart MT5 if needed
6. ✓ Verify EA in Navigator
7. ✓ Enable automated trading in Options
8. ✓ Ready for demo account attachment

**Next Step**: Proceed to Demo Account Setup Checklist
