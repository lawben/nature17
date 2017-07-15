#cython: boundscheck=False, wraparound=False, nonecheck=False
import cython
from diversity cimport Student
from libc.stdlib cimport malloc, free
from libc.math cimport log

cdef class Fitness:
    cdef int unique_genders
    cdef int unique_disciplines
    cdef int unique_nationalities
    cdef int num_students
    cdef int TEAM_SIZE
    cdef int MAX_TEAMS

    def __init__(self, int unique_genders, int unique_disciplines,
                 int unique_nationalities, int num_students):
        self.unique_genders = unique_genders
        self.unique_disciplines = unique_disciplines
        self.unique_nationalities = unique_nationalities
        self.num_students = num_students
        self.TEAM_SIZE = 5
        self.MAX_TEAMS = 16

    cdef double intra_fit(self, Student *students, int *teaming) nogil:
        cdef double res = 0
        cdef int i
        cdef short* genders = <short*> malloc(self.num_students * sizeof(short))
        cdef short* disciplines = <short*> malloc(self.num_students * sizeof(short))
        cdef short* nationalities = <short*> malloc(self.num_students * sizeof(short))
        cdef Student* s

        for i in range(self.num_students):
            s = &students[i]
            genders[i] = s.sex
            disciplines[i] = s.discipline
            nationalities[i] = s.nationality

        cdef double team_entropy = 0
        cdef int num_team_members = self.TEAM_SIZE
        for i in range(self.MAX_TEAMS):
            team_entropy = 0
            if i == self.MAX_TEAMS - 1 and self.num_students == 81:
                num_team_members = 6
            team_entropy += self.get_team_entropy(genders, self.unique_genders, num_team_members, i)
            team_entropy += self.get_team_entropy(disciplines, self.unique_disciplines, num_team_members, i)
            team_entropy += self.get_team_entropy(nationalities, self.unique_nationalities, num_team_members, i)
            res += team_entropy

        free(genders)
        free(disciplines)
        free(nationalities)
        return res

    @cython.cdivision(True)
    cdef double get_team_entropy(self, short *attributes, int unique_items,
                                 int num_team_members, int team_number) nogil:
        cdef int i
        cdef double* probabilities = <double*> malloc(unique_items * sizeof(double))
        cdef int* item_counts = <int*> malloc(unique_items * sizeof(int))
        cdef int team_offset = self.TEAM_SIZE*team_number

        for i in range(team_offset, team_offset + num_team_members):
            item_counts[attributes[i]] += 1

        for i in range(unique_items):
            probabilities[i] = (<double> item_counts[i])/num_team_members

        cdef double sum_ = 0
        cdef double prob
        for i in range(unique_items):
            prob = probabilities[i]
            sum_ += prob * (log(prob)/log(unique_items))

        free(probabilities)
        free(item_counts)
        return -sum_
