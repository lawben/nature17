#cython: boundscheck=False, wraparound=False, nonecheck=False
import os
import time

import cython

from libc.stdlib cimport srand, malloc, free

from diversity cimport Student
from fitness import Fitness
from fitness cimport Fitness

cdef extern from "<algorithm>" namespace "std":
    void random_shuffle(int* start, int* end)

cdef class RS:

    cdef int n_students
    cdef int* best_individual
    cdef int* population
    cdef Fitness fitness_calculator
    cdef double best_fitness

    def __init__(self, int n_students, Fitness fitness):
        srand(int(time.time()))
        self.n_students = n_students

        self.best_individual = <int*> malloc(self.n_students * sizeof(int*))
        self.population = <int*> malloc(self.n_students * sizeof(int*))
        cdef int i

        for i in range(self.n_students):
            self.best_individual[i] = i
            self.population[i] = i

        self.fitness_calculator = fitness
        self.best_fitness = self.fitness(self.best_individual)

    def run(self, iterations=100000000):
        self.search(iterations)
        return

    cdef void search(self, int iterations):
        cdef int counter_no_changes = 0
        cdef int notified = 0
        cdef int counter = 0
        cdef int i
        cdef double new_fitness
        cdef list best

        while counter <= iterations:
            random_shuffle(&self.population[0], &self.population[self.n_students])
            new_fitness = self.fitness(self.population)

            if new_fitness > self.best_fitness:
                best = []
                for i in range(self.n_students):
                    self.best_individual[i] = <int> self.population[i]
                    best.append(self.best_individual[i])
                self.best_fitness = new_fitness
                counter_no_changes = 0
                notified = False

            if counter_no_changes > 1000000 and not notified:
                self.notify("Score {} with {} after {} iterations".format(self.best_fitness, best, counter))
                notified = True

            if counter % 1000 == 0:
                print('iteration %d, %s' % (counter, str(self.best_fitness)))

            counter += 1
            counter_no_changes += 1

    cdef double fitness(self, int* individual) nogil:
        return self.fitness_calculator.fitness(individual)

    def notify(self, msg):
        os.system("ntfy -b telegram send '{}'".format(msg))

    def __dealloc__(self):
        free(self.best_individual)
        free(self.population)
