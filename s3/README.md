# Usage

Upload deduped file to `s3://web-language-models/ngrams/${lang}/deduped`. This deletes any previous deduped file.
```
./upload_deduped.sh ${lang}.deduped.xz
```

Upload raw file to `s3://web-language-models/ngrams/${lang}/raw`.
```
./upload_raw.sh ${lang}.2017_17.raw.xz
```

Copy object on S3 (allows for multipart copy which `s3cmd` does not support).
```
./s3_copy.py -sourcekey ngrams/de/raw/source.xz -targetkey ngrams/de/raw/target.xz
```
