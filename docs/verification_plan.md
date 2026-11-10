# Synchronous FIFO Verification Plan

## 1. Verification Strategy Overview

The verification environment for the Synchronous FIFO is designed to be **autonomous**, **self-checking**, and **regression-ready**. It uses an integrated golden queue reference model to compare expected vs actual transactions cycle-by-cycle, validating data integrity, flag protocols, and corner-case boundaries.

---

## 2. Test Matrix and Scenario Coverage

| Test Phase | Test Objective | Stimulus Applied | Expected Behavior | Status |
| :---: | :--- | :--- | :--- | :---: |
| **TEST 1** | **Synchronous Reset** | Assert `rst=1` for 3 cycles, deassert on `negedge clk` | `empty=1`, `full=0`, `dout=8'h00`, pointers=0 | **PASS** |
| **TEST 2** | **Single Write & Single Read** | Write `8'hA5`, then read `8'hA5` | `empty` drops to 0, data matches `8'hA5`, `empty` asserts | **PASS** |
| **TEST 3** | **Multiple Write (Burst 8)** | Write 8 consecutive words (`8'h10` to `8'h17`) | `fifo_cnt=8`, `empty=0`, `full=0` | **PASS** |
| **TEST 4** | **Multiple Read (Burst 8)** | Read 8 consecutive words | Data returned in strict FIFO order, `empty=1` | **PASS** |
| **TEST 5** | **FIFO Full Condition** | Write 16 consecutive words (`8'h50` to `8'h5F`) | `full=1`, `empty=0`, `fifo_cnt=16` | **PASS** |
| **TEST 6** | **Overflow Prevention** | Attempt 3 additional writes (`8'hFE, 8'hFD, 8'hFC`) while `full=1` | `full=1` held, `wr_ptr` does not advance, memory intact | **PASS** |
| **TEST 7** | **FIFO Empty Condition** | Read 16 consecutive words from full buffer | All 16 words match, `empty=1`, `full=0`, `fifo_cnt=0` | **PASS** |
| **TEST 8** | **Underflow Prevention** | Attempt 3 reads while `empty=1` | `empty=1` held, `rd_ptr` does not advance, `dout` unchanged | **PASS** |
| **TEST 9** | **Simultaneous Read & Write** | Preload 4 words; execute 8 concurrent write/read cycles | Both write and read succeed; `fifo_cnt` remains steady | **PASS** |
| **TEST 10** | **Pointer Wraparound** | Execute 40+ alternating writes & reads across address 15 to 0 | Pointers roll over $15 \rightarrow 0$ seamlessly; MSB toggles | **PASS** |

---

## 3. Scoreboard and Golden Queue Architecture

```
                      TESTBENCH VERIFICATION FLOW
    +--------------------------------------------------------------+
    |                     Stimulus Generator                       |
    |          (Tasks: apply_reset, write_byte, read_byte)         |
    +--------------+--------------------------------+-------------+
                   |                                |
            (Write Data)                     (Write Data)
                   v                                v
         +-------------------+            +-------------------+
         |  Golden Queue     |            |  DUT (fifo_top)   |
         |  Software Model   |            |  Hardware RTL     |
         +---------+---------+            +---------+---------+
                   |                                |
             (Expected Data)                  (Actual Data)
                   |                                |
                   +----------------+---------------+
                                    |
                                    v
                     +-----------------------------+
                     |    Autonomous Scoreboard    |
                     |  - Data Mismatch Checker    |
                     |  - Flag Assertions          |
                     |  - Error Counter Tracking   |
                     +-----------------------------+
```

### Self-Checking Scoreboard Rules
1. **Data Match Assertion**: On every valid read cycle, `dout` is compared with `golden_queue[head]`. Any difference triggers an immediate `[FAIL]` message with timestamp and values.
2. **Flag Assertion**: Full and empty flags are checked against expected states before and after transactions.
3. **Pointer Guard Assertion**: Verified that write pointer never advances when `full=1` and read pointer never advances when `empty=1`.

---

## 4. Corner-Case and Edge-Condition Analysis

### 4.1 Boundary Transition: Full to Not-Full
When `full=1` and a read request arrives, the next rising clock edge reads the word and increments `rd_ptr`.
- At the next cycle, `wr_ptr[3:0] != rd_ptr[3:0]`.
- The `full` flag deasserts immediately, allowing subsequent write transactions without latency.

### 4.2 Boundary Transition: Empty to Not-Empty
When `empty=1` and a write request arrives, the next rising clock edge writes the word and increments `wr_ptr`.
- At the next cycle, `wr_ptr != rd_ptr`.
- The `empty` flag deasserts immediately.

### 4.3 Simultaneous Read and Write at Boundary States
- **At Full State (`full=1`)**: If both `wr_en=1` and `rd_en=1` are asserted:
  - `wr_valid = wr_en & ~full = 0` (write blocked by control logic).
  - `rd_valid = rd_en & ~empty = 1` (read succeeds).
  - FIFO exits the full state safely without losing new data or corrupting pointers.
- **At Empty State (`empty=1`)**: If both `wr_en=1` and `rd_en=1` are asserted:
  - `wr_valid = wr_en & ~full = 1` (write succeeds).
  - `rd_valid = rd_en & ~empty = 0` (read blocked by control logic).
  - FIFO exits the empty state safely.

---

## 5. Waveform Inspection Guidelines

Waveform files are saved in:
- `simulation/fifo_waveform.vcd` (Standard VCD format, viewable in GTKWave or Vivado)
- `simulation/sim_work/` (Vivado `.wdb` waveform database)

### Key Signal Groups to Add to Waveform Viewer:
1. **Clock & Reset**: `clk`, `rst`
2. **Write Port**: `wr_en`, `wr_valid`, `din[7:0]`, `wr_ptr[4:0]`, `wr_addr[3:0]`
3. **Read Port**: `rd_en`, `rd_valid`, `dout[7:0]`, `rd_ptr[4:0]`, `rd_addr[3:0]`
4. **Status Flags**: `full`, `empty`, `fifo_cnt[4:0]`
