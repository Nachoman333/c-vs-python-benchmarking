import sys, time
n = int(sys.argv[1]) if len(sys.argv) > 1 else 50_000_000
s = time.perf_counter()
total = 0
for i in range(n):
    total += i
e = time.perf_counter()
print(total, f"{e-s:.6f}")
