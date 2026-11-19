#!/usr/bin/env bash
# Compiles the C version at -O0 and -O2, runs every version RUNS times,
# and prints the median time for each.
set -e
N=${1:-50000000}
RUNS=${2:-5}
cd "$(dirname "$0")"
mkdir -p build
gcc -O0 c/sum.c -o build/sum_O0
gcc -O2 c/sum.c -o build/sum_O2
gcc -O2 -S c/sum.c -o build/sum_O2.s

median() { sort -n | awk '{a[NR]=$1} END {print (NR%2 ? a[(NR+1)/2] : (a[NR/2]+a[NR/2+1])/2)}'; }

echo "N = $N, runs = $RUNS"
for v in O0 O2; do
  t=$(for i in $(seq $RUNS); do ./build/sum_$v $N | awk '{print $2}'; done | median)
  echo "C -$v:            ${t}s"
done
t=$(for i in $(seq $RUNS); do python3 python/sum_loop.py $N | awk '{print $2}'; done | median)
echo "Python loop:      ${t}s"
out=$(for i in $(seq $RUNS); do python3 python/sum_fast.py $N; done)
echo "Python sum():     $(echo "$out" | awk '/builtin/{print $3}' | median)s"
echo "NumPy .sum():     $(echo "$out" | awk '/numpy/{print $3}' | median)s"
echo "Assembly for -O2 written to build/sum_O2.s"
