from mlp_conf import MLP_conf


def main():
    mlp_conf = MLP_conf(1, 1, 100, [1, 2, 3, 4, 5], [0, 1, 3])
    mlp_conf.start()


if __name__ == "__main__":
    main()
