from evolutionary_algorithm import EvolutionaryAlgorithm

if __name__ == '__main__':
    ea = EvolutionaryAlgorithm(100, 100, [], 40, 3)
    ea.print_population()
    print(ea.run())
    print(ea.prun())