from test_functions import one_max, jump, bin_val, royal_roads, leading_ones
from algos import random_local_search, one_one_ea, one_lambda_ea


N_STEP = 25
N_MAX = 50
ITERATIONS = 10


def test_algo(algo, eval_fn):
    n = N_STEP
    all_iterations = []
    for n in range(N_STEP, N_MAX + 1, N_STEP):
        iterations = [algo(eval_fn, n) for _ in range(ITERATIONS)]
        all_iterations.append(iterations)
        avg_iterations = sum(iterations) // len(iterations)
        print("Finnished: {} - {} - {} - {}".format(
            algo.__name__, eval_fn.__name__, n, avg_iterations))
        n += N_STEP

    return all_iterations


def main():
    its = []
    algos = [random_local_search, one_lambda_ea, one_one_ea]
    evals = [one_max, jump, bin_val, royal_roads, leading_ones]

    for algo in algos:
        for eval_fn in evals:
            its += test_algo(algo, eval_fn)


if __name__ == '__main__':
    main()
