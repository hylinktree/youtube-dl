#!/usr/bin/env python

import youtube_dl
import os

if __name__ == '__main__':
    try:
        os.mkdir('out')
    except:
        pass

    youtube_dl.main()
