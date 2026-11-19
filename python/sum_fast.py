# Same task as sum_loop.py, but the loop runs in C instead of the Python interpreter.
import sys, time
import numpy as np

n = int(sys.argv[1]) if len(sys.argv) > 1 else 50_000_000

s = time.perf_counter()
total = sum(range(n))
e = time.perf_counter()
print("builtin_sum", total, f"{e-s:.6f}")

a = np.arange(n, dtype=np.int64)   # array creation is NOT timed
s = time.perf_counter()
total = int(a.sum())
e = time.perf_counter()
print("numpy_sum", total, f"{e-s:.6f}")
