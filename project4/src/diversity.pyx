#cython: boundscheck=False, wraparound=False, nonecheck=False
from cython.parallel import prange

import numpy as np
cimport numpy as np
import math

from rls import RLS


cdef class DiversityFinder:

    cdef int num_students
    cdef Student students[81]
    cdef dict dis_to_number
    cdef dict nat_to_number
    cdef int unique_genders
    cdef int unique_disciplines
    cdef int unique_nationalities

    def __init__(self, students):
        self.num_students = len(students)

        self.dis_to_number = None
        self.nat_to_number = None
        self._convert_students(students)

        # Init student array
        cdef Student *s
        cdef int i

        self.unique_genders = 2
        disciplines = []
        nationalities = []

        for i in range(self.num_students):
            stud = students[i]
            s = &self.students[i]

            s.s_hash = stud[0].encode()
            s.sex = False if stud[1] == "m" else True
            s.discipline = self.dis_to_number[stud[2]]
            s.nationality = self.nat_to_number[stud[3]]

            disciplines.append(s.discipline)
            nationalities.append(s.nationality)

        self.unique_disciplines = max(disciplines) + 1
        self.unique_nationalities = max(nationalities) + 1


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
        self.get_intra_fitness(team)
        return self.teaming_to_team(team)

    cdef get_entropy(self, list attribute_list, int unique_overall):
      max_item = max(attribute_list)
      item_counts = [0]*(max_item+1)

      for i in range(len(attribute_list)):
        item_counts[attribute_list[i]] += 1

      p = []
      sum_item_counts = sum(item_counts)
      for item_count in item_counts:
        p.append(item_count/float(sum_item_counts))
      base = min(len(attribute_list), unique_overall)

      sum_ = 0
      for pi in p:
        sum_ += pi * math.log(pi, base)
      return -sum_

    cdef float get_intra_fitness(self, list team):
      """Get intra-team diversities using the entropy on all attributes"""
      cdef list genders = []
      cdef list disciplines = []
      cdef list nationalities = []

      for i in range(self.num_students):
          s = &self.students[i]
          genders.append(s.sex)
          disciplines.append(s.discipline)
          nationalities.append(s.nationality)
      print(self.get_entropy(genders, self.unique_genders),
            self.get_entropy(disciplines, self.unique_disciplines),
            self.get_entropy(nationalities, self.unique_nationalities))
      return self.get_entropy(genders, self.unique_genders)

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
