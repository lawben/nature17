#cython: boundscheck=False, wraparound=False, nonecheck=False
import sys
import random
import itertools as it

from cpython cimport array
import array

import numpy as np
cimport numpy as np

from parser import parse, parse_tour, parse_points, get_opt
from plot_tsp import TspPlotter


cdef class MMAS:

    cdef float[:,:] edge_weights, pheremones
    cdef float rho, tau_min, tau_max, alpha, beta, opt, best_value
    cdef int n
    cdef object plotter
    cdef list best_tour, all_nodes, all_edges

    def __init__(self, np.ndarray adjacency_matrix, opt, rho=None, tau_min=None, 
                 tau_max=None, alpha=1.0, beta=4.0, object plotter=None):
        n = len(adjacency_matrix)
        self.edge_weights = adjacency_matrix
        self.n = self.edge_weights.shape[0]
        self.pheremones = np.empty([n, n], dtype=np.float32)

        # Init default values
        self.rho = 1/n if not rho else rho
        self.tau_min = 1/(n*n) if not tau_min else tau_min
        self.tau_max = 1 - 1/n if not tau_max else tau_max
        self.alpha = alpha
        self.beta = beta
        self.n = n

        self.plotter = plotter

        self.best_tour = None
        self.best_value = sys.maxsize

        self.all_nodes = list(range(self.n))
        self.all_edges = list(it.combinations(self.all_nodes, 2))

    @classmethod
    def of(cls, data_file, tour_file, use_plotter=True):
        mat = parse(data_file)
        tour = parse_tour(tour_file)
        opt = get_opt(tour, mat)
        try:
            points = parse_points(data_file)
        except ValueError:
            # Cannot display points in plot, so no plot needed
            print("Cannot parse point from file. No plot possible.")
            use_plotter = False

        n = len(mat)
        if use_plotter:
            plotter = TspPlotter(points, TspPlotter.nodes2tour(tour))
        else:
            plotter = None
        mat = np.asmatrix(mat, dtype=np.float32)
        return MMAS(mat, opt, plotter)

    def run(self):
        self.init_pheremones()
        cdef int counter = 0
        print('Optimum: %d' % self.opt)
        while self.best_value > self.opt:
            for i in range(4):
                tour, value = self.construct()
                if value < self.best_value:
                    self.best_tour = tour
                    self.best_value = value
            self.update_pheremones(self.best_tour)
            counter += 1
            if counter % 1000 == 0:
                print('Iterations: %d  Current opt: %f' % (
                      counter, self.best_value))
                if self.plotter is not None:
                    self.plotter.plot_solution(self.best_tour)
                    self.plotter.plot_pheremones(self.all_edges,
                                                 self.pheremones)
            if counter == 10000:
                break

        return self.best_tour, self.best_value, counter

    cdef tuple construct(self):
        cdef int vertex = np.random.choice(self.all_nodes)
        cdef int start_vertex = vertex
        cdef set unvisited = set(self.all_nodes)
        unvisited.remove(vertex)

        cdef list tour = []
        cdef float value = 0

        cdef int old_vertex, i
        for i in range(self.n - 1):
            old_vertex = vertex
            vertex = self.chose_next(vertex, unvisited)
            tour.append((old_vertex, vertex))
            unvisited.remove(vertex)
            value += self.edge_weights[old_vertex, vertex]

        tour.append((vertex, start_vertex))
        value += self.edge_weights[vertex, start_vertex]
        return tour, value

    cdef int chose_next(self, int vertex, set unvisited_set):
        cdef float R = 0
        cdef int n = len(unvisited_set)
        cdef np.ndarray[np.int_t] unvisited = np.array(list(unvisited_set), dtype=np.int)
        cdef np.ndarray[np.float32_t, ndim=1] probs = np.empty(n, dtype=np.float32)

        cdef float tau
        cdef float weight
        cdef float prob
        cdef int i, other_vertex
        for i in range(n):
            other_vertex = unvisited[i]
            tau = self.get_pheromone(vertex, other_vertex)
            weight = self.edge_weights[vertex, other_vertex]
            prob = tau**self.alpha * weight**(-self.beta)
            R += prob
            probs[i] = prob
        
        cdef int j
        for j in range(n):
            probs[j] /= R 

        return np.random.choice(unvisited, p=probs)

    cdef tuple edge_id(self, int i, int j):
        if j < i:
            (i, j) = (j, i)
        return (i, j)

    cdef float get_pheromone(self, int i, int j):
        cdef int tmp
        if j < i:
            tmp = i
            i = j
            j = tmp
        return self.pheremones[i, j]

    cdef set_pheromone(self, float value, int i, int j):
        cdef int tmp
        if j < i:
            tmp = i
            i = j
            j = tmp
        self.pheremones[i, j] = value

    cdef init_pheremones(self):
        cdef float value = 1 / self.n
        for edge in self.all_edges:
            self.set_pheromone(value, edge[0], edge[1])

    cdef update_pheremones(self, list tour):
        tour_edge_ids = set(self.edge_id(edge[0], edge[1]) for edge in tour)
        cdef float current_tau
        cdef float new_tau
        for edge in self.all_edges:
            current_tau = self.get_pheromone(edge[0], edge[1])
            if self.edge_id(edge[0], edge[1]) in tour_edge_ids:
                new_tau = min((1 - self.rho) * current_tau + self.rho,
                              self.tau_max)
            else:
                new_tau = max((1 - self.rho) * current_tau, self.tau_min)
            self.set_pheromone(new_tau, edge[0], edge[1])
