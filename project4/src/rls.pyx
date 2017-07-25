#cython: boundscheck=False, wraparound=False, nonecheck=False
import random
import time
import os

from libc.stdlib cimport rand, malloc, free, srand
from libc.string cimport memcpy

from diversity cimport Student
from fitness import Fitness
from fitness cimport Fitness


cdef class RLS:

    cdef int n_students
    cdef int* population
    cdef Fitness fitness_calc
    cdef double best_fitness

    def __init__(self, int n_students, Fitness fitness):
        srand(int(time.time()))
        self.n_students = n_students
        self.fitness_calc = fitness

        cdef list raw_pop = list(range(self.n_students))
        random.shuffle(raw_pop)
        self.population = <int*> malloc(self.n_students * sizeof(int))

        for i in range(self.n_students):
            self.population[i] = raw_pop[i]

    def run(self, iterations=10000):
        res = self.search(iterations)
        msg = "Fitness {} for teaming {} after {} iterations.".format(
            self.best_fitness, res, iterations)
        #self.notify(msg)
        return res

    cdef double fitness(self, int* teaming) nogil:
        return self.fitness_calc.fitness(teaming)

    cdef list search(self, int iterations):
        cdef int i, j, counter = 0
        cdef double new_fitness
        #cdef int* offspring = <int*> malloc(self.n_students * sizeof(int))

        self.best_fitness = self.fitness(self.population)
        print("First iteration:", self.best_fitness)

        while counter <= iterations:
            #memcpy(offspring, self.population, self.n_students * sizeof(int))
            i = rand() % self.n_students
            j = rand() % self.n_students
            self.swap(self.population, i, j)

            new_fitness = self.fitness(self.population)
            if new_fitness > self.best_fitness:
                self.best_fitness = new_fitness
            else:
                # Not better, so swap back
                self.swap(self.population, i, j)

            counter += 1

            if counter % 10000 == 0:
                print("iteration", counter, "fitness", self.best_fitness)

        cdef list res = [None] * self.n_students
        for i in range(self.n_students):
            res[i] = self.population[i]

        #free(offspring)
        return res

    cdef inline void swap(self, int* arr, int i, int j):
        cdef int tmp = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp

    def notify(self, msg):
        os.system("ntfy -b telegram send '{}'".format(msg))

    def __dealloc__(self):
        free(self.population)
