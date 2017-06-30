import numpy as np
import sys
import random
import itertools as it

from parser import parse, parse_tour, parse_points, get_opt
from plot_tsp import TspPlotter


class MMAS:

    def __init__(self, adjacency_matrix, rho, tau_min, tau_max, alpha, beta, opt, plotter=None):
        self.edge_weights = np.matrix(adjacency_matrix)

        self.rho = rho
        self.tau_min = tau_min
        self.tau_max = tau_max
        self.alpha = alpha
        self.beta = beta
        self.opt = opt

        self.plotter = plotter

        self.pheremones = {}
        self.best_tour = None
        self.best_value = sys.maxsize
        self.n = self.edge_weights.shape[0]

        self.all_nodes = range(self.n)
        self.all_edges = list(it.combinations(self.all_nodes, 2))

    @classmethod
    def of(cls, data_file, tour_file, use_plotter=True):
        mat = parse(data_file)
        tour = parse_tour(tour_file)
        opt = get_opt(tour, mat)
        points = parse_points(data_file)
        n = len(mat)
        if use_plotter:
            plotter = TspPlotter(points, TspPlotter.nodes2tour(tour))
        else:
            plotter = None
        return MMAS(mat, 1/n, 1/(n**2), 1 - 1/n, 1, 4, opt, plotter)

    def run(self):
        self.init_pheremones()
        counter = 0
        print('Optimum: %d' % self.opt)
        print()
        while self.best_value > self.opt:
            for i in range(4):
                tour, value = self.construct()
                if value < self.best_value:
                    self.best_tour = tour
                    self.best_value = value
            self.update_pheremones(self.best_tour)
            counter += 1
            if counter % 1000 == 0:
                print('Iterations: %d  Current opt: %d' % (counter, self.best_value))
                if self.plotter is not None:
                    self.plotter.plot_solution(self.best_tour)
                    self.plotter.plot_pheremones(self.all_edges, self.pheremones)
            if counter == 10000:
                break

        return self.best_tour, self.best_value, counter

    def construct(self):
        vertex = start_vertex = np.random.choice(self.all_nodes)
        unvisited = set(self.all_nodes)
        unvisited.remove(vertex)

        tour = []
        value = 0

        for i in range(self.n - 1):
            old_vertex = vertex
            vertex = self.chose_next(vertex, unvisited)
            tour.append((old_vertex, vertex))
            unvisited.remove(vertex)
            value += self.edge_weights[old_vertex, vertex]

        tour.append((vertex, start_vertex))
        value += self.edge_weights[vertex, start_vertex]
        return tour, value

    def chose_next(self, vertex, unvisited):
        R = 0
        probs = []
        unvisited = list(unvisited)
        for j in unvisited:
            tau = self.get_pheromone(vertex, j)
            weight = float(self.edge_weights[vertex, j])
            prob = tau**self.alpha * weight**(-self.beta)
            R += prob
            probs.append(prob)

        probs = [prob / R for prob in probs]

        return np.random.choice(unvisited, p=probs)

    def edge_id(self, i, j):
        if j < i:
            (i, j) = (j, i)
        # return self.n * i + j
        return (i, j)

    def get_pheromone(self, i, j):
        return self.pheremones[self.edge_id(i, j)]

    def set_pheromone(self, value, i, j):
        self.pheremones[self.edge_id(i, j)] = value

    def init_pheremones(self):
        value = 1 / self.n
        for edge in self.all_edges:
            self.set_pheromone(value, *edge)

    def update_pheremones(self, tour):
        tour_edge_ids = set(self.edge_id(*edge) for edge in tour)
        for edge in self.all_edges:
            current_tau = self.get_pheromone(*edge)
            new_tau = None
            if self.edge_id(*edge) in tour_edge_ids:
                new_tau = min((1 - self.rho) * current_tau + self.rho, self.tau_max)
            else:
                new_tau = max((1 - self.rho) * current_tau, self.tau_min)
            self.set_pheromone(new_tau, *edge)


if __name__ == '__main__':
    # mat = [
    #     [0, 1, 2, 2, 1],
    #     [1, 0, 1, 2, 2],
    #     [2, 1, 0, 1, 2],
    #     [2, 2, 1, 0, 1],
    #     [1, 2, 2, 1, 0]
    # ]
    # n = len(mat)
    # mmas = MMAS(mat, 1/n, 1/(n**2), 1 - 1/n, 1, 0, 5)
    mmas = MMAS.of(sys.argv[1], sys.argv[2])
    tour, value, iters = mmas.run()

    print(tour)
    print(value)
    print(iters)
