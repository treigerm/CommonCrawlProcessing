# Precc

A tool to extract monolingual data from the CommonCrawl corpus. `precc` stands for preprocessing CommonCrawl. The main `precc` script
is a wrapper around several scripts which can be also be used on their own.

## Dependencies

Some of the scripts depend on binaries that don't come with this repository. You will need the `commoncrawl_dedupe_save_table` binary from Kenneth 
Heafield's [preprocessing tools](https://github.com/treigerm/preprocess) (this is a fork) and the `langsplit` executable from [here](https://github.com/christianbuck/mtma_bitext/tree/master/html_convert).
After you compiled both binaries place a copy of them in the `lib` folder of this project.

## General process

CommonCrawl provides each crawl in the WET format, which for each crawled web page contains the text that was extracted from the HTML. Each crawl
consists of several thousand WET files. Each WET file in turn contains the data for several web pages, many of which might be in different
languages. `precc` can convert these WET files into two different types of files:
- `.raw.xz`: These files contain the same data as the WET files but they are splitted according to language i.e. per crawl there is one `.raw.xz` file for each language. For English there are 100 `.raw.xz` files since the English data is a lot larger then the remaining languages. Documents are delimited by a header which begins with the hash df6fa1abb58549287111ba8d776733e9.
- `.deduped.xz`: These are the result of processing the `.raw.xz` and removing any duplicate lines. There is one `.deduped.xz` file for each language and it grows with each crawl. English, again, is an exception and is sharded into 100 `.deduped.xz` files.

In total there are four steps in our pipeline which are described below.

## 1. Setup folder structure and create batches

```
./precc --download-dir /path/to/downloads --raw-dir /path/to/raw --deduped-dir /path/to/deduped --crawl-url http://crawl.com --batch-size 25 setup
```

### Run standalone script

```
mkdir /path/to/downloads
/path/to/precc/setup.sh /path/to/downloads http:://crawl.com 25
```

## 2. Download data

```
./precc --download-dir /path/to/downloads download
```

### Run standalone script

```
export SCRIPTDIR=/path/to/precc

find "${DOWNLOAD_DIR}" -maxdepth 1 -name "batch.*" -type d | \
parallel --env ${SCRIPTDIR} --sshloginfile nodelist /path/to/precc/downloadsplit.sh
```

## 3. Create raw data

The file `languages` is as in [here](https://github.com/treigerm/CommonCrawlProcessing/blob/master/language_lists/languages.non_en) 
and indicates for which languages we want to create the raw files.

```
./precc --download-dir /path/to/downloads --raw-dir /path/to/raw --languagesfile languages --crawl-id ${crawl_id} create_raw
```

### Run standalone script

```
mkdir /path/to/raw
cat languages | parallel /path/to/precc/concat_raw.sh /path/to/downloads /path/to/raw {} ${crawl_id}
```

Here `${crawl_id}` is the ID given by CommmonCrawl (e.g. 2017_17 for the April 2017 crawl).

## 4. Create deduped files for each language

```
./precc --deduped-dir /path/to/deduped --raw-dir /path/to/raw --languagesfile languages --crawl-id ${crawl_id} dedupe
```

The deduper will save the hash table it uses for the deduping to disk at `/path/to/deduped/hash_table/${language_code}_deduper_hash_table`.
If you want to load the hash table back into memory to dedupe the next file you can pass the option `--hash-table-dir /path/to/deduped/hash_table`.

If you already have deduplicated files name with the convention `${language_code}.deduped.xz`, then you can pass the directory which contains
these files with the option `--previous-deduped-dir /path/to/previous_deduped`.

### Run standalone script

See [here](https://github.com/treigerm/CommonCrawlProcessing/tree/master/deduped).

## The Config file

You can also specify common options in a config file. Normally you want to have a config file for each crawl in which you store the directories which contain your data. All options in the config file have the same name as in the command-line interface except that hyphens are replace by underscores. So a config file for the 2017_17 crawl could look like this:

```
crawl_id=2017_17
download_dir=/path/to/downloads
deduped_dir=/path/to/deduped
raw_dir=/path/to/raw
```

Assuming that you stored the config file at `/path/to/config` then you can use it with the `-c,--config` flag like so:

```
./precc -c /path/to/config setup
```

## GNU Parallel

`precc` makes use of GNU Parallel and allows you to pass options to it. All the GNU Parallel specific options have the same name as their origional and you can look up their function [here](https://www.gnu.org/software/parallel/parallel_tutorial.html). At the moment the following options are available:

```
--progress
-j,--jobs
--sshloginfile
```

Example usage:

```
./precc -c /path/to/config --progress --sshloginfile /path/to/nodelist download
```

