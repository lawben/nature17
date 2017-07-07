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


def parse_full_matrix(raw_data, matrix_start, dimension):
    matrix = np.empty((dimension, dimension))
    for row_num in range(matrix_start, matrix_start + dimension):
        i = row_num - matrix_start
        data_row = [float(x) for x in raw_data[row_num].split()]
        for j in range(len(data_row)):
            matrix[i, j] = matrix[j, i] = data_row[j]

    return matrix


def parse_lower_diag_row(raw_data, matrix_start):
    raw_matrix = []

    row = []
    for i in range(matrix_start, len(raw_data)):
        line = raw_data[i]
        if "EOF" in line:
            break

        file_row = [float(x) for x in line.split()]
        for val in file_row:
            row.append(val)
            if val == 0:
                raw_matrix.append(row)
                row = []

    n = len(raw_matrix)

    matrix = np.empty((n, n))
    for i in range(n):
        dist_row = raw_matrix[i]
        for j in range(i + 1):
            matrix[i, j] = matrix[j, i] = dist_row[j]

    return matrix


def parse_matrix(raw_data, matrix_start, dimension):
    for line in raw_data:
        if "LOWER_DIAG_ROW" in line:
            return parse_lower_diag_row(raw_data, matrix_start)

        if "FULL_MATRIX" in line:
            return parse_full_matrix(raw_data, matrix_start, dimension)

    raise ValueError("File does not contain matrix!")


def parse_node_coords(raw_data, matrix_start, dimension):
    points = parse_node_points(raw_data, matrix_start, dimension)

    n = len(points)
    matrix = np.empty((n, n))

    for i in range(n):
        x1, y1 = points[i]
        for j in range(i, n):
            x2, y2 = points[j]
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
