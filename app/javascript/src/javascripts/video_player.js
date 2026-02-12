import { clamp, round } from "./utility";
import debounce from "lodash/debounce";
import UgoiraRenderer from './ugoira_renderer.js';
import VideoRenderer from './video_renderer.js';

export default class VideoPlayer {
  MAX_PLAYBACK_RATE = 2.0;
  PLAYBACK_RATE_STEP = 0.25;

  constructor(container) {
    this.$container = $(container);
    this.paused = true;
    this.duration = 0;
    this.video = null;
    this.quality = null;
    this.resumePlayback = false;
    this.scrubbing = false;
    this.scrubbingVolume = false;
    this.hasSound = this.$container.data("has-sound");

    this._currentTime = 0;
    this._playbackRate = 1.0;
    this._showPlaybackRate = false;
    this._volume = JSON.parse(localStorage.getItem("video.volume")) ?? 1.0;
    this._muted = JSON.parse(localStorage.getItem("video.muted")) ?? false;
    this._previousVolume = this._volume;

    this._variants = {};
    this.$container.find(".video-variant").each((index, element) => {
      let $element = $(element);
      let variant = $element.data("variant");

      if ($element.is("canvas")) {
        const fileUrl = $element.data("src");
        const fileSize = $element.data("file-size");
        const frameDelays = $element.data("frame-delays");
        const frameOffsets = $element.data("frame-offsets");
        this._variants[variant] = new UgoiraRenderer(fileUrl, element, frameDelays, { frameOffsets, fileSize });
      } else {
        this._variants[variant] = new VideoRenderer(element);
      }
    });
  }

  initialize() {
    this.$container.data("video-player", this);
    this.$container.get(0).videoPlayer = this;

    $(document).on("visibilitychange", event => this.onVisibilityChange(event));
    this.$container.on("keydown", event => this.onKeypress(event));
    this.$container.on("fullscreenchange", event => this.fullscreen = document.fullscreenElement !== null);
    this.$container.find("canvas, video").on("click", event => this.togglePlaying());
    this.$container.find("canvas, video").on("dblclick", event => this.toggleFullscreen(event));
    this.$container.find("canvas, video").on("seeking", event => this.currentTime = this.video.currentTime);
    this.$container.find("canvas, video").on("progress", event => this.currentTime = this.video.currentTime);
    this.$container.find("canvas, video").on("timeupdate", event => this.currentTime = this.video.currentTime);
    this.$container.find("canvas, video").on("durationchange", event => this.duration = this.video.duration);
    this.$container.find("canvas, video").on("ratechange", event => this.playbackRate = this.video.playbackRate);
    this.$container.find("canvas, video").on("ratechange", event => this._showPlaybackRate = true);
    this.$container.find("canvas, video").on("ratechange", debounce(event => this._showPlaybackRate = false, 1000)); // hide after 1 second of no changes to the playback rate
    this.$container.find("canvas, video").on("play", event => this.onPlay());
    this.$container.find("canvas, video").on("pause", event => this.onPause());
    this.$container.find("canvas, video").on("volumechange", event => this.onVolumeChange());
    this.$container.find(".video-slider").on("pointerdown", event => this.onDragStart(event));
    this.$container.find(".video-slider").on("pointerup", event => this.onDragEnd(event));
    this.$container.find(".video-slider").on("input", event => this.onDrag(event));
    this.$container.find(".volume-slider").on("pointerdown", event => this.onVolumeDragStart(event));
    this.$container.find(".volume-slider").on("pointerup", event => this.onVolumeDragEnd(event));
    this.$container.find(".volume-slider").on("input", event => this.onVolumeDrag(event));
    this.$container.find(".video-slider, .volume-slider").on("keydown", event => this.onKeypress(event));

    let quality = this.$container.data("quality");
    this.setQuality(quality);

    // Ignore autoplay errors due to browser restrictions.
    this.play().catch(() => {});
  }

  async play() {
    await this.video?.play();
  }

  onPlay() {
    this.paused = false;
  }

  async pause() {
    this.resumePlayback = !this.paused;
    await this.video?.pause();
  }

  onPause() {
    this.paused = true;
  }

  // Resumes playing if it was previously playing before it was last paused.
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

  // Called when the playback slider starts being dragged. Pauses while the user drags the playback slider.
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

  // Called when the playback slider stops being dragged. Resumes if it was playing before the user started dragging the slider.
  onDragEnd(event) {
    if (this.scrubbing) {
      this.resume();
      this.scrubbing = false;
    }
  }

  onVolumeDragStart(event) {
    if (event.pointerType !== "mouse" || event.button === 0) {
      this.scrubbingVolume = true;
      this._previousVolume = this.volume;
    }
  }

  onVolumeDrag(event) {
    if (this.scrubbingVolume) {
      this.volume = parseFloat(event.target.value);
    }
  }

  onVolumeDragEnd(event) {
    if (this.scrubbingVolume) {
      // Treat dragging the volume to 0% as muting the video instead of lowering the volume so that unmuting will restore the previous volume
      if (this.volume === 0) {
        this.volume = this._previousVolume;
        this.muted = true;
      }

      this.scrubbingVolume = false;
    }
  }

  onKeypress(event) {
    if (event.key === " " && !this.scrubbing) {
      this.togglePlaying();
    } else if (event.key === "ArrowLeft" && !this.scrubbing) {
      this.currentTime -= this.duration * 0.01;
    } else if (event.key === "ArrowRight" && !this.scrubbing) {
      this.currentTime += this.duration * 0.01;
    } else if (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].includes(event.key) && !this.scrubbing) {
      this.currentTime = this.duration * (parseInt(event.key) / 10);
    } else if (event.key === "<" && !this.scrubbing) {
      this.playbackRate -= this.PLAYBACK_RATE_STEP;
    } else if (event.key === ">" && !this.scrubbing) {
      this.playbackRate += this.PLAYBACK_RATE_STEP;
    } else if (event.key === "ArrowDown" && !this.scrubbingVolume) {
      this.volume -= 0.1;
    } else if (event.key === "ArrowUp" && !this.scrubbingVolume) {
      this.volume += 0.1;
    } else if (event.key === "m" && !this.scrubbingVolume) {
      this.toggleMute();
    }

    if ([" ", "<", ">", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "ArrowLeft", "ArrowRight"].includes(event.key) ||
       (["m", "ArrowDown", "ArrowUp"].includes(event.key) && this.hasSound)) {
      return false;
    }
  }

  // Pauses the video while the user is tabbed out.
  onVisibilityChange(event) {
    if (this.inferredVolume === 0) {
      if (document.hidden) {
        this.pause();
      } else {
        this.resume();
      }
    }
  }

  // Sets the video to either the original or the sample. Playback will continue from the
  // current time when the video is switched.
  async setQuality(quality) {
    if (quality === this.quality) {
      return;
    }

    if (this.video) {
      await this.pause();
    }
    this.quality = quality;
    this.video = this._variants[quality];

    this.video.load();
    this.duration = this.video.duration || 0;

    this.video.currentTime = this.currentTime;
    this.video.playbackRate = this.playbackRate;
    this.video.volume = this.volume;
    this.video.muted = this.muted;

    this.resume();
  }

  // Toggle fullscreen mode.
  toggleFullscreen(event) {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else if (document.fullscreenEnabled) {
      this.$container.get(0).requestFullscreen();
    }
  }

  get inferredVolume() {
    return this.muted ? 0 : this.volume;
  }

  get volume() {
    return this._volume;
  }

  set volume(value) {
    value = parseFloat(value) ?? 1.0;
    value = round(value, 0.01);
    value = clamp(value, 0.0, 1.0);

    if (this.hasSound && this.video.volume !== value) {
      this.video.volume = value;
    }

    if (value > 0) {
      this.muted = false;
    }
  }

  get muted() {
    return this._muted;
  }

  set muted(value) {
    if (this.hasSound && this.video.muted !== value) {
      this.video.muted = value;
    }
  }

  onVolumeChange() {
    this._volume = this.video.volume;
    this._muted = this.video.muted;
    localStorage.setItem("video.volume", this._volume);
    localStorage.setItem("video.muted", this._muted);
  }

  toggleMute() {
    if (this.inferredVolume === 0) {
      this.muted = false;
      this.volume = clamp(this.volume, 0.1, 1.0); // when unmuting, raise the volume if it was at 0% so that it doesn't remain silent
    } else {
      this.muted = true;
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

  get playbackRate() {
    return this._playbackRate;
  }

  set playbackRate(rate) {
    this._playbackRate = round(clamp(rate, this.PLAYBACK_RATE_STEP, this.MAX_PLAYBACK_RATE), this.PLAYBACK_RATE_STEP);

    if (this.video.playbackRate !== this._playbackRate) {
      this.video.playbackRate = this._playbackRate;
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

    if (!this.video) {
      return "0%";
    }

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
