import os
import parser
from datetime import datetime
from multiprocessing import Pool, Queue, Lock, cpu_count
from queue import Empty as QEmpty

import numpy as np
from mmas import MMAS

FILE_DIR = os.path.dirname(__file__)
RESULT_DIR = os.path.join(FILE_DIR, "results")


def notify(msg):
    os.system("ntfy -b telegram send '{}'".format(msg))


def setup_run(tsp_instance):
    run_time = datetime.now().strftime("%Y%m%d-%H%M%S")
    res_dir = os.path.join(RESULT_DIR, tsp_instance)
    res_filename = "{}.csv".format(run_time)
    res_file = os.path.join(res_dir, res_filename)

    os.makedirs(res_dir, exist_ok=True)
    return res_file


def parse_files(files):
    file_dir = os.path.dirname(__file__)

    pairs = []
    for f in files:
        if not f.endswith(".tsp"):
            print("File: %s isn't a valid TSP file. Skipping..." % f)
            continue

        instance_path = os.path.join(file_dir, os.path.dirname(f))
        instance_name = os.path.basename(f)[:-4]
        opt_file = os.path.join(instance_path, instance_name + ".opt")
        tsp_file = os.path.join(file_dir, f)
        instance_files = (tsp_file, opt_file)
        pairs.append((instance_name, instance_files))

    return pairs


def parse_data_dir(data_dir):
    file_dir = os.path.dirname(__file__)
    inst_files = []
    for (dirpath, _, files) in os.walk(data_dir):
        for f in sorted(files):
            if f.endswith(".tsp"):
                tsp_file_path = os.path.join(file_dir, dirpath, f)
                inst_files.append(tsp_file_path)

    return parse_files(inst_files)


def get_instance_files(data_path):
    if "," in data_path:
        files = data_path.split(",")
        return parse_files(files)

    if os.path.isfile(data_path):
        return parse_files([data_path])

    if os.path.isdir(data_path):
        return parse_data_dir(data_path)

    raise ValueError("Need one of data_dir or file(s)!")


def parallel_setup(instances, iterations, params, arg_list):
    queue = Queue()
    exec_number = 0
    for inst, files in instances:
        for param in params:
            for _ in range(iterations):
                run_config = (exec_number, inst, files, param, arg_list)
                queue.put(run_config)
            exec_number += 1

    return queue


def parallel_runner(queue, result_files, locks):
    log_fmt = "{} - [{}] - OPT: {} - RESULT: {} - ITERATIONS: {} - GOAL: {}%"
    while True:
        try:
            config = queue.get(block=False, timeout=1)
        except QEmpty:
            return

        exec_number, inst, files, params, arg_list = config

        raw_matrix = parser.parse(files[0])
        opt_tour = parser.parse_tour(files[1])
        opt = parser.get_opt(opt_tour, raw_matrix)

        goal = int(arg_list['goal'])
        tsp_file = arg_list['tsp_file']

        # Make sure this is always a float matrix
        matrix = np.asmatrix(raw_matrix, dtype=np.float32)
        mmas = MMAS(matrix, opt, goal=goal, **params)
        res = mmas.run()
        res.exec_number = exec_number

        log = log_fmt.format(datetime.now(), inst, opt, res.result,
                             res.iterations, res.goal)

        res_line = res.to_csv()
        res_file = result_files[inst]
        lock = locks[inst]

        lock.acquire()
        with open(res_file, "a") as res_f:
            res_f.write(res_line)
        lock.release()

        should_notify = arg_list['notify']
        if should_notify is not None and should_notify:
            message = "Goal Deviation of {0:.0f}% reached for {1:s} after {2:0d} iterations\n"
            notify(message.format(goal, tsp_file, res.iterations))


def run_parallel(data_path, params=None, args=None):
    if params is None:
        params = [{}]
    arg_list = vars(args)

    instances = get_instance_files(data_path)

    result_files = {inst: setup_run(inst) for inst, _ in instances}
    locks = {inst: Lock() for inst, _ in instances}

    instance_queue = parallel_setup(instances, 10, params, arg_list)

    num_processes = cpu_count()
    pool = Pool(num_processes, parallel_runner,
                (instance_queue, result_files, locks))

    pool.close()
    pool.join()
