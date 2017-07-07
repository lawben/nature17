import os
from argparse import ArgumentParser
from itertools import product

from mmas import MMAS
import parser
from plot_tsp import TspPlotter
from parallel import run_parallel


def notify(msg):
    os.system("ntfy -b telegram send '{}'".format(msg))


def run_single(args, data_file, tour_file):
    solver = MMAS.of(data_file, tour_file, not args.no_plot, args.goal)
    tsp_res = solver.run()

    outputs = ["Tour: " + tsp_res.str_tour,
               "Score: " + str(tsp_res.result),
               "Iterations: " + str(tsp_res.iterations)]
    print("\n".join(outputs))

    if args.notify:
        message = ("Goal Deviation of {0:.0f}% reached for file {1:s} after"
                   "{2:0d} iterations\n")
        notify(message.format(args.goal, data_file, tsp_res.iterations))


def main(args):
    print("\nWelcome to ANT WORLD!")
    print("=====================\n")

    # Run in parallel
    if args.parallel:
        return run_parallel(args.tsp_file, args.iterations)

    data_file = args.tsp_file
    goal = float(args.goal)
    tour_file = data_file[:-4] + ".opt"
    for i in range(args.iterations):
        run_single(args, data_file, tour_file)


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("-f", "--tsp_file", required=True)
    parser.add_argument("--no-plot", action='store_true')
    parser.add_argument("--notify", action='store_true')
    parser.add_argument("-g", "--goal", default=0, type=int)
    parser.add_argument("--parallel", action="store_true")
    parser.add_argument("-i", "--iterations", default=5, type=int)

    args = parser.parse_args()
    main(args)
