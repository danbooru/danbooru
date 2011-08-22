#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "Resize.h"
#include "Filter.h"
#include <algorithm>
using namespace std;

namespace
{
	inline float sincf(float x)
	{
		if(fabsf(x) < 1e-9)
			return 1.0;
		
		return sinf(x) / x;
	}

	inline double fract(double f)
	{
		return f - floor(f);
	}
}

static const int KERNEL_SIZE = 3;

LanczosFilter::LanczosFilter()
{
	m_pFilters = NULL;
}

LanczosFilter::~LanczosFilter()
{
	delete[] m_pFilters;
}

void LanczosFilter::Init(float fFactor)
{
	/* If we're reducing the image, each output pixel samples each input pixel in the
	 * range once, so we step one pixel.  If we're enlarging it by 2x, each output pixel
	 * samples each input pixel twice, so we step half a pixel. */
	m_fStep = 1;
	if(fFactor > 1.0)
		m_fStep = 1.0 / fFactor;

	/* If we're sampling each pixel twice (m_fStep is .5), then we need twice as many taps
	 * to sample KERNEL_SIZE pixels. */
	m_iTaps = (int) ceil(KERNEL_SIZE / m_fStep) * 2;

	delete[] m_pFilters;
	m_pFilters = NULL; // in case of exception
	m_pFilters = new float[m_iTaps * 256];

	float *pOutput = m_pFilters;
	for(int i=0; i < 256; ++i)
	{
		float fOffset = i / 256.0f;

		float fSum = 0;
		for(int i = 0; i < m_iTaps; ++i)
		{
			float fPos = -(m_iTaps/2-1) - fOffset + i;
			fPos *= m_fStep;

			float fValue = 0;
			if(fabs(fPos) < KERNEL_SIZE)
				fValue = sincf(M_PI*fPos) * sincf(M_PI / KERNEL_SIZE * fPos);

			pOutput[i] = fValue;
			fSum += fValue;
		}

		/* Scale the filter so it sums to 1. */
		for(int i = 0; i<m_iTaps; ++i)
			pOutput[i] /= fSum;

		pOutput += m_iTaps;
	}
}

const float *LanczosFilter::GetFilter(float fOffset) const
{
	int iOffset = int(fOffset * 256.0f);
	iOffset %= 256;
	return m_pFilters + iOffset*m_iTaps;
}

Resizer::Resizer(auto_ptr<Filter> pOutput):
	m_pCompressor(pOutput)
{
	m_DestWidth = -1;
	m_DestHeight = -1;
	m_CurrentY = 0;
	m_OutBuf = NULL;
	m_szError = NULL;
	m_iInputY = 0;
}

Resizer::~Resizer()
{
	if(m_OutBuf)
		free(m_OutBuf);
}

const char *Resizer::GetError() const
{
	if(m_szError != NULL)
		return m_szError;
	return m_pCompressor->GetError();
}

bool Resizer::Init(int iSourceWidth, int iSourceHeight, int iBPP)
{
	assert(m_DestWidth != -1);
	assert(m_DestHeight != -1);
	assert(iBPP == 3);
	m_SourceWidth = iSourceWidth;
	m_SourceHeight = iSourceHeight;
	m_SourceBPP = iBPP;

	float fXFactor = float(m_SourceWidth) / m_DestWidth;
	m_XFilter.Init(fXFactor);

	float fYFactor = float(m_SourceHeight) / m_DestHeight;
	m_YFilter.Init(fYFactor);

	if(!m_Rows.Init(m_DestWidth, m_SourceHeight, m_SourceBPP, m_YFilter.m_iTaps))
	{
		m_szError = "out of memory";
		return false;
	}

	m_OutBuf = (uint8_t *) malloc(m_DestWidth * m_SourceBPP);
	if(m_OutBuf == NULL)
	{
		m_szError = "out of memory";
		return false;
	}

	return m_pCompressor->Init(m_DestWidth, m_DestHeight, m_SourceBPP);
}

void Resizer::SetDest(int iDestWidth, int iDestHeight)
{
	m_DestWidth = iDestWidth;
	m_DestHeight = iDestHeight;
}

static uint8_t *PadRow(const uint8_t *pSourceRow, int iWidth, int iBPP, int iPadding)
{
	uint8_t *pRow = new uint8_t[(iWidth + iPadding*2) * iBPP];
	uint8_t *pDest = pRow;
	for(int x = 0; x < iPadding; ++x)
	{
		for(int i = 0; i < iBPP; ++i)
			pDest[i] = pSourceRow[i];
		pDest += iBPP;
	}

	memcpy(pDest, pSourceRow, iWidth*iBPP*sizeof(uint8_t));
	pDest += iWidth*iBPP;

	for(int x = 0; x < iPadding; ++x)
	{
		for(int i = 0; i < iBPP; ++i)
			pDest[i] = pSourceRow[i];
		pDest += iBPP;
	}

	return pRow;
}

bool Resizer::WriteRow(uint8_t *pNewRow)
{
	if(m_SourceWidth == m_DestWidth && m_SourceHeight == m_DestHeight)
	{
		++m_CurrentY;

		/* We don't actually have any resizing to do, so short-circuit. */
		if(!m_pCompressor->WriteRow((uint8_t *) pNewRow))
			return false;

		if(m_CurrentY != m_DestHeight)
			return true;

		return m_pCompressor->Finish();
	}

	/* Make a copy of pNewRow with the first and last pixel duplicated, so we don't have to do
	 * bounds checking in the inner loop below. */
	uint8_t *pActualPaddedRow = PadRow(pNewRow, m_SourceWidth, m_SourceBPP, m_XFilter.m_iTaps/2);
	const uint8_t *pPaddedRow = pActualPaddedRow + (m_XFilter.m_iTaps/2)*m_SourceBPP;

	const float fXFactor = float(m_SourceWidth) / m_DestWidth;
	const float fYFactor = float(m_SourceHeight) / m_DestHeight;

	/* Run the horizontal filter on the incoming row, and drop the result into m_Rows. */
	{
		float *pRow = m_Rows.GetRow(m_iInputY);
		++m_iInputY;

		float *pOutput = pRow;
		for(int x = 0; x < m_DestWidth; ++x)
		{
			const double fSourceX = (x + 0.5f) * fXFactor;
			const double fOffset = fract(fSourceX + 0.5);
			const float *pFilter = m_XFilter.GetFilter(fOffset);
			const int iStartX = lrint(fSourceX - m_XFilter.m_iTaps/2 + 1e-6);

			const uint8_t *pSource = pPaddedRow + iStartX*3;

			float fR = 0, fG = 0, fB = 0;
			for(int i = 0; i < m_XFilter.m_iTaps; ++i)
			{
				float fWeight = *pFilter++;

				fR += pSource[0] * fWeight;
				fG += pSource[1] * fWeight;
				fB += pSource[2] * fWeight;
				pSource += 3;
			}

			pOutput[0] = fR;
			pOutput[1] = fG;
			pOutput[2] = fB;

			pOutput += m_SourceBPP;
		}
	}
	delete[] pActualPaddedRow;

	const float *const *pSourceRows = m_Rows.GetRows();
	while(m_CurrentY < m_DestHeight)
	{
		const double fSourceY = (m_CurrentY + 0.5) * fYFactor;
		const double fOffset = fract(fSourceY + 0.5);
		const int iStartY = lrint(fSourceY - m_YFilter.m_iTaps/2 + 1e-6);

		/* iStartY is the first row we'll need, and we never move backwards.  Discard rows
		 * before it to save memory. */
		m_Rows.DiscardRows(iStartY);

		if(m_iInputY != m_SourceHeight && iStartY+m_YFilter.m_iTaps >= m_iInputY)
			return true;

		/* Process the next output row. */
		uint8_t *pOutput = m_OutBuf;
		for(int x = 0; x < m_DestWidth; ++x)
		{
			const float *pFilter = m_YFilter.GetFilter(fOffset);

			float fR = 0, fG = 0, fB = 0;
			for(int i = 0; i < m_YFilter.m_iTaps; ++i)
			{
				const float *pSource = pSourceRows[iStartY+i];
				pSource += x * m_SourceBPP;

				float fWeight = *pFilter++;
				fR += pSource[0] * fWeight;
				fG += pSource[1] * fWeight;
				fB += pSource[2] * fWeight;
			}

			pOutput[0] = (uint8_t) max(0, min(255, (int) lrintf(fR)));
			pOutput[1] = (uint8_t) max(0, min(255, (int) lrintf(fG)));
			pOutput[2] = (uint8_t) max(0, min(255, (int) lrintf(fB)));

			pOutput += 3;
		}

		if(!m_pCompressor->WriteRow((uint8_t *) m_OutBuf))
			return false;
		++m_CurrentY;
	}

	if(m_CurrentY == m_DestHeight)
	{
		if(!m_pCompressor->Finish())
			return false;
	}

	return true;
}

