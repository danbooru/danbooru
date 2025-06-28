import Dropzone from 'dropzone';
import { delay, uploadError } from "./utility";
import Notice from "./notice";

export default class FileUploadComponent {
  static POLL_DELAY = 250;

  static initialize() {
    $(".file-upload-component").toArray().forEach(element => {
      new FileUploadComponent($(element));
    });
  }

  constructor($component) {
    this.$component = $component;
    this.$component.on("ajax:success", e => this.onSubmit(e));
    this.$component.on("ajax:error", e => this.onError(e));
    this.$dropTarget.on("paste.danbooru", e => this.onPaste(e));
    this.dropzone = this.initializeDropzone();

    // If the source field is pre-filled, then immediately submit the upload.
    if (/^https?:\/\//.test(this.$sourceField.val())) {
      this.$component.find("input[type='submit']").click();
    }
  }

  initializeDropzone() {
    if (!window.FileReader) {
      this.$dropzone.addClass("hidden");
      this.$component.find("input[type='file']").removeClass("hidden");
      return null;
    }

    let dropzone = new Dropzone(this.$dropTarget.get(0), {
      url: "/uploads.json",
      paramName: "upload[files]",
      clickable: this.$dropzone.get(0),
      previewsContainer: this.$dropzone.get(0),
      thumbnailHeight: null,
      thumbnailWidth: null,
      addRemoveLinks: false,
      parallelUploads: this.maxFiles,
      maxFiles: this.maxFiles,
      maxFilesize: this.maxFileSize,
      maxThumbnailFilesize: this.maxFileSize,
      timeout: 0,
      uploadMultiple: true,
      createImageThumbnails: false,
      acceptedFiles: ".jpg,.jpeg,.png,.gif,.webp,.avif,.mp4,.webm,.zip,.rar,.7z",
      previewTemplate: this.$component.find(".dropzone-preview-template").html(),
    });

    dropzone.on("complete", file => {
      this.$dropzone.find(".dz-progress").hide();
    });

    dropzone.on("addedfile", file => {
      this.$dropzone.removeClass("error");
      this.$dropzone.find(".dropzone-hint").hide();
    });

    dropzone.on("success", file => {
      this.$dropzone.addClass("success");
      let upload = JSON.parse(file.xhr.response)
      this.pollStatus(upload);
    });

    dropzone.on("error", (file, msg) => {
      this.$dropzone.find(".dropzone-hint").show();
      dropzone.removeFile(file);
      Notice.error(msg);
    });

    return dropzone;
  }

  onPaste(e) {
    let url = e.originalEvent.clipboardData.getData("text");
    this.$component.find("input[name='upload[source]']:not([disabled])").val(url);

    if (/^https?:\/\//.test(url)) {
      this.$component.find("input[type='submit']:not([disabled])").click();
    }

    e.preventDefault();
  }

  onSubmit(e) {
    let upload = e.originalEvent.detail[0];
    this.pollStatus(upload);
  }

  loadingStart() {
    this.$component.find(".spinner-icon").removeClass("hidden");
    this.$component.find("input").attr("disabled", "disabled");
    this.$component.find("form").addClass("pointer-events-none cursor-wait opacity-50");
  }

  loadingStop() {
    this.$component.find(".spinner-icon").addClass("hidden");
    this.$component.find("input").removeAttr("disabled");
    this.$component.find("form").removeClass("pointer-events-none cursor-wait opacity-50");
  }

  // Called after the upload is submitted via AJAX. Polls the upload until it
  // is complete, then redirects to the upload page.
  async pollStatus(upload) {
    this.loadingStart();

    while (upload.media_asset_count <= 1 && upload.status !== "completed" && upload.status !== "error") {
      await delay(FileUploadComponent.POLL_DELAY);
      upload = await $.get(`/uploads/${upload.id}.json`);
    }

    if (upload.status === "error") {
      this.$dropzone.removeClass("success");
      this.loadingStop();

      Notice.error(`Upload failed: ${upload.error}.`);
    } else {
      let params = new URLSearchParams(window.location.search);
      let isBookmarklet = params.has("url");
      params.delete("url");
      params.delete("ref");

      let url = new URL(`/uploads/${upload.id}`, window.location.origin);
      url.search = params.toString();

      if (isBookmarklet) {
        window.location.replace(url);
      } else {
        window.location.assign(url);
      }
    }
  }

  // Called when creating the upload failed because of a non-2xx response (usually a rate limiting error or a validation error).
  async onError(e) {
    let upload = e.originalEvent?.detail?.[0];
    let message = uploadError(upload);

    Notice.error(`Upload failed: ${message}`);
  }

  get $dropzone() {
    return this.$component.find(".dropzone-container");
  }

  get $sourceField() {
    return this.$component.find("input[name='upload[source]']");
  }

  get maxFileSize() {
    return Number(this.$component.attr("data-max-file-size")) / (1024 * 1024);
  }

  get maxFiles() {
    return Number(this.$component.attr("data-max-files-per-upload"));
  }

  // The element to listen for drag and drop events and paste events. By default,
  // it's the `.file-upload-component` element. If `data-drop-target` is the `body`
  // element, then you can drop images or paste URLs anywhere on the page.
  get $dropTarget() {
    return $(this.$component.attr("data-drop-target") || this.$component);
  }
}

$(FileUploadComponent.initialize);
