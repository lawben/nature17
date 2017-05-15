import random

from test_functions import OPTIMA


def generate_x(n):
    return [random.getrandbits(1) for _ in range(n)]


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


def generate_offspring(x, n):
    y = x.copy()
    flip_probability = 1 / n
    for i in range(n):
        if random.random() < flip_probability:
            y[i] = 1 - y[i]
    return y


def one_lambda_ea(eval_fn, n, λ):
    x = generate_x(n)
    score = eval_fn(x)
    iterations = 0
    optimum = stopping_criterion(eval_fn, n)
    while score != optimum:
        iterations += 1
        P = [generate_offspring(x, n) for _ in range(λ)]
        P_scores = [(y, eval_fn(y)) for y in P]
        y, score_y = max(P_scores, key=lambda t: t[1])
        if score_y >= score:
            score = score_y
            x = y
    return iterations


def one_one_ea(eval_fn, n):
    x = generate_x(n)
    score = eval_fn(x)
    iterations = 0
    optimum = stopping_criterion(eval_fn, n)
    while score != optimum:
        iterations += 1
        y = generate_offspring(x, n)

        score_y = eval_fn(y)
        if score_y >= score:
            score = score_y
            x = y

    return iterations
