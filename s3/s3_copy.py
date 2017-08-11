#!/usr/bin/env python

import argparse
import boto3
from boto3.s3.transfer import TransferConfig

parser = argparse.ArgumentParser()
parser.add_argument('-chunksize', type=int, default=1000, help='size of each part in MB')
parser.add_argument('-sourcekey', help='source object location')
parser.add_argument('-targetkey', help='location to copy to')
args = parser.parse_args()

# Convert chunksize from MB to bytes
chunksize = args.chunksize * 1000000
transferConfig = TransferConfig(multipart_threshold=chunksize, multipart_chunksize=chunksize)

s3 = boto3.resource('s3')
copy_source = {
    'Bucket': 'web-language-models',
    'Key': args.sourcekey
}
s3.meta.client.copy(copy_source, 'web-language-models', args.targetkey, Config=transferConfig)
