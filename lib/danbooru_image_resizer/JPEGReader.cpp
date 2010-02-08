#include <string.h>
#include "JPEGReader.h"
#include "RowBuffer.h"
#include "Resize.h"
#include <algorithm>
using namespace std;

static void jpeg_error_exit(j_common_ptr CInfo)
{
	jpeg_error *myerr = (jpeg_error *) CInfo->err;
	(*CInfo->err->format_message) (CInfo, myerr->buffer);
	longjmp(myerr->setjmp_buffer, 1);
}

static void jpeg_warning(j_common_ptr cinfo, int msg_level)
{
}

JPEGCompressor::JPEGCompressor(FILE *f)
{
	m_File = f;
	memset(&m_CInfo, 0, sizeof(m_CInfo));
}

JPEGCompressor::~JPEGCompressor()
{
	jpeg_destroy_compress(&m_CInfo);
}

const char *JPEGCompressor::GetError() const
{
	return m_JErr.buffer;
}


bool JPEGCompressor::Init(int width, int height, int quality)
{
	m_CInfo.err = jpeg_std_error(&m_JErr.pub);

	m_JErr.pub.error_exit = jpeg_error_exit;
	m_JErr.pub.emit_message = jpeg_warning;

	if(setjmp(m_JErr.setjmp_buffer))
		return false;

	jpeg_create_compress(&m_CInfo);

	jpeg_stdio_dest(&m_CInfo, m_File);

	m_CInfo.image_width = width;
	m_CInfo.image_height = height;
	m_CInfo.input_components = 3;		/* # of color components per pixel */
	m_CInfo.in_color_space = JCS_RGB; 	/* colorspace of input image */

	jpeg_set_defaults(&m_CInfo);
	jpeg_simple_progression(&m_CInfo);
	jpeg_set_quality(&m_CInfo, quality, TRUE); // limit to baseline-JPEG values

	jpeg_start_compress(&m_CInfo, TRUE);

	return true;
}

int JPEGCompressor::GetWidth() const
{
	return m_CInfo.image_width;
}

int JPEGCompressor::GetHeight() const
{
	return m_CInfo.image_height;
}

bool JPEGCompressor::WriteRow(uint8_t *row)
{
	if(setjmp(m_JErr.setjmp_buffer))
		return false;

	jpeg_write_scanlines(&m_CInfo, (JSAMPLE **) &row, 1);
	return true;
}

bool JPEGCompressor::Finish()
{
	if(setjmp(m_JErr.setjmp_buffer))
		return false;

	jpeg_finish_compress(&m_CInfo);
	return true;
}

bool JPEG::Read(FILE *f, Resizer *resizer, char error[1024])
{
	// JMSG_LENGTH_MAX <= sizeof(error)
	m_JErr.buffer = error;
	RowBuffer Rows;

	m_Resizer = resizer;

	struct jpeg_decompress_struct CInfo;
	CInfo.err = jpeg_std_error(&m_JErr.pub);
	m_JErr.pub.error_exit = jpeg_error_exit;
	m_JErr.pub.emit_message = jpeg_warning;

	bool Ret = false;
	if(setjmp(m_JErr.setjmp_buffer))
		goto cleanup;

	jpeg_create_decompress(&CInfo);

	jpeg_stdio_src(&CInfo, f);
	jpeg_read_header(&CInfo, TRUE);
	CInfo.out_color_space = JCS_RGB;

	jpeg_start_decompress(&CInfo);

	if(!Rows.Init(CInfo.output_width, CInfo.output_height, 3))
	{
		strcpy(error, "out of memory");
		goto cleanup;
	}

	m_Resizer->SetSource(CInfo.output_width, CInfo.output_height, 3);

	while(CInfo.output_scanline < CInfo.output_height)
	{
		uint8_t *p = Rows.GetRow(CInfo.output_scanline);
		if(p == NULL)
		{
			strcpy(error, "out of memory");
			goto cleanup;
		}

		jpeg_read_scanlines(&CInfo, &p, 1);

		int DiscardRow;
		if(!m_Resizer->Run(Rows.GetRows(), Rows.GetStartRow(), min(Rows.GetEndRow(), (int) CInfo.output_scanline+1), DiscardRow))
		{
			strcpy(error, m_Resizer->GetError());
			goto cleanup;
		}

		Rows.DiscardRows(DiscardRow);
	}

	jpeg_finish_decompress(&CInfo);

	Ret = true;

cleanup:
	jpeg_destroy_decompress(&CInfo);

	return Ret;
}

