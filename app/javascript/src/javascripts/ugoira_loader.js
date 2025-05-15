// https://users.cs.jmu.edu/buchhofp/forensics/formats/pkzip.html

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

export default class UgoiraLoader {
  constructor(fileUrl, { frameCount = null, fileSize = null } = {}) {
    this.fileUrl = fileUrl; // The URL of the .zip file.
    this.failed = false;    // True if any errors occured while loading the ugoira.
    this.onload = null;     // An optional callback called when a frame is loaded.

    this._frameCount = frameCount;
    this._fileSize = fileSize;
    this._endOfCentralDirectory = null;
    this._frames = [];
  }

  // Read a range of bytes from the remote .zip file.
  async read(offset, length) {
    let response = await fetch(this.fileUrl, {
      method: 'GET',
      headers: { 'Range': `bytes=${offset}-${offset + length - 1}` }
    });

    this.assert(response.status === 206, `read() failed (status: ${response.status})`);

    let buffer = await response.arrayBuffer();
    return new DataView(buffer);
  }

  // Return the size of the ugoira .zip file in bytes. If we don't already know the size, we have to do a HEAD request
  // to get the Content-Length header.
  async fileSize() {
    if (this._fileSize) { return this._fileSize; }

    let response = await fetch(this.fileUrl, { method: 'HEAD' });

    this.assert(response.status === 200, `fileSize() failed (status: ${response.status})`);
    this.assert(response.headers.has('Content-Length'), `fileSize() failed (no Content-Length header)`);
    this.assert(response.headers.get('Content-Type') === 'application/zip', `fileSize() failed (not a zip file)`);

    this._fileSize = parseInt(response.headers.get('Content-Length'), 10);
    return this._fileSize;
  }

  // Return the end of central directory record. This is the last 22 bytes of the zip file, which contains the size and
  // location of the central directory, which contains the list of files in the zip file. If we know the file size and
  // frame count, we can calculate the location of the central directory without having to read the file based on the
  // assumption that filenames are always 10 bytes long and there are no extra fields or comments. This should always be
  // true, but if it's wrong, we'll detect it when we parse the central directory.
  async endOfCentralDirectory() {
    if (this._endOfCentralDirectory) { return this._endOfCentralDirectory; }

    if (this._frameCount && this._fileSize) {
      let cdEntries = this._frameCount;              // The number of entries in the central directory is just the number of frames.
      let cdLength = cdEntries * 56;                 // Each central directory entry is assumed to be 56 bytes long (46 byte header + 10 byte file name).
      let cdOffset = this._fileSize - cdLength - 22; // The end of the central directory record starts 22 bytes before the end of the file (assuming no file comment).

      this._endOfCentralDirectory = { cdLength, cdOffset, cdEntries };
    } else {
      let fileSize = await this.fileSize();
      let eocd = await this.read(fileSize - 22, 22);
      let signature = eocd.getUint32(0, true);
      let cdEntries = eocd.getUint16(10, true);
      let cdLength = eocd.getUint32(12, true);
      let cdOffset = eocd.getUint32(16, true);

      this.assert(signature === 0x06054b50, `endOfCentralDirectory() failed (bad signature, signature=${signature.toString(16)})`);
      this.assert(cdOffset + cdLength <= fileSize, `endOfCentralDirectory() failed (bad central directory size, cdLength: ${cdLength}, fileSize: ${fileSize})`);

      this._endOfCentralDirectory = { cdLength, cdOffset, cdEntries };
    }

    return this._endOfCentralDirectory;
  }

  // Return the list of frames in the ugoira. Each frame will have `fileOffset` and `fileSize` properties indicating the
  // location of the frame in the zip file. Frames will have an `image` property after the frame is loaded by loadFrames().
  async frames() {
    if (this._frames.length) { return this._frames; }

    let { cdOffset, cdLength, cdEntries } = await this.endOfCentralDirectory();
    let cdBuffer = await this.read(cdOffset, cdLength);
    let entries = [];

    // Parse the entries from the central directory. Each entry is 46 bytes long, plus a variable-length file name,
    // extra field, and file comment. The file name is always 10 bytes long, and the extra field and file comment are
    // always 0 bytes long, so each entry is always 56 bytes long. Each entry points to a 40-byte file header followed
    // by the file data.
    for (let i = 0, offset = 0; i < cdEntries; i++) {
      let entry = {};

      let signature = cdBuffer.getUint32(offset, true);
      let compressionMethod = cdBuffer.getUint16(offset + 10, true);
      let fileNameLength = cdBuffer.getUint16(offset + 28, true);
      let extraFieldLength = cdBuffer.getUint16(offset + 30, true);
      let fileCommentLength = cdBuffer.getUint16(offset + 32, true);
      let headerOffset = cdBuffer.getUint32(offset + 42, true);
      let entryLength = 46 + fileNameLength + extraFieldLength + fileCommentLength;

      // The file data starts after the file header. The header is 30 bytes long, plus a variable-length file name which
      // is always 10 bytes long, and an extra field which is always zero, so the file header is always 40 bytes long.
      entry.fileOffset = headerOffset + 30 + fileNameLength + extraFieldLength;
      entry.fileSize = cdBuffer.getUint32(offset + 20, true);

      this.assert(signature === 0x02014b50, `centralDirectory() failed (bad signature, entry: ${i}, signature: ${signature.toString(16)})`);
      this.assert(compressionMethod === 0, `centralDirectory() failed (bad compression method, entry: ${i}, compressionMethod: ${compressionMethod})`);
      this.assert(fileNameLength === 10, `centralDirectory() failed (bad file name length, entry: ${i}, fileNameLength: ${fileNameLength})`);
      this.assert(extraFieldLength === 0, `centralDirectory() failed (bad extra field length, entry: ${i}, extraFieldLength: ${extraFieldLength})`);
      this.assert(fileCommentLength === 0, `centralDirectory() failed (bad file comment length, entry: ${i}, fileCommentLength: ${fileCommentLength})`);
      this.assert(offset <= cdLength, `centralDirectory() failed (bad central directory length, entry: ${i}, offset: ${offset}, cdLength: ${cdLength})`);
      this.assert(entry.fileOffset + entry.fileSize <= cdOffset, `centralDirectory() failed (bad file length, entry: ${i}, fileOffset: ${entry.fileOffset}, fileSize: ${entry.fileSize}, cdOffset: ${cdOffset})`);
      this.assert(entryLength === 56, `centralDirectory() failed (bad entry length, entry: ${i}, length: ${entryLength})`);

      entries.push(entry);
      offset += entryLength;
    }

    this._frames = entries;
    return this._frames;
  }

  // Load the frames from N to N + count. Multiple images can be loaded at once to reduce the number of HTTP requests.
  async loadFrames(n, count = 1) {
    let frames = await this.frames();

    count = clamp(count, 1, frames.length - n);
    let frameGroup = frames.slice(n, n + count);

    // Return the existing frames if they're loaded already.
    if (n >= frames.length || (frameGroup.length === count && frameGroup.every(frame => frame.image))) {
      return frameGroup;
    }

    // Read a group of files from N to N+count from the zip file. There is a 40 byte header between each file in the zip file.
    let frameGroupOffset = frames[n].fileOffset;
    let frameGroupSize = frameGroup.reduce((sum, frame) => sum + frame.fileSize, 0) + 40 * (count - 1);
    let frameGroupData = await this.read(frameGroupOffset, frameGroupSize);
    let images = [];

    // Split the frame group into individual frames and load the raw image data into <img src="blob:..."> elements.
    for (let i = n; i < n + count; i++) {
      let frame = frames[i];
      let frameOffset = frame.fileOffset - frameGroupOffset;
      let frameData = frameGroupData.buffer.slice(frameOffset, frameOffset + frame.fileSize);
      let blob = new Blob([frameData]);
      let url = URL.createObjectURL(blob);
      let image = new Image();

      let promise = new Promise((resolve, reject) => {
        image.src = url;

        image.onload = () => {
          frame.image = image;
          URL.revokeObjectURL(url);
          this.onload?.(i, frame);
          resolve(image);
        };

        image.onerror = () => {
          URL.revokeObjectURL(url);
          this.failed = true;
          reject(new Error(`Failed to load frame ${n}`));
        }
      });

      images.push(promise);
    }

    return images;
  }

  // Load all frames in the ugoira. Frames are loaded in chunks of around 500kb, with 4 chunks loading in parallel.
  async load(chunkSize = 500000, chunks = 4) {
    let frames = await this.frames();
    let fileSize = await this.fileSize();
    let framesPerChunk = clamp(Math.round(chunkSize / (fileSize / frames.length)), 1, frames.length);

    for (let frame = 0; frame < frames.length; frame += framesPerChunk * chunks) {
      let promises = Array.from({ length: chunks }).map((_, chunk) => {
        let chunkStart = frame + framesPerChunk * chunk;

        if (chunkStart < frames.length) {
          return this.loadFrames(chunkStart, framesPerChunk);
        }
      });

      await Promise.all(promises);
    }
  }

  assert(condition, message) {
    if (!condition) {
      this.failed = true;
      throw new Error(`[Ugoira] ${message}`);
    }
  }
}
