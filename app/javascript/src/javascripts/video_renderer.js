export default class VideoRenderer {
  constructor(videoElement) {
    this.video = videoElement;
    this._currentTime = 0;
    this._animationId = null;
    this._lastVideoTime = null;
    this._lastWallTime = null;

    this.video.addEventListener("play", () => this.onPlay());
    this.video.addEventListener("pause", () => this.onPause());
  }

  async play() {
    await this.video.play();
  }

  onPlay() {
    this._lastVideoTime = null;
    this._lastWallTime = null;
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  pause() {
    this.video.pause();
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
    this._currentTime = time;
    this._lastVideoTime = null;
    this._lastWallTime = null;
    this.triggerEvent("timeupdate");
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
    const currentTime = this.video.currentTime;
    const now = performance.now() / 1000;

    if (currentTime !== this._lastVideoTime || this._lastWallTime === null) {
      this._lastVideoTime = currentTime;
      this._lastWallTime = now;
    }

    const elapsedTime = (now - this._lastWallTime) * this.playbackRate;
    const duration = this.duration || 0; // Might be NaN if video metadata isn't loaded yet.
    this._currentTime = Math.min(currentTime + elapsedTime, duration);

    this.triggerEvent("timeupdate");

    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  triggerEvent(eventName, detail = {}) {
    const event = new CustomEvent(eventName, { bubbles: false, cancelable: false, detail });
    this.video.dispatchEvent(event);
  }
}
