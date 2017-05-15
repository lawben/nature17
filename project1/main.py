from bitstring import BitArray

from test_functions import one_max, jump, bin_val, royal_roads, leading_ones
from algos import random_local_search, one_lambda_ea

N_STEP = 25
ITERATIONS = 10


def test_algo(algo, eval_fn, max_n):
    n = N_STEP
    all_iterations = []
    while n <= max_n:
        iterations = [algo(eval_fn, n) for _ in range(ITERATIONS)]
        all_iterations.append(iterations)
        n += N_STEP

    return all_iterations


def main():
    its = []
    for algo in [random_local_search, one_lambda_ea]:
        for eval_fn in [one_max, bin_val, royal_roads, leading_ones]:
            its += test_algo(algo, eval_fn, 50)
            print(eval_fn)
    print(its)


if __name__ == '__main__':
    main()
