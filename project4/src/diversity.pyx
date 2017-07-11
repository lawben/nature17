#cython: boundscheck=False, wraparound=False, nonecheck=False
from cpython cimport array
from cython.parallel import prange
import array

import numpy as np
cimport numpy as np


Student_DT = np.dtype([('id_', np.int16), 
               ('sex', np.int8), 
               ('discipline', np.int8), 
               ('nationality', np.int8)])

cdef packed struct Student:
    np.int16_t id_  # We don't want to carry along the string hash
    np.int8_t sex
    np.int8_t discipline
    np.int8_t nationality

cdef class DiversityFinder:
    
    cdef int num_students
    cdef Student[:] students

    def __init__(self, students):
        self.num_students = len(students)

        raw_students = []
        for i in range(self.num_students):
            stud = students[i]
            id_ = 0
            sex = 0 if stud[1] == "m" else 1
            discipline = 1  # TODO: Make this dependent on stud[2]
            nationality = 1  # TODO: Make this dependent on stud[3]
            raw_stud = (id_, sex, discipline, nationality)
            raw_students.append(raw_stud)

        self.students = np.asarray(raw_students, dtype=Student_DT)

    def get_diverse_teams(self):
        for i in range(self.num_students):
            print(self.students[i].sex)

        print("===")
        self.calc()

        for i in range(self.num_students):
            print(self.students[i].sex)

    cdef void calc(self) nogil:
        for i in range(self.num_students):
            self.students[i].sex += 1

