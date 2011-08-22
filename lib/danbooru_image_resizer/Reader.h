#ifndef READER_H
#define READER_H

#include <stdio.h>

class Filter;
class Reader
{
public:
	virtual ~Reader() { }
	virtual bool Read(FILE *f, Filter *rp, char errorbuf[1024]) = 0;
};

#endif
