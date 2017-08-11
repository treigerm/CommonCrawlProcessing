# Deduping .raw files

## Installation

You will have to install Kenneth Heafield's [preprocessing tools](github.com/treigerm/preprocess) (this is a fork). To run the scripts 
locally you will have to change some variables inside the scripts.

## Dedupe

Deduping is done by using the `commoncrawl_dedupe` executable from Kenneth Heafield's [preprocessing tools](github.com/treigerm/preprocess) 
(this is a fork). The script `dedupe.sh` is simply a wrapper for it. The deduper uses an hash table to detect the duplicates. By saving the hash table
to disk we can avoid reading and decompressing the previous deduped files. The `commoncrawl_dedupe_save_table` executable makes this possible.

## Shard and dedupe

If the all of the raw data of one language is too big to fit into memory we have to shard the raw into multiple files. This is usually done with English.
Before the sharding we do some minor processing of the raw data which removes lines with the document delimiter hash (df6fa1abb58549287111ba8d776733e9), 
strips leading and trailing white space and removes lines with invalid UTF-8.

## Running the scripts

I indicated which executable from the preprocessing tools each script uses.

### Deduping without sharding

Uses: `commoncrawl_dedupe`

Let's assume that all the raw files you want to dedupe are in `/path/to/raw` and are named `${language_code}.raw.2017_17.xz`. You want to store the new
deduped files at `/path/to/deduped` and each language already has a deduped file with the name `/path/to/${language_code}.deduped.xz`. Then deduping
all languages in parallel can be done with:
```bash
cat language.codes | parallel ./dedupe.sh /path/to/raw/{}.2017_17.raw.xz /path/to/deduped {} /path/to/{}.deduped.xz
```
`language.codes` is as in [here](https://github.com/treigerm/CommonCrawlProcessing/blob/master/language_lists/languages.non_en). 
The command also works if some languages don't already have a deduplicated file at `/path/to/${language_code}.deduped.xz`.

### Deduping without sharding and with saving the hash table to disk 

Uses: `commoncrawl_deduped_save_table`

Assuming we have the same setup as in the previous section and you want to store the hash table at `/path/to/out_table`. Then you can run:
```bash
cat language.codes | \
parallel ./dedupe_hash_table.sh /path/to/raw/{}.raw.2017_17.xz /path/to/deduped {} /dev/null /path/to/table1 /path/to/{}.deduped.xz
```

Then you can reuse the hash table to dedupe the next crawl as follows:
```bash
cat language.codes | \
parallel ./dedupe_hash_table.sh /path/to/raw/{}.raw.2017_30.xz /path/to/deduped {} /path/to/table1 /path/to/table2
```


### Deduping with sharding 

Uses: `commoncrawl_dedupe`, `shard_fifo`

<b>NOTE:</b> By default the sharding assumes that we are working on English data and shard into 100 files. However it should be trivial to change 
the script and add the language code as an argument.

Sharding the files:
```bash
./shard_fifo.sh /path/to/raw_files /path/to/fifos
```

Then open a new shell on the same machine and run:
```bash
seq 0 99 | parallel -j100 ./compress_shard.sh {} /path/to/fifos /path/to/shards
```
Here `/path/to/shards` is the output directory. It is important that you start all 100 jobs at once and that all of them are running on the same machine 
otherwise the FIFOs don't work.

Now dedupe the sharded files:
```bash
seq 0 99 | parallel ./dedupe_from_shard.sh {} /path/to/shards /path/to/previous_deduped_files /path/to/outdir
```

### Creating offset files

The deduper outputs only new lines that it sees. This means we want to concat the output of the deduper to the already existing deduped file and record 
the offset. This can be done with `update_deduped_data.sh`.
```bash
./update_deduped_data.sh ${old_deduped_file} ${new_deduped_file} ${offset_file} ${crawl_id}
```
