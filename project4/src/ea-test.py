from evolutionary_algorithm import EvolutionaryAlgorithm

if __name__ == '__main__':
    ea = EvolutionaryAlgorithm(10, 10, [], 5, 3)
    ea.print_population()
    ea.run()