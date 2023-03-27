import argparse
import numpy as np
import pandas as pd
import umap


def main(embeddings, output_2d, output_5d, sep, n_neighbors=15, n_components=5, metric='cosine'):
    embeddings = pd.read_csv(embeddings, sep=sep).to_numpy()
    
    umap_2d = umap.UMAP(n_neighbors=n_neighbors, 
                                n_components=2, 
                                metric=metric).fit_transform(embeddings)
    umap_2d = pd.DataFrame(umap_2d)
    umap_2d.to_csv(output_2d, sep=sep, index=False) 

    umap_5d = umap.UMAP(n_neighbors=n_neighbors, 
                                n_components=5, 
                                metric=metric).fit_transform(embeddings)
    umap_5d = pd.DataFrame(umap_5d)
    umap_5d.to_csv(output_5d, sep=sep, index=False) 


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", 
                        help="Filepath for the sentence embeddings.")
    parser.add_argument("--output-2d",
                         help="Filepath for the 2d umap embeddings.")
    parser.add_argument("--output-5d",
                        help="Filepath for the 5d umap embeddings.")
    parser.add_argument("--sep", default="\t", help="Delimiter for the input table")
    args = parser.parse_args()

    main(embeddings=args.input,
         output_2d=args.output_2d, output_5d=args.output_5d,
         sep=args.sep)

