#include <string.h>
#include <assert.h>
#include "JPEGReader.h"
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

void JPEGCompressor::SetQuality(int quality)
{
	m_iQuality = quality;
}

bool JPEGCompressor::Init(int width, int height, int bpp)
{
	assert(bpp == 3);
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
	jpeg_set_quality(&m_CInfo, m_iQuality, TRUE); // limit to baseline-JPEG values

	/* For high-quality compression, disable color subsampling. */
	if(m_iQuality >= 95)
	{
		m_CInfo.comp_info[0].h_samp_factor = 1;
		m_CInfo.comp_info[0].v_samp_factor = 1;
		m_CInfo.comp_info[1].h_samp_factor = 1;
		m_CInfo.comp_info[1].v_samp_factor = 1;
		m_CInfo.comp_info[2].h_samp_factor = 1;
		m_CInfo.comp_info[2].v_samp_factor = 1;
	}

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

bool JPEG::Read(FILE *f, Filter *pOutput, char error[1024])
{
	// JMSG_LENGTH_MAX <= sizeof(error)
	m_pOutputFilter = pOutput;

	struct jpeg_decompress_struct CInfo;
	CInfo.err = jpeg_std_error(&m_JErr.pub);
	m_JErr.pub.error_exit = jpeg_error_exit;
	m_JErr.pub.emit_message = jpeg_warning;

	bool Ret = false;
	uint8_t *pBuf = NULL;
	if(setjmp(m_JErr.setjmp_buffer))
	{
		memcpy(error, m_JErr.buffer, JMSG_LENGTH_MAX);
		goto cleanup;
	}

	jpeg_create_decompress(&CInfo);

	jpeg_stdio_src(&CInfo, f);
	jpeg_read_header(&CInfo, TRUE);
	CInfo.out_color_space = JCS_RGB;
	if(CInfo.jpeg_color_space == JCS_CMYK || CInfo.jpeg_color_space == JCS_YCCK)
	{
		strcpy(error, "CMYK JPEGs are not supported; please convert to RGB");
		goto cleanup;
	}

	jpeg_start_decompress(&CInfo);

	if(!m_pOutputFilter->Init(CInfo.output_width, CInfo.output_height, 3))
	{
		strncpy(error, m_pOutputFilter->GetError(), sizeof(error));
		error[sizeof(error)-1] = 0;
		goto cleanup;
	}

	pBuf = (uint8_t *) malloc(CInfo.output_width * 3);
	if(pBuf == NULL)
	{
		strcpy(error, "out of memory");
		goto cleanup;
	}

	while(CInfo.output_scanline < CInfo.output_height)
	{
		jpeg_read_scanlines(&CInfo, &pBuf, 1);

		if(!m_pOutputFilter->WriteRow(pBuf))
		{
			strcpy(error, m_pOutputFilter->GetError());
			goto cleanup;
		}
	}

	if(!m_pOutputFilter->Finish())
	{
		strcpy(error, m_pOutputFilter->GetError());
		goto cleanup;
	}

	jpeg_finish_decompress(&CInfo);

	Ret = true;

cleanup:
	if(pBuf != NULL)
		free(pBuf);
	jpeg_destroy_decompress(&CInfo);

	return Ret;
}

