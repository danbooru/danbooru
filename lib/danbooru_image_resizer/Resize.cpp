#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Resize.h"
#include "JPEGReader.h"
#include <algorithm>
using namespace std;

Resizer::Resizer(JPEGCompressor *Compressor)
{
	m_Compressor = Compressor;
	m_CurrentY = 0;
	m_OutBuf = NULL;
}

Resizer::~Resizer()
{
	if(m_OutBuf)
		free(m_OutBuf);
}

const char *Resizer::GetError() const
{
	return m_Compressor->GetError();
}

void Resizer::SetSource(int Width, int Height, int BPP)
{
	m_SourceWidth = Width;
	m_SourceHeight = Height;
	m_SourceBPP = BPP;
}

bool Resizer::SetDest(int Width, int Height, int Quality)
{
	m_DestWidth = Width;
	m_DestHeight = Height;
	m_OutBuf = (uint8_t *) malloc(Width*3);

	return m_Compressor->Init(Width, Height, Quality);
}

#define scale(x, l1, h1, l2, h2) (((x)-(l1))*((h2)-(l2))/((h1)-(l1))+(l2))

static void Average(const uint8_t *const *src, float Colors[3], float SourceXStart, float SourceXEnd, float SourceYStart, float SourceYEnd, int SourceBPP)
{
	float Total = 0.0f;
	for(float y = SourceYStart; y < SourceYEnd; ++y)
	{
		float YCoverage = 1.0f;
		if(int(y) == int(SourceYStart))
			YCoverage -= y - int(y);
		if(int(y) == int(SourceYEnd))
			YCoverage -= 1.0f - (SourceYEnd - int(SourceYEnd));

		const uint8_t *xsrc=src[(int) y]+(int)SourceXStart*SourceBPP;

		/* The two conditionals can only be true on the first and last iteration of the loop,
		 * so unfold those iterations and pull the conditionals out of the inner loop. */
/*		while(x < SourceXEnd)
		{
			float XCoverage = 1.0f;
			if(int(x) == int(SourceXStart))
				XCoverage -= x - int(x);
			if(int(x) == int(SourceXEnd))
				XCoverage -= 1.0f - (SourceXEnd - int(SourceXEnd));

			Colors[0] += xsrc[0] * XCoverage * YCoverage;
			Colors[1] += xsrc[1] * XCoverage * YCoverage;
			Colors[2] += xsrc[2] * XCoverage * YCoverage;
			if(SourceBPP == 4)
				Colors[3] += xsrc[3] * XCoverage * YCoverage;
			xsrc += SourceBPP;

			Total += XCoverage * YCoverage;
			++x;
		}
*/
		float x = int(SourceXStart);
		if(x < SourceXEnd)
		{
			float XCoverage = 1.0f;
			if(int(x) == int(SourceXStart))
				XCoverage -= x - int(x);
			if(int(x) == int(SourceXEnd))
				XCoverage -= 1.0f - (SourceXEnd - int(SourceXEnd));

			Colors[0] += xsrc[0] * XCoverage * YCoverage;
			Colors[1] += xsrc[1] * XCoverage * YCoverage;
			Colors[2] += xsrc[2] * XCoverage * YCoverage;
			if(SourceBPP == 4)
				Colors[3] += xsrc[3] * XCoverage * YCoverage;
			xsrc += SourceBPP;

			Total += XCoverage * YCoverage;
			++x;
		}

		while(x < SourceXEnd-1)
		{
			Colors[0] += xsrc[0] * YCoverage;
			Colors[1] += xsrc[1] * YCoverage;
			Colors[2] += xsrc[2] * YCoverage;
			if(SourceBPP == 4)
				Colors[3] += xsrc[3] * YCoverage;
			xsrc += SourceBPP;

			Total += YCoverage;
			++x;
		}

		if(x < SourceXEnd)
		{
			float XCoverage = 1.0f;
			if(int(x) == int(SourceXStart))
				XCoverage -= x - int(x);
			if(int(x) == int(SourceXEnd))
				XCoverage -= 1.0f - (SourceXEnd - int(SourceXEnd));

			Colors[0] += xsrc[0] * XCoverage * YCoverage;
			Colors[1] += xsrc[1] * XCoverage * YCoverage;
			Colors[2] += xsrc[2] * XCoverage * YCoverage;
			if(SourceBPP == 4)
				Colors[3] += xsrc[3] * XCoverage * YCoverage;
			xsrc += SourceBPP;

			Total += XCoverage * YCoverage;
		}
	}

	if(Total != 0.0f)
		for(int i = 0; i < 4; ++i)
			Colors[i] /= Total;
}

bool Resizer::Run(const uint8_t *const *Source, int StartRow, int EndRow, int &DiscardRow)
{
	while(m_CurrentY < m_DestHeight)
	{
		float SourceYStart = scale((float) m_CurrentY,   0.0f, (float) m_DestHeight, 0.0f, (float) m_SourceHeight);
		float SourceYEnd = scale((float) m_CurrentY + 1, 0.0f, (float) m_DestHeight, 0.0f, (float) m_SourceHeight);
		DiscardRow = int(SourceYStart)-1;

		if(EndRow != m_SourceHeight && int(SourceYEnd)+1 > EndRow-1)
			return true;
		assert(SourceYStart>=StartRow);

		uint8_t *Output = m_OutBuf;
		for(int x = 0; x < m_DestWidth; ++x)
		{
			float SourceXStart = scale((float) x,   0.0f, (float) m_DestWidth, 0.0f, (float) m_SourceWidth);
			float SourceXEnd = scale((float) x + 1, 0.0f, (float) m_DestWidth, 0.0f, (float) m_SourceWidth);

			float Colors[4] = { 0.0 };
			Average(Source, Colors, SourceXStart, SourceXEnd, SourceYStart, SourceYEnd, m_SourceBPP);

			if(m_SourceBPP == 4)
			{
				for(int i = 0; i < 3; ++i)
					Colors[i] *= Colors[3]/255.0f;
			}

			Output[0] = (uint8_t) min(255, int(Colors[0]));
			Output[1] = (uint8_t) min(255, int(Colors[1]));
			Output[2] = (uint8_t) min(255, int(Colors[2]));

			Output += 3;
		}

		if(!m_Compressor->WriteRow((JSAMPLE *) m_OutBuf))
			return false;
		++m_CurrentY;
	}

	if(m_CurrentY == m_DestHeight)
	{
		if(!m_Compressor->Finish())
			return false;
	}

	return true;
}

