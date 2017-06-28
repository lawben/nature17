import sys
import re


def get_int_from_line(line):
    return int(re.search("(\d+)", line).group(0))


def get_dimension(raw_lines):
    for line in raw_lines:
        if line.startswith("DIMENSION"):
            return get_int_from_line(line)


def parse(data_file):
    raw_data = [line for line in open(data_file)]
    matrix_start = -1
    dimension = get_dimension(raw_data)

    for i, line in enumerate(raw_data):
        if line.startswith("EDGE_WEIGHT_SECTION"):
            matrix_start = i + 1
            break

    if matrix_start == -1 or dimension == -1:
        raise ValueError("File does not contain matrix or dimension!")

    matrix = []
    for i in range(matrix_start, matrix_start + dimension):
        data_row = raw_data[i].split()
        matrix.append(data_row)

    return matrix


def parse_tour(data_file):
    raw_data = [line for line in open(data_file)]
    tour_start = -1
    dimension = get_dimension(raw_data)

    for i, line in enumerate(raw_data):
        if line.startswith("TOUR_SECTION"):
            tour_start = i + 1

    if tour_start == -1:
        raise ValueError("File does not contain tour!")

    tour = []
    for i in range(tour_start, tour_start + dimension):
        tour.append(get_int_from_line(raw_data[i]))

    return tour


if __name__ == '__main__':
    print("Matrix:")
    print(parse(sys.argv[1]))
    print("\n")
    print("Tour:")
    print(parse_tour(sys.argv[2]))
