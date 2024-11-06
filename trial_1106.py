# %%
pip install thefuzz python-Levenshtein

# %%
pip install tqdm

# %%
import pandas as pd
from thefuzz import fuzz
from thefuzz import process
import numpy as np
from tqdm import tqdm

# %%

def memory_efficient_fuzzy_merge(file1_path, file2_path, output_path, key1, key2, 
                               chunk_size=500, threshold=80):
    """
    Memory-efficient fuzzy matching and merging for large datasets
    
    Parameters:
    file1_path (str): Path to first dta file
    file2_path (str): Path to second dta file
    output_path (str): Path where merged file will be saved
    key1 (str): Column name in first dataset containing bank IDs
    key2 (str): Column name in second dataset containing bank IDs
    chunk_size (int): Number of rows to process at once
    threshold (int): Minimum similarity score (0-100) to consider a match
    """
    # First, create a mapping dictionary using only unique IDs
    print("Reading unique IDs from second file...")
    df2_ids = pd.read_stata(file2_path, columns=[key2])[key2].unique()
    df2_ids = pd.Series(df2_ids).astype(str)
    
    print("Creating mapping dictionary...")
    # Process df1 in chunks to create mapping
    mapping = {}
    chunk_iterator = pd.read_stata(file1_path, chunksize=chunk_size)
    
    for chunk in tqdm(chunk_iterator):
        chunk_ids = chunk[key1].astype(str).unique()
        for id1 in chunk_ids:
            if id1 not in mapping:  # Only process if we haven't seen this ID before
                match = process.extractOne(id1, df2_ids, scorer=fuzz.ratio)
                if match and match[1] >= threshold:
                    mapping[id1] = match[0]
    
    print("Processing and saving merged data...")
    # Now process the actual merge in chunks
    first_chunk = True
    chunk_iterator = pd.read_stata(file1_path, chunksize=chunk_size)
    
    for chunk in tqdm(chunk_iterator):
        # Process chunk
        chunk[key1] = chunk[key1].astype(str)
        chunk['matched_id'] = chunk[key1].map(mapping)
        
        # Read only necessary rows from df2
        matched_ids = chunk['matched_id'].dropna().unique()
        if len(matched_ids) > 0:
            df2_chunk = pd.read_stata(file2_path)
            df2_chunk = df2_chunk[df2_chunk[key2].astype(str).isin(matched_ids)]
            
            # Merge
            merged_chunk = pd.merge(
                chunk,
                df2_chunk,
                left_on='matched_id',
                right_on=key2,
                how='left'
            )
            
            # Remove temporary column
            merged_chunk = merged_chunk.drop('matched_id', axis=1)
            
            # Save
            if first_chunk:
                merged_chunk.to_stata(output_path)
                first_chunk = False
            else:
                merged_chunk.to_stata(output_path, append=True)
        
        # Clear memory
        del chunk
        if 'df2_chunk' in locals():
            del df2_chunk
        if 'merged_chunk' in locals():
            del merged_chunk

# %%
memory_efficient_fuzzy_merge(
    file1_path='/Volumes/aae/users/zchen2365/update_uniqueid.dta',
    file2_path='/Volumes/aae/users/zchen2365/combined_necessary_uniqueid.dta',
    output_path='/Volumes/aae/users/zchen2365/python/merged_file.dta',
    key1='bank_id',
    key2='bank_id',
    chunk_size=500,  # Adjust this based on your available memory
    threshold=80
)

# %%



