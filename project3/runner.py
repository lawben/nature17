import os
from argparse import ArgumentParser
from mmas import MMAS


def notify(msg):
    os.system("ntfy -b telegram send '{}'".format(msg))


def main(args):
    data_file = args.tsp_file
    notify = args.notify
    goal = float(args.goal)
    tour_file = data_file[:-4] + ".opt"
    mmas = MMAS.of(data_file, tour_file, not args.no_plot, goal)
    tour, value, iters = mmas.run()

    outputs = ["Tour: " + str(tour), "Score: " + str(value), "Iterations: " + str(iters)]
    print("\n".join(outputs))

    if notify:
        message = "Goal Deviation of {0:.0f}% reached for file {1:s} after {2:0d} iterations\n".format(goal, data_file,
                                                                                                       iters)
        MMAS.notify(message)


if __name__ == '__main__':
    # mat = [
    #     [0, 1, 2, 2, 1],
    #     [1, 0, 1, 2, 2],
    #     [2, 1, 0, 1, 2],
    #     [2, 2, 1, 0, 1],
    #     [1, 2, 2, 1, 0]
    # ]
    # n = len(mat)
    # mmas = MMAS(mat, 1/n, 1/(n**2), 1 - 1/n, 1, 0, 5)
    parser = ArgumentParser()
    parser.add_argument("-f", "--tsp_file", required=True)
    parser.add_argument("--no-plot", action='store_true')
    parser.add_argument("--notify", action='store_true')
    parser.add_argument("-g", "--goal", default=0)

    args = parser.parse_args()
    main(args)
