#cython: boundscheck=False, wraparound=False, nonecheck=False
import random
import sys

from cpython.mem cimport PyMem_Malloc, PyMem_Free
from cython.parallel import prange
import numpy as np
cimport numpy as np

from diversity cimport Student

cdef class EvolutionaryAlgorithm:
    """(μ+λ)-EA
    μ - population size
    λ - number of generated offsprings
    """

    cdef Student[:] students
    cdef int n_individuals, n_offsprings, n_students, n_teams
    cdef int **population

    def __init__(self, int n_individuals, int n_offsprings, students,
                 int n_students, int n_teams):
        self.n_individuals = n_individuals
        self.n_offsprings = n_offsprings
        # self.students = students
        self.n_students = n_students
        self.n_teams = n_teams

        self.init_population()

    def init_population(self):
        self.population = <int**> PyMem_Malloc(self.n_individuals * sizeof(int**))
        cdef list proto_individual = list(range(self.n_students))

        cdef int i, j
        for i in range(self.n_individuals):
            self.population[i] = <int*> PyMem_Malloc(self.n_students * sizeof(int))
            random.shuffle(proto_individual)
            for j in range(self.n_students):
                self.population[i][j] = proto_individual[j]

    def print_population(self):
        cdef int i, j
        print(str(self.n_individuals))
        print(str(self.n_students))
        for i in range(self.n_individuals):
            for j in range(self.n_students):
                sys.stdout.write(str(self.population[i][j]) + ', ')
                sys.stdout.flush()
            print('')

    def run(self):
        cdef int i
        cdef int* individual
        for i in prange(self.n_individuals, nogil=True):
            individual = self.population[i]

    def __dealloc__(self):
        cdef int i
        #for i in range(self.n_individuals):
         #   PyMem_Free(self.population[i])
        #PyMem_Free(self.population) 

