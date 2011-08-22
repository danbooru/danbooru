#ifndef RESIZE_H
#define RESIZE_H

#include "RowBuffer.h"
#include "Filter.h"
#include <memory>
using namespace std;
#include <stdint.h>

struct LanczosFilter
{
	LanczosFilter();
	~LanczosFilter();
	void Init(float fFactor);
	const float *GetFilter(float fOffset) const;

	float m_fStep;
	int m_iTaps;
	float *m_pFilters;
};

class Resizer: public Filter
{
public:
	Resizer(auto_ptr<Filter> pCompressor);
	~Resizer();

	// BPP is 3 or 4, indicating RGB or RGBA.
	bool Init(int iSourceWidth, int iSourceHeight, int BPP);
	void SetDest(int iDestWidth, int iDestHeight);
	bool WriteRow(uint8_t *pNewRow);
	bool Finish() { return true; }

	const char *GetError() const;

private:
	auto_ptr<Filter> m_pCompressor;
	uint8_t *m_OutBuf;
	RowBuffer<float> m_Rows;
	const char *m_szError;

	int m_SourceWidth;
	int m_SourceHeight;
	int m_SourceBPP;

	int m_DestWidth;
	int m_DestHeight;

	LanczosFilter m_XFilter;
	LanczosFilter m_YFilter;

	int m_iInputY;
	int m_CurrentY;
};

#endif
