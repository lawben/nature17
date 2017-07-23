#cython: boundscheck=False, wraparound=False, nonecheck=False
import sys
import time

import cython
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from cython.parallel import parallel, prange
import numpy as np
cimport numpy as np

from libc.stdlib cimport rand, RAND_MAX, srand, malloc, free

from diversity cimport Student
from fitness import Fitness
from fitness cimport Fitness

cdef extern from "<algorithm>" namespace "std":
    void random_shuffle(int* start, int* end)

cdef class EvolutionaryAlgorithm:
    """(μ+λ)-EA
    μ - population size
    λ - number of generated offsprings
    """

    cdef int** population
    cdef int*** offsprings
    cdef int n_individuals, n_offsprings, n_students, tournament_size
    cdef double swap_prob, inverse_prob, insert_prob, shift_prob, best_fitness
    cdef int* best_individual
    cdef Fitness fitness_calculator

    def __init__(self, int n_individuals, int n_offsprings, int n_students, Fitness fitness):
        srand(<unsigned>time.time())
        self.n_individuals = n_individuals
        self.n_offsprings = n_offsprings
        self.n_students = n_students
        self.fitness_calculator = fitness
        self.best_fitness = 0.0

        self.tournament_size = 10

        self.swap_prob = <double> 1 / self.n_students
        self.inverse_prob = <double> 1 / self.n_students
        self.insert_prob = <double> 1 / self.n_students
        self.shift_prob = <double> 1 / self.n_students

        self.init_population()
        self.init_offsprings()

    def run(self, iterations=1000):
        self.search(iterations)
        best = []
        for i in range(self.n_students):
            best.append(self.best_individual[i])
        for s in range(self.n_students):
            assert s in best
        return best

    cdef void search(self, int iterations):
        cdef int counter = 0
        self.best_individual = self.select_best(self.population, self.n_individuals)
        self.best_fitness = self.fitness(self.best_individual)

        while counter <= iterations:
            if counter % 100 == 0:
                print('iteration %d, %s' % (counter, str(self.best_fitness)))
                self.print_array(self.best_individual, self.n_students)
            self.generate_offsprings()
            self.select_offsprings()

            self.best_individual = self.select_best(self.population, self.n_individuals)
            self.best_fitness = self.fitness(self.best_individual)
            counter += 1

    #
    # Memory allocation and deallocation
    #

    cdef void init_population(self):
        self.population = <int**> PyMem_Malloc(self.n_individuals * sizeof(int*))
        cdef int i, j
        for i in range(self.n_individuals):
            self.population[i] = <int*> PyMem_Malloc(self.n_students * sizeof(int))
            for j in range(self.n_students):
                self.population[i][j] = j
            self.shuffle(self.population[i], self.n_students)

    cdef void free_population(self):
        cdef int i
        for i in range(self.n_individuals):
            PyMem_Free(self.population[i])
        PyMem_Free(self.population)

    cdef void init_offsprings(self):
        self.offsprings = <int***> PyMem_Malloc(self.n_individuals * sizeof(int**))
        cdef int i, j
        for i in range(self.n_individuals):
            self.offsprings[i] = <int**> PyMem_Malloc(self.n_offsprings * sizeof(int*))
            for j in range(self.n_offsprings):
                self.offsprings[i][j] = <int*> PyMem_Malloc(self.n_students * sizeof(int))

    cdef void free_offsprings(self):
        cdef int i, j
        for i in range(self.n_individuals):
            for j in range(self.n_offsprings):
                PyMem_Free(self.offsprings[i][j])
            PyMem_Free(self.offsprings[i])
        PyMem_Free(self.offsprings)

    #
    # Offspring generation
    #

    cdef void swap_mutation(self, int* offspring) nogil:
        cdef int i = self.rand_int(self.n_students)
        cdef int j = self.rand_int(self.n_students)
        self.swap(offspring, i, j)

    @cython.cdivision(True)
    cdef void swap_all_mutation(self, int* offspring) nogil:
        cdef int i
        cdef float swap_prob = 1.0 / self.n_students
        for i in range(self.n_students):
            if self.rand_decision(swap_prob):
                self.swap(offspring, i, self.rand_int(self.n_students))

    cdef void inversion_mutation(self, int* offspring) nogil:
        cdef int i = self.rand_int(self.n_students - 1)
        cdef int j = self.rand_int_range(i + 1, self.n_students)
        while i < j:
            self.swap(offspring, i, j)
            i += 1
            j -= 1            

    cdef void insertion_mutation(self, int* offspring) nogil:
        cdef int i = self.rand_int(self.n_students - 1)
        cdef int j = self.rand_int_range(i + 1, self.n_students)
        while i < j:
            self.swap(offspring, i, i + 1)
            i += 1

    # todo: this does not work :(
    cdef void shift_mutation(self, int* offspring) nogil:
        cdef int i = self.rand_int(self.n_students)
        cdef int j = self.rand_int_range(i, self.n_students)
        cdef int k = self.rand_int(self.n_students - 1)
        cdef int shift_len = j - i + 1
        cdef int left = j + 1
        cdef int right = j + k + 1
        cdef int s
        for s in range(left, right):
            self.bubble(offspring, s % self.n_students, shift_len)

    cdef void bubble(self, int* offspring, int i, int shift_len) nogil:
        cdef int left_val = i - shift_len
        cdef int k     
        for k in range(i - 1, left_val - 1, -1):
            self.swap(offspring, i % self.n_students, k % self.n_students)
            i -= 1

    cdef void mutate(self, int* offspring) nogil:
        if self.rand_decision(self.swap_prob):
            self.swap_mutation(offspring)

        if self.rand_decision(self.inverse_prob):
            self.inversion_mutation(offspring)

        if self.rand_decision(self.insert_prob):
            self.insertion_mutation(offspring)

        #if self.rand_decision(self.shift_prob):
        #self.shift_mutation(offspring)

    cdef void generate_offspring(self, int* individual, int* offspring) nogil:
        cdef int i
        for i in range(self.n_students):
            offspring[i] = individual[i]
        self.mutate(offspring)

    cdef void generate_offsprings(self) nogil:
        cdef int i, j = 0
        cdef int* local_individual
        with parallel():
            for i in prange(self.n_individuals):
                local_individual = self.population[i]
                for j in prange(self.n_offsprings):
                    self.generate_offspring(local_individual, self.offsprings[i][j])

    #
    # Offspring selection
    #

    cdef double fitness(self, int* individual) nogil:
        return self.fitness_calculator.fitness(individual)

    cdef int* select_best(self, int** individuals, int n) nogil:
        cdef double best_fitness = self.fitness(individuals[0])
        cdef int* local_best_individual = individuals[0]
        cdef int i
        cdef double current_fitness
        for i in range(1, n):
            current_fitness = self.fitness(individuals[i])
            if current_fitness >= best_fitness:
                best_fitness = current_fitness
                local_best_individual = individuals[i]
        return local_best_individual

    cdef int* rand_tournament_member(self) nogil:
        cdef int individual_idx, offspring_idx

        if self.rand_decision(0.0):
            # select from current population
            individual_idx = self.rand_int(self.n_individuals)
            return self.population[individual_idx]
        else:
            # select from offsprings
            individual_idx = self.rand_int(self.n_individuals)
            offspring_idx = self.rand_int(self.n_offsprings)
            return self.offsprings[individual_idx][offspring_idx]

    cdef void select_offsprings(self) nogil:
        cdef int i, j
        cdef int** tournament_members
        cdef int* best
        with parallel():
            tournament_members = <int**> malloc(self.tournament_size * sizeof(int*))
            for i in prange(self.n_individuals):
                for j in range(self.tournament_size):
                    tournament_members[j] = self.rand_tournament_member()
                best = self.select_best(tournament_members, self.tournament_size)
                for j in range(self.n_students):
                    self.population[i][j] = best[j]
            free(tournament_members)

    #
    # Util methods
    #

    def print_population(self):
        cdef int i, j
        print(str(self.n_individuals))
        print(str(self.n_students))
        for i in range(self.n_individuals):
            self.print_array(self.population[i], self.n_students)

    cdef void shuffle(self, int* arr, int length):
        random_shuffle(&arr[0], &arr[length])

    @cython.cdivision(True)
    cdef inline int rand_int(self, int max_number) nogil:
        """Random number in range [0, max_number)"""
        return rand() % max_number

    @cython.cdivision(True)
    cdef inline int rand_int_range(self, int min_number, int max_number) nogil:
        """Random number in range [min_number, max_number)"""
        return rand() % (max_number - min_number) + min_number

    @cython.cdivision(True)
    cdef inline bint rand_decision(self, float prob) nogil:
        return <float> rand() / RAND_MAX <= prob

    cdef inline void swap(self, int* arr, int i, int j) nogil:
        cdef int tmp = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp

    cdef void print_array(self, int* arr, int n):
        cdef list line = []
        cdef int i
        for i in range(n):
            line.append(str(arr[i]))
        print(','.join(line))

    def __dealloc__(self):
        self.free_offsprings()
        self.free_population()
