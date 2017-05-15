import random

from bitstring import BitArray

from test_functions import OPTIMA


N_STEP = 25
ITERATIONS = 10

LAMBDA = 10


def generate_x(n):
    return BitArray([bool(random.getrandbits(1)) for _ in range(n)])


def decision(probability):
    return random.random() < probability


def stopping_criterion(eval_fn, n):
    return OPTIMA[eval_fn](n)


def random_local_search(eval_fn, n):
    x = generate_x(n)
    score = eval_fn(x)
    iterations = 0
    optimum = stopping_criterion(eval_fn, n)
    while score != optimum:
        iterations += 1
        y = x.copy()
        i = random.randint(0, n - 1)
        y[i] = not y[i]
        score_y = eval_fn(y)
        if score_y >= score:
            score = score_y
            x = y
    return iterations


def one_lambda_ea(eval_fn, n):
    def generate_offspring(x):
        y = x.copy()
        for i in range(n):
            if decision(1/n):
                y[i] = not y[i]
        return y

    x = generate_x(n)
    score = eval_fn(x)
    iterations = 0
    optimum = stopping_criterion(eval_fn, n)
    while score != optimum:
        iterations += 1
        P = [generate_offspring(x) for _ in range(LAMBDA)]
        P_scores = [(y, eval_fn(y)) for y in P]
        y, score_y = max(P_scores, key=lambda t: t[1])
        if score_y >= score:
            score = score_y
            x = y
    return iterations
