# S3 File Structure

In general we have a seperate directory for each language, which in turn contains up to three subdirectories:
```
s3://web-language-models/ngrams/${lang}/deduped
s3://web-language-models/ngrams/${lang}/raw
s3://web-language-models/ngrams/${lang}/lm
```

The deduped folder contains the deduped file of that language with the corresponding offset file. The raw folder contains 
the `.raw` files for each individual crawl. The lm folder contains the language model, if there exists one.

## Irregularities

The English language model is located at `s3://web-language-models/ngrams/lm/en.trie.xz` which is an artifact of the old 
file structure. All attempts to copy the language model on AWS failed due to the size of the model. We might need to reupload 
it if we want to change its location.
