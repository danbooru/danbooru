#include <ruby.h>
#include <stdio.h>
#include <string.h>
#include <memory>
using namespace std;
#include "PNGReader.h"
#include "GIFReader.h"
#include "JPEGReader.h"
#include "Resize.h"
#include "Histogram.h"
#include "ConvertToRGB.h"

static VALUE danbooru_module;

static Reader *GetReader(const char *file_ext)
{
	if (!strcmp(file_ext, "jpg") || !strcmp(file_ext, "jpeg"))
		return new JPEG;
	if (!strcmp(file_ext, "gif"))
		return new GIF;
	if (!strcmp(file_ext, "png"))
		return new PNG;
	return NULL;
}

static VALUE danbooru_resize_image(VALUE module, VALUE file_ext_val, VALUE read_path_val, VALUE write_path_val,
		VALUE output_width_val, VALUE output_height_val,
		VALUE output_quality_val)
{
	const char * file_ext = StringValueCStr(file_ext_val);
	const char * read_path = StringValueCStr(read_path_val);
	const char * write_path = StringValueCStr(write_path_val);
	int output_width = NUM2INT(output_width_val);
	int output_height = NUM2INT(output_height_val);
	int output_quality = NUM2INT(output_quality_val);

	FILE *read_file = fopen(read_path, "rb");
	if(read_file == NULL)
		rb_raise(rb_eIOError, "can't open %s\n", read_path);

	FILE *write_file = fopen(write_path, "wb");
	if(write_file == NULL)
	{
		fclose(read_file);
		rb_raise(rb_eIOError, "can't open %s\n", write_path);
	}

	bool ret = false;
	char error[1024];

	try
	{
		auto_ptr<Reader> pReader(GetReader(file_ext));
		if(pReader.get() == NULL)
		{
			strcpy(error, "unknown filetype");
			goto cleanup;
		}

		auto_ptr<Filter> pFilter(NULL);

		{
			auto_ptr<JPEGCompressor> pCompressor(new JPEGCompressor(write_file));
			pCompressor->SetQuality(output_quality);
			pFilter.reset(pCompressor.release());
		}

		{
			auto_ptr<Resizer> pResizer(new Resizer(pFilter));
			pResizer->SetDest(output_width, output_height);
			pFilter.reset(pResizer.release());
		}


		{
			auto_ptr<ConvertToRGB> pConverter(new ConvertToRGB(pFilter));
			pFilter.reset(pConverter.release());
		}

		ret = pReader->Read(read_file, pFilter.get(), error);
	}
	catch(const std::bad_alloc &e)
	{
		strcpy(error, "out of memory");
	}

cleanup:
	fclose(read_file);
	fclose(write_file);

	if(!ret)
		rb_raise(rb_eException, "%s", error);

	return INT2FIX(0);
}

static VALUE danbooru_histogram(VALUE module, VALUE file_ext_val, VALUE read_path_val)
{
	const char * file_ext = StringValueCStr(file_ext_val);
	const char * read_path = StringValueCStr(read_path_val);

	FILE *read_file = fopen(read_path, "rb");
	if(read_file == NULL)
		rb_raise(rb_eIOError, "can't open %s\n", read_path);

	bool ret = false;
	char error[1024];
	VALUE results = Qnil;

	try
	{
		auto_ptr<Reader> pReader(GetReader(file_ext));
		if(pReader.get() == NULL)
		{
			strcpy(error, "unknown filetype");
			goto cleanup;
		}

		auto_ptr<Filter> pFilter(NULL);

		Histogram *pHistogram = new Histogram();
		pFilter.reset(pHistogram);

		{
			auto_ptr<ConvertToRGB> pConverter(new ConvertToRGB(pFilter));
			pFilter.reset(pConverter.release());
		}

		ret = pReader->Read(read_file, pFilter.get(), error);

		results = rb_ary_new();
		int channels = pHistogram->GetChannels();
		for(int channel = 0; channel < channels; ++channel)
		{
			const unsigned *pChannelData = pHistogram->GetHistogram(channel);
			VALUE channel_array = rb_ary_new();
			rb_ary_push(results, channel_array);

			for(int i = 0; i < 256; ++i)
				rb_ary_push(channel_array, INT2NUM(pChannelData[i]));
		}
	}
	catch(const std::bad_alloc &e)
	{
		strcpy(error, "out of memory");
	}

cleanup:
	fclose(read_file);

	if(!ret)
		rb_raise(rb_eException, "%s", error);

	return results;
}

extern "C" void Init_danbooru_image_resizer() {
  danbooru_module = rb_define_module("Danbooru");
  rb_define_module_function(danbooru_module, "resize_image", (VALUE(*)(...))danbooru_resize_image, 6);
  rb_define_module_function(danbooru_module, "histogram", (VALUE(*)(...))danbooru_histogram, 2);
}
