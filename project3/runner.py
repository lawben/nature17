from argparse import ArgumentParser

from mmas import MMAS


def main(args):
    data_file = args.tsp_file
    tour_file = data_file[:-4] + ".opt"
    mmas = MMAS.of(data_file, tour_file, not args.no_plot)
    tour, value, iters = mmas.run()

    print("Tour: ", tour)
    print("Score: ", value)
    print("Iterations: ", iters)


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

    args = parser.parse_args()
    main(args)
