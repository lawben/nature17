K_JUMP = 3
K_ROYAL = 5


def one_max(x):
    return sum(x)


def leading_ones(x):
    leading = 0
    for i in x:
        if i:
            leading += 1
        else:
            return leading
    return leading


def jump(x):
    n = len(x)
    one_max_x = one_max(x)

    if one_max_x == n:
        return n
    elif n - K_JUMP <= one_max_x and one_max_x < n:
        return n - K_JUMP
    else:
        return one_max_x


def royal_roads(x):
    n = len(x)
    road = 0
    for i in range(0, n, K_ROYAL):
        road += 1 if all(x[i:i + K_ROYAL]) else 0
    return road


def bin_val(x):
    bit_string = "".join(["1" if a else "0" for a in x])
    return int(bit_string, 2)


OPTIMA = {
    one_max: lambda n: n,
    leading_ones: lambda n: n,
    jump: lambda n: n,
    royal_roads: lambda n: n // 5,
    bin_val: lambda n: 2**n - 1
}

if __name__ == '__main__':
    a = [1, 1, 0, 0, 0, 1, 1, 1, 1, 1]
    print(a.bin)
    print(bin_val(a))
    print(one_max(a))
    print(leading_ones(a))
    print(jump(a))
    print(royal_roads(a))
