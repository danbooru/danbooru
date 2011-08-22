#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "Histogram.h"
#include "Filter.h"
#include <algorithm>
using namespace std;

Histogram::Histogram()
{
	memset(m_Histogram, 0, sizeof(m_Histogram));
}

bool Histogram::Init(int iSourceWidth, int iSourceHeight, int iBPP)
{
	assert(iBPP >= 3);
	m_SourceWidth = iSourceWidth;
	m_SourceBPP = iBPP;

	return true;
}
int Histogram::GetChannels() const
{
	return min(m_SourceBPP, 3);
}

bool Histogram::WriteRow(uint8_t *pNewRow)
{
	uint8_t *pInput = pNewRow;
	int channels = GetChannels();
	for(int x = 0; x < m_SourceWidth; ++x)
	{
		for(int c = 0; c < channels; ++c)
		{
			int color = pInput[c];
			if(m_SourceBPP == 3)
				color = (color * pInput[3]) / 255;
			++m_Histogram[c][color];
		}

		pInput += m_SourceBPP;
	}

	return true;
}

