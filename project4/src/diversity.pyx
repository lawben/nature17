#cython: boundscheck=False, wraparound=False, nonecheck=False
from cython.parallel import prange

import numpy as np
cimport numpy as np

from rls import RLS


cdef class DiversityFinder:
    
    cdef int num_students
    cdef Student students[81]
    cdef dict dis_to_number
    cdef dict nat_to_number

    def __init__(self, students):
        self.num_students = len(students)

        self.dis_to_number = None
        self.nat_to_number = None
        self._convert_students(students)

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
        teams["teaming2"] = self.get_teaming2()
        # teams["teaming3"] = self.get_teaming3()
        # teams["teaming4"] = self.get_teaming4()

        return teams
        

    def get_teaming1(self):
        cdef list team = self.create_teaming1()
        return self.teaming_to_team(team)

    cdef list create_teaming1(self):
        return list(range(self.num_students))

    def get_teaming2(self):
        cdef list team = self.create_teaming2()
        return self.teaming_to_team(team)

    cdef list create_teaming2(self):
        rls = RLS(self.students, self.num_students)
        return rls.run()

    cdef list teaming_to_team(self, list teaming):
        cdef list teams = []
        cdef int student_number
        cdef int team_number = 0
        
        for i in range(self.num_students):
            # teaming at i contains student number
            student_number = teaming[i]

            # Decode fom bytes and remove null bytes
            s_hash = self.students[student_number].s_hash.decode()[:32]

            # Each block of 5 students belong to one team
            team_number = i / 5

            # Last team has 6 people, if neccessary
            if i == 80:
                team_number = 15

            stud = (s_hash, team_number)
            teams.append(stud)

        return teams

    cdef void calc(self):
        cdef int sum_sex = 0
        cdef int i

        for i in prange(self.num_students, nogil=True):
            sum_sex += self.students[i].sex
