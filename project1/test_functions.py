from bitstring import BitArray

K_JUMP = 3
K_ROYAL = 5


def n_(x):
    return len(a.bin)


def oneMax(x):
    return sum([_ for _ in x])


def leadingOnes(x):
    leading = 0
    for i in x:
        if i:
            leading += 1
        else:
            return leading
    return leading


def jump(x):
    n = n_(x)
    oneMax_x = oneMax(x)

    if oneMax_x == n:
        return n
    elif n - K_JUMP <= oneMax_x and oneMax_x < n:
        return n - K_JUMP
    else:
        return oneMax


def royalRoads(x):
    n = n_(x)
    road = 0
    for i in range(0, n, K_ROYAL):
        road += 1 if x[i:i+K_ROYAL].bin == '11111' else 0
    return road


if __name__ == '__main__':
    a = BitArray('0b1100011111')
    print a.bin
    print oneMax(a)
    print leadingOnes(a)
    print jump(a)
    print royalRoads(a)
