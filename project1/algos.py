import random

from bitstring import BitArray

from test_functions import one_max, jump, bin_val, royal_roads, leading_ones

N_STEP = 25
ITERATIONS = 10


def generate_x(n):
    return BitArray([bool(random.getrandbits(1)) for _ in range(n)])


def random_local_search(eval_fn, n):
    x = generate_x(n)
    score = eval_fn(x)
    print(score)
    iterations = 0
    while score != n:
        y = x[:]
        i = random.randint(0, n - 1)
        y[i] = not y[i]
        score_x = eval_fn(x)
        score_y = eval_fn(y)
        if score_y >= score_x:
            score = score_y
            x = y

        iterations += 1

    return iterations


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
    for algo in [random_local_search]:
        for eval_fn in [one_max, jump, bin_val, royal_roads, leading_ones]:
            its += test_algo(algo, eval_fn, 50)
    print(its)


if __name__ == '__main__':
    main()
