from collections import defaultdict, Counter


def parse(data_file):
    # Drop header line
    students_raw = list(open(data_file))[1:]
    students = defaultdict(list)
    for raw_s in students_raw:
        parsed_s = raw_s.strip().replace('"', '').split(",")
        s_hash, sex, dis, nat, sem = parsed_s
        if not sex:
            sex = "not-identify"
        student = (s_hash, sex.lower(), dis, nat)
        students[sem].append(student)

    return students


if __name__ == "__main__":
    # Format: hash,sex,discipline,nationality,semester
    students = parse("project4.csv")

    disciplines = Counter()
    sex = Counter()
    nationalities = Counter()

    print("Semester:")
    for k, v in sorted(students.items(), key=lambda x: x[0].split("-")[1]):
        print(k, "-->", len(v), "student(s)")
        for s in v:
            sex[s[1]] += 1
            disciplines[s[2]] += 1
            nationalities[s[3]] += 1

    print("\nDisciplines:")
    for d, number in sorted(disciplines.items()):
        print(d, "-->", number, "student(s)")

    print("\nSex:")
    for d, number in sorted(sex.items()):
        print(d, "-->", number, "student(s)")

    print("\nNationalities:")
    for d, number in sorted(nationalities.items()):
        print(d, "-->", number, "student(s)")
