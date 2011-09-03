#ifndef GIF_READER_H
#define GIF_READER_H

#include "Reader.h"
class Filter;
class GIF: public Reader
{
public:
	bool Read(FILE *f, Filter *pOutput, char error[1024]);
};

#endif
