#include <string.h>
#include <gd.h>
#include "GIFReader.h"
#include "RowBuffer.h"
#include "Resize.h"

bool GIF::Read(FILE *f, Resizer *resizer, char error[1024])
{
	RowBuffer Rows;
	bool Ret = false;
	gdImage *image = gdImageCreateFromGif(f);

	if(!image)
	{
		strcpy(error, "couldn't read GIF");
		return false;
	}

	if(!Rows.Init(image->sx, image->sy, 3))
	{
		strcpy(error, "out of memory");
		goto cleanup;
	}

	resizer->SetSource(image->sx, image->sy, 3);
	for(int y = 0; y < image->sy; ++y)
	{
		uint8_t *p = Rows.GetRow(y);
		if(p == NULL)
		{
			strcpy(error, "out of memory");
			goto cleanup;
		}

		for(int x = 0; x < image->sx; ++x)
		{
			int c = gdImageGetTrueColorPixel(image, x, y);
			(*p++) = gdTrueColorGetRed(c);
			(*p++) = gdTrueColorGetGreen(c);
			(*p++) = gdTrueColorGetBlue(c);
		}

		int DiscardRow;
		if(!resizer->Run(Rows.GetRows(), Rows.GetStartRow(), Rows.GetEndRow(), DiscardRow))
		{
			strcpy(error, resizer->GetError());
			goto cleanup;
		}

		Rows.DiscardRows(DiscardRow);
	}

	Ret = true;

cleanup:
	gdImageDestroy(image);
	return Ret;
}
