<!---
TODO: Explain general process.
TODO: Explain config file.
TODO: Documentation in single scripts on how to use them individually.
--->

# Precc

A tool to extract monolingual data from the CommonCrawl corpus.

<!---
General workflow:
1. run "precc download"
2. run "precc create_raw" (concats files from part 1)
3. run "precc dedupe"
(4. update deduped file)

Filetypes:
- Raw files
- Deduped files
--->

## Setup folder structure

```
./precc --download-dir /path/to/downloads --raw-dir /path/to/raw --deduped-dir /path/to/deduped --crawl-url http://crawl.com --batch-size 25 setup
```

## Download data

```
./precc --download-dir /path/to/downloads download
```

## Create raw data

```
./precc --download-dir /path/to/downloads --raw-dir /path/to/raw --languagesfile languages --crawl-id 2017_17 create_raw
```

## Create deduped files for each language

<!-- TODO: Mention hash table and previous deduped dir option -->
```
./precc --deduped-dir /path/to/deduped --raw-dir /path/to/raw --languagesfile languages --crawl-id 2017_17 dedupe
```

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

## Parallel

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

