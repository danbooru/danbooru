#ifndef GIF_READER_H
#define GIF_READER_H

#include "Reader.h"
class GIF: public Reader
{
public:
	bool Read(FILE *f, Resizer *resizer, char error[1024]);
};

#endif
