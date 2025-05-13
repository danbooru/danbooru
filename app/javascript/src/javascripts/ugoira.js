import { ZipImagePlayer } from '../../vendor/pixiv-ugoira-player';

export default class Ugoira {
  constructor($ugoiraContainer) {
    this.$ugoiraContainer = $ugoiraContainer;
    this.$canvas = $ugoiraContainer.find("canvas");
    this.$playButton = $ugoiraContainer.find(".ugoira-play");
    this.$pauseButton = $ugoiraContainer.find(".ugoira-pause");
    this.$fullscreenButton = $ugoiraContainer.find(".ugoira-fullscreen");
    this.$exitFullscreenButton = $ugoiraContainer.find(".ugoira-exit-fullscreen");
    this.$playbackSlider = $ugoiraContainer.find(".ugoira-slider");
    this.$currentTime = $ugoiraContainer.find(".ugoira-time");
    this.$duration = $ugoiraContainer.find(".ugoira-duration");

    this.fileUrl = $ugoiraContainer.attr("src");         // The URL of the ugoira .zip file.
    this.frames = $ugoiraContainer.data("frame-delays"); // The array of frame delays (in milliseconds).

    this.previousTime = 0;          // The time in seconds when we last updated the ugoira. Used for measuring elapsed time.
    this.currentTime = 0;           // The current playback time of the ugoira (e.g 3.2 means we're 3.2 seconds into the ugoira).
    this.currentFrame = null;       // The current ugoira frame number.
    this.previousFrame = null;      // The previous ugoira frame number. Used for detecting when the frame has changed and the canvas needs to be rerendered.
    this.loadedFrames = 0;          // The number of ugoira frames that have been downloaded.
    this.loadProgress = 0;          // The percentage of ugoira frames that have been downloaded.
    this.scrubbing = false;         // Whether we're currently dragging the playback slider.
    this.playing = false;           // Whether the ugoira is currently playing or paused.
    this.resumePlayback = false;    // Whether to resume playback after we stop scrubbing the playback slider or when we tab back in.
    this.animationId = null;        // The handle for the requestAnimationFrame callback that renders the next ugoira frame.
    this.duration = this.frames.reduce((sum, n) => sum + n, 0) / 1000; // The total duration of the ugoira in seconds.

    this.player = new ZipImagePlayer({
      canvas: this.$canvas.get(0),
      source: this.fileUrl,
      metadata: { frames: this.frames },
      chunkSize: 300000,
      loop: true,
      autoStart: false,
      debug: false,
    });

    this.initialize();
  }

  initialize() {
    this.$ugoiraContainer.data("ugoira", this);
    this.$ugoiraContainer.get(0).ugoira = this;

    this.$duration.text(this.formatTime(Math.round(this.duration)));

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
    $(this.player).on("frameLoaded.danbooru", (event, frame) => this.onLoadFrame(frame));
    $(document).on("visibilitychange", event => this.onVisibilityChange(event));
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
    this.currentTime = Math.min(this.frameStart(this.loadedFrames + 1), Math.max(0, seconds));
    this.previousFrame = this.currentFrame;
    this.currentFrame = Math.min(this.loadedFrames, this.frameAt(this.currentTime));

    if (this.currentFrame !== this.previousFrame) {
      this.player._frame = this.currentFrame;
      this.player._displayFrame();
      // console.log(`[${this.formatTime(this.currentTime)}]: draw frame frame=${this.currentFrame}`);
    }

    this.updateUI();
  }

  // Called every ~16ms by the browser to update the UI and render a ugoira frame.
  onAnimationFrame() {
    let now = this.now();
    let elapsedTime = now - (this.previousTime ?? now);
    let time = (this.currentTime + elapsedTime) % this.duration;

    this.setTime(time);
    // console.log(`[${this.formatTime(time)}]: update UI fps=${Math.round(1 / elapsedTime)}`);

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
    }

    event.preventDefault();
  }

  // Called each time a frame is downloaded. Updates the playback slider to indicate download progress.
  onLoadFrame(frame) {
    this.loadedFrames = frame;
    this.loadProgress = Math.round(100 * (this.frameStart(frame + 1) / this.duration));
    this.$playbackSlider.css("--load-progress", `${this.loadProgress}%`);
  }

  // Pauses the video while the user is tabbed out.
  onVisibilityChange(event) {
    if (document.hidden) {
      this.pause();
      // console.log(`[${this.formatTime(this.currentTime)}]: hide now=${this.now()}`);
    } else {
      this.resume();
      this.previousTime = null; // Clear the time to ignore the time spent while tabbed out.
      // console.log(`[${this.formatTime(this.currentTime)}]: unhidden now=${this.now()}`);
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
    return document.timeline.currentTime / 1000;
  }

  // Convert a frame number to the time in seconds when the frame starts.
  frameStart(frame = this.player._frame) {
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
