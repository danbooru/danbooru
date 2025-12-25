import UgoiraRenderer from './ugoira_renderer.js';

export default class Ugoira {
  constructor(ugoiraContainer) {
    this.$ugoiraContainer = $(ugoiraContainer);
    this.paused = true;
    this.duration = 0;

    let $canvas = this.$ugoiraContainer.find("canvas");
    let fileUrl = $canvas.data("src");
    let fileSize = $canvas.data("file-size");
    let frameDelays = $canvas.data("frame-delays");
    let frameOffsets = $canvas.data("frame-offsets");

    this._currentTime = 0;
    this._ugoira = new UgoiraRenderer(fileUrl, $canvas.get(0), frameDelays, { frameOffsets, fileSize });
    this._sample = this.$ugoiraContainer.find("video").get(0);
  }

  initialize() {
    this.$ugoiraContainer.data("ugoira", this);
    this.$ugoiraContainer.get(0).ugoira = this;

    $(document).on("visibilitychange", event => this.onVisibilityChange(event));
    this.$ugoiraContainer.on("keydown", event => this.onKeypress(event));
    this.$ugoiraContainer.on("fullscreenchange", event => this.fullscreen = document.fullscreenElement !== null);
    this.$ugoiraContainer.find("canvas, video").on("click", event => this.togglePlaying());
    this.$ugoiraContainer.find("canvas, video").on("dblclick", event => this.toggleFullscreen(event));
    this.$ugoiraContainer.find("canvas, video").on("seeking", event => this.currentTime = this.video.currentTime);
    this.$ugoiraContainer.find("canvas, video").on("progress", event => this.currentTime = this.video.currentTime);
    this.$ugoiraContainer.find("canvas, video").on("timeupdate", event => this.currentTime = this.video.currentTime);
    this.$ugoiraContainer.find("canvas, video").on("durationchange", event => this.duration = this.video.duration);
    this.$ugoiraContainer.find(".ugoira-slider").on("pointerdown", event => this.onDragStart(event));
    this.$ugoiraContainer.find(".ugoira-slider").on("pointerup", event => this.onDragEnd(event));
    this.$ugoiraContainer.find(".ugoira-slider").on("input", event => this.onDrag(event));

    let quality = this.$ugoiraContainer.data("quality");
    this.setQuality(quality);
    this.play();
  }

  play() {
    this.video?.play();
    this.paused = false;
  }

  pause() {
    this.resumePlayback = !this.paused;
    this.video?.pause();
    this.paused = true;
  }

  // Resumes playing the ugoira if it was previously playing before it was last paused.
  resume() {
    if (this.resumePlayback) {
      this.play();
    }
  }

  togglePlaying() {
    if (this.paused) {
      this.play();
    } else {
      this.pause();
    }
  }

  // Called when the playback slider starts being dragged. Pauses the ugoira while the user drags the playback slider.
  onDragStart(event) {
    // Ignore right clicks.
    if (event.pointerType !== "mouse" || event.button === 0) {
      this.scrubbing = true;
      this.pause();
    }
  }

  // Called as the playback slider is being dragged. Updates the current time based on the playback slider position.
  onDrag(event) {
    if (this.scrubbing) {
      this.currentTime = parseFloat(event.target.value);
    }
  }

  // Called when the playback slider stops being dragged. Resumes the ugoira if it was playing before the user started dragging the slider.
  onDragEnd(event) {
    if (this.scrubbing) {
      this.resume();
      this.scrubbing = false;
    }
  }

  // Called when a key is pressed while the ugoira player has focus. Ignores keypresses while the playback slider is being dragged.
  onKeypress(event) {
    if (this.scrubbing) {
      return;
    }

    if (event.key === " ") {
      this.togglePlaying();
    } else if (event.key === "ArrowLeft") {
      this.currentTime -= this.duration * 0.01;
    } else if (event.key === "ArrowRight") {
      this.currentTime += this.duration * 0.01;
    } else {
      return;
    }

    event.preventDefault();
  }

  // Pauses the video while the user is tabbed out.
  onVisibilityChange(event) {
    if (document.hidden) {
      this.pause();
    } else {
      this.resume();
    }
  }

  // Sets the video to either the original ugoira video or the webm sample video. Playback will continue from the
  // current time when the video is switched.
  setQuality(quality) {
    if (quality === this.quality) {
      return;
    }

    this.pause();
    this.quality = quality;

    if (quality === "original") {
      this.video = this._ugoira;
      this.duration = this._ugoira.duration || 0;
      this.currentTime = this._sample.currentTime || 0;
      this.video.load();
    } else if (quality === "sample") {
      this.video = this._sample;
      this.duration = this._sample.duration || 0;
      this.currentTime = this._ugoira.currentTime || 0;
      this.video.load();
    }

    this.resume();
  }

  // Toggle fullscreen mode.
  toggleFullscreen(event) {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else if (document.fullscreenEnabled) {
      this.$ugoiraContainer.get(0).requestFullscreen();
    }
  }

  get currentTime() {
    return this._currentTime;
  }

  set currentTime(time) {
    this._currentTime = time;

    if (this.video.currentTime !== time) {
      this.video.currentTime = time;
    }
  }

  // The percentage of the video that has been played.
  get playbackProgress() {
    return this.formatPercentage(this.currentTime, this.duration);
  }

  // The percentage of the video that has been downloaded.
  get loadProgress() {
    // XXX Hack to force Alpine to update the progress bar every time the time is updated, because browsers don't always
    // send the final progress event when the video finishes loading, which causes the loading bar to get stuck below 100%.
    this.currentTime;

    let buffered = this.video.buffered;
    let bufferedDuration = buffered.length > 0 ? buffered.end(buffered.length - 1) : 0;

    // Sometimes the browser has buffered part of the video and started playback, but it hasn't finished downloading
    // the metadata and so doesn't know the duration yet. Just say we've loaded something in that case.
    if (bufferedDuration > 0 && this.duration === 0) {
      return "1%";
    // Sometimes the browser says it hasn't buffered anything yet, but it says the video is ready and has already
    // started playback, so it's at least downloaded something.
    } else if (bufferedDuration === 0 && this.video.readyState > 1) {
      return "1%"
    } else {
      // XXX Some webm samples have an incorrect duration, which causes the load progress to be wrong.
      // Ex: https://danbooru.donmai.us/posts/3448662
      return this.formatPercentage(bufferedDuration, this.duration);
    }
  }

  // Format a time in seconds as "0:00".
  formatTime(seconds) {
    const mm = Math.floor(seconds / 60).toString().padStart(1, '0');
    const ss = Math.floor(seconds % 60).toString().padStart(2, '0');

    return `${mm}:${ss}`;
  }

  // Format a ratio as "12.3%"
  formatPercentage(numerator, denominator, precision = 1) {
    if (denominator) {
      let roundedRatio = Math.round(Math.pow(10, precision) * 100 * (numerator / denominator)) / Math.pow(10, precision);
      return `${roundedRatio}%`;
    } else {
      return "0%";
    }
  }
}
