#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "ConvertToRGB.h"
#include "Filter.h"
#include <algorithm>
using namespace std;

ConvertToRGB::ConvertToRGB(auto_ptr<Filter> pCompressor):
	m_pCompressor(pCompressor)
{
	m_pBuffer = NULL;
}

ConvertToRGB::~ConvertToRGB()
{
	delete[] m_pBuffer;
}

bool ConvertToRGB::Init(int iSourceWidth, int iSourceHeight, int iBPP)
{
	m_iSourceWidth = iSourceWidth;
	// m_iSourceHeight = iSourceHeight;
	m_iBPP = iBPP;
	m_pBuffer = new uint8_t[iSourceWidth * 3];
	assert(m_iBPP == 1 || m_iBPP == 3 || m_iBPP == 4); // greyscale, RGB or RGBA

	return m_pCompressor->Init(iSourceWidth, iSourceHeight, 3);
}

bool ConvertToRGB::WriteRow(uint8_t *pNewRow)
{
	if(m_iBPP == 3)
		return m_pCompressor->WriteRow(pNewRow);
	if(m_iBPP == 1)
	{
		uint8_t *pBuffer = m_pBuffer;
		for(int i = 0; i < m_iSourceWidth; ++i)
		{
			*pBuffer++ = *pNewRow;
			*pBuffer++ = *pNewRow;
			*pBuffer++ = *pNewRow;
			++pNewRow;
		}
	}
	else if(m_iBPP == 4)
	{
		uint8_t *pBuffer = m_pBuffer;
		for(int i = 0; i < m_iSourceWidth; ++i)
		{
			uint8_t iR = *pNewRow++;
			uint8_t iG = *pNewRow++;
			uint8_t iB = *pNewRow++;
			uint8_t iA = *pNewRow++;
			iR = uint8_t((iR * iA) / 255.0f);
			iG = uint8_t((iG * iA) / 255.0f);
			iB = uint8_t((iB * iA) / 255.0f);
			*pBuffer++ = iR;
			*pBuffer++ = iG;
			*pBuffer++ = iB;
		}
	}

	return m_pCompressor->WriteRow(m_pBuffer);
}

