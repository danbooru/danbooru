#ifndef HISTOGRAM_H
#define HISTOGRAM_H

#include "Filter.h"
#include <memory>
using namespace std;
#include <stdint.h>

class Histogram: public Filter
{
public:
	Histogram();

	bool Init(int iSourceWidth, int iSourceHeight, int BPP);
	bool WriteRow(uint8_t *pNewRow);
	bool Finish() { return true; }

	const char *GetError() const { return NULL; }
	int GetChannels() const;
	const unsigned *GetHistogram(int iChannel) const { return m_Histogram[iChannel]; }

private:
	unsigned m_Histogram[3][256];

	int m_SourceWidth;
	int m_SourceBPP;
};

#endif
