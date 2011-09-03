#include <stdlib.h>
#include <string.h>
#include <gd.h>
#include "GIFReader.h"
#include "Resize.h"

bool GIF::Read(FILE *f, Filter *pOutput, char error[1024])
{
	bool Ret = false;
	gdImage *image = gdImageCreateFromGif(f);

	if(!image)
	{
		strcpy(error, "couldn't read GIF");
		return false;
	}

	uint8_t *pBuf = NULL;
	pBuf = (uint8_t *) malloc(image->sx * 3);
	if(pBuf == NULL)
	{
		strcpy(error, "out of memory");
		goto cleanup;
	}

	pOutput->Init(image->sx, image->sy, 3);
	for(int y = 0; y < image->sy; ++y)
	{
		uint8_t *p = pBuf;

		for(int x = 0; x < image->sx; ++x)
		{
			int c = gdImageGetTrueColorPixel(image, x, y);
			(*p++) = gdTrueColorGetRed(c);
			(*p++) = gdTrueColorGetGreen(c);
			(*p++) = gdTrueColorGetBlue(c);
		}

		if(!pOutput->WriteRow(pBuf))
		{
			strcpy(error, pOutput->GetError());
			goto cleanup;
		}
	}

	if(!pOutput->Finish())
	{
		strcpy(error, pOutput->GetError());
		goto cleanup;
	}

	Ret = true;

cleanup:
	if(pBuf != NULL)
		free(pBuf);

	gdImageDestroy(image);
	return Ret;
}
