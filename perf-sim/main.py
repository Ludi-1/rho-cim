"""
Main script to instantiate configurations
"""

from conf import Conf
from params import param_dict
import os


def main():
    if not os.path.exists("./output"):
        os.mkdir("./output")
    f = open("./output/log.txt", "w")
    conf = Conf(param_dict, f)
    conf.start()


if __name__ == "__main__":
    main()
