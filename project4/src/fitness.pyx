#cython: boundscheck=False, wraparound=False, nonecheck=False
import cython
from diversity cimport Student
from libc.stdlib cimport malloc, free
from libc.math cimport log
from libcpp.vector cimport vector
from libcpp.algorithm cimport sort as cppsort
from cython.operator cimport dereference as deref, preincrement as inc

ctypedef vector[int].iterator iterator_t
cdef extern from "<algorithm>" namespace "std" nogil:
    iterator_t set_intersection (iterator_t first1, iterator_t last1, iterator_t first2, iterator_t last2, iterator_t result);

cdef class Fitness:
    def __init__(self, int unique_genders, int unique_disciplines,
                 int unique_nationalities, int num_students, list teamings):
        self.unique_genders = unique_genders
        self.unique_disciplines = unique_disciplines
        self.unique_nationalities = unique_nationalities
        self.num_students = num_students
        self.TEAM_SIZE = <int> 5
        self.MAX_TEAMS = <int> 16
        self.n_teamings = <int> len(teamings)
        if self.n_teamings > 0:
            self.init_reference_vectors(teamings)

    cdef vector[vector[int]] teaming_vectors(self, int* teaming) nogil:
        cdef vector[vector[int]] vectors
        cdef vector[int] vector
        cdef int i, j, team_size
        for i in range(self.MAX_TEAMS):
            vectors.push_back(vector)
            if i == self.MAX_TEAMS - 1 and self.num_students == 81:
                team_size = 6
            else:
                team_size = self.TEAM_SIZE
            for j in range(team_size):
                vectors[i].push_back(<int> teaming[i * team_size + j])
            cppsort(vectors[i].begin(), vectors[i].end())

        return vectors

    cdef void init_reference_vectors(self, list teamings):
        cdef int i, j
        cdef int* teaming = <int*> malloc(self.num_students * sizeof(int))
        for i in range(self.n_teamings):
            for j in range(self.num_students):
                teaming[j] = teamings[i][j]
            self.reference_vectors.push_back(self.teaming_vectors(teaming))
        free(teaming)

    cdef void set_students(self, Student* students):
        self.students = students

    cdef double fitness(self, int* teaming) nogil:
        return self.intra_fit(teaming)

    cdef bint dominates(self, int* teaming1, int* teaming2) nogil:
        return 1

    cdef double intra_fit(self, int *teaming) nogil:
        cdef double res = 0
        cdef int i, j
        cdef short* genders = <short*> malloc(self.num_students * sizeof(short))
        cdef short* disciplines = <short*> malloc(self.num_students * sizeof(short))
        cdef short* nationalities = <short*> malloc(self.num_students * sizeof(short))
        cdef Student* s

        for i in range(self.num_students):
            j = teaming[i]
            s = &self.students[j]
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

        for i in range(unique_items):
            item_counts[i] = 0

        for i in range(team_offset, team_offset + num_team_members):
            item_counts[attributes[i]] += 1

        for i in range(unique_items):
            probabilities[i] = (<double> item_counts[i])/num_team_members

        cdef double sum_ = 0
        cdef double prob
        for i in range(unique_items):
            prob = probabilities[i]
            if prob == 0:
                continue
            sum_ += prob * log(prob)

        free(probabilities)
        free(item_counts)
        return -sum_

    cdef int collisions_between(self, vector[int]* v1, vector[int]* v2) nogil:
        cdef vector[int] intersection
        set_intersection(v1.begin(), v1.end(), v2.begin(), v2.end(), intersection.begin())
        return intersection.size()

    cdef int collisions(self, int* teaming) nogil:
        if self.n_teamings == 0:
            return 0
        cdef vector[vector[int]] teaming_vectors = self.teaming_vectors(teaming)
        cdef int collisions = 0
        cdef int i, j, s, team_size

        for s in range(self.n_teamings):
            for i in range(self.MAX_TEAMS):
                for j in range(self.MAX_TEAMS):
                    collisions += self.collisions_between(&self.reference_vectors[s][i], &teaming_vectors[j])

        return collisions
