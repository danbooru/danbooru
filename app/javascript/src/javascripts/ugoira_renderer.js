// https://users.cs.jmu.edu/buchhofp/forensics/formats/pkzip.html

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

// A UgoiraLoader loads a ugoira from a remote .zip file. It reads the .zip file in chunks using range requests, parses
// the file to find the frames, and returns the frames as <img src="blob:..."> elements.
export class UgoiraLoader {
  constructor(fileUrl, frameDelays, frameOffsets = null, fileSize = null) {
    this.fileUrl = fileUrl; // The URL of the .zip file.

    this._fileSize = fileSize;
    this._endOfCentralDirectory = null;
    this._frames = this.initFrames(frameDelays, frameOffsets, fileSize);
  }

  // Calculate the start and end times of each frame in the ugoira, and the file offsets and sizes if provided.
  initFrames(frameDelays, frameOffsets = null, fileSize = null) {
    let frameStart = 0;

    return frameDelays.map((frameDelay, i) => {
      let frame = {};
      let duration = frameDelay / 1000;

      frame.frameStart = frameStart;
      frame.frameEnd = frameStart + duration;

      if (frameOffsets?.[i] != null && fileSize != null) {
        frame.fileOffset = frameOffsets[i] + 40; // 40 bytes for the zip file header
        frame.fileSize = (frameOffsets[i + 1] ?? fileSize) - frame.fileOffset;
      }

      frameStart += duration;
      return frame;
    });
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
  // location of the central directory, which contains the list of files in the zip file.
  async endOfCentralDirectory() {
    if (this._endOfCentralDirectory) { return this._endOfCentralDirectory; }

    let fileSize = await this.fileSize();
    let eocd = await this.read(fileSize - 22, 22);
    let signature = eocd.getUint32(0, true);
    let cdEntries = eocd.getUint16(10, true);
    let cdLength = eocd.getUint32(12, true);
    let cdOffset = eocd.getUint32(16, true);

    this.assert(signature === 0x06054b50, `endOfCentralDirectory() failed (bad signature, signature=${signature.toString(16)})`);
    this.assert(cdOffset + cdLength <= fileSize, `endOfCentralDirectory() failed (bad central directory size, cdLength: ${cdLength}, fileSize: ${fileSize})`);

    this._endOfCentralDirectory = { cdLength, cdOffset, cdEntries };

    return this._endOfCentralDirectory;
  }

  // Return the list of frames in the ugoira. Each frame will have `fileOffset` and `fileSize` properties indicating the
  // location of the frame in the zip file. Frames will have an `image` property after the frame is loaded by loadFrames().
  async frames() {
    if (this._frames[0].fileOffset != null) { return this._frames; }

    let { cdOffset, cdLength, cdEntries } = await this.endOfCentralDirectory();
    let cdBuffer = await this.read(cdOffset, cdLength);

    // Parse the entries from the central directory. Each entry is 46 bytes long, plus a variable-length file name,
    // extra field, and file comment. The file name is always 10 bytes long, and the extra field and file comment are
    // always 0 bytes long, so each entry is always 56 bytes long. Each entry points to a 40-byte file header followed
    // by the file data.
    for (let i = 0, offset = 0; i < cdEntries; i++) {
      let entry = this._frames[i];

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

      offset += entryLength;
    }

    return this._frames;
  }

  // Load the frames from N to N + count. Multiple images can be loaded at once to reduce the number of HTTP requests.
  async loadFrames(n, count = 1, loadFrameCallback = null) {
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
          loadFrameCallback?.(i);
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
  async load(chunkSize = 500000, chunks = 4, loadFrameCallback = null) {
    let frames = await this.frames();
    let fileSize = await this.fileSize();
    let framesPerChunk = clamp(Math.round(chunkSize / (fileSize / frames.length)), 1, frames.length);

    for (let frame = 0; frame < frames.length; frame += framesPerChunk * chunks) {
      let promises = Array.from({ length: chunks }).map((_, chunk) => {
        let chunkStart = frame + framesPerChunk * chunk;

        if (chunkStart < frames.length) {
          return this.loadFrames(chunkStart, framesPerChunk, loadFrameCallback);
        }
      });

      await Promise.all(promises);
    }
  }

  assert(condition, message) {
    if (!condition) {
      throw new Error(`[Ugoira] ${message}`);
    }
  }
}

// A UgoiraRenderer renders a ugoira on a <canvas>. It uses a UgoiraLoader to load frames and animates them using
// requestAnimationFrame. It implements the HTMLMediaElement interface so it can be used as a <video> element.
//
// https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement
export default class UgoiraRenderer {
  constructor(fileUrl, canvas, frameDelays, { frameOffsets = null, fileSize = null } = {}) {
    this.currentSrc = fileUrl;
    this.paused = true;
    this.width = canvas.width;
    this.height = canvas.height;
    this.duration = frameDelays.reduce((sum, n) => sum + n, 0) / 1000;

    // https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/networkState
    // https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/readyState
    this.networkState = HTMLMediaElement.NETWORK_IDLE; // EMPTY, IDLE, LOADING, NO_SOURCE
    this.readyState = HTMLMediaElement.HAVE_METADATA; // HAVE_NOTHING, HAVE_METADATA, HAVE_CURRENT_DATA, HAVE_FUTURE_DATA, HAVE_ENOUGH_DATA

    this._canvas = canvas;      // The <canvas> element the ugoira is drawn on.
    this._previousTime = null;  // The time in seconds of the last requestAnimationFrame call. Used for measuring elapsed time.
    this._currentTime = 0;      // The current playback time in seceonds (e.g 3.2 means we're 3.2 seconds into the ugoira).
    this._animationId = null;   // The handle for the requestAnimationFrame callback that updates the canvas.
    this._loadedFrame = null;   // The frame number of the latest frame that is ready to be drawn.
    this._currentFrame = null;  // The frame that is currently being displayed on the canvas.
    this._loader = new UgoiraLoader(fileUrl, frameDelays, frameOffsets, fileSize);
    this._frames = this._loader._frames;

    this._context = this._canvas.getContext("2d");
    this._context.clearRect(0, 0, this.width, this.height);
  }

  // Starts loading the ugoira asynchronously. Does nothing if the ugoira is already loading or has been loaded.
  async load() {
    if (this.networkState === HTMLMediaElement.NETWORK_LOADING || this.readyState === HTMLMediaElement.HAVE_ENOUGH_DATA) {
      return;
    }

    this.networkState = HTMLMediaElement.NETWORK_LOADING;
    await this._loader.load(500000, 4, frame => {
      this._loadedFrame = Math.max(this._loadedFrame, frame);

      if (this.buffered.end(0) >= this.currentTime) {
        this.readyState = Math.max(this.readyState, HTMLMediaElement.HAVE_FUTURE_DATA);
      }

      if (this._currentFrame === null) {
        this.drawFrame(this.currentTime);
      }

      this.triggerEvent("progress", { frame: this._loadedFrame });
    });

    this.networkState = HTMLMediaElement.NETWORK_IDLE;
    this.readyState = HTMLMediaElement.HAVE_ENOUGH_DATA;
  }

  // Plays the ugoira. Starts the callback that renders the ugoira frames.
  play() {
    this.paused = false;

    this._previousTime = null;
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
    this.triggerEvent("play");
  }

  // Pauses the ugoira. Removes the callback that renders the ugoira frames.
  pause() {
    this.paused = true;

    cancelAnimationFrame(this._animationId);
    this.triggerEvent("pause");
  }

  // Called every ~16ms by the browser to advance playback and render a new frame. Loops playback when it reaches the end.
  onAnimationFrame() {
    let now = this.now();
    let elapsedTime = now - (this._previousTime ?? now);

    this.currentTime = (this.currentTime + elapsedTime) % this.duration;
    this._previousTime = now;
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  get currentTime() {
    return this._currentTime;
  }

  // Sets the current playback time and redraws the frame if it has changed. Doesn't allow seeking past loaded frames.
  set currentTime(seconds) {
    this._currentTime = clamp(seconds, 0, this.buffered.end(0));
    this.drawFrame(this.currentTime);
    this.triggerEvent("timeupdate");
  }

  // Renders the frame at the given time. Only redraws the frame if it has changed.
  drawFrame(time) {
    let frame = this.frameAt(time);

    if (frame !== this._currentFrame && frame?.image) {
      this._context.clearRect(0, 0, this.width, this.height);
      this._context.drawImage(frame.image, 0, 0);
      this._currentFrame = frame;
    }
  }

  // Returns an object representing the time ranges that have been downloaded and are ready to play. This indicates when
  // the last loaded frame ends. Conforms to the TimeRanges interface.
  //
  // https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/buffered
  // https://developer.mozilla.org/en-US/docs/Web/API/TimeRanges
  get buffered() {
    let endTime = this._loadedFrame !== null ? this._frames[this._loadedFrame].frameEnd : 0;

    return { length: 1, start: n => 0, end: n => endTime };
  }

  // Finds the frame at the given time.
  frameAt(seconds) {
    return this._frames.find(frame => frame.frameStart <= seconds && seconds < frame.frameEnd);
  }

  // Dispatches a custom event on the <canvas> element.
  triggerEvent(eventName, detail = {}) {
    let event = new CustomEvent(eventName, { bubbles: false, cancelable: false, detail });
    this._canvas.dispatchEvent(event);
  }

  // Returns the current time in seconds.
  now() {
    return performance.now() / 1000;
  }
}
