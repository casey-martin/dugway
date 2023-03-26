import pandas as pd
from collections import Counter
from string import punctuation

nlp = spacy.load("en_core_web_lg")
df = pd.read_csv('./data/dugway_table.tsv', sep='\t')

