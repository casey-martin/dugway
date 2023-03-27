import argparse
import pandas as pd
import hdbscan

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', help='Filepath to umap embeddings.')
    parser.add_argument('--output', help='Filepath to cluster labels')
    parser.add_argument('--min-cluster-size',
                         default=15,
                         help='Minimum size for clusters.')
    parser.add_argument('--metric',
                         default='euclidean',
                         help='Distance metric.')
    parser.add_argument('--cluster-selection-method',
                         default='eom',
                         help='Methods for selecting clusters.')
    parser.add_argument('--sep',
                         default='\t',
                         help='Delimiter for output file.')
    args = parser.parse_args()

    umap_embeddings = pd.read_table(args.input)
    cluster = hdbscan.HDBSCAN(min_cluster_size=args.min_cluster_size,
                              metric=args.metric,                      
                              cluster_selection_method=args.cluster_selection_method).fit(umap_embeddings)
    cluster = pd.DataFrame(cluster.labels_)
    cluster[0] = 'cluster'
    cluster.to_csv(args.output, sep=args.sep, index = False)

if __name__ == '__main__':
    main() 
