import { ungzip } from "pako";

let PromptProtector = {};

PromptProtector.initializeAll = function initializeAll() {
  $("input#file").on("change.danbooru", PromptProtector.loadToCanvas);
}

PromptProtector.loadToCanvas = function loadToCanvas(e) {
  if (e.target.files[0]) {
    $("span#filename").text(e.target.files[0].name);
    let blob = URL.createObjectURL(e.target.files[0]);
    let canvas = document.getElementsByTagName("canvas")[0];
    let ctx = canvas.getContext("2d");
    let image = new Image();
    image.onload = (e) => {
      canvas.width = e.target.width;
      canvas.height = e.target.height;
      ctx.drawImage(image, 0, 0);
      let imageData = ctx.getImageData(0, 0, e.target.width, e.target.height);
      URL.revokeObjectURL(blob);
      let result = PromptProtector.loadStealthMetadata(imageData.data, e.target.width, e.target.height);
      $("#output > textarea").text(result ?? "Error loading metadata");
    };
    image.src = blob;
  }
}

function bytesToString(bytes) {
  let result = "";
  for (let i = 0; i < bytes.length; i++) {
    result += String.fromCharCode(bytes[i]);
  }
  return result;
}

PromptProtector.loadStealthMetadata = function loadStealthMetadata(data, width, height) {
  function getPixel(x, y, width) {
    const red = y * (width * 4) + x * 4;
    return [data[red], data[red + 1], data[red + 2], data[red + 3]];
  }

  let mode = null;
  let binaryData = "";
  let bufferA = "";
  let bufferRGB = "";
  let indexA = 0;
  let indexRGB = 0;
  let paramLen = 0;
  let sigConfirmed = false;
  let confirmingSignature = true;
  let readingParamLen = false;
  let readingParam = false;
  let readEnd = false;
  let decodedSig = "";

  for (let x = 0; x < width; x++) {
    for (let y = 0; y < height; y++) {
      let [r, g, b, a] = getPixel(x, y, width);
      bufferA += (a & 1).toString();
      indexA += 1;
      bufferRGB += (r & 1).toString() + (b & 1).toString() + (g & 1).toString();
      indexRGB += 3;

      if (confirmingSignature) {
        if (indexA === "stealth_pnginfo".length * 8) {
          let sig = [];
          for (let i = 0; i < bufferA.length; i += 8) {
            sig.push(parseInt(bufferA.slice(i, i + 8), 2));
          }
          decodedSig = bytesToString(sig);
          if (["stealth_pnginfo", "stealth_pngcomp"].includes(decodedSig)) {
            confirmingSignature = false;
            sigConfirmed = true;
            readingParamLen = true;
            mode = "alpha";
            bufferA = "";
            indexA = 0;
          } else {
            readEnd = true;
            break;
            // return;
          }
        } else if (indexRGB === "stealth_rgbinfo".length * 8) {
          let sig = [];
          for (let i = 0; i < bufferRGB.length; i += 8) {
            sig.push(parseInt(bufferRGB.slice(i, i + 8), 2));
          }
          decodedSig = bytesToString(sig);
          if (["stealth_rgbinfo", "stealth_rgbcomp"].includes(decodedSig)) {
            confirmingSignature = false;
            sigConfirmed = true;
            readingParamLen = true;
            mode = "rgb";
            bufferRGB = "";
            indexRGB = 0;
          }
        }
      } else if (readingParamLen) {
        if (mode === "alpha") {
          if (indexA === 32) {
            paramLen = parseInt(bufferA, 2);
            console.log(`paramLen === ${paramLen}`);
            readingParamLen = false;
            readingParam = true;
            bufferA = "";
            indexA = 0;
          }
        } else {
          if (indexRGB === 33) {
            let pop = bufferRGB[bufferRGB.length - 1];
            paramLen = parseInt(bufferRGB.slice(0, 32), 2);
            readingParamLen = false;
            readingParam = true;
            bufferRGB = pop;
            indexRGB = 1;
          }
        }
      } else if (readingParam) {
        if (mode === "alpha") {
          if (indexA === paramLen) {
            binaryData = bufferA;
            readEnd = true;
            break;
          }
        } else {
          if (indexRGB >= paramLen) {
            let diff = paramLen - indexRGB;
            if (diff < 0) {
              bufferRGB = bufferRGB.slice(0, diff);
            }
            binaryData = bufferRGB;
            readEnd = true;
            break;
          }
        }
      }
    }

    if (readEnd) break;
  }

  if (!sigConfirmed || binaryData === "") {
    return null;
  }

  let bytes = [];
  for (let i = 0; i < binaryData.length; i += 8) {
    bytes.push(parseInt(binaryData.slice(i, i + 8), 2));
  }
  if (["stealth_pngcomp", "stealth_rgbcomp"].includes(decodedSig)) {
    return bytesToString(ungzip(bytes));
  } else {
    return bytesToString(bytes);
  }
}

$(function() {
  PromptProtector.initializeAll();
});

export default PromptProtector;
