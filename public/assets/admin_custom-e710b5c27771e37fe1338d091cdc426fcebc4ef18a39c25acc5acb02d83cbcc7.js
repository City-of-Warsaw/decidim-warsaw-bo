/** @class Abstract class representing a tool for a Quill Editor toolbar. */

class QuillToolbarItem {
  constructor(options) {
    const me = this;
    me.options = options;

    me.qlFormatsEl = document.createElement("span");
    me.qlFormatsEl.className = "ql-formats";
  }
  /**
   * Attaches this tool to the given Quill Editor instance.
   *
   * @param {Quill} quill - The Quill Editor instance that this tool should get added to.
   */
  attach(quill) {
    const me = this;
    me.quill = quill;
    me.toolbar = quill.getModule("toolbar");
    me.toolbarEl = me.toolbar.container;
    me.toolbarEl.appendChild(me.qlFormatsEl);
  }
  /**
   * Detaches this tool from the given Quill Editor instance.
   *
   * @param {Quill} quill - The Quill Editor instance that this tool should get added to.
   */
  detach(quill) {
    const me = this;
    me.toolbarEl.removeChild(me.qlFormatsEl);
  }
  /**
   * Calculate the width of text.
   *
   * @param {string} text - The text of which the length should be calculated.
   * @param {string} [font="500 14px 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"] - The font css that shuold be applied to the text before calculating the width.
   */
  _getTextWidth(
    text,
    font = "500 14px 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
  ) {
    const canvas =
      this._getTextWidth.canvas ||
      (this._getTextWidth.canvas = document.createElement("canvas"));
    const context = canvas.getContext("2d");
    context.font = font;
    const metrics = context.measureText(text);
    return metrics.width;
  }
  /**
   * Add a global css rule to the document.
   *
   * @param {string} cssRule - CSS rules
   */
  _addCssRule(cssRule) {
    const style = document.createElement("style");
    document.head.appendChild(style);
    style.sheet.insertRule(cssRule, 0);
  }
  /**
   * Generate a random ID.
   *
   * @returns {string} random 10 digit ID
   */
  _generateId() {
    return Math.random().toString().substr(2, 10);
  }
}

/** @class Class representing a dropdown tool for a Quill Editor toolbar. */
class QuillToolbarDropDown extends QuillToolbarItem {
  /**
   * Creates an instance of QuillToolbarDropDown.
   *
   * @constructor
   * @param {object} [options] - The options/settings for this QuillToolbarDropDown.
   * @param {string} [options.id=`dropdown-${random10digitNumber}`] - The id of the quill tool.
   * @param {string} [options.label=""] - The default label that is being displayed before making a selection.
   * @param {boolean} [options.rememberSelection=true] - Automatically change the label to the current selection.
   * @param {object} [options.items={}] - The default items this dropdown will have. Needs to be a key-value-object (key=visible label; value=actual value).
   */
  constructor(options) {
    super(options);
    const me = this;

    me.id = me.options.id || `dropdown-${me._generateId()}`;

    const qlPicker = document.createElement("span");
    qlPicker.className = `ql-${me.id} ql-picker`;
    me.qlFormatsEl.appendChild(qlPicker);

    const qlPickerLabel = document.createElement("span");
    qlPickerLabel.className = "ql-picker-label";
    qlPicker.appendChild(qlPickerLabel);
    qlPickerLabel.addEventListener("click", function (e) {
      qlPicker.classList.toggle("ql-expanded");
    });
    window.addEventListener("click", function (e) {
      if (!qlPicker.contains(e.target)) {
        qlPicker.classList.remove("ql-expanded");
      }
    });

    const qlPickerOptions = document.createElement("span");
    qlPickerOptions.className = "ql-picker-options";
    qlPicker.appendChild(qlPickerOptions);

    me.dropDownEl = qlPicker;
    me.dropDownPickerEl = me.dropDownEl.querySelector(".ql-picker-options");
    me.dropDownPickerLabelEl = me.dropDownEl.querySelector(".ql-picker-label");
    me.dropDownPickerLabelEl.innerHTML = `<svg viewBox="0 0 18 18"> <polygon class="ql-stroke" points="7 11 9 13 11 11 7 11"></polygon> <polygon class="ql-stroke" points="7 7 9 5 11 7 7 7"></polygon> </svg>`;

    me.setLabel(me.options.label || "");
    me.setItems(me.options.items || {});

    me._addCssRule(`
          .ql-snow .ql-picker.ql-${me.id} .ql-picker-label::before, .ql-${me.id} .ql-picker.ql-size .ql-picker-item::before {
              content: attr(data-label);
          }
      `);
  }
  /**
   * Set the items for this dropdown tool.
   *
   * @param {object} items - Needs to be a key-value-object (key=visible label; value=actual value).
   */
  setItems(items) {
    const me = this;
    for (const [label, value] of Object.entries(items)) {
      const newItemEl = document.createElement("span");
      newItemEl.className = "ql-picker-item";
      newItemEl.innerHTML = label;
      newItemEl.setAttribute("data-value", value);
      newItemEl.onclick = function (e) {
        me.dropDownEl.classList.remove("ql-expanded");
        if (me.options.rememberSelection) me.setLabel(label);
        if (me.onSelect) me.onSelect(label, value, me.quill);
      };
      me.dropDownPickerEl.appendChild(newItemEl);
    }
  }
  /**
   * Set the label for this dropdown tool and automatically adjust the width to fit the label.
   *
   * @param {String} newLabel - The new label that should be set.
   */
  setLabel(newLabel) {
    const me = this;
    const requiredWidth = `${me._getTextWidth(newLabel) + 30}px`;
    me.dropDownPickerLabelEl.style.width = requiredWidth;
    me.dropDownPickerLabelEl.setAttribute("data-label", newLabel);
  }
  /**
   * A callback that gets called automatically when the dropdown selection changes. This callback is expected to be overwritten.
   *
   * @param {string} label - The label of the newly selected item.
   * @param {string} value - The value of the newly selected item.
   * @param {Quill} quill - The quill instance the dropdown tool is attached to.
   */
  onSelect(label, value, quill) {}
}

/** @class Class representing a button tool for a Quill Editor toolbar. */
class QuillToolbarButton extends QuillToolbarItem {
  /**
   * Creates an instance of QuillToolbarButton.
   *
   * @constructor
   * @param {object} [options] - The options/settings for this QuillToolbarButton.
   * @param {string} [options.id=`button-${random10digitNumber}`] - The id of the quill tool.
   * @param {string} [options.value] - The default hidden value of the button.
   * @param {string} options.icon - The default icon this button tool will have.
   */
  constructor(options) {
    super(options);
    const me = this;

    me.id = me.options.id || `button-${me._generateId()}`;

    me.qlButton = document.createElement("button");
    me.qlButton.className = `ql-${me.id}`;
    me.setValue(me.options.value);
    me.setIcon(me.options.icon);
    me.qlButton.onclick = function () {
      me.onClick(me.quill);
    };
    me.qlFormatsEl.appendChild(me.qlButton);
  }
  /**
   * Set the icon for this button tool.
   *
   * @param {string} newLabel - The <svg> or <img> html tag to use as an icon. (Make sure it's 18x18 in size.)
   */
  setIcon(imageHtml) {
    const me = this;
    me.qlButton.innerHTML = imageHtml;
  }
  /**
   * Set the hidden value of this button tool.
   *
   * @param {string} newLabel - The <svg> or <img> html tag to use as an icon. (Make sure it's 18x18 in size.)
   */
  setValue(value) {
    const me = this;
    me.qlButton.value = value;
  }
  /**
   * Set the hidden value of this button tool.
   *
   * @param {string} newLabel - The <svg> or <img> html tag to use as an icon. (Make sure it's 18x18 in size.)
   */
  getValue() {
    const me = this;
    return me.qlButton.value;
  }
  /**
   * A callback that gets called automatically when the button is clicked, tapped or triggered witht he keyboard etc. This callback is expected to be overwritten.
   *
   * @param {Quill} quill - The quill instance the dropdown tool is attached to.
   */
  onClick(button, quill) {}
}
;
Parchment = Quill.import("parchment");

const DEFAULT_LABEL = "Styl";

function registerQuillStyleToolbarTool() {
  Quill.register(
    new Parchment.Attributor.Class("class", "custom", {
      scope: Parchment.Scope.BLOCK,
    }),
    true
  );
}

function initializeQuillStyleToolbarTool(quill, styles = {}) {
  const flippedStyles = Object.fromEntries(
    Object.entries(styles).map(([k, v]) => [v, k])
  );

  const stylesDropdown = new QuillToolbarDropDown({
    label: DEFAULT_LABEL,
    rememberSelection: true,
  });

  stylesDropdown.setItems(styles);

  stylesDropdown.onSelect = function (label, value, quill) {
    var range = quill.selection.savedRange;
    var format = quill.getFormat(range);

    if (format && format["class"] !== value) {
      quill.format("class", value);
      stylesDropdown.setLabel(label);
      stylesDropdown.dropDownPickerLabelEl.classList.add("ql-active");
    } else {
      quill.removeFormat(range.index, range.index + range.length);
    }
  };

  quill.on("selection-change", (range) => {
    if (range) {
      var format = quill.getFormat(range);

      if (format["class"]) {
        stylesDropdown.setLabel(flippedStyles[format["class"]]);
        stylesDropdown.dropDownPickerLabelEl.classList.add("ql-active");
      } else {
        stylesDropdown.setLabel(DEFAULT_LABEL);
        stylesDropdown.dropDownPickerLabelEl.classList.remove("ql-active");
      }
    }
  });

  const toolbar = quill.getModule("toolbar");
  const styleButton = toolbar.container.querySelector(".ql-style");

  if (styleButton) {
    stylesDropdown.quill = quill;
    styleButton.replaceWith(stylesDropdown.qlFormatsEl);
  }
}
;
function createImageToolbarToolHandler(options) {
  const DEFAULT_OPTIONS = {
    uploadEndpointUrl: "",
    acceptMimeTypes: "image/png, image/gif, image/jpeg",
  };

  options = { ...DEFAULT_OPTIONS, ...options };

  let quill;

  const popup = document.createElement("div");
  popup.id = "ql-image-toolbar-popup";
  popup.style.display = "none";

  const popupCloseButton = document.createElement("button");
  popupCloseButton.id = "ql-image-toolbar-popup-close-button";
  popupCloseButton.innerHTML = "&times;";
  popupCloseButton.addEventListener("click", () => {
    popup.style.display = "none";
  });

  popup.appendChild(popupCloseButton);

  const popupForm = document.createElement("form");
  popupForm.setAttribute("method", "post");
  popupForm.setAttribute("enctype", "multipart/form-data");
  popupForm.setAttribute("action", options.uploadEndpointUrl);
  popupForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);
    const file = formData.get("file[file_input]");
    const alt = formData.get("file[alt]");

    if (!file || file.size === 0) {
      alert("Nie wybrano pliku");
      return false;
    }

    const imageUrl = await uploadFile(file, alt);

    if (imageUrl) {
      insertImage(quill, imageUrl, alt);
    }

    popup.style.display = "none";
    popupForm.reset();
  });

  const popupFileField = document.createElement("div");
  popupFileField.className = "ql-image-toolbar-popup-field";
  const popupFileFieldLabel = document.createElement("div");
  popupFileFieldLabel.innerText = "Plik:";

  const popupFileFieldInput = document.createElement("input");
  popupFileFieldInput.style.width = "100%";
  popupFileFieldInput.setAttribute("type", "file");
  popupFileFieldInput.setAttribute("accept", options.acceptMimeTypes);
  popupFileFieldInput.name = "file[file_input]";

  popupFileField.appendChild(popupFileFieldLabel);
  popupFileField.appendChild(popupFileFieldInput);

  popupForm.appendChild(popupFileField);

  const popupAltField = document.createElement("div");
  popupAltField.className = "ql-image-toolbar-popup-field";
  const popupAltFieldLabel = document.createElement("div");
  popupAltFieldLabel.innerText = "Opis alternatywny:";

  const popupAltFieldInput = document.createElement("input");
  popupAltFieldInput.setAttribute("type", "text");
  popupAltFieldInput.style.width = "100%";
  popupAltFieldInput.name = "file[alt]";

  popupAltField.appendChild(popupAltFieldLabel);
  popupAltField.appendChild(popupAltFieldInput);

  popupForm.appendChild(popupAltField);

  const popupSubmitButton = document.createElement("button");
  popupSubmitButton.className = "ql-image-toolbar-popup-button";
  popupSubmitButton.innerText = "Dodaj";
  popupSubmitButton.style.alignSelf = "flex-end";
  popupSubmitButton.type = "submit";

  popupForm.appendChild(popupSubmitButton);

  popup.appendChild(popupForm);

  document.body.appendChild(popup);

  async function uploadFile(file, alt) {
    const data = new FormData();
    data.append("file[name]", file.name);
    data.append("file[file_input]", file);
    data.append("file[alt]", alt);
    data.append(
      "authenticity_token",
      document.getElementsByName("csrf-token")[0].content
    );

    try {
      const response = await fetch(options.uploadEndpointUrl, {
        method: "POST",
        body: data,
        headers: {
          Accept: "application/json",
        },
        credentials: "include",
      });

      if (!response.ok) {
        alert("Wystąpił błąd podczas wysyłania pliku.");

        return null;
      }

      const json = await response.json();

      if (json["file_url"]) {
        return json["file_url"];
      } else {
        alert(
          `Wystąpiły następujące błędy podczas przetwarzania pliku:\n${json[
            "errors"
          ].join("\n")}`
        );

        return null;
      }
    } catch (error) {
      console.error(error);

      alert("Wystąpił błąd podczas wysyłania pliku.");

      return null;
    }
  }

  function insertImage(quill, url, alt) {
    const range = quill.getSelection(true);

    quill.insertEmbed(range.index, "extended-image", { url, alt });
    quill.setSelection(range.index + 1);
  }

  return async function () {
    quill = this.quill;

    const [, element] = this.controls.find(([id]) => id === "image");

    if (popup.style.display === "flex") {
      popup.style.display = "none";
    } else {
      popup.style.display = "flex";
      popup.style.top = `${element.offsetTop + element.offsetHeight}px`;
      popup.style.left = `${element.offsetLeft - popup.scrollWidth}px`;
    }
  };
}
;
const ATTRIBUTES = ["alt", "height", "width"];

function sanitize(url, protocols) {
  const anchor = document.createElement("a");
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(":"));
  return protocols.indexOf(protocol) > -1;
}

class ExtendedImage extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
    if (typeof value === "object") {
      node.setAttribute("src", this.sanitize(value.url));
      if (value.alt) {
        node.setAttribute("alt", value.alt);
      }
    }
    return node;
  }

  static formats(domNode) {
    return ATTRIBUTES.reduce(function (formats, attribute) {
      if (domNode.hasAttribute(attribute)) {
        formats[attribute] = domNode.getAttribute(attribute);
      }
      return formats;
    }, {});
  }

  static match(url) {
    return /\.(jpe?g|gif|png)$/.test(url) || /^data:image\/.+;base64/.test(url);
  }

  static sanitize(url) {
    return sanitize(url, ["http", "https", "data"]) ? url : "//:0";
  }

  static value(domNode) {
    return {
      url: domNode.getAttribute("src"),
      alt: domNode.getAttribute("alt"),
    };
  }

  format(name, value) {
    if (ATTRIBUTES.indexOf(name) > -1) {
      if (value) {
        this.domNode.setAttribute(name, value);
      } else {
        this.domNode.removeAttribute(name);
      }
    } else {
      super.format(name, value);
    }
  }
}
ExtendedImage.blotName = "extended-image";
ExtendedImage.tagName = "IMG";
// const ATTRIBUTES = ["alt", "height", "width"];

function sanitize(url, protocols) {
  const anchor = document.createElement("a");
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(":"));
  return protocols.indexOf(protocol) > -1;
}

class ExtendedVideo extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
    node.setAttribute("contenteditable", false);
    node.setAttribute("controls", true);
    node.setAttribute("data-setup", '{ "fluid": true }');

    if (typeof value === "object") {
      if (value.posterUrl) {
        node.setAttribute("poster", value.posterUrl);
      }

      const mainSource = document.createElement("source");
      mainSource.setAttribute("src", this.sanitize(value.url));
      mainSource.setAttribute("type", value.mimetype);
      node.appendChild(mainSource);

      if (value.descriptionsTrackUrl) {
        const descriptionsTrack = document.createElement("track");
        descriptionsTrack.setAttribute("kind", "descriptions");
        descriptionsTrack.setAttribute(
          "src",
          this.sanitize(value.descriptionsTrackUrl)
        );
        descriptionsTrack.setAttribute("srclang", "pl");
        descriptionsTrack.setAttribute("label", "Polski");
        node.appendChild(descriptionsTrack);
      }

      if (value.subtitlesTrackUrl) {
        const subtitlesTrack = document.createElement("track");
        subtitlesTrack.setAttribute("kind", "subtitles");
        subtitlesTrack.setAttribute(
          "src",
          this.sanitize(value.subtitlesTrackUrl)
        );
        subtitlesTrack.setAttribute("srclang", "pl");
        subtitlesTrack.setAttribute("label", "Polski");
        node.appendChild(subtitlesTrack);
      }

      if (value.captionsTrackUrl) {
        const captionsTrack = document.createElement("track");
        captionsTrack.setAttribute("kind", "captions");
        captionsTrack.setAttribute(
          "src",
          this.sanitize(value.captionsTrackUrl)
        );
        captionsTrack.setAttribute("srclang", "pl");
        captionsTrack.setAttribute("label", "Polski");
        node.appendChild(captionsTrack);
      }
    }

    return node;
  }

  static formats(domNode) {
    return ["height", "width"].reduce(function (formats, attribute) {
      if (domNode.hasAttribute(attribute)) {
        formats[attribute] = domNode.getAttribute(attribute);
      }
      return formats;
    }, {});
  }

  static sanitize(url) {
    return sanitize(url, ["http", "https", "data"]) ? url : "//:0";
  }

  static value(domNode) {
    const value = {
      posterUrl: domNode.getAttribute("poster"),
    };

    const mainSource = domNode.querySelector("source");

    if (mainSource) {
      value.url = mainSource.getAttribute("src");
      value.mimetype = mainSource.getAttribute("type");
    }

    const descriptionsTrack = domNode.querySelector(
      'track[kind="descriptions"]'
    );
    if (descriptionsTrack) {
      value.descriptionsTrackUrl = descriptionsTrack.getAttribute("src");
    }

    const subtitlesTrack = domNode.querySelector('track[kind="subtitles"]');
    if (subtitlesTrack) {
      value.subtitlesTrackUrl = subtitlesTrack.getAttribute("src");
    }

    const captionsTrack = domNode.querySelector('track[kind="captions"]');
    if (captionsTrack) {
      value.captionsTrackUrl = captionsTrack.getAttribute("src");
    }

    return value;
  }

  format(name, value) {
    if (ATTRIBUTES.indexOf(name) > -1) {
      if (value) {
        this.domNode.setAttribute(name, value);
      } else {
        this.domNode.removeAttribute(name);
      }
    } else {
      super.format(name, value);
    }
  }
}
ExtendedVideo.blotName = "extended-video";
ExtendedVideo.className = "video-js";
ExtendedVideo.tagName = "VIDEO"; 
 class Divider extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
 
    return node;
  }
}
Divider.blotName = "divider";
Divider.tagName = "HR";
class Link extends Quill.import("blots/inline") {
  static blotName = 'link';
  static tagName = 'A';
  static SANITIZED_URL = 'about:blank';
  static PROTOCOL_WHITELIST = ['http', 'https', 'mailto', 'tel', 'sms'];

  static create(value) {
    const node = super.create(value);
    node.setAttribute('href', this.sanitize(value));
    node.setAttribute('rel', 'noopener noreferrer');

    if (!value.startsWith(window.location.origin)) {
      node.setAttribute('target', '_blank');
    }

    return node;
  }

  static formats(domNode) {
    return domNode.getAttribute('href');
  }

  static sanitize(url) {
    return sanitize(url, this.PROTOCOL_WHITELIST) ? url : this.SANITIZED_URL;
  }

  format(name, value) {
    if (name !== this.statics.blotName || !value) {
      super.format(name, value);
    } else {
      // @ts-expect-error
      this.domNode.setAttribute('href', this.constructor.sanitize(value));
    }
  }
}

function sanitize(url, protocols) {
  const anchor = document.createElement('a');
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(':'));
  return protocols.indexOf(protocol) > -1;
}

Link.blotName = "link";
Link.tagName = "A";







