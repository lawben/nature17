#cython: boundscheck=False, wraparound=False, nonecheck=False
from cython.parallel import prange

import numpy as np
cimport numpy as np


cdef struct Student:
    char s_hash[32]
    char sex
    short discipline
    short nationality


cdef class DiversityFinder:
    
    cdef int num_students
    cdef Student students[81]
    cdef dict dis_to_number
    cdef dict nat_to_number

    def __init__(self, students):
        self.num_students = len(students)

        self.dis_to_number = {}
        self.nat_to_number = {}
        converted_students = self._convert_students(students)

        # Init student array
        cdef Student *s
        cdef int i
        for i in range(self.num_students):
            stud = students[i]
            s = &self.students[i]

            s.s_hash = stud[0].encode()
            s.sex = False if stud[1] == "m" else True
            s.discipline = self.dis_to_number[stud[2]] 
            s.nationality = self.nat_to_number[stud[3]]

    def _convert_students(self, students):
        self.dis_to_number = self._convert_disciplines(students)
        self.nat_to_number = self._convert_nationalities(students)

    def _convert_disciplines(self, students):
        disciplines = sorted({s[2] for s in students})
        return {dis: num for num, dis in enumerate(disciplines)}

    def _convert_nationalities(self, students):
        nationalities = sorted({s[3] for s in students})
        return {nat: num for num, nat in enumerate(nationalities)}

    def get_diverse_teams(self):
        teams = {}

        teams["teaming1"] = self.get_teaming1()
        # teams["teaming2"] = self.get_teaming2()
        # teams["teaming3"] = self.get_teaming3()
        # teams["teaming4"] = self.get_teaming4()

        return teams
        

    def get_teaming1(self):
        cdef int team1[81]
        self.create_teaming1(team1)
        return self.teaming_to_team(team1)

    cdef list teaming_to_team(self, int* teaming):
        cdef list team = []
        cdef int student_number
        cdef int team_number = 0
        for i in range(self.num_students):
            student_number = teaming[i]
            s_hash = self.students[student_number].s_hash.decode()[:32]
            team_number = i / 5
            if i == 80:
                team_number = 15
            stud = (s_hash, team_number)
            team.append(stud)

        return team

    cdef void create_teaming1(self, int* teaming):
        cdef int i
        for i in range(self.num_students):
            teaming[i] = i

    cdef void calc(self):
        cdef int sum_sex = 0
        cdef int i

        for i in prange(self.num_students, nogil=True):
            sum_sex += self.students[i].sex
