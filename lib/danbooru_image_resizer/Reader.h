#ifndef READER_H
#define READER_H

#include <stdio.h>

class Resizer;
class Reader
{
public:
	virtual ~Reader() { }
	virtual bool Read(FILE *f, Resizer *rp, char errorbuf[1024]) = 0;
};

#endif
