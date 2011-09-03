#ifndef FILTER_H
#define FILTER_H

#include <stdint.h>

class Filter
{
public:
	virtual ~Filter() { }
	virtual bool Init(int iSourceWidth, int iSourceHeight, int iSourceBPP) = 0;
	virtual bool WriteRow(uint8_t *row) = 0;
	virtual bool Finish() = 0;
	virtual const char *GetError() const = 0;
};

#endif
