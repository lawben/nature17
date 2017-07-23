from libcpp.vector cimport vector
from diversity cimport Student

cdef class Fitness:
    cdef Student* students
    cdef int unique_genders
    cdef int unique_disciplines
    cdef int unique_nationalities
    cdef int num_students
    cdef int TEAM_SIZE
    cdef int MAX_TEAMS
    cdef int n_teamings
    cdef vector[vector[vector[int]]] reference_vectors

    cdef vector[vector[int]] teaming_vectors(self, int* teaming) nogil
    cdef void init_reference_vectors(self, list teamings)
    cdef void set_students(self, Student* students)
    cdef double fitness(self, int* teaming) nogil
    cdef bint dominates(self, int* teaming1, int* teaming2) nogil
    cdef double intra_fit(self, int *teaming) nogil
    cdef double get_team_entropy(self, short *attributes, int unique_items,
                                 int num_team_members, int team_number) nogil
    cdef int collisions_between(self, vector[int]* set1, vector[int]* set2) nogil
    cdef int collisions(self, int* teaming) nogil
                                