#ifndef CONVERT_TO_RGB_H
#define CONVERT_TO_RGB_H

#include "Filter.h"
#include <memory>
using namespace std;

class ConvertToRGB: public Filter
{
public:
	ConvertToRGB(auto_ptr<Filter> pCompressor);
	~ConvertToRGB();

	bool Init(int iSourceWidth, int iSourceHeight, int BPP);
	bool WriteRow(uint8_t *pNewRow);
	bool Finish() { return true; }

	const char *GetError() const { return NULL; }

private:
	uint8_t *m_pBuffer;
	auto_ptr<Filter> m_pCompressor;
	int m_iSourceWidth;
	int m_iBPP;
};

#endif
