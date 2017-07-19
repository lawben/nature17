#cython: boundscheck=False, wraparound=False, nonecheck=False
import random
import time

import cython
from cpython.mem cimport PyMem_Malloc, PyMem_Free

from libc.stdlib cimport rand, RAND_MAX, srand, malloc, free

from diversity cimport Student
from fitness import Fitness
from fitness cimport Fitness

cdef class RS:

    cdef int n_students
    cdef int* best_individual
    cdef list proto_individual
    cdef Fitness fitness_calculator
    cdef double best_fitness

    def __init__(self, int n_students, Fitness fitness):
        srand(int(time.time()))
        self.n_students = n_students

        self.best_individual = <int*> PyMem_Malloc(self.n_students * sizeof(int*))
        self.proto_individual = list(range(self.n_students))
        cdef int i
        random.shuffle(self.proto_individual)
        for i in range(self.n_students):
            self.best_individual[i] = <int> self.proto_individual[i]

        self.fitness_calculator = fitness
        self.best_fitness = self.fitness(self.best_individual)

    def run(self, iterations=1000000):
        self.search(iterations)
        return

    cdef void search(self, int iterations):
        cdef int counter = 0
        cdef int i
        cdef double new_fitness
        cdef int* test_individual = <int*> PyMem_Malloc(self.n_students * sizeof(int*))

        while counter <= iterations:
            random.shuffle(self.proto_individual)
            for i in range(self.n_students):
                test_individual[i] = <int> self.proto_individual[i]
            new_fitness = self.fitness(test_individual)

            if new_fitness > self.best_fitness:
                for i in range(self.n_students):
                    self.best_individual[i] = <int> self.proto_individual[i]
                self.best_fitness = new_fitness

            if counter % 1000 == 0:
                print('iteration %d, %s' % (counter, str(self.best_fitness)))

            counter += 1

    cdef double fitness(self, int* individual) nogil:
        return self.fitness_calculator.fitness(individual)
