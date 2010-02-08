#ifndef JPEG_READER_H
#define JPEG_READER_H

#include <stdio.h>
#include <stdint.h>
#include <setjmp.h>
#include "jpeglib-extern.h"
#include "Reader.h"

struct jpeg_error
{
	struct jpeg_error_mgr pub;
	jmp_buf setjmp_buffer;
	char *buffer;
};

class JPEG: public Reader
{
public:
	bool Read(FILE *f, Resizer *resizer, char error[1024]);

private:
	Resizer *m_Resizer;
	struct jpeg_error m_JErr;
};

class JPEGCompressor
{
public:
	JPEGCompressor(FILE *f);
	~JPEGCompressor();

	bool Init(int width, int height, int quality);
	bool WriteRow(uint8_t *row);
	bool Finish();

	int GetWidth() const;
	int GetHeight() const;
	const char *GetError() const;

private:
	FILE *m_File;
	struct jpeg_compress_struct m_CInfo;
	struct jpeg_error m_JErr;
};

#endif
