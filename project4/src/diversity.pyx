
from cython.parallel import prange

import numpy as np
cimport numpy as np

from rls import RLS
from evolutionary_algorithm import EvolutionaryAlgorithm

algos = {
    'ea': lambda params: EvolutionaryAlgorithm(20, 4, **params),
    'rls': lambda params: RLS(**params)
}

cdef class DiversityFinder:

    cdef int num_students
    cdef Student students[81]
    cdef dict dis_to_number
    cdef dict nat_to_number
    cdef str algo_name

    def __init__(self, students, algo_name):
        self.num_students = len(students)
        
        self.algo_name = algo_name

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
            s.sex = 0 if stud[1] == "m" else 1
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
        algo = algos[self.algo_name]({ 'n_students': self.num_students })
        return algo.run()

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
