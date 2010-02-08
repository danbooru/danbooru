#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "RowBuffer.h"
#include <algorithm>
using namespace std;

RowBuffer::RowBuffer()
{
	m_Rows = NULL;
	m_StartRow = 0;
	m_EndRow = 0;
	m_BPP = 0;
	m_Height = 0;
}

RowBuffer::~RowBuffer()
{
	for(int i = 0; i < m_Height; ++i)
		delete [] m_Rows[i];

	delete [] m_Rows;
}

bool RowBuffer::Init(int Width, int Height, int BPP)
{
	m_Width = Width;
	m_Height = Height;
	m_BPP = BPP;

	m_Rows = new uint8_t *[Height];
	if(m_Rows == NULL)
		return false;
	memset(m_Rows, 0, sizeof(uint8_t *) * Height);

	return true;
}

uint8_t *RowBuffer::GetRow(int Row)
{
	assert(m_BPP > 0);

	if(m_Rows[Row] == NULL)
	{
		m_Rows[Row] = new uint8_t[m_Width*m_BPP];
		if(m_Rows[Row] == NULL)
			return NULL;
		if(m_StartRow == m_EndRow)
		{
			m_StartRow = Row;
			m_EndRow = m_StartRow + 1;
		}
	}

	if(int(Row) == m_StartRow+1)
	{
		while(m_StartRow != 0 && m_Rows[m_StartRow-1])
			--m_StartRow;
	}

	if(int(Row) == m_EndRow)
	{
		while(m_EndRow < m_Height && m_Rows[m_EndRow])
			++m_EndRow;
	}
	return m_Rows[Row];
}

void RowBuffer::DiscardRows(int DiscardRow)
{
	assert(m_BPP > 0);

	for(int i = m_StartRow; i < DiscardRow; ++i)
	{
		delete [] m_Rows[i];
		m_Rows[i] = NULL;
	}

	m_StartRow = max(m_StartRow, DiscardRow);
	m_EndRow = max(m_EndRow, DiscardRow);
}
