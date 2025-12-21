export default class VideoRenderer {
  constructor(videoElement) {
    this.video = videoElement;
    this._currentTime = 0;
    this._animationId = null;
    this._previousTime = null;

    this.video.addEventListener("playing", () => this.onPlay());
    this.video.addEventListener("pause", () => this.onPause());
    this.video.addEventListener("waiting", () => this.onPause());
    this.video.addEventListener("timeupdate", event => event.isTrusted && this.onTimeUpdate());
  }

  async play() {
    await this.video.play();
  }

  onPlay() {
    this._previousTime = null;
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
    this.onTimeUpdate();
  }

  onTimeUpdate() {
    this._currentTime = this.video.currentTime;
    this._previousTime = null;
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
    const elapsedTime = (now - (this._previousTime ?? now)) * this.playbackRate;
    this._currentTime = (this._currentTime + elapsedTime) % this.duration;
    this.triggerEvent("timeupdate");

    this._previousTime = now;
    this._animationId = requestAnimationFrame(() => this.onAnimationFrame());
  }

  triggerEvent(eventName, detail = {}) {
    const event = new CustomEvent(eventName, { bubbles: false, cancelable: false, detail });
    this.video.dispatchEvent(event);
  }
}
