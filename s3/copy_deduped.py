#!/usr/bin/env python

import sys
import boto3
from boto3.s3.transfer import TransferConfig

for line in sys.stdin:
    link = line.split()[-1]
    if ".xz" in link:
        lang = link.split('/')[-1].split('.')[0]
        sourcekey = "ngrams/deduped/{lang}.deduped.xz".format(lang=lang)
        targetkey = "ngrams/{lang}/deduped/{lang}.deduped.xz".format(lang=lang)

        print("Copy from {} to {}..".format(sourcekey, targetkey))
        chunksize = 1000 * 1000000
        transferConfig = TransferConfig(multipart_threshold=chunksize, multipart_chunksize=chunksize)

        s3 = boto3.resource('s3')
        copy_source = {
            'Bucket': 'web-language-models',
            'Key': sourcekey
        }
        s3.meta.client.copy(copy_source, 'web-language-models', targetkey, Config=transferConfig)

