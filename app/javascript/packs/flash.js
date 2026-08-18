import "@ruffle-rs/ruffle/ruffle.js";

// Discover whatever chunk files ruffle ships, instead of hardcoding their hashes here.
const ruffleChunks = require.context("@ruffle-rs/ruffle", false, /^\.\/(core\.ruffle\..*\.js|.*\.wasm)$/);
ruffleChunks.keys().forEach(ruffleChunks);
