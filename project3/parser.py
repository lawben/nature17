import math
import sys
import re

import numpy as np


def get_int_from_line(line):
    return int(re.search("(\d+)", line).group(0))


def get_dimension(raw_lines):
    for line in raw_lines:
        if line.startswith("DIMENSION"):
            return get_int_from_line(line)


def parse_node_points(raw_data, points_start, dimension):
    points = []
    for i in range(points_start, points_start + dimension):
        _, x, y = [float(x) for x in raw_data[i].split()]
        points.append((x, y))

    return points


def parse_points(data_file):
    raw_data = [line for line in open(data_file)]
    dimension = get_dimension(raw_data)

    for i, line in enumerate(raw_data):
        if line.startswith("DISPLAY_DATA_SECTION"):
            return parse_node_points(raw_data, i + 1, dimension)

        if line.startswith("NODE_COORD_SECTION"):
            return parse_node_points(raw_data, i + 1, dimension)

    raise ValueError("Cannot parse points from file!")


def parse_matrix(raw_data, matrix_start, dimension):
    matrix = []
    for i in range(matrix_start, matrix_start + dimension):
        data_row = [int(x) for x in raw_data[i].split()]
        matrix.append(data_row)

    return matrix


def parse_node_coords(raw_data, matrix_start, dimension):
    info = parse_node_points(raw_data, matrix_start, dimension)

    n = len(info)
    matrix = np.empty((n, n))

    for i in range(n):
        x1, y1 = info[i]
        for j in range(i, n):
            x2, y2 = info[j]
            dist = math.sqrt((x1 - x2)**2 + (y1 - y2)**2)
            matrix[i, j] = matrix[j, i] = dist

    return matrix


def parse(data_file):
    raw_data = [line for line in open(data_file)]
    matrix_start = -1
    dimension = get_dimension(raw_data)

    if dimension == -1:
        raise ValueError("File does not contain dimension!")

    for i, line in enumerate(raw_data):
        if line.startswith("EDGE_WEIGHT_SECTION"):
            return parse_matrix(raw_data, i + 1, dimension)

        if line.startswith("NODE_COORD_SECTION"):
            return parse_node_coords(raw_data, i + 1, dimension)

    raise ValueError("File does not contain relevant information")


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
        tour.append(get_int_from_line(raw_data[i]) - 1)

    return tour


def get_opt(tour, matrix):
    tour_offset = tour[1:]
    tour_offset.append(tour[0])
    edges = zip(tour, tour_offset)
    return sum(matrix[i][j] for (i, j) in edges)


if __name__ == '__main__':
    mat = parse(sys.argv[1])
    tour = parse_tour(sys.argv[2])
    opt = get_opt(tour, mat)

    print("Matrix:")
    print(mat)
    print("\n")
    print("Tour:")
    print(tour)
    print("\n")
    print("Optimum:")
    print(opt)
