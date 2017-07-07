class TSPResult:
    def __init__(self, opt, tour, result, iterations, rho, tau_min,
                 tau_max, alpha, beta, goal, exec_number=-1, iteration=-1):

        self.opt = opt
        self.tour = tour
        self.result = result
        self.iterations = iterations
        self.rho = rho
        self.tau_min = tau_min
        self.tau_max = tau_max
        self.alpha = alpha
        self.beta = beta
        self.goal = goal
        self.exec_number = exec_number
        self.iteration = iteration

        self.str_tour = self.build_str_tour()

    def build_str_tour(self):
        start = self.tour[0][0]
        # Nodes are counted from 1 :/
        tour = [str(start + 1)]
        for _, city in self.tour:
            tour.append(str(city + 1))
        return "-".join(tour)

    def to_csv(self):
        str_ = ("{exec_number},{iteration},{opt},{str_tour},{result},"
                "{iterations},{goal},{rho},{tau_min},{tau_max},{alpha},{beta}"
                "\n")
        return str_.format(**self.__dict__)
