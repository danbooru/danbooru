import UgoiraPlayer from './ugoira_loader.js';

export default class Ugoira {
  constructor($ugoiraContainer, { fileUrl = null, frameDelays = null, fileSize = null } = {}) {
    fileUrl ??= $ugoiraContainer.attr("src");
    frameDelays ??= $ugoiraContainer.data("frame-delays");
    fileSize ??= fileSize || $ugoiraContainer.data("file-size");

    this.$ugoiraContainer = $ugoiraContainer;
    this.$canvas = $ugoiraContainer.find("canvas");
    this.$playButton = $ugoiraContainer.find(".ugoira-play");
    this.$pauseButton = $ugoiraContainer.find(".ugoira-pause");
    this.$fullscreenButton = $ugoiraContainer.find(".ugoira-fullscreen");
    this.$exitFullscreenButton = $ugoiraContainer.find(".ugoira-exit-fullscreen");
    this.$playbackSlider = $ugoiraContainer.find(".ugoira-slider");
    this.$currentTime = $ugoiraContainer.find(".ugoira-time");
    this.$duration = $ugoiraContainer.find(".ugoira-duration");

    this.scrubbing = false;      // Whether we're currently dragging the playback slider.
    this.resumePlayback = false; // Whether to resume playback after we stop scrubbing the playback slider or when we tab back in.
    this.video = new UgoiraPlayer(fileUrl, this.$canvas.get(0), frameDelays, { fileSize });

    this.initialize();
  }

  initialize() {
    this.$ugoiraContainer.data("ugoira", this);
    this.$ugoiraContainer.get(0).ugoira = this;

    this.$video.on("click.danbooru", event => this.toggle(event));
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

    this.$video.on("play", event => this.updateUI(event));
    this.$video.on("pause", event => this.updateUI(event));
    this.$video.on("timeupdate", event => this.updateUI(event));
    this.$video.on("progress", event => this.onLoadFrame());

    this.video.load();
  }

  play() {
    this.video.play();
  }

  pause() {
    this.resumePlayback = !this.video.paused;
    this.video.pause();
  }

  // Resumes playing the ugoira if it was previously playing before it was last paused.
  resume() {
    if (this.resumePlayback) {
      this.play();
    }
  }

  // Toggles between playing and paused.
  toggle(event = null) {
    if (this.video.paused) {
      this.play();
    } else {
      this.pause();
    }

    event?.preventDefault();
  }

  // Updates the playback slider and the time display.
  updateUI() {
    let duration = this.video.duration || 0;
    let currentTime = this.video.currentTime;
    let progress = Math.round(100 * (currentTime / duration));

    this.$currentTime.text(this.formatTime(currentTime));
    this.$duration.text(this.formatTime(duration));
    this.$playbackSlider.css("--playback-progress", `${progress}%`);
    this.$playbackSlider.val(currentTime);
    this.$ugoiraContainer.attr("data-playing", !this.video.paused);

    this.$playButton.toggleClass("hidden", this.video.paused);
    this.$pauseButton.toggleClass("hidden", !this.video.paused);

    this.$fullscreenButton.toggleClass("hidden", document.fullscreenElement !== null);
    this.$exitFullscreenButton.toggleClass("hidden", document.fullscreenElement === null);
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
      this.video.currentTime = parseFloat(event.target.value);
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
      this.video.currentTime -= this.video.duration * 0.01;
    } else if (event.key === "ArrowRight") {
      this.video.currentTime += this.video.duration * 0.01;
    } else {
      return;
    }

    event.preventDefault();
  }

  // Called each time a frame is downloaded. Updates the playback slider to indicate how much of the video has been downloaded.
  onLoadFrame() {
    let buffered = this.video.buffered;
    let bufferedDuration = buffered.length > 0 ? buffered.end(buffered.length - 1) : 0;
    let loadProgress = Math.round(100 * (bufferedDuration / this.video.duration));

    this.$playbackSlider.css("--load-progress", `${loadProgress}%`);
  }

  // Pauses the video while the user is tabbed out.
  onVisibilityChange(event) {
    if (document.hidden) {
      this.pause();
    } else {
      this.resume();
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

  // Format a time in seconds as "0:00".
  formatTime(seconds) {
    const mm = Math.floor(seconds / 60).toString().padStart(1, '0');
    const ss = Math.floor(seconds % 60).toString().padStart(2, '0');

    return `${mm}:${ss}`;
  }
}
