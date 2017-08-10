#!/usr/bin/env python

import sys
import boto3
from boto3.s3.transfer import TransferConfig

for line in sys.stdin:
    link = line.split()[-1]
    if ".xz" in link:
        index = link.split('/')[-1].split('.')[1]
        sourcekey = "ngrams/deduped/en/en.{index}.deduped.xz".format(index=index)
        targetkey = "ngrams/en/deduped/en.{index}.deduped.xz".format(index=index)

        print("Copy from {} to {}..".format(sourcekey, targetkey))
        chunksize = 1000 * 1000000
        transferConfig = TransferConfig(multipart_threshold=chunksize, multipart_chunksize=chunksize)

        s3 = boto3.resource('s3')
        copy_source = {
            'Bucket': 'web-language-models',
            'Key': sourcekey
        }
        s3.meta.client.copy(copy_source, 'web-language-models', targetkey, Config=transferConfig)

