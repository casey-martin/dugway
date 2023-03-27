import argparse
from unstructured.partition.auto import partition
import pandas as pd

COL_NAMES = ['CBRNIAC Number:', 'AD Number:', 'Site Holding:', 'Title:', 'Author(s):', 'Report Number:',
             'Publish Date:'  , 'Corp Author Name:', 'Distribution Statement:', 
             'Document Classification:']

def elements2df(elements):
    out_elements = []
    for el in elements:
        for col in COL_NAMES:
            if el.text.startswith(col):
                out_elements.append(el.text)

    out_df = []
    tmp_list = [out_elements[0]]
    for el in out_elements[1:]:
        if el.startswith(COL_NAMES[0]):
            out_df.append(tmp_list)
            tmp_list = []
        tmp_list.append(el)
    out_df.append(tmp_list)

    out_df = pd.DataFrame(out_df)
    out_df.columns = [i[:-1] for i in COL_NAMES]

    for i in range(len(COL_NAMES)):
        col = out_df.columns[i]
        out_df[col] = out_df[col].str[len(COL_NAMES[i]):]
    
    out_df.columns = out_df.columns.str.replace(' ', '_')
    out_df = out_df.applymap(lambda x: x.lstrip())

    return(out_df)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="Document filepath")
    parser.add_argument("--output", help="Output filepath")
    parser.add_argument("--sep", default='\t', help="Output delimiter")
    args = parser.parse_args()
   
    elements = partition(filename=args.input)
    df = elements2df(elements)
    df.to_csv(args.output, sep=args.sep, index=False)
    
if __name__ == '__main__':
    main()
