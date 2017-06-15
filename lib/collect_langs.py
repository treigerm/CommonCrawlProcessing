#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import argparse

magic_number = 'df6fa1abb58549287111ba8d776733e9'

cld2_langcodes = ['en', 'da', 'nl', 'fi', 'fr', 'de', 'iw', 'it',
                  'ja', 'ko', 'no', 'pl', 'pt', 'ru', 'es', 'sv',
                  'zh', 'cs', 'el', 'is', 'lv', 'lt', 'ro', 'hu',
                  'et', 'xxx', 'un', 'bg', 'hr', 'sr', 'ga', 'gl',
                  'tl', 'tr', 'uk', 'hi', 'mk', 'bn', 'id', 'la',
                  'ms', 'ml', 'cy', 'ne', 'te', 'sq', 'ta', 'be',
                  'jw', 'oc', 'ur', 'bh', 'gu', 'th', 'ar', 'ca',
                  'eo', 'eu', 'ia', 'kn', 'pa', 'gd', 'sw', 'sl',
                  'mr', 'mt', 'vi', 'fy', 'sk', 'zh-Hant', 'fo',
                  'su', 'uz', 'am', 'az', 'ka', 'ti', 'fa', 'bs',
                  'si', 'nn', 'xh', 'zu', 'gn', 'st', 'tk', 'ky',
                  'br', 'tw', 'yi', 'so', 'ug', 'ku', 'mn', 'hy',
                  'lo', 'sd', 'rm', 'af', 'lb', 'my', 'km', 'bo',
                  'dv', 'chr', 'syr', 'lif', 'or', 'as', 'co',
                  'ie', 'kk', 'ln', 'mi', 'wo', 'ab', 'aa', 'ay',
                  'ba', 'bi', 'dz', 'fj', 'kl', 'ha', 'ht', 'ik',
                  'iu', 'ks', 'rw', 'mg', 'na', 'om', 'rn', 'sm',
                  'sg', 'sa', 'ss', 'ts', 'tn', 'vo', 'za', 'kha',
                  'sco', 'lg', 'gv', 'sr-ME', 'ak', 'ig', 'mfe',
                  'haw', 'ceb', 'ee', 'gaa', 'blu', 'kri', 'loz',
                  'lua', 'luo', 'new', 'ny', 'os', 'pam', 'nso',
                  'raj', 'crs', 'tum', 've', 'war',  'nr', 'zzb',
                  'zzp', 'zzh', 'tlh', 'zze', 'xx-Zyyy', 'xx-Latn',
                  'xx-Grek', 'xx-Cyrl', 'xx-Armn', 'xx-Hebr',
                  'xx-Arab', 'xx-Syrc', 'xx-Thaa', 'xx-Deva',
                  'xx-Beng', 'xx-Guru', 'xx-Gujr', 'xx-Orya',
                  'xx-Taml', 'xx-Telu', 'xx-Knda', 'xx-Mlym',
                  'xx-Sinh', 'xx-Thai', 'xx-Laoo', 'xx-Tibt',
                  'xx-Mymr', 'xx-Geor', 'xx-Hang', 'xx-Ethi',
                  'xx-Cher', 'xx-Cans', 'xx-Ogam', 'xx-Runr',
                  'xx-Khmr', 'xx-Mong', 'xx-Hira', 'xx-Kana',
                  'xx-Bopo', 'xx-Hani', 'xx-Yiii', 'xx-Ital',
                  'xx-Goth', 'xx-Dsrt', 'xx-Qaai', 'xx-Tglg',
                  'xx-Hano', 'xx-Buhd', 'xx-Tagb', 'xx-Limb',
                  'xx-Tale', 'xx-Linb', 'xx-Ugar', 'xx-Shaw',
                  'xx-Osma', 'xx-Cprt', 'xx-Brai', 'xx-Bugi',
                  'xx-Copt', 'xx-Talu', 'xx-Glag', 'xx-Tfng',
                  'xx-Sylo', 'xx-Xpeo', 'xx-Khar', 'xx-Bali',
                  'xx-Xsux', 'xx-Phnx', 'xx-Phag', 'xx-Nkoo',
                  'xx-Sund', 'xx-Lepc', 'xx-Olck', 'xx-Vaii',
                  'xx-Saur', 'xx-Kali', 'xx-Rjng', 'xx-Lyci',
                  'xx-Cari', 'xx-Lydi', 'xx-Cham', 'xx-Lana',
                  'xx-Tavt', 'xx-Avst', 'xx-Egyp', 'xx-Samr',
                  'xx-Lisu', 'xx-Bamu', 'xx-Java', 'xx-Mtei',
                  'xx-Armi', 'xx-Sarb', 'xx-Prti', 'xx-Phli',
                  'xx-Orkh', 'xx-Kthi', 'xx-Batk', 'xx-Brah',
                  'xx-Mand', 'xx-Cakm', 'xx-Merc', 'xx-Mero',
                  'xx-Plrd', 'xx-Shrd', 'xx-Sora', 'xx-Takr']
cld2_langcodes = [lc.replace('-', '_') for lc in cld2_langcodes]

parser = argparse.ArgumentParser()
for lc in cld2_langcodes:
    parser.add_argument("-%s" % lc,
                        help="outfile for %s data" % lc,
                        type=argparse.FileType('wb'))
args = parser.parse_args()

lang2file = {}
for lc in cld2_langcodes:
    if getattr(args, lc) is not None:
        lang2file[lc] = getattr(args, lc)


buf = []
current_lang = None

for line in sys.stdin:
    if line.startswith(magic_number):
        if buf:
            assert current_lang is not None
            lang2file[current_lang].write("".join(buf))

        current_lang = None
        buf = []

        for kv in line.strip().split():
            if kv.startswith("language:"):
                lang = kv.split(':', 1)[1]
                if lang in lang2file:
                    current_lang = lang

    if current_lang:
        buf.append(line)

if buf:
    assert current_lang is not None
    lang2file[current_lang].write("".join(buf))

for _, lang_file in lang2file.iteritems():
    lang_file.flush()
    lang_file.close()
