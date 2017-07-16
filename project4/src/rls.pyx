#cython: boundscheck=False, wraparound=False, nonecheck=False
import random

from libc.stdlib cimport rand
from cpython.array cimport array as carray
from cpython cimport array
from cpython.mem cimport PyMem_Malloc, PyMem_Free
import numpy as np
cimport numpy as np

from diversity cimport Student


cdef class RLS:

    cdef int n_students
    cdef carray population

    def __init__(self, int n_students):
        self.n_students = n_students

        cdef list raw_pop = list(range(self.n_students))
        random.shuffle(raw_pop)
        self.population = carray('i', raw_pop)

    def run(self, iterations=10000):
        return self.search(iterations)

    cdef double fitness(self, int[:] teaming):
        return 0.0

    cdef list search(self, int iterations):
        cdef int i, j, counter = 0
        cdef double current_fitness = self.fitness(self.population)
        cdef double new_fitness
        cdef carray y = array.clone(self.population, self.n_students, zero=False)

        while counter < iterations: 
            for i in range(self.n_students):
                y[i] = self.population[i]

            i = rand() % self.n_students
            j = rand() % self.n_students
            self.swap(y, i, j)

            new_fitness = self.fitness(y)
            if new_fitness < current_fitness:
                current_fitness = new_fitness
                self.population = y

            counter += 1

        cdef list res = [None] * self.n_students
        for i in range(self.n_students):
            res[i] = self.population[i]
        return res


    cdef inline void swap(self, int[:] arr, int i, int j):
        cdef int tmp = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp
