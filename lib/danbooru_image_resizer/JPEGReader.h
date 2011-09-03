#ifndef JPEG_READER_H
#define JPEG_READER_H

#include <stdio.h>
#include <stdint.h>
#include <setjmp.h>
#include "jpeglib-extern.h"
#include "Reader.h"
#include "Filter.h"

struct jpeg_error
{
	struct jpeg_error_mgr pub;
	jmp_buf setjmp_buffer;
	char buffer[JMSG_LENGTH_MAX];
};

class JPEG: public Reader
{
public:
	bool Read(FILE *f, Filter *pOutput, char error[1024]);

private:
	Filter *m_pOutputFilter;
	struct jpeg_error m_JErr;
};

class JPEGCompressor: public Filter
{
public:
	JPEGCompressor(FILE *f);
	~JPEGCompressor();

	bool Init(int iSourceWidth, int iSourceHeight, int iBPP);
	void SetQuality(int quality);
	bool WriteRow(uint8_t *row);
	bool Finish();

	int GetWidth() const;
	int GetHeight() const;
	const char *GetError() const;

private:
	FILE *m_File;
	int m_iQuality;
	struct jpeg_compress_struct m_CInfo;
	struct jpeg_error m_JErr;
};

#endif
