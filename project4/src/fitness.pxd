from diversity cimport Student

cdef class Fitness:
    cdef Student* students
    cdef int unique_genders
    cdef int unique_disciplines
    cdef int unique_nationalities
    cdef int num_students
    cdef int TEAM_SIZE
    cdef int MAX_TEAMS

    cdef void set_students(self, Student* students)
    cdef double fitness(self, int* teaming) nogil
    cdef double intra_fit(self, int *teaming) nogil
    cdef double get_team_entropy(self, short *attributes, int unique_items,
                                 int num_team_members, int team_number) nogil