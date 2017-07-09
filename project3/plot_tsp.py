import time

from six.moves import input
import matplotlib.pylab as plt


class TspPlotter:
    def __init__(self, points, opt_tour):
        self.points = points
        self.opt_tour = opt_tour
        self.figure = None
        self.ax1 = None
        self.ax2 = None
        self.ax3 = None

        self.init_plot()
        self.plot_opt()

    @staticmethod
    def nodes2tour(nodes):
        nodes_offset = nodes[1:]
        nodes_offset.append(nodes[0])
        return list(zip(nodes, nodes_offset))

    def init_plot(self):
        plt.ion()
        f, (ax1, ax2, ax3) = plt.subplots(1, 3)
        self.figure = f
        self.ax1 = ax1
        self.ax2 = ax2
        self.ax3 = ax3
        plt.tight_layout()

    def plot_arrow(self, ax, edge, width=None):
        start, end = edge
        sx, sy = self.points[start]
        ex, ey = self.points[end]
        if width is None:
            width = 1
        else:
            width = width
        ax.arrow(sx, sy, ex - sx, ey - sy, alpha=width)

    def plot_points(self, ax):
        x = []
        y = []
        for point in self.points:
            x.append(point[0])
            y.append(point[1])

        ax.plot(x, y, 'co')

    def plot_pheromones(self, edges, pheromones):
        self.ax3.cla()

        self.plot_points(self.ax3)
        for edge in edges:
            pheremone = pheromones[edge]
            self.plot_arrow(self.ax3, edge, width=min(pheremone*10, 1))
        plt.draw()
        plt.pause(1)

    def plot_opt(self):
        self.plot_tsp(self.ax1, self.opt_tour)

    def plot_solution(self, tour):
        self.ax2.cla()
        self.plot_tsp(self.ax2, tour)

    def plot_tsp(self, ax, path):
        # plot points
        self.plot_points(ax)

        # plot path
        for edge in path:
            self.plot_arrow(ax, edge)
        plt.draw()
        plt.pause(0.1)


if __name__ == '__main__':
    # Run an example

    # Create a randomn list of coordinates, pack them into a list
    x_cor = [1, 8, 4, 9, 2, 1, 8]
    y_cor = [1, 2, 3, 4, 9, 5, 7]
    points = []
    for i in range(0, len(x_cor)):
        points.append((x_cor[i], y_cor[i]))

    # Create two paths, teh second with two values swapped to simulate a 2-OPT
    # Local Search operation
    solution1 = [0, 2, 1, 3, 4, 5, 6]
    solution2 = [0, 2, 3, 1, 4, 5, 6]
    opt = [0, 2, 1, 3, 6, 4, 5]

    opt_tour = TspPlotter.nodes2tour(opt)
    solution1_tour = TspPlotter.nodes2tour(solution1)
    solution2_tour = TspPlotter.nodes2tour(solution2)

    tsp_plotter = TspPlotter(points, opt_tour)
    tsp_plotter.plot_solution(solution1_tour)
    time.sleep(5)
    tsp_plotter.plot_solution(solution2_tour)
    time.sleep(5)
    tsp_plotter.plot_solution(opt_tour)

    input('Press Enter to quit')