#ifndef ROW_BUFFER_H
#define ROW_BUFFER_H

#include <stdint.h>

class RowBuffer
{
public:
	RowBuffer();
	~RowBuffer();

	bool Init(int Width, int Height, int BPP);

	/* Return row, allocating if necessary. */
	uint8_t *GetRow(int row);

	// Free rows [0,DiscardRow).
	void DiscardRows(int DiscardRow);

	/* Get a range of rows allocated in m_Rows: [m_StartRow,m_EndRow).  If
	 * more than one allocated range exists, which range is returned is undefined. */
	int GetStartRow() const { return m_StartRow; }
	int GetEndRow() const { return m_EndRow; }
	const uint8_t *const *GetRows() const { return m_Rows; }

private:
	/* Array of image rows.  These are allocated as needed. */
	uint8_t **m_Rows;

	/*  in m_Rows is allocated: */
	int m_StartRow;
	int m_EndRow;

	int m_Width;
	int m_Height;
	int m_BPP;
};

#endif

