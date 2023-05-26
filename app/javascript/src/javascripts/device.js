import { find as lodashFind, memoize } from "lodash";

// Collects information about the user's browser and computer. Used for detecting bots and ban evaders.
export default class Device {
  static canvas = document.createElement("canvas");
  static commonFrameRates = [60, 75, 90, 120, 144, 240, 360];

  static async metadata() {
    try {
      if ("speechSynthesis" in window) {
        window.speechSynthesis.onvoiceschanged = () => {}; // Somehow forces Chrome to initialize the getVoices() list.
      }

      return {
        hardware: {
          hardwareConcurrency: window.navigator?.hardwareConcurrency,
          deviceMemory: window.navigator?.deviceMemory,
          webglUnmaskedRenderer: this.webgl?.getParameter?.(this.webgl?.getExtension?.("WEBGL_debug_renderer_info")?.UNMASKED_RENDERER_WEBGL),
          webglUnmaskedVendor: this.webgl?.getParameter?.(this.webgl?.getExtension?.("WEBGL_debug_renderer_info")?.UNMASKED_VENDOR_WEBGL),
          maxTouchPoints: window.navigator?.maxTouchPoints,
          batteryLevel: await window.navigator?.getBattery?.()?.level,
          batteryCharging: await window.navigator?.getBattery?.()?.charging,
          mobile: window.navigator?.userAgentData?.mobile,
          platform: window.navigator?.userAgentData?.platform,
          platformVersion: (await this.userAgentData())?.platformVersion,
          architecture: (await this.userAgentData())?.architecture,
          bitness: (await this.userAgentData())?.bitness,
          mathFingerprint: await this.mathFingerprint(),
        },
        connection: {
          httpVersion: window.performance?.getEntriesByType?.('navigation')?.[0]?.nextHopProtocol,
          downlink: window.navigator?.connection?.downlink,
          effectiveType: window.navigator?.connection?.effectiveType,
          rtt: window.navigator?.connection?.rtt,
          saveData: window.navigator?.connection?.saveData,
        },
        user: {
          locale: Intl?.DateTimeFormat?.()?.resolvedOptions?.().locale,
          timeZone: Intl?.DateTimeFormat?.()?.resolvedOptions?.().timeZone,
          timeZoneOffset: new Date().getTimezoneOffset(),
          languages: window.navigator?.languages?.join("; "),
          darkMode: window.matchMedia?.("(prefers-color-scheme: dark)")?.matches,
        },
        window: {
          width: window.innerWidth,
          height: window.innerHeight,
        },
        screen: {
          width: window.screen?.width,
          height: window.screen?.height,
          frameRate: await this.frameRate(),
          orientation: window.screen?.orientation?.type,
          pixelDepth: window.screen?.pixelDepth,
          pixelRatio: window.devicePixelRatio,
          colorGamut: this.colorGamut(),
        },
        page: {
          domNodes: $('*').length,
          historyLength: window.history?.length,
          navigationLength: window.navigation?.currentEntry?.index,
          openDuration: (window.performance?.now?.() ?? 0) / 1000,
        },
        browser: {
          userAgent: window.navigator?.userAgent,
          userAgentFullVersion: (await this.userAgentData())?.uaFullVersion,
          //hasWindowScheduler: "scheduler" in window,
          //hasWindowNavigation: "navigation" in window,
          //hasEventCounts: "eventCounts" in (window.performance ?? {}),
          //hasNavigatorConnection: "connection" in (window.navigator ?? {}),
          //hasNavigatorUSB: "usb" in (window.navigator ?? {}),
          //hasNavigatorHID: "hid" in (window.navigator ?? {}),
          //hasNavigatorShare: "share" in (window.navigator ?? {}),
          speechSynthesisFingerprint: await this.speechSynthesisFingerprint(),
          webdriver: window.navigator?.webdriver,
        },
      };
    } catch (error) {
      // Swallow errors to prevent breaking pages in case we do something unsupported by uncommon browsers.
      return {};
    }
  }

  static async flatMetadata() {
    let objects = Object.entries(await this.metadata()).map(([category, values]) => {
      return Object.entries(values).map(([name, value]) => {
        return ({ [`${category}.${name}`]: value });
      });
    }).flat();

    return Object.assign(...objects);
  }

  static async jsonMetadata() {
    return JSON.stringify(await this.metadata(), (key, value) => value ?? null); // convert undefined to null.
  }

  // Estimate the screen's frame rate. Calculates the frame rate N times and takes the median value, then rounds it to
  // the nearest standard frame rate.
  static async frameRate(samples = 5) {
    let frameTimes = [];
    for (let i = 0; i < samples; i++) {
      frameTimes[i] = await this.frameTime();
    }

    let medianTime = frameTimes.sort()[Math.floor(samples / 2)];
    let frameRate = Math.round(1000 / medianTime);
    let closestFrameRate = lodashFind(this.commonFrameRates, rate => Math.abs(frameRate - rate) <= 0.1 * rate);
    return closestFrameRate ?? frameRate;
  }

  // Calculate the time in milliseconds between two animation frames. Used to estimate the screen's frame rate. May
  // be slightly off due to timing fluctuations.
  static async frameTime() {
    return new Promise(resolve => {
      requestAnimationFrame(t1 => {
        requestAnimationFrame(t2 => {
          resolve(t2 - t1);
        })
      })
    });
  }

  static async userAgentData() {
    return await window.navigator.userAgentData?.getHighEntropyValues?.([
      "architecture", "bitness", "formFactor", "fullVersionList", "model", "platformVersion", "uaFullVersion", "wow64"
    ]);
  }

  static colorGamut() {
    let gamuts = ["rec2020", "p3", "srgb"];
    return lodashFind(gamuts, gamut => window.matchMedia?.(`(color-gamut: ${gamut})`)?.matches);
  }

  // Detect floating point rounding differences between browsers.
  static async mathFingerprint() {
    let log  = Math.log;
    let exp  = Math.exp;
    let sqrt = Math.sqrt;
    let acoshPf = x => log(x + sqrt(x * x - 1))
    let asinhPf = x => log(x + sqrt(x * x + 1))
    let atanhPf = x => log((1 + x) / (1 - x)) / 2
    let sinhPf  = x => exp(x) - 1 / exp(x) / 2
    let coshPf  = x => (exp(x) + 1 / exp(x)) / 2
    let expm1Pf = x => exp(x) - 1
    let tanhPf  = x => (exp(2 * x) - 1) / (exp(2 * x) + 1)
    let log1pPf = x => log(1 + x)

    let fingerprint = {
      acos:    Math.acos(0.123124234234234242),
      acosh:   Math.acosh(1e308),
      acoshPf: acoshPf(1e154),
      asin:    Math.asin(0.123124234234234242),
      asinh:   Math.asinh(1),
      asinhPf: asinhPf(1),
      atanh:   Math.atanh(0.5),
      atanhPf: atanhPf(0.5),
      atan:    Math.atan(0.5),
      sin:     Math.sin(-1e300),
      sinh:    Math.sinh(1),
      sinhPf:  sinhPf(1),
      cos:     Math.cos(10.000000000123),
      cosh:    Math.cosh(1),
      coshPf:  coshPf(1),
      tan:     Math.tan(-1e300),
      tanh:    Math.tanh(1),
      tanhPf:  tanhPf(1),
      exp:     Math.exp(1),
      expm1:   Math.expm1(1),
      expm1Pf: expm1Pf(1),
      log1p:   Math.log1p(10),
      log1pPf: log1pPf(10),
      powPI:   Math.pow(Math.PI, -100),
    }

    let hash = await this.hash(JSON.stringify(fingerprint));
    return `v1:${hash}`;
  }

  static async speechSynthesisFingerprint(data) {
    if (! ("speechSynthesis" in window)) {
      return undefined;
    }

    let voices = window.speechSynthesis.getVoices().map(voice => voice.voiceURI);
    let hash = await this.hash(JSON.stringify(voices));
    return `v1:${hash}`;
  }

  // Generate a hash of the data. The hash function is SHA-512, truncated to first 32 hex characters.
  static async hash(data) {
    if (! ("subtle" in window.crypto)) {
      return undefined;
    }

    let input = new TextEncoder().encode(data);
    let hash = await window.crypto.subtle.digest("SHA-512", input);
    let bytes = new Uint8Array(hash);
	  let hex = Array.from(bytes).map(byte => byte.toString(16).padStart(2, "0")).join("");

	  return hex.slice(0, 32);
  }

  static get webgl() {
    return this.canvas?.getContext?.("webgl");
  }
}

Device.frameRate = memoize(Device.frameRate);
Device.userAgentData = memoize(Device.userAgentData);
