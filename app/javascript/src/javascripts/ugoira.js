import UgoiraLoader from './ugoira_loader.js';

export default class Ugoira {
  constructor($ugoiraContainer, { fileUrl = null, frameDelays = null, fileSize = null } = {}) {
    this.$ugoiraContainer = $ugoiraContainer;
    this.$canvas = $ugoiraContainer.find("canvas");
    this.$playButton = $ugoiraContainer.find(".ugoira-play");
    this.$pauseButton = $ugoiraContainer.find(".ugoira-pause");
    this.$fullscreenButton = $ugoiraContainer.find(".ugoira-fullscreen");
    this.$exitFullscreenButton = $ugoiraContainer.find(".ugoira-exit-fullscreen");
    this.$playbackSlider = $ugoiraContainer.find(".ugoira-slider");
    this.$currentTime = $ugoiraContainer.find(".ugoira-time");
    this.$duration = $ugoiraContainer.find(".ugoira-duration");

    this.fileUrl = fileUrl || $ugoiraContainer.attr("src");
    this.frames = frameDelays || $ugoiraContainer.data("frame-delays");
    this.fileSize = fileSize || $ugoiraContainer.data("file-size");
    this.context = this.$canvas.get(0).getContext("2d");
    this.width = this.$canvas.get(0).width;
    this.height = this.$canvas.get(0).height;

    this.previousTime = 0;       // The time in seconds when we last updated the ugoira. Used for measuring elapsed time.
    this.currentTime = 0;        // The current playback time of the ugoira (e.g 3.2 means we're 3.2 seconds into the ugoira).
    this.currentFrame = null;    // The current ugoira frame number.
    this.previousFrame = null;   // The previous ugoira frame number. Used for detecting when the frame has changed and the canvas needs to be rerendered.
    this.loadedFrame = null;     // The frame number of the latest frame that is ready to be drawn.
    this.loadProgress = 0;       // The percentage of ugoira frames that have been downloaded.
    this.scrubbing = false;      // Whether we're currently dragging the playback slider.
    this.playing = false;        // Whether the ugoira is currently playing or paused.
    this.resumePlayback = false; // Whether to resume playback after we stop scrubbing the playback slider or when we tab back in.
    this.animationId = null;     // The handle for the requestAnimationFrame callback that renders the next ugoira frame.

    this.duration = this.frames.reduce((sum, n) => sum + n, 0) / 1000; // The total duration of the ugoira in seconds.
    this.loader = new UgoiraLoader(this.fileUrl, { frameCount: this.frames.length, fileSize: fileSize });

    this.initialize();
  }

  initialize() {
    this.$ugoiraContainer.data("ugoira", this);
    this.$ugoiraContainer.get(0).ugoira = this;

    this.$duration.text(this.formatTime(Math.round(this.duration)));
    this.context.clearRect(0, 0, this.width, this.height);

    this.$canvas.on("click.danbooru", event => this.toggle(event));
    this.$playButton.on("click.danbooru", event => this.toggle(event));
    this.$pauseButton.on("click.danbooru", event => this.toggle(event));
    // this.$canvas.on("dblclick.danbooru", event => this.toggleFullscreen(event)); // XXX click event interferes with this.
    this.$fullscreenButton.on("click.danbooru", event => this.toggleFullscreen(event));
    this.$exitFullscreenButton.on("click.danbooru", event => this.toggleFullscreen(event));
    this.$ugoiraContainer.on("keydown.danbooru", event => this.onKeypress(event));
    this.$playbackSlider.on("pointerdown.danbooru", event => this.onDragStart(event));
    this.$playbackSlider.on("input.danbooru", event => this.onDrag(event));
    this.$playbackSlider.on("pointerup.danbooru", event => this.onDragEnd(event));
    $(document).on("visibilitychange", event => this.onVisibilityChange(event));

    this.loader.onload = frame => this.onLoadFrame(frame);
    this.loader.load();
  }

  // Starts playing the ugoira. Sets up a callback to animate the ugoira frames and update the UI as time passes.
  play() {
    this.playing = true;

    this.previousTime = this.now();
    this.animationId = requestAnimationFrame(() => this.onAnimationFrame());
    this.updateUI();
  }

  // Pauses the ugoira. Removes the callback that renders the ugoira frames.
  pause() {
    this.resumePlayback = this.playing;
    this.playing = false;

    cancelAnimationFrame(this.animationId);
    this.updateUI();
  }

  // Resumes playing the ugoira if it was previously playing before it was last paused.
  resume() {
    if (this.resumePlayback) {
      this.play();
    }
  }

  // Toggles between playing and paused.
  toggle(event = null) {
    if (this.playing) {
      this.pause();
    } else {
      this.play();
    }

    event.preventDefault();
  }

  // Fast forwards or rewinds a given number of seconds.
  advance(seconds) {
    this.setTime(this.currentTime + seconds);
  }

  // Updates the playback slider and the time display.
  updateUI() {
    let progress = Math.round(100 * (this.currentTime / this.duration));

    this.$currentTime.text(this.formatTime(this.currentTime));
    this.$playbackSlider.css("--playback-progress", `${progress}%`);
    this.$playbackSlider.val(this.currentTime);
    this.$ugoiraContainer.attr("data-playing", this.playing);

    if (this.playing) {
      this.$playButton.addClass("hidden");
      this.$pauseButton.removeClass("hidden");
    } else {
      this.$playButton.removeClass("hidden");
      this.$pauseButton.addClass("hidden");
    }

    if (document.fullscreenElement === this.$ugoiraContainer.get(0)) {
      this.$fullscreenButton.addClass("hidden");
      this.$exitFullscreenButton.removeClass("hidden");
    } else {
      this.$fullscreenButton.removeClass("hidden");
      this.$exitFullscreenButton.addClass("hidden");
    }
  }

  // Sets the current playback time and renders the frame if the frame has changed. Doesn't allow seeking past loaded frames.
  setTime(seconds) {
    this.currentTime = this.loadedFrame ? Math.min(this.frameStart(this.loadedFrame + 1), Math.max(0, seconds)) : 0;
    this.previousFrame = this.currentFrame;
    this.currentFrame = Math.min(this.loadedFrame, this.frameAt(this.currentTime));

    if (this.currentFrame !== this.previousFrame) {
      let drawn = this.drawFrame(this.currentFrame);

      if (!drawn) {
        this.currentFrame = null;
      }
    }

    this.updateUI();
  }

  // Draws frame N if it's loaded, or does nothing if the frame isn't loaded yet.
  drawFrame(n) {
    let image = this.loader._frames[n]?.image;

    if (image) {
      this.context.clearRect(0, 0, this.width, this.height);
      this.context.drawImage(image, 0, 0);
    }

    return image;
  }

  // Called every ~16ms by the browser to update the UI and render a ugoira frame.
  onAnimationFrame() {
    let now = this.now();
    let elapsedTime = now - (this.previousTime ?? now);
    let time = (this.currentTime + elapsedTime) % this.duration;

    this.setTime(time);

    this.previousTime = now;
    this.animationId = requestAnimationFrame(() => this.onAnimationFrame());
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
      let seconds = parseFloat(event.target.value);
      this.setTime(seconds);
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
      this.toggle(event);
    } else if (event.key === "ArrowLeft") {
      this.advance(this.duration * -0.01);
    } else if (event.key === "ArrowRight") {
      this.advance(this.duration * 0.01);
    } else {
      return;
    }

    event.preventDefault();
  }

  // Called each time a frame is downloaded. Updates the playback slider to indicate download progress.
  onLoadFrame(frame) {
    frame = Math.max(this.loadedFrame, frame);

    this.loadedFrame = frame;
    this.loadProgress = Math.round(100 * (this.frameStart(frame + 1) / this.duration));
    this.$playbackSlider.css("--load-progress", `${this.loadProgress}%`);
  }

  // Pauses the video while the user is tabbed out.
  onVisibilityChange(event) {
    if (document.hidden) {
      this.pause();
    } else {
      this.resume();
      this.previousTime = null; // Clear the time to ignore the time spent while tabbed out.
    }
  }

  // Toggle fullscreen mode.
  toggleFullscreen(event) {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else if (document.fullscreenEnabled) {
      this.$ugoiraContainer.get(0).requestFullscreen();
    }
  }

  // Returns the current time in seconds.
  now() {
    return performance.now() / 1000;
  }

  // Convert a frame number to the time in seconds when the frame starts.
  frameStart(frame) {
    return this.frames.slice(0, frame).reduce((sum, n) => sum + n, 0) / 1000;
  }

  // Convert a time in seconds to a frame number.
  frameAt(seconds) {
    let cumulativeSeconds = 0;

    for (const frame of this.frames.keys()) {
      cumulativeSeconds += this.frames[frame] / 1000;

      if (seconds <= cumulativeSeconds) {
        return frame;
      }
    }

    return this.frames.length - 1;
  }

  // Format a time in seconds as "0:00".
  formatTime(seconds) {
    const mm = Math.floor(seconds / 60).toString().padStart(1, '0');
    const ss = Math.floor(seconds % 60).toString().padStart(2, '0');

    return `${mm}:${ss}`;
  }
}
