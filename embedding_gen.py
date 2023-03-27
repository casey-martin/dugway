import argparse
from sentence_transformers import SentenceTransformer
import pandas as pd

def main(doc_table, output, sep):
    model = SentenceTransformer('all-MiniLM-L6-v2')
    df = pd.read_csv(doc_table, sep=sep)

    sentences = df['Title'].apply(str).to_list()
    embeddings = model.encode(sentences)

    embeddings = pd.DataFrame(embeddings)
    embeddings.to_csv(output, sep=sep, index=False)

    
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="Filepath for the tabulated corpus. Must have a 'Title' column.")
    parser.add_argument("--output", help="Filepath for the pickled embeddings")
    parser.add_argument("--sep", default="\t", help="Delimiter for the input table")
    args = parser.parse_args()

    main(doc_table=args.input, output=args.output, sep=args.sep)
