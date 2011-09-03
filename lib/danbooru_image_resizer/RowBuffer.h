#ifndef ROW_BUFFER_H
#define ROW_BUFFER_H

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "RowBuffer.h"
#include <algorithm>
using namespace std;

template<typename T>
class RowBuffer
{
public:
	RowBuffer()
	{
		m_Rows = NULL;
		m_ActualRows = NULL;
		m_StartRow = 0;
		m_EndRow = 0;
		m_BPP = 0;
		m_Height = 0;
	}

	~RowBuffer()
	{
		for(int i = 0; i < m_Height; ++i)
			delete [] m_Rows[i];

		delete [] m_ActualRows;
	}

	/*
	 * If iVertPadding is non-zero, simulate padding on the top and bottom of the image.  After
	 * row 0 is written, rows [-1 ... -iVertPadding] will point to the same row.  After the bottom
	 * row is written, the following iVertPadding will also point to the last row.  These rows
	 * are discarded when the row they refer to is discarded.
	 */
	bool Init(int iWidth, int iHeight, int iBPP, int iVertPadding = 0)
	{
		m_Width = iWidth;
		m_Height = iHeight;
		m_BPP = iBPP;
		m_iVertPadding = iVertPadding;

		m_ActualRows = new T *[iHeight + iVertPadding*2];
		m_Rows = m_ActualRows + iVertPadding;
		memset(m_ActualRows, 0, sizeof(T *) * (iHeight + iVertPadding*2));

		return true;
	}

	/* Return row, allocating if necessary. */
	T *GetRow(int Row)
	{
		assert(m_BPP > 0);

		if(m_Rows[Row] == NULL)
		{
			m_Rows[Row] = new T[m_Width*m_BPP];
			if(Row == 0)
			{
				for(int i = -m_iVertPadding; i < 0; ++i)
					m_Rows[i] = m_Rows[0];
			}
			if(Row == m_Height - 1)
			{
				for(int i = m_Height; i < m_Height + m_iVertPadding; ++i)
					m_Rows[i] = m_Rows[m_Height - 1];
			}
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

	// Free rows [0,DiscardRow).
	void DiscardRows(int DiscardRow)
	{
		assert(m_BPP > 0);
		if(DiscardRow > m_Height)
			DiscardRow = m_Height;

		for(int i = m_StartRow; i < DiscardRow; ++i)
		{
			delete [] m_Rows[i];
			m_Rows[i] = NULL;
		}

		m_StartRow = max(m_StartRow, DiscardRow);
		m_EndRow = max(m_EndRow, DiscardRow);
	}

	/* Get a range of rows allocated in m_Rows: [m_StartRow,m_EndRow).  If
	 * more than one allocated range exists, which range is returned is undefined. */
	int GetStartRow() const { return m_StartRow; }
	int GetEndRow() const { return m_EndRow; }
	const T *const *GetRows() const { return m_Rows; }

private:
	/* Array of image rows.  These are allocated as needed. */
	T **m_Rows;

	/* The actual pointer m_Rows is contained in.  m_Rows may be offset from this to
	 * implement padding. */
	T **m_ActualRows;

	/*  in m_Rows is allocated: */
	int m_StartRow;
	int m_EndRow;

	int m_Width;
	int m_Height;
	int m_BPP;
	int m_iVertPadding;
};

#endif

