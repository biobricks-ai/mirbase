from Bio import SeqIO
import pandas as pd

new_embl_records = SeqIO.parse("./download/miRNA.dat", "embl")
# prev_embl_records = SeqIO.parse("./download/miRNA.dead", "embl")
records = [{'name': record.name, 'description': record.description} for record in new_embl_records]
# old_records = [{'name': record.name, 'description': record.description} for record in prev_embl_records]
df = pd.DataFrame.from_records(records)
# dead = pd.DataFrame.from_records(old_records)
df.to_parquet("./brick/miRNA.parquet")
# df.to_parquet("./brick/miRNA_dead.parquet")