#ifndef PNG_READER_H
#define PNG_READER_H

#include <png.h>
#include "Reader.h"
#include "RowBuffer.h"

struct png_error_info
{
	char *err;
};

class PNG: public Reader
{
public:
	PNG()
	{
		m_Done = false;
	}

	bool Read(FILE *f, Resizer *resizer, char error[1024]);

private:
	RowBuffer m_Rows;
	Resizer *m_Resizer;

	bool m_Done;
	int m_Passes;

	static void Error(png_struct *png, const char *error);
	static void Warning(png_struct *png, const char *warning);
	static void InfoCallback(png_struct *png, png_info *info_ptr);
	static void RowCallback(png_struct *png, png_byte *new_row, png_uint_32 row_num, int pass);
	static void EndCallback(png_struct *png, png_info *info);
};

#endif
