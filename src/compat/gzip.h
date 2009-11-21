/*
 *  gzip.h
 *  zfs
 *
 *  Created by Jason McNeil on 11/20/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

size_t gzip_compress(void *s_start, void *d_start, size_t s_len, size_t d_len, int n);
int gzip_decompress(void *s_start, void *d_start, size_t s_len, size_t d_len, int n);
