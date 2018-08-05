const ZipImagePlayer = require('../../vendor/pixiv-ugoira-player');

let Ugoira = {};

Ugoira.create_player = (mime_type, frames, file_url) => {
  var meta_data = {
    mime_type: mime_type,
    frames: frames
  };
  var options = {
    canvas: document.getElementById("image"),
    source: file_url,
    metadata: meta_data,
    chunkSize: 300000,
    loop: true,
    autoStart: true,
    debug: false,
  }
  var player = new ZipImagePlayer(options);

  $(player).on("loadProgress", (ev, progress) => {
    $("#seek-slider").progressbar("value", Math.floor(progress * 100));
  });

  var player_manually_paused = false;

  $("#ugoira-play").click(e => {
    Ugoira.player.play();
    $(this).hide();
    $("#ugoira-pause").show();
    player_manually_paused = false;
    e.preventDefault();
  })

  $("#ugoira-pause").click(e => {
    Ugoira.player.pause();
    $(this).hide();
    $("#ugoira-play").show();
    player_manually_paused = true;
    e.preventDefault();
  });

  $("#seek-slider").progressbar({
    value: 0
  });

  $("#seek-slider").slider({
    min: 0,
    max: Ugoira.player._frameCount-1,
    start: function(event, ui) {
      // Need to pause while slider is being dragged or playback speed will bug out
      Ugoira.player.pause();
    },
    slide: function(event, ui) {
      Ugoira.player._frame = ui.value;
      Ugoira.player._displayFrame();
    },
    stop: function(event, ui) {
      // Resume playback when dragging stops, but only if player was not paused by the user earlier
      if (!(player_manually_paused)) {
        Ugoira.player.play();
      }
    }
  });

  $(player).on("frame", function(frame, frame_number) {
    $("#seek-slider").slider("option", "value", frame_number);
  });
}

export default Ugoira;

