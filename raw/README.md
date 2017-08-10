# Creating .raw files

## High-level description

This pipeline takes the `*.langsplit.xz` files as input. Note that each crawl from CommonCrawl is usually split into 100 different shards. 
However, this number is not necessarily consistent among all crawls (e.g. sometimes it might be 98). Each of those 100 different shards is in turn split into 
several hundred files. For each of these files we have one `.langsplit.xz` file. 

The script `collect_monolingual.sh` takes as input the directory name of one shard and reads all the `.langsplit.xz` files in that directory and splits them 
according to language. The second argument of this script is the output directory. For each language `collect_monolingual.sh` writes a files with the name 
`text.${language}.gz` to the output directory.

Now since `collect_monolingual.sh` is called on each of the 100 shards separately we still have to concatenate all the different `text.${language}.gz` files 
into one big `${language}.raw.xz` file. This is done with the `create_raw.sh` script. There is a separate `create_raw_en.sh` since we want to create 100 raw files
for English because a single raw file for English would be too large.

## Running the pipeline

```bash
ls * | parallel ./collect_monolingual.sh {} {}
```

```bash
cat language.codes | parallel $crawl_dir $out_dir {}
```
