from Bio import SeqIO
import pandas as pd
import pickle

new_embl_records = SeqIO.parse("./download/miRNA.dat", "embl")
records = [{'name': record.name, 'description': record.description,
            'AC': record.id, 'SQ': pickle.dumps(record.seq),
            'molecule': record.annotations['molecule_type'],
            'division': record.annotations['data_file_division']} 
           for record in new_embl_records]
df = pd.DataFrame.from_records(records)
df.to_parquet("./brick/miRNA.dat.parquet")