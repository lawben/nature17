import argparse
from functools import partial

import pandas as pd

from test_functions import one_max, jump, bin_val, royal_roads, leading_ones
from algos import random_local_search, one_lambda_ea


N_STEP = 25
ITERATIONS = 10


def test_algo(algo, eval_fn, steps, strict):
    n = N_STEP
    n_max = N_STEP * steps
    for n in range(N_STEP, n_max + 1, N_STEP):
        iterations = [algo(eval_fn, n, strict) for _ in range(ITERATIONS)]
        yield (n, iterations)
        n += N_STEP


def main(steps, filename):
    algos = [('RLS', random_local_search),
             ('(1+1)-EA', partial(one_lambda_ea, λ=1)),
             ('(1+2)-EA', partial(one_lambda_ea, λ=2)),
             ('(1+10)-EA', partial(one_lambda_ea, λ=10)),
             ('(1+20)-EA', partial(one_lambda_ea, λ=20)),
             ('(1+50)-EA', partial(one_lambda_ea, λ=50))]
    evals = [one_max,
             jump,
             bin_val,
             royal_roads,
             leading_ones]
    is_strict = [False, True]

    for strict in is_strict:
        rows = []
        if strict:
            filename = "strict-" + filename
            algos = algos[1:]

        for algo_name, algo in algos:
            for eval_fn in evals:
                for n, iterations in test_algo(algo, eval_fn, steps, strict):
                    rows.append([algo_name, eval_fn.__name__, n] + iterations)

        header = ['algorithm', 'test-function', 'n'] + ['iteration-' + str(1 + i) for i in range(ITERATIONS)]
        df = pd.DataFrame.from_records(rows, columns=header)

        df.to_csv(filename, index=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--steps', default=2, type=int)
    parser.add_argument('--outfile', default='results.csv')
    args = parser.parse_args()
    main(args.steps, args.outfile)
