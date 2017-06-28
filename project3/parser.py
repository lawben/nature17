import sys
import re


def parse(data_file):
    raw_data = [line for line in open(data_file)]
    matrix_start = -1
    dimension = -1
    for i, line in enumerate(raw_data):
        if line.startswith("EDGE_WEIGHT_SECTION"):
            matrix_start = i + 1
            continue

        if line.startswith("DIMENSION"):
            dimension = int(re.search("(\d+)", line).group(0))
            continue

    if matrix_start == -1 or dimension == -1:
        raise ValueError("File does not contain matrix or dimension!")

    matrix = []
    for i in range(matrix_start, matrix_start + dimension):
        data_row = raw_data[i].split()
        matrix.append(data_row)

    return matrix


if __name__ == '__main__':
    print(parse(sys.argv[1]))
