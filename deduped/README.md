# Deduping .raw files

## Dedupe

Deduping is done by using the `commoncrawl_dedupe` executable from [github.com/kpu/preprocess](github.com/kpu/preprocess). The script
`dedupe.sh` is simply a wrapper for it.

## Shard and dedupe

If the all of the raw data of one language is too big to fit into memory we have to shard the raw into multiple files. This is usually done with English.
Before the sharding we do some minor processing of the raw data which removes lines with the document delimiter hash (df6fa1abb58549287111ba8d776733e9), 
strip leading and trailing white space and remove lines with invalid UTF-8.

## Running the scripts

### Deduping without sharding

Let's assume that all the raw files you want to dedupe are in `/path/to/raw` and are named `${language_code}.raw.2017_17.xz`. You want to store the new
deduped files at `/path/to/deduped` and each language already has a deduped file with the name `/path/to/${language_code}.deduped.xz`. Then deduping
all languages in parallel can be done with:
```bash
cat language.codes | parallel ./dedupe.sh /path/to/raw/{}.2017_17.raw.xz /path/to/deduped {} /path/to/{}.deduped.xz
```
Here `language.codes` is a a list of the language codes that we want to deduped separated by newline. Note that the command also works if some languages
don't already have a file at `/path/to/${language_code}.deduped.xz`.

### Deduping with sharding

<b>NOTE:</b> By default the sharding assumes that we are working on English data and shard into 100 files. However it should be trivial to change the script and 
add the language code as an argument.

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

