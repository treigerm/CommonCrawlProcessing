# Deduping .raw files

## Dedupe


## Shard and dedupe

If the all of the raw data of one language is too big to fit into memory we have to shard the raw into multiple files. This is usually done with English.
Before the sharding we do some minor processing of the raw data which removes lines with the document delimiter hash (df6fa1abb58549287111ba8d776733e9), 
strip leading and trailing white space and remove lines with invalid UTF-8.
