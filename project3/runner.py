from argparse import ArgumentParser
import os

from mmas import MMAS
from parallel import run_parallel, notify


def run_single(args, data_file, tour_file=None, opt=None):
    solver = MMAS.of(data_file, tour_file=tour_file, opt=opt,
                     use_plotter=not args.no_plot, goal=args.goal)
    tsp_res = solver.run()

    if args.output is not None:
        line = tsp_res.to_csv()
        with open(args.output, 'a') as f:
            f.write(line)

    outputs = ["Tour: " + tsp_res.str_tour,
               "Score: " + str(tsp_res.result),
               "Iterations: " + str(tsp_res.iterations)]
    print("\n".join(outputs))

    if args.notify:
        message = ("Goal Deviation of {0:.0f}% reached for file {1:s} after "
                   "{2:0d} iterations")
        notify(message.format(args.goal, data_file, tsp_res.iterations))


def print_ant():
    ant = """
   \       /
    \     /
     \.-./
    (o\^/o)  _   _   _     __
     ./ \.\ ( )-( )-( ) .-'  '-.
      {-} \(//  ||   \\/ (   )) '-.-|
           //-__||__.-\\.       .-'-|
          (/    ()     \)'-._.-'
          ||    |)      \\
          ('    ('       ')
"""
    print(ant)


def main(args):
    print("\nWelcome to ANT WORLD!")
    print("=====================\n")
    print("")
    print_ant()

    # Run in parallel
    if args.parallel:
        notify_fn = notify if args.notify else print
        config = {
            'goal': args.goal,
        }

        if args.opt is not None:
            config['opt'] = args.opt

        return run_parallel(args.tsp_file, args.iterations, notify_fn, config)

    data_file = args.tsp_file
    tour_file = data_file[:-4] + ".opt"
    for i in range(args.iterations):
        if args.opt is not None:
            run_single(args, data_file, opt=args.opt)
        elif os.path.isfile(tour_file):
            run_single(args, data_file, tour_file=tour_file)
        else:
            raise 'Must provide opt file or optimal value'


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("-f", "--tsp_file", required=True)
    parser.add_argument("--no-plot", action='store_true')
    parser.add_argument("--notify", action='store_true')
    parser.add_argument("-g", "--goal", default=0, type=int)
    parser.add_argument("--parallel", action="store_true")
    parser.add_argument("-i", "--iterations", default=1, type=int)
    parser.add_argument("--opt",  type=int)
    parser.add_argument("-o", "--output")

    args = parser.parse_args()
    main(args)
