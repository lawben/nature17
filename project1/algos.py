import random

from bitstring import BitArray


N_STEP = 25
ITERATIONS = 10


def generate_x(n):
    return BitArray([bool(random.getrandbits(1)) for _ in range(n)])


def random_local_search(eval_fn, n):
    x = generate_x(n)
    score = eval_fn(x)
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
