class SourceDataComponent {
  static initialize() {
    $(document).on("click.danbooru", ".source-data-fetch", SourceDataComponent.fetchData);
  }

  static async fetchData(e) {
    let url = $("#post_source").val();
    let ref = $("#post_referer_url").val();

    e.preventDefault();

    if (/^https?:\/\//.test(url)) {
      $(".source-data").addClass("loading");
      let script = await $.get("/source.js", { url: url, ref: ref });
      $.globalEval(script);
      $(".source-data").removeClass("loading");
    }
  }
}

$(document).ready(SourceDataComponent.initialize);

export default SourceDataComponent;
