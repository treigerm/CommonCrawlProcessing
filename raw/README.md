# Creating .raw files

## High-level description

This pipeline takes the `*.langsplit.xz` files as input. Note that each crawl from CommonCrawl is usually split into 100 different shards. 
However, this number is not necessarily consistent among all crawls (e.g. sometimes it might be 98). Each of those 100 different shards is 
in turn split into several hundred files. For each of these files we have one `.langsplit.xz` file. 

The script `collect_monolingual.sh` takes as input the directory name of one shard and reads all the `.langsplit.xz` files in that directory 
and splits them according to language. The second argument of this script is the output directory. For each language `collect_monolingual.sh` 
writes a files with the name `text.${language}.gz` to the output directory.

Now since `collect_monolingual.sh` is called on each of the 100 shards separately we still have to concatenate all the different `text.${language}.gz` 
files into one big `${language}.raw.xz` file. This is done with the `create_raw.sh` script. There is a separate `create_raw_en.sh` since we 
want to create 100 raw files for English because a single raw file for English would be too large.

## Running the code

Assuming that all the shards of the crawl are at `/path/to/crawl`:
```bash
cd /path/to/crawl
ls | grep -E '^[0-9]+\.[0-9]{,2}$' | parallel ./collect_monolingual.sh {} {}
```
The regex ensures that we only go through the directories which are a CommonCrawl timestamp.

Collecting all the data from the previous file into one big `.raw.xz` file for each language:
```bash
cat language.codes | parallel ./create_raw.sh /path/to/crawl /path/to/raw {}
```
Here `language.codes` is as in [here](https://github.com/treigerm/CommonCrawlProcessing/blob/master/language_lists/languages.non_en).

To collect the English data:
```
find /path/to/crawl -name "text.en.gz" | parallel ./create_raw_en.sh {} /path/to/raw_en {#}
```
