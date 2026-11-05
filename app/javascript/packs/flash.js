import "@ruffle-rs/ruffle/ruffle.js";

// Discover whatever chunk files ruffle ships, instead of hardcoding their hashes here.
const ruffleChunks = require.context("@ruffle-rs/ruffle", false, /^\.\/(core\.ruffle\..*\.js|.*\.wasm)$/);
ruffleChunks.keys().forEach(ruffleChunks);

// This runs inside a sandboxed iframe (see app/views/media_assets/_flash_player.html.erb). Also disable Ruffle's
// JS access, link opening, and networking, in case the sandbox is ever bypassed.
document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector(".ruffle-container[data-swf]");
  const player = window.RufflePlayer.newest().createPlayer();

  container.appendChild(player);
  player.load({
    url: container.dataset.swf,
    allowScriptAccess: false,
    allowNetworking: "none",
    openUrlMode: "deny",
  });
});
