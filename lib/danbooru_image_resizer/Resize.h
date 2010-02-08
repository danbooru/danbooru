#ifndef RESIZE_H
#define RESIZE_H

#include <stdint.h>

class JPEGCompressor;

class Resizer
{
public:
	Resizer(JPEGCompressor *Compressor);
	~Resizer();

	// BPP is 3 or 4, indicating RGB or RGBA.
	void SetSource(int Width, int Height, int BPP);
	bool SetDest(int Width, int Height, int Quality);

	/*
	 * Resize part of an image.
	 *
	 * [FirstRow,LastRow) is a range indicating which elements in src[] are available.
	 * On return, any rows in [0,DiscardRow) are no longer needed and can be deleted.
	 */
	bool Run(const uint8_t *const *src, int FirstRow, int LastRow, int &DiscardRow);
	const char *GetError() const;

private:
	JPEGCompressor *m_Compressor;
	uint8_t *m_OutBuf;

	int m_SourceWidth;
	int m_SourceHeight;
	int m_SourceBPP;

	int m_DestWidth;
	int m_DestHeight;

	float m_CurrentY;
};

#endif
