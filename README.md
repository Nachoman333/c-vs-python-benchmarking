# C vs. Python Performance Benchmarking

COMP 211 Checkoff 3: an exploration of how to fairly measure and compare program speed in C and Python.

## The question

Everyone "knows" C is faster than Python. But how much faster, why, and how do you measure it without fooling yourself?

## What was explored

- **Why C is faster:** C compiles to machine code ahead of time. CPython compiles to bytecode and runs it through an interpreter, which has to handle Python objects, dynamic types, and reference counts on every step.
- **How to time programs:** `clock_gettime()` in C and `time.perf_counter()` in Python, timing only the work itself, not startup or setup.
- **Why one run is not enough:** background processes, CPU frequency, and caching make times vary, so each version runs several times and the median is reported.
- **What makes a comparison fair:** same algorithm, same input size, same bounds, same timing boundaries, and stating the compiler flags.

## The benchmark

Sum every integer from 0 to N-1 with a plain loop, N = 50,000,000, in:

1. C compiled with `-O0` (no optimization)
2. C compiled with `-O2`
3. A plain Python `for` loop
4. Python's built-in `sum(range(n))`
5. NumPy's `np.arange(n).sum()`

## Results (median of 5 runs)

| Version | Time | vs. Python loop |
|---|---|---|
| Python loop | 3.17 s | 1x |
| Python `sum()` | ~0.75 s | ~4x faster |
| C -O0 | 0.134 s | ~24x faster |
| NumPy | 0.038 s | ~83x faster |
| C -O2 | 0.018 s | ~175x faster |

Full data and analysis: [`results/results.md`](results/results.md)

## Most interesting discoveries

1. **The compiler flag mattered almost as much as the language.** `-O2` made the same C code ~7x faster than `-O0`. Comparing Python to unoptimized C understates the gap by a lot.
2. **-O2 did not delete the loop, it unrolled it.** The suspicion was that GCC replaced the loop with the formula N(N-1)/2. The assembly showed the loop was still there, but GCC was adding two numbers per iteration with one instruction. See the annotated assembly in `results/results.md`.
3. **"Python" can be nearly as fast as C.** `sum()` and NumPy are Python calls, but the actual loop runs in compiled C. NumPy came within ~2x of optimized C. The language you write in is not always the language doing the work.
4. **Checking the AI's claims paid off.** At one point the AI said the C loop included N while the Python versions did not. Every version printed 1249999975000000 = N(N-1)/2, which proved all of them excluded N.

## Running it yourself

Requirements: `gcc`, `python3`, and NumPy (`pip install numpy`).

```bash
git clone https://github.com/Nachoman333/c-vs-python-benchmarking.git
cd c-vs-python-benchmarking
bash run_benchmarks.sh            # N = 50,000,000, 5 runs each
bash run_benchmarks.sh 10000000 7 # custom N and number of runs
```

The script compiles the C code at `-O0` and `-O2`, runs every version, prints the median times, and writes the `-O2` assembly to `build/sum_O2.s`.

Run individual programs:

```bash
gcc -O2 c/sum.c -o sum && ./sum 50000000    # prints total and seconds
python3 python/sum_loop.py 50000000
python3 python/sum_fast.py 50000000
```

Times will differ by machine, but the ratios should look similar.

## Repository layout

```
c/sum.c                 C summing loop, timed with clock_gettime
python/sum_loop.py      plain Python loop, timed with perf_counter
python/sum_fast.py      built-in sum() and NumPy versions
run_benchmarks.sh       compiles, runs everything, reports medians
results/results.md      raw data, speedups, annotated assembly
slides/                 presentation slides
```

## Resources

- [Python `dis` module docs](https://docs.python.org/3.13/library/dis.html): inspect the bytecode CPython runs
- [Python `timeit` docs](https://docs.python.org/3.13/library/timeit.html): Python's built-in benchmarking tool
- [CPython interpreter internals](https://github.com/python/cpython/blob/main/InternalDocs/interpreter.md): how the bytecode loop works
- [GCC optimization options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html): what -O0, -O2, and -funroll-loops do
- [What is NumPy?](https://numpy.org/doc/stable/user/whatisnumpy.html): why NumPy arrays are fast
- AI exploration conversations: [Part 1](https://chatgpt.com/share/6aff5046-5138-83ea-bf41-d2b7db38d44a), [Part 2](https://chatgpt.com/share/6aff53c0-bfa8-83e9-85d9-6e84b160f2b8)
