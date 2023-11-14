import { ZipImagePlayer } from '../../vendor/pixiv-ugoira-player';
require("jquery-ui/ui/widgets/progressbar");
require("jquery-ui/ui/widgets/slider");
require("jquery-ui/themes/base/progressbar.css");
require("jquery-ui/themes/base/slider.css");

let Ugoira = {};

Ugoira.create_player = (frames, file_url) => {
  var meta_data = {
    frames: frames
  };
  var options = {
    canvas: $("#image")[0],
    source: file_url,
    metadata: meta_data,
    chunkSize: 300000,
    loop: true,
    autoStart: true,
    debug: false,
  }

  Ugoira.player = new ZipImagePlayer(options);
  Ugoira.player_manually_paused = false;

  $(Ugoira.player).on("loadProgress.danbooru", (ev, progress) => {
    $("#seek-slider").progressbar("value", Math.floor(progress * 100));
  });

  $("#ugoira-play").on("click.danbooru", e => {
    Ugoira.player.play();
    $("#ugoira-play").hide();
    $("#ugoira-pause").show();
    Ugoira.player_manually_paused = false;
    e.preventDefault();
  })

  $("#ugoira-pause").on("click.danbooru", e => {
    Ugoira.player.pause();
    $("#ugoira-pause").hide();
    $("#ugoira-play").show();
    Ugoira.player_manually_paused = true;
    e.preventDefault();
  });

  $("#seek-slider").progressbar({
    value: 0
  });

  $("#seek-slider").slider({
    min: 0,
    max: Ugoira.player._frameCount - 1,
    start: (event, ui) => {
      // Need to pause while slider is being dragged or playback speed will bug out
      Ugoira.player.pause();
    },
    slide: (event, ui) => {
      Ugoira.player._frame = ui.value;
      Ugoira.player._displayFrame();
    },
    stop: (event, ui) => {
      // Resume playback when dragging stops, but only if player was not paused by the user earlier
      if (!(Ugoira.player_manually_paused)) {
        Ugoira.player.play();
      }
    }
  });

  $(Ugoira.player).on("frame.danbooru", (frame, frame_number) => {
    $("#seek-slider").slider("option", "value", frame_number);
  });
}

export default Ugoira;

