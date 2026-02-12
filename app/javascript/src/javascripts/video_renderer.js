export default class VideoRenderer {
  constructor(videoElement) {
    this.video = videoElement;
    this._currentTime = 0;
    this._lastVideoTime = null;
    this._lastWallTime = null;
    this._animationId = null;

    this.video.addEventListener("playing", () => this.onPlay());
    this.video.addEventListener("pause", () => this.onPause());
    this.video.addEventListener("waiting", () => this.onPause());
    this.video.addEventListener("timeupdate", event => event.isTrusted && this.onTimeUpdate());
  }

  async play() {
    await this.video.play();
  }

  onPlay() {
    this._lastWallTime = null;
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  pause() {
    if (this.video.paused) {
      return;
    }

    return new Promise((resolve) => {
      this.video.addEventListener('pause', resolve, { once: true });
      this.video.pause();
    });
  }

  onPause() {
    cancelAnimationFrame(this._animationId);
  }

  load() {
    this.video.load();
  }

  get duration() {
    return this.video.duration;
  }

  get currentTime() {
    return this._currentTime;
  }

  set currentTime(time) {
    this.video.currentTime = time;
    this.onTimeUpdate();
  }

  onTimeUpdate() {
    const videoTime = this.video.currentTime;
    if (videoTime !== this._lastVideoTime) {
      this._lastWallTime = null;
      this._lastVideoTime = videoTime;
      this._currentTime = videoTime;
    }
  }

  get buffered() {
    return this.video.buffered;
  }

  get readyState() {
    return this.video.readyState;
  }

  get playbackRate() {
    return this.video.playbackRate;
  }

  get volume() {
    return this.video.volume;
  }

  set volume(value) {
    this.video.volume = value;
  }

  get muted() {
    return this.video.muted;
  }

  set muted(value) {
    this.video.muted = value;
  }

  get paused() {
    return this.video.paused;
  }

  onAnimationFrame() {
    const now = performance.now() / 1000;

    this.onTimeUpdate();
    this._currentTime += (now - (this._lastWallTime ?? now)) * this.playbackRate;
    this._lastWallTime = now;

    if (isFinite(this.duration)) {
      this._currentTime = Math.min(this._currentTime, this.duration);
    }

    this.triggerEvent("timeupdate");
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  triggerEvent(eventName, detail = {}) {
    const event = new CustomEvent(eventName, { bubbles: false, cancelable: false, detail });
    this.video.dispatchEvent(event);
  }
}
