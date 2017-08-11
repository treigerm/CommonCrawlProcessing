# Locations of data

## /fs/zisa0/commoncrawl

- 2015_27 raw non-english
- 2016_30 raw non-english
- 2017_17 experiments with extracting parallel text:
  * `/fs/zisa0/commoncrawl/2017_17/db`: CommonCrawl Index DB as described [here](https://github.com/ModernMT/DataCollection/blob/master/metadata/metadata.md).
  * `/fs/zisa0/commoncrawl/2017_17/baseline`: Files for running the [ModernMT baseline](https://github.com/ModernMT/DataCollection/blob/master/baseline/baseline.md) for parallel corpus extraction. It contains sentence aligned text for `lv-en` all other language pairs are only partially finished.
  * `/fs/zisa0/commoncrawl/2017_17/lsi`: Results of running Ulrich Germann's [LSI](http://aclweb.org/anthology/W/W16/W16-2368.pdf).

## /fs/freyja0/commoncrawl

- 2015_06 raw non-english
- 2015_27 langsplit files
- 2015_30 langsplit files
- 2017_17 langsplit files

## /fs/mimir0/commoncrawl

- 2015_06 english raw
- 2015_11, 2015_14, 2015_18, 2015_22, 2015_27, 2015_27, 2015_32, 2015_35, 2015_40, 2015_48, 2016_50, 2017_17 all raw

## /fs/nas/eikthyrnir0/tim/cc

- 2015_11, 2015_14 english raw
- deduped files for ar, cs, de, es, fr, it, pl, ru

## /fs/meili0/tim/commoncrawl

- 2015_06 sharded English raw data to feed into the deduper as described in [here](https://github.com/treigerm/CommonCrawlProcessing/tree/master/deduped)

## /fs/nas/heithrun0/commoncrawl/langsplit

- langsplit files for all crawls from 2013_20 up to 2015_48 and for 2016_50
- some scripts and files from Christian which seem to be related to the parallel corpus extraction

## /fs/vili0/buck/cc/langsplit2/raw

- non-english raw files for all 2014 crawls

## /fs/vili0/buck/cc/langsplit2 and /fs/vili0/buck/cc/langsplit

- temporary data between the langsplit files and the raw files for 2014 and 2015 crawls, potential candidate for deletion

## /fs/vili0/www/data.statmt.org/ngrams

- home directory of the "data.statmt.org/ngrams" website, contains symbolic links to old raw data

## /fs/gna0/buck/cc/db

- contains RocksDB Index data for all crawls from 2012 to 2015_40 + 2016_50; used in the parallel corpus extraction pipeline

