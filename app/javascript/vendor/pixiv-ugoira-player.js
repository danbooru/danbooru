// Source: https://github.com/pixiv/zip_player

function ZipImagePlayer(options) {
    this.op = options;
    if (!URL) {
        this._error("No URL support");
    }
    if (!Blob) {
        this._error("No Blob support");
    }
    if (!Uint8Array) {
        this._error("No Uint8Array support");
    }
    if (!DataView) {
        this._error("No DataView support");
    }
    if (!ArrayBuffer) {
        this._error("No ArrayBuffer support");
    }
    if (!this.op.source) {
        this._error("No source URL provided");
    }
    this._loadingState = 0;
    this._dead = false;
    this._context = options.canvas.getContext("2d");
    this._files = [];
    this._frameCount = this.op.metadata.frames.length;
    this._debugLog("Frame count: " + this._frameCount);
    this._frame = 0;
    this._loadFrame = 0;
    this._frameImages = [];
    this._paused = false;
    this._startLoad();
    if (this.op.autoStart) {
        this.play();
    } else {
        this._paused = true;
    }
}

ZipImagePlayer.prototype = {
    _trailerBytes: 30000,
    _failed: false,
    _mkerr: function(msg) {
        var _this = this;
        return function() {
            _this._error(msg);
        }
    },
    _error: function(msg) {
        this._failed = true;
        throw Error("ZipImagePlayer error: " + msg);
    },
    _debugLog: function(msg) {
        if (this.op.debug) {
            console.log(msg);
        }
    },
    _load: function(offset, length, callback) {
        var _this = this;
        // Unfortunately JQuery doesn't support ArrayBuffer XHR
        var xhr = new XMLHttpRequest();
        xhr.addEventListener("load", function(ev) {
            if (_this._dead) {
                return;
            }
            _this._debugLog("Load: " + offset + " " + length + " status=" +
                            xhr.status);
            if (xhr.status == 200) {
                _this._debugLog("Range disabled or unsupported, complete load");
                offset = 0;
                length = xhr.response.byteLength;
                _this._len = length;
                _this._buf = xhr.response;
                _this._bytes = new Uint8Array(_this._buf);
            } else {
                if (xhr.status != 206) {
                    _this._error("Unexpected HTTP status " + xhr.status);
                }
                if (xhr.response.byteLength != length) {
                    _this._error("Unexpected length " +
                                 xhr.response.byteLength +
                                 " (expected " + length + ")");
                }
                _this._bytes.set(new Uint8Array(xhr.response), offset);
            }
            if (callback) {
                callback.apply(_this, [offset, length]);
            }
        }, false);
        xhr.addEventListener("error", this._mkerr("Fetch failed"), false);
        xhr.open("GET", this.op.source);
        xhr.responseType = "arraybuffer";
        if (offset != null && length != null) {
            var end = offset + length;
            xhr.setRequestHeader("Range", "bytes=" + offset + "-" + (end - 1));
        }
        /*this._debugLog("Load: " + offset + " " + length);*/
        xhr.send();
    },
    _startLoad: function() {
        var _this = this;
        $.ajax({
            url: this.op.source,
            type: "HEAD"
        }).done(function(data, status, xhr) {
            if (_this._dead) {
                return;
            }
            _this._pHead = 0;
            _this._pNextHead = 0;
            _this._pFetch = 0;
            var len = parseInt(xhr.getResponseHeader("Content-Length"));
            if (!len) {
                _this._debugLog("HEAD request failed: invalid file length.");
                _this._debugLog("Falling back to full file mode.");
                _this._load(null, null, function(off, len) {
                    _this._pTail = 0;
                    _this._pHead = len;
                    _this._findCentralDirectory();
                });
                return;
            }
            _this._debugLog("Len: " + len);
            _this._len = len;
            _this._buf = new ArrayBuffer(len);
            _this._bytes = new Uint8Array(_this._buf);
            var off = len - _this._trailerBytes;
            if (off < 0) {
                off = 0;
            }
            _this._pTail = len;
            _this._load(off, len - off, function(off, len) {
                _this._pTail = off;
                _this._findCentralDirectory();
            });
        }).fail(this._mkerr("Length fetch failed"));
    },
    _findCentralDirectory: function() {
        // No support for ZIP file comment
        var dv = new DataView(this._buf, this._len - 22, 22);
        if (dv.getUint32(0, true) != 0x06054b50) {
            this._error("End of Central Directory signature not found");
        }
        var cd_count = dv.getUint16(10, true);
        var cd_size = dv.getUint32(12, true);
        var cd_off = dv.getUint32(16, true);
        if (cd_off < this._pTail) {
            this._load(cd_off, this._pTail - cd_off, function() {
                this._pTail = cd_off;
                this._readCentralDirectory(cd_off, cd_size, cd_count);
            });
        } else {
            this._readCentralDirectory(cd_off, cd_size, cd_count);
        }
    },
    _readCentralDirectory: function(offset, size, count) {
        var dv = new DataView(this._buf, offset, size);
        var p = 0;
        for (var i = 0; i < count; i++ ) {
            if (dv.getUint32(p, true) != 0x02014b50) {
                this._error("Invalid Central Directory signature");
            }
            var compMethod = dv.getUint16(p + 10, true);
            var uncompSize = dv.getUint32(p + 24, true);
            var nameLen = dv.getUint16(p + 28, true);
            var extraLen = dv.getUint16(p + 30, true);
            var cmtLen = dv.getUint16(p + 32, true);
            var off = dv.getUint32(p + 42, true);
            if (compMethod != 0) {
                this._error("Unsupported compression method");
            }
            p += 46 + nameLen + extraLen + cmtLen;
            this._files[i] = {off: off, len: uncompSize};
        }
        // Two outstanding fetches at any given time.
        // Note: the implementation does not support more than two.
        if (this._pHead >= this._pTail) {
            this._pHead = this._len;
            $(this).triggerHandler("loadProgress", [this._pHead / this._len]);
            this._loadNextFrame();
        } else {
            this._loadNextChunk();
            this._loadNextChunk();
        }
    },
    _loadNextChunk: function() {
        if (this._pFetch >= this._pTail) {
            return;
        }
        var off = this._pFetch;
        var len = this.op.chunkSize;
        if (this._pFetch + len > this._pTail) {
            len = this._pTail - this._pFetch;
        }
        this._pFetch += len;
        this._load(off, len, function() {
            if (off == this._pHead) {
                if (this._pNextHead) {
                    this._pHead = this._pNextHead;
                    this._pNextHead = 0;
                } else {
                    this._pHead = off + len;
                }
                if (this._pHead >= this._pTail) {
                    this._pHead = this._len;
                }
                /*this._debugLog("New pHead: " + this._pHead);*/
                $(this).triggerHandler("loadProgress",
                                       [this._pHead / this._len]);
                this._loadNextFrame();
            } else {
                this._pNextHead = off + len;
            }
            this._loadNextChunk();
        });
    },
    _fileDataStart: function(offset) {
        var dv = new DataView(this._buf, offset, 30);
        var nameLen = dv.getUint16(26, true);
        var extraLen = dv.getUint16(28, true);
        return offset + 30 + nameLen + extraLen;
    },
    _isFileAvailable: function(index) {
        var info = this._files[index];
        if (!info) {
            this._error("File " + index + " not found in ZIP");
        }
        if (this._pHead < (info.off + 30)) {
            return false;
        }
        return this._pHead >= (this._fileDataStart(info.off) + info.len);
    },
    _loadNextFrame: function() {
        if (this._dead) {
            return;
        }
        var frame = this._loadFrame;
        if (frame >= this._frameCount) {
            return;
        }
        if (!this._isFileAvailable(frame)) {
            return;
        }
        this._loadFrame += 1;
        var off = this._fileDataStart(this._files[frame].off);
        var end = off + this._files[frame].len;
        var slice = this._buf.slice(off, end);
        var blob = new Blob([slice]);
        /*_this._debugLog("Loading " + meta.file + " to frame " + frame);*/
        var url = URL.createObjectURL(blob);
        this._loadImage(frame, url);
    },
    _loadImage: function(frame, url) {
        var _this = this;
        var image = new Image();
        image.addEventListener('load', function() {
            _this._debugLog(`Loaded frame ${frame}`);
            URL.revokeObjectURL(url);
            if (_this._dead) {
                return;
            }
            _this._frameImages[frame] = image;
            $(_this).triggerHandler("frameLoaded", frame);
            if (_this._loadingState == 0) {
                _this._displayFrame.apply(_this);
            }
            if (frame >= (_this._frameCount - 1)) {
                _this._setLoadingState(2);
                _this._buf = null;
                _this._bytes = null;
            } else {
                _this._loadNextFrame();
            }
        });
        image.src = url;
    },
    _setLoadingState: function(state) {
        if (this._loadingState != state) {
            this._loadingState = state;
            $(this).triggerHandler("loadingStateChanged", [state]);
        }
    },
    _displayFrame: function() {
        if (this._dead) {
            return;
        }
        var _this = this;
        var delay = this.op.metadata.frames[this._frame];
        this._debugLog("Displaying frame: " + this._frame);
        var image = this._frameImages[this._frame];
        if (!image) {
            this._debugLog("Image not available!");
            this._setLoadingState(0);
            return;
        }
        if (this._loadingState != 2) {
            this._setLoadingState(1);
        }
        if (this.op.autosize) {
            if (this._context.canvas.width != image.width || this._context.canvas.height != image.height) {
                // make the canvas autosize itself according to the images drawn on it
                // should set it once, since we don't have variable sized frames
                this._context.canvas.width = image.width;
                this._context.canvas.height = image.height;
            }
        };
        this._context.clearRect(0, 0, this.op.canvas.width,
                                this.op.canvas.height);
        this._context.drawImage(image, 0, 0);
        $(this).triggerHandler("frame", this._frame);
        if (!this._paused) {
            this._timer = setTimeout(function() {
                _this._timer = null;
                _this._nextFrame.apply(_this);
            }, delay);
        }
    },
    _nextFrame: function(frame) {
        if (this._frame >= (this._frameCount - 1)) {
            if (this.op.loop) {
                this._frame = 0;
            } else {
                this.pause();
                return;
            }
        } else {
            this._frame += 1;
        }
        this._displayFrame();
    },
    play: function() {
        if (this._dead) {
            return;
        }
        if (this._paused) {
            $(this).triggerHandler("play", [this._frame]);
            this._paused = false;
            this._displayFrame();
        }
    },
    pause: function() {
        if (this._dead) {
            return;
        }
        if (!this._paused) {
            if (this._timer) {
                clearTimeout(this._timer);
            }
            this._paused = true;
            $(this).triggerHandler("pause", [this._frame]);
        }
    },
    rewind: function() {
        if (this._dead) {
            return;
        }
        this._frame = 0;
        if (this._timer) {
            clearTimeout(this._timer);
        }
        this._displayFrame();
    },
    stop: function() {
        this._debugLog("Stopped!");
        this._dead = true;
        if (this._timer) {
            clearTimeout(this._timer);
        }
        this._frameImages = null;
        this._buf = null;
        this._bytes = null;
        $(this).triggerHandler("stop");
    },
}

export { ZipImagePlayer };
