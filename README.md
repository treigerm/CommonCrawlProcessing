# CommonCrawlProcessing

## Contents

- `download`, `raw`, `deduped`: Contain scripts for downloading, creating `.raw.xz` and creating `.deduped.xz` files, respectively. Largely they are based on Christian's pipeline.
- `s3`: Contains scripts for uploading the local CommonCrawl data to AWS.
- `precc`: Is a command line application to which automates the CommonCrawl processing pipeline. It is a wrapper around several scripts which can also be run separately.
- `language_lists`: Files which simply contain a list of language codes. They are used extensively in the pipeline.
- `LOCATIONS.md`: Contains information on where the CommonCrawl data is located on Valhalla.
- `TODO`: List of things that I did not manage to finish.
