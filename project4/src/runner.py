import os

from parser import parse
from diversity import DiversityFinder


def main(csv_file):

    students = parse(csv_file)
    for semester, studs in students.items():
        div = DiversityFinder(studs)
        print(div.get_diverse_teams())
        break


if __name__ == '__main__':
    file_dir = os.path.dirname(__file__)
    file_ = os.path.join(file_dir, "..", "project4.csv")
    main(file_)
