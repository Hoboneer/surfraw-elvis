#!/usr/bin/env python3
from urllib.parse import unquote
from base64 import b64decode

# From 'sp' param
#"" # all
normal_params = {
    'video': "EgIQAQ%253D%253D",
    'channel': "EgIQAg%253D%253D",
    'playlist': "EgIQAw%253D%253D",
    'movie': "EgIQBA%253D%253D",
    'show': "EgIQBQ%253D%253D", # No longer supported on youtube?
}

sort_params = {
    'video': [
        "CAASAhAB", # relevance
        "CAISAhAB", # upload date
        "CAMSAhAB", # view count
        "CAESAhAB", # rating
    ],
    'channel': [
        "CAASAhAC", # relevance
        "CAISAhAC", # upload date
        "CAMSAhAC", # view count
        "CAESAhAC", # rating
    ],
    'playlist': [
        "CAASAhAD", # relevance
        "CAISAhAD", # upload date
        "CAMSAhAD", # view count
        "CAESAhAD", # rating
    ],
    'movie': [
        "CAASAhAE", # relevance
        "CAISAhAE", # upload
        "CAMSAhAE", # view
        "CAESAhAE", # rating
    ],
    'show': [

    ],
}
sort_indices = ['relevance', 'upload', 'view', 'rating']

def decode(s):
    unquoted = unquote(unquote(s))
    return (unquoted, b64decode(unquoted))
def print(*args, **kwargs):
    import builtins
    builtins.print(*args, sep='\t', **kwargs)


for k,v in normal_params.items():
    print(k[:4], *decode(v))
print()

for k,v in sort_params.items():
    for i,s in enumerate(v):
        print(k[0] + "_" + sort_indices[i][:3], *decode(s))
    print()

# When sorting (all the time, except when on "all") From left to right (from 1):
# byte 2 of param: sort (relevance, upload date, etc.)
# byte 6 of param: search type (video, channel, etc.)
# Also https://old.reddit.com/r/AskProgramming/comments/60wcli/youtube_seems_to_have_an_odd_way_of_paginating/df9vb17/

# Output:
"""
vide	EgIQAQ==	b'\x12\x02\x10\x01'
chan	EgIQAg==	b'\x12\x02\x10\x02'
play	EgIQAw==	b'\x12\x02\x10\x03'
movi	EgIQBA==	b'\x12\x02\x10\x04'
show	EgIQBQ==	b'\x12\x02\x10\x05'

v_rel	CAASAhAB	b'\x08\x00\x12\x02\x10\x01'
v_upl	CAISAhAB	b'\x08\x02\x12\x02\x10\x01'
v_vie	CAMSAhAB	b'\x08\x03\x12\x02\x10\x01'
v_rat	CAESAhAB	b'\x08\x01\x12\x02\x10\x01'

c_rel	CAASAhAC	b'\x08\x00\x12\x02\x10\x02'
c_upl	CAISAhAC	b'\x08\x02\x12\x02\x10\x02'
c_vie	CAMSAhAC	b'\x08\x03\x12\x02\x10\x02'
c_rat	CAESAhAC	b'\x08\x01\x12\x02\x10\x02'

p_rel	CAASAhAD	b'\x08\x00\x12\x02\x10\x03'
p_upl	CAISAhAD	b'\x08\x02\x12\x02\x10\x03'
p_vie	CAMSAhAD	b'\x08\x03\x12\x02\x10\x03'
p_rat	CAESAhAD	b'\x08\x01\x12\x02\x10\x03'

m_rel	CAASAhAE	b'\x08\x00\x12\x02\x10\x04'
m_upl	CAISAhAE	b'\x08\x02\x12\x02\x10\x04'
m_vie	CAMSAhAE	b'\x08\x03\x12\x02\x10\x04'
m_rat	CAESAhAE	b'\x08\x01\x12\x02\x10\x04'
"""
