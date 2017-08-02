from collections import Counter
import math


def single_entropy(team):
    counter = Counter(team)
    l = len(team)
    return -sum((c / l) * math.log(c / l) for c in counter.values())


def entropy(teams):
    return sum(single_entropy(team) for team in teams)


def max_entropy(value_map):
    n_teams = 16
    teams = []
    for _ in range(n_teams):
        teams.append([])
    i = 0
    for attr_id, value_count in enumerate(value_map):
        base_n = value_count // n_teams
        for team in teams:
            team.extend([attr_id] * base_n)
        value_count = value_count % n_teams
        while value_count > 0:
            teams[i].append(attr_id)
            value_count -= 1
            i = (i + 1) % n_teams
    return entropy(teams)


def max_entropy_teaming(teaming):
    attrs = ['Sex', 'Nationality', 'Discipline']
    return sum(max_entropy(teaming[attr].value_counts()) for attr in attrs)


def print_entropies(teaming, teams):
    attrs = ['Sex', 'Nationality', 'Discipline']
    for attr in attrs:
        print(attr)
        print('no teaming: {:0.4f}'.format(single_entropy(teams[attr].values)))
        print('teaming: {:0.4f}'.format(
            max_entropy(teaming[attr].value_counts())))
        print('')
    print('total teaming: {:0.4f}'.format(max_entropy_teaming(teaming)))
