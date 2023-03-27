import argparse
import numpy as np
import pandas as pd
import umap


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", 
                        help="Filepath for the sentence embeddings.")
    parser.add_argument("--output-2d",
                         help="Filepath for the 2d umap embeddings.")
    parser.add_argument("--output-5d",
                        help="Filepath for the 5d umap embeddings.")
    parser.add_argument("--sep", default="\t", help="Delimiter for the input table")
    parser.add_argument("--n-neighbors", default=15, help="Number of neighbors")
    parser.add_argument("--metric", default="cosine", help="Similarity metric")
    args = parser.parse_args()


    embeddings = pd.read_csv(args.input, sep=args.sep).to_numpy()
    
    umap_2d = umap.UMAP(n_neighbors=args.n_neighbors, 
                                n_components=2, 
                                metric=args.metric).fit_transform(embeddings)
    umap_2d = pd.DataFrame(umap_2d)
    umap_2d.to_csv(args.output_2d, sep=args.sep, index=False) 

    umap_5d = umap.UMAP(n_neighbors=args.n_neighbors, 
                                n_components=5, 
                                metric=args.metric).fit_transform(embeddings)
    umap_5d = pd.DataFrame(umap_5d)
    umap_5d.to_csv(args.output_5d, sep=args.sep, index=False) 


if __name__ == '__main__':
    main()
