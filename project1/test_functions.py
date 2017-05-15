from bitstring import BitArray


def n_(x):
    return len(a.bin)


def oneMax(x):
    return sum([i for i in x])


def leadingOnes(x):
    leading = 0
    for i in x:
        if i:
            leading += 1
        else:
            return leading
    return leading


def jump(x):
    k = 3
    n = n_(x)
    oneMax_x = oneMax(x)

    if oneMax_x == n:
        return n
    elif n - k <= oneMax_x and oneMax_x < n:
        return n - k
    else:
        return oneMax


def royalRoads(x):
    k = 5
    n = n_(x)
    road = 0
    for i in range(0, n, k):
        road += 1 if x[i:i+k].bin == '11111' else 0
    return road


if __name__ == '__main__':
    a = BitArray('0b1100011111')
    print a.bin
    print oneMax(a)
    print leadingOnes(a)
    print jump(a)
    print royalRoads(a)
