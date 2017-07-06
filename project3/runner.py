import os
from argparse import ArgumentParser
from itertools import product

from mmas import MMAS
import parser
from plot_tsp import TspPlotter
from parallel import run_parallel


def notify(msg):
    os.system("ntfy -b telegram send '{}'".format(msg))


def main(args):
    # Run in parallel
    if args.parallel:
        run_parallel(args.tsp_file)

    data_file = args.tsp_file
    should_notify = args.notify
    goal = float(args.goal)
    tour_file = data_file[:-4] + ".opt"

    solver = MMAS.of(data_file, tour_file, not args.no_plot, goal)
    tsp_res = solver.run()

    outputs = ["Tour: " + tsp_res.str_tour,
               "Score: " + str(tsp_res.result),
               "Iterations: " + str(tsp_res.iterations)]
    print("\n".join(outputs))

    if should_notify:
        message = ("Goal Deviation of {0:.0f}% reached for file {1:s} after"
                   "{2:0d} iterations\n")
        notify(message.format(goal, data_file, tsp_res.iterations))


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("-f", "--tsp_file", required=True)
    parser.add_argument("--no-plot", action='store_true')
    parser.add_argument("--notify", action='store_true')
    parser.add_argument("-g", "--goal", default=0)
    parser.add_argument("--parallel", action="store_true")

    args = parser.parse_args()
    main(args)
