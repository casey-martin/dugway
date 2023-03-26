import argparse
from sentence_transformers import SentenceTransformer
import pandas as pd
import pickle

def main(doc_table, output, sep):
    model = SentenceTransformer('all-MiniLM-L6-v2')
    df = pd.read_csv(doc_table, sep=sep)

    sentences = df['Title'].apply(str).to_list()
    #embeddings = [model.encode(i) for i in sentences]
    embeddings = model.encode(sentences)

    embeddings = pd.DataFrame(embeddings)
    embeddings.to_csv(output, sep=sep, index=False)
    #Store sentences & embeddings on disc
    # 'embeddings.pkl'
    # with open(output, "wb") as fOut:
    #    pickle.dump({'sentences': sentences, 'embeddings': embeddings}, fOut, protocol=pickle.HIGHEST_PROTOCOL)

    
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="Filepath for the tabulated corpus. Must have a 'Title' column.")
    parser.add_argument("--output", default="./data/embeddings.pkl", help="Filepath for the pickled embeddings")
    parser.add_argument("--sep", default="\t", help="Delimiter for the input table")
    args = parser.parse_args()

    main(doc_table=args.input, output=args.output, sep=args.sep)
