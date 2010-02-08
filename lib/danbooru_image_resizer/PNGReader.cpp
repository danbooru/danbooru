#include <errno.h>
#include <stdio.h>
#include "PNGReader.h"
#include "Resize.h"
#include <algorithm>
using namespace std;

void PNG::Error(png_struct *png, const char *error)
{
	png_error_info *info = (png_error_info *) png->error_ptr;
	strncpy(info->err, error, 1024);
	info->err[1023] = 0;
	longjmp(png->jmpbuf, 1);
}

void PNG::Warning(png_struct *png, const char *warning)
{
}

void PNG::InfoCallback(png_struct *png, png_info *info_ptr)
{
	PNG *data = (PNG *) png_get_progressive_ptr(png);

	png_uint_32 width, height;
	int bit_depth, color_type;
	png_get_IHDR(png, info_ptr, &width, &height, &bit_depth, &color_type, NULL, NULL, NULL);

	png_set_palette_to_rgb(png);
	png_set_tRNS_to_alpha(png);
	png_set_filler(png, 0xFF, PNG_FILLER_AFTER);
	if(bit_depth < 8)
		png_set_packing(png);
	if(color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
		png_set_expand_gray_1_2_4_to_8(png);
	if(bit_depth == 16)
		png_set_strip_16(png);
	data->m_Passes = png_set_interlace_handling(png);

	if (color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
		png_set_gray_to_rgb(png);

	if(!data->m_Rows.Init(width, height, 4))
		Error(png, "out of memory");

	png_read_update_info(png, info_ptr);

	data->m_Resizer->SetSource(width, height, 4);
}

void PNG::RowCallback(png_struct *png, png_byte *new_row, png_uint_32 row_num, int pass)
{
	PNG *data = (PNG *) png_get_progressive_ptr(png);

	uint8_t *p = data->m_Rows.GetRow(row_num);
	if(p == NULL)
		Error(png, "out of memory");

	png_progressive_combine_row(png, p, new_row);

	if(pass != data->m_Passes - 1)
		return;

	/* We've allocated data->m_RowsAllocated, but if we're doing multiple passes, only
	 * rows 0 to row_num will actually have usable data. */
	int DiscardRow;
	int LastRow = min(data->m_Rows.GetEndRow(), (int) row_num+1);
	if(!data->m_Resizer->Run(data->m_Rows.GetRows(), data->m_Rows.GetStartRow(), LastRow, DiscardRow))
		Error(png, data->m_Resizer->GetError());

	/* If we're interlaced, never discard rows. */
	if(data->m_Passes == 1)
		data->m_Rows.DiscardRows(DiscardRow);
}

void PNG::EndCallback(png_struct *png, png_info *info)
{
	PNG *data = (PNG *) png_get_progressive_ptr(png);
	data->m_Done = true;
}


bool PNG::Read(FILE *f, Resizer *resizer, char error[1024])
{
	m_Resizer = resizer;

	png_error_info err;
	err.err = error;

	png_struct *png = png_create_read_struct(PNG_LIBPNG_VER_STRING, &err, Error, Warning);
	if(png == NULL)
	{
		sprintf(error, "creating png_create_read_struct failed");
		return false;
	}

	png_info *info_ptr = png_create_info_struct(png);
	if(info_ptr == NULL)
	{
		png_destroy_read_struct(&png, NULL, NULL);
		sprintf(error, "creating png_create_info_struct failed");
		return false;
	}

	if(setjmp(png->jmpbuf))
	{
		png_destroy_read_struct(&png, &info_ptr, NULL);
		return false;
	}

	png_set_progressive_read_fn(png, this, InfoCallback, RowCallback, EndCallback);

	while(1)
	{
		png_byte buf[1024*16];
		int ret = fread(buf, 1, sizeof(buf), f);
		if(ret == 0)
			break;
		if(ferror(f))
		{
			strcpy(error, strerror(errno));
			png_destroy_read_struct(&png, &info_ptr, NULL);
			return false;
		}

		png_process_data(png, info_ptr, buf, ret);
	}

	if(!m_Done)
	{
		strcpy(error, "incomplete file");
		png_destroy_read_struct(&png, &info_ptr, NULL);
		return false;
	}

	png_destroy_read_struct(&png, &info_ptr, NULL);
	return true;
}

