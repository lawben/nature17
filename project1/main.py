from functools import partial

import pandas as pd

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
        yield (n, iterations)
        n += N_STEP

    return all_iterations


def main():
    rows = []
    algos = [('RLS', random_local_search),
             ('(1+1)-EA', one_one_ea),
             ('(1+2)-EA',  partial(one_lambda_ea, λ=2)),
             ('(1+10)-EA',  partial(one_lambda_ea, λ=10)),
             ('(1+20)-EA',  partial(one_lambda_ea, λ=20)),
             ('(1+50)-EA',  partial(one_lambda_ea, λ=50))]
    evals = [one_max,
             jump,
             bin_val,
             royal_roads,
             leading_ones]

    for algo_name, algo in algos:
        for eval_fn in evals:
            for n, iterations in test_algo(algo, eval_fn):
                rows.append([algo_name, eval_fn.__name__, n] + iterations)

    header = ['algorithm', 'test-function', 'n'] + ['iteration-' + str(1 + i) for i in range(ITERATIONS)]
    df = pd.DataFrame(rows, columns=header)
    df.to_csv('results.csv')

if __name__ == '__main__':
    main()
