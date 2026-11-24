import Notice from "./notice";
import Utility from "./utility";

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

      try {
        let script = await $.get("/source.js", { url: url, ref: ref });
        $.globalEval(script, { nonce: Utility.meta("csp-nonce") });

        // The source data is above the tag box, so loading it can push the tag box off the screen.
        $("#post_tag_string:focus")[0]?.scrollIntoView({ block: "nearest" });
      } catch (error) {
        Notice.error(`Error fetching source data (error: ${error.status} ${error.statusText})`);
      } finally {
        $(".source-data").removeClass("loading");
      }
    }
  }
}

$(document).ready(SourceDataComponent.initialize);

export default SourceDataComponent;
