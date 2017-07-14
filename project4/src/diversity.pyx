#cython: boundscheck=False, wraparound=False, nonecheck=False
from cpython cimport array
from cython.parallel import prange
from libc.stdlib cimport malloc
import array

import numpy as np
cimport numpy as np

cdef class DiversityFinder:
    
    cdef int num_students
    cdef Student students[81]

    def __init__(self, students):
        self.num_students = len(students)

        cdef Student *s

        for i in range(self.num_students):
            stud = students[i]
            s = &self.students[i]

            s.id_ = i
            s.sex = 0 if stud[1] == "m" else 1
            s.discipline = i  # TODO: Make this dependent on stud[2]
            s.nationality = 1  # TODO: Make this dependent on stud[3]


    def get_diverse_teams(self):
        self.calc()

    cdef void calc(self):
        cdef int sum_sex = 0
        cdef int i

        for i in prange(self.num_students, nogil=True):
            sum_sex += self.students[i].sex
