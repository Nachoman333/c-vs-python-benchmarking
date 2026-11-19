# Results

Task: add every integer from 0 to N-1, with N = 50,000,000.
Each version was run 5 times. Only the summing part is timed (no program startup, no compile time, no array creation).

Machine: Linux x86-64, gcc 13.3.0, Python 3.13

## Raw times (seconds)

| Version | Run 1 | Run 2 | Run 3 | Run 4 | Run 5 | Median |
|---|---|---|---|---|---|---|
| C, gcc -O0 | 0.133 | 0.132 | 0.137 | 0.134 | 0.134 | **0.134** |
| C, gcc -O2 | 0.018 | 0.018 | 0.018 | 0.018 | 0.018 | **0.018** |
| Python loop | 3.13 | 3.01 | 3.44 | 3.26 | 3.17 | **3.17** |

| Version | Times | 
|---|---|
| Python `sum(range(n))` | 0.70 to 0.79 |
| NumPy `np.arange(n).sum()` | 0.038 |

## Speedups vs. the Python loop

| Version | Times faster |
|---|---|
| Python `sum()` | ~4x |
| C -O0 | ~24x |
| NumPy | ~83x |
| C -O2 | ~175x |

All versions printed the same total, 1249999975000000 = N(N-1)/2, which confirms they did the same work with the same bounds.

## The -O2 loop in assembly

```asm
.L3:
	xorl	%eax, %eax          # i = 0
	xorl	%ebx, %ebx          # total = 0
	testb	$1, %bpl            # is N odd?
	je	.L5
	movl	$1, %eax            # if odd, handle i = 0 first, start at i = 1
	cmpq	%rbp, %rax
	je	.L4
.L5:
	leaq	1(%rbx,%rax,2), %rbx  # total += i + (i+1)  ->  total + 2i + 1
	addq	$2, %rax              # i += 2
	cmpq	%rbp, %rax
	jne	.L5
```

GCC kept the loop but unrolled it 2x: each pass adds two numbers with a single `leaq` instruction and moves the counter by 2. The `testb $1` check handles odd N so the pairs line up.
