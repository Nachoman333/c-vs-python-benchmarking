#include <stdio.h>
#include <stdlib.h>
#include <time.h>
int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 50000000;
    struct timespec s, e;
    clock_gettime(CLOCK_MONOTONIC, &s);
    long long total = 0;
    for (long i = 0; i < n; i++) total += i;
    clock_gettime(CLOCK_MONOTONIC, &e);
    double t = (e.tv_sec - s.tv_sec) + (e.tv_nsec - s.tv_nsec) / 1e9;
    printf("%lld %.6f\n", total, t);
    return 0;
}
