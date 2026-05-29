# Phase 2: Signal Detection - Implementation Summary

## Completion Status: ✅ COMPLETE

All signal detection functions have been successfully extracted from the indicator and integrated into MonsterArrows_V3_EA.mq5.

---

## Functions Implemented

### 1. **DetectSignal()** - Main Signal Detection Engine
- **Location:** Line 220
- **Returns:** `1` (BUY), `-1` (SELL), `0` (NONE)
- **Logic Flow:**
  1. Validates minimum bar count (ZZDepth + BarsToConfirm + 10)
  2. Copies price arrays (OHLC) in as-series format
  3. Retrieves ATR from indicator handle
  4. Checks HTF bias filters (if enabled)
  5. Analyzes previous bar (bar index 1) for signals
  6. Finds pivot levels for liquidity sweeps
  7. Detects liquidity sweeps and FVG patterns
  8. Validates local pivot confirmation (3-bar check)
  9. Combines all conditions with HTF filter
  10. Returns signal direction

**Key Features:**
- Uses previous bar (bar 1) to avoid current bar noise
- Modular design with separate helper functions
- HTF filter with strict/loose mode support
- No lookahead bias (looks left only)

---

### 2. **FindPivots()** - Pivot Detection for Liquidity Sweeps
- **Location:** Line 323
- **Parameters:**
  - `low[], high[]` - Price arrays (as-series)
  - `barIdx` - Current bar index
  - `outPivotLow, outPivotHigh` - Output pivot levels
- **Algorithm:**
  1. Scans backwards from current bar (no lookahead)
  2. Identifies pivot low: bar whose low is lower than ZZDepth bars to its left
  3. Identifies pivot high: bar whose high is higher than ZZDepth bars to its left
  4. Stops scanning once both pivots found
  5. Falls back to simple window min/max if no pivot found

**Characteristics:**
- Zero lookahead bias (only looks left)
- Configurable depth (ZZDepth parameter)
- Fallback mechanism for edge cases
- Efficient early exit when both pivots found

---

### 3. **CheckLiquiditySweep()** - Stop Hunt Detection
- **Location:** Line 399
- **Parameters:**
  - `low[], high[], close[]` - Price arrays
  - `barIdx` - Current bar index
  - `pivotLow, pivotHigh` - Pivot levels from FindPivots()
  - `outBuy, outSell` - Output sweep signals
- **Logic:**
  - **Buy Sweep:** `low[barIdx] < pivotLow AND close[barIdx] > pivotLow`
    - Price wicks below pivot, then reclaims above
    - Indicates stops hunted below support
  - **Sell Sweep:** `high[barIdx] > pivotHigh AND close[barIdx] < pivotHigh`
    - Price wicks above pivot, then reclaims below
    - Indicates stops hunted above resistance

**Smart Money Concept:**
- Detects institutional stop-loss hunting patterns
- Confirms liquidity sweep with close reclamation
- Used as primary trigger for entry signals

---

### 4. **CheckFairValueGap()** - FVG Detection with ATR Confirmation
- **Location:** Line 423
- **Parameters:**
  - `low[], high[], open[], close[]` - Price arrays
  - `barIdx` - Current bar index
  - `curATR` - Current ATR value
  - `outBuy, outSell` - Output FVG signals
- **Buy FVG Conditions:**
  1. Current low > 2 bars ago high (gap exists)
  2. Gap size > 0.5 × ATR (filters tiny gaps)
  3. Previous candle bullish (close[barIdx-1] > open[barIdx-1])
- **Sell FVG Conditions:**
  1. Current high < 2 bars ago low (gap exists)
  2. Gap size > 0.5 × ATR (filters tiny gaps)
  3. Previous candle bearish (close[barIdx-1] < open[barIdx-1])

**Features:**
- 3-candle confirmation (current + 2 prior bars)
- ATR-based gap size filtering (avoids noise)
- Directional candle confirmation
- Detects displacement/imbalance patterns

---

### 5. **CheckHTFBias()** - Dual-Filter Higher Timeframe Confirmation
- **Location:** Line 453
- **Parameters:**
  - `outHTFBull, outHTFBear` - Output HTF bias signals
- **Dual Filter Architecture:**

#### Filter 1: HTF 20 EMA
- Checks if HTF close > EMA AND EMA rising (BULL)
- Checks if HTF close < EMA AND EMA falling (BEAR)
- Validates EMA slope strength (minimum 0.3 × ATR movement)
- Requires 2-bar slope confirmation

#### Filter 2: SuperTrend Dual RMA on HTF
- Computes RMA1 (14-period) and RMA2 (21-period) on HLC3
- Calculates basis = (RMA1 + RMA2) / 2
- Derives bands: upper = basis + 1.0 × ATR, lower = basis - 1.0 × ATR
- Tracks trend direction flips:
  - BULL flip: -1.0 → 1.0 (close crosses above upper band)
  - BEAR flip: 1.0 → -1.0 (close crosses below lower band)
- Validates RMA alignment:
  - BULL: last flip was BUY AND RMA1 > RMA2
  - BEAR: last flip was SELL AND RMA1 < RMA2

**Combination Logic:**
- `HTF_BULLISH = Filter1_Bull AND Filter2_Bull`
- `HTF_BEARISH = Filter1_Bear AND Filter2_Bear`
- Both filters must agree (AND logic, not OR)
- Prevents false signals from single-filter divergence

**State Management:**
- `g_ST_trendDir` persists last arrow flip direction across ticks
- Prevents flip detection on every bar
- Ensures stable HTF bias confirmation

---

### 6. **CalculateRMA()** - Recursive Moving Average Helper
- **Location:** Line 597
- **Parameters:**
  - `prevRMA` - Previous RMA value
  - `currentValue` - Current bar value
  - `period` - RMA period
- **Formula:** `RMA = (prevRMA × (period - 1) + currentValue) / period`
- **Initialization:** Returns `currentValue` if `prevRMA == 0`

**Purpose:**
- Used internally by CheckHTFBias() for SuperTrend RMA computation
- Provides exponential smoothing for trend detection
- Modular design allows reuse in future enhancements

---

## Integration with OnTick()

The DetectSignal() function is called from OnTick():

```mql5
void OnTick()
{
   int rates_total = Bars(_Symbol, TradeTimeframe);
   if(rates_total < ZZDepth + BarsToConfirm + 10)
      return;

   int signal = DetectSignal(rates_total);
   // signal: 1=BUY, -1=SELL, 0=NONE
   // Phase 2 focus: signal detection only
   // Order management will be Phase 3+
}
```

---

## Key Design Decisions

### 1. **As-Series Array Handling**
- All price arrays use `ArraySetAsSeries(true)` for consistency
- Index 0 = current/newest bar, Index 1 = previous bar
- Matches MQL5 standard convention for indicator data

### 2. **No Lookahead Bias**
- FindPivots() only scans backwards (left)
- Uses previous bar (index 1) for signal detection
- Prevents future bar information leakage

### 3. **Modular Function Design**
- Each function has single responsibility
- Clear input/output parameters
- Reusable across different contexts
- Well-commented for maintenance

### 4. **HTF Dual-Filter Approach**
- EMA filter: trend direction + slope strength
- SuperTrend filter: momentum + RMA alignment
- Both must agree (strict confirmation)
- Reduces false signals from single-indicator reliance

### 5. **ATR-Based Confirmation**
- FVG gap size filtered by 0.5 × ATR
- HTF EMA slope validated against 0.3 × ATR
- Adapts to market volatility automatically
- Prevents noise-based false signals

### 6. **State Persistence**
- `g_ST_trendDir` maintains SuperTrend flip state
- Prevents repeated flip detection
- Ensures stable HTF bias across ticks

---

## Configuration Parameters Used

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `EnableHTFFilter` | true | Enable/disable HTF bias confirmation |
| `RequireBothHTF` | true | Strict mode: both HTF filters must agree |
| `BarsToConfirm` | 2 | Bars to wait for signal confirmation |
| `HTF_EMAPeriod` | 20 | EMA period on HTF |
| `ST_RMA1Length` | 14 | SuperTrend RMA1 period |
| `ST_RMA2Length` | 21 | SuperTrend RMA2 period |
| `ST_ATRPeriod` | 14 | SuperTrend ATR period |
| `ST_ATRMult` | 1.0 | SuperTrend ATR multiplier |
| `UseLiquiditySweep` | true | Enable liquidity sweep detection |
| `UseFairValueGap` | true | Enable FVG detection |
| `ZZDepth` | 30 | ZigZag pivot depth |
| `HistBars` | 1000 | Historical bars to analyze |
| `ATRPeriod` | 14 | ATR period for gap filtering |

---

## Testing Checklist

- [x] All 6 functions implemented
- [x] No compilation errors
- [x] Proper array handling (as-series)
- [x] No lookahead bias
- [x] HTF bias dual-filter logic correct
- [x] FVG ATR confirmation implemented
- [x] Liquidity sweep detection working
- [x] Pivot finding algorithm correct
- [x] State persistence for SuperTrend
- [x] Modular, well-commented code
- [x] Ready for Phase 3 (order management)

---

## Files Modified

- **MonsterArrows_V3_EA.mq5** (623 lines)
  - Phase 1 skeleton preserved
  - Phase 2 signal detection functions added (lines 210-602)
  - OnTick() updated to call DetectSignal()
  - All helper functions integrated

---

## Next Phase (Phase 3)

Order management will use DetectSignal() return value:
- `signal == 1`: Execute BUY order
- `signal == -1`: Execute SELL order
- `signal == 0`: No action

Additional Phase 3 components:
- Position sizing (risk %)
- Stop loss / Take profit calculation
- Trade entry/exit logic
- Position tracking
- Daily trade limits

---

## Code Quality

- **Modularity:** Each function has single responsibility
- **Readability:** Clear variable names, comprehensive comments
- **Efficiency:** Early exits, minimal redundant calculations
- **Robustness:** Error checking, fallback mechanisms
- **Maintainability:** Well-structured, easy to debug/modify

