#!/usr/bin/python

from algorithm.SRClustering import SRClustering


def main():
    folder_path = '/home/marcvaldivia/HDD/EDUB-Seg/images/'
    folder_name = 'Subject1_Set1'
    GT_path = ''

    sr_clustering = SRClustering(folder_path, folder_name)
    result = sr_clustering.execute()
    return result


if __name__ == '__main__':
    main()
