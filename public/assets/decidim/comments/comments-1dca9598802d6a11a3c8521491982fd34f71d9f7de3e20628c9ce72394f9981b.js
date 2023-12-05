


window.DecidimComments = window.DecidimComments || {};

window.DecidimComments = {
  assets: {
    'icons.svg': "/assets/decidim/icons-12032a129d2a2668259128b86df2c8829ea6cdaa07beb8538a61c4872aa66328.svg"
  }
};
/**
 * A plain Javascript component that handles the comments.
 *
 * @class
 * @augments Component
 */

"use strict";

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

(function (exports) {
  var $ = exports.$; // eslint-disable-line

  var CommentsComponent = (function () {
    function CommentsComponent($element, config) {
      _classCallCheck(this, CommentsComponent);

      this.$element = $element;
      this.commentableGid = config.commentableGid;
      this.commentsUrl = config.commentsUrl;
      this.rootDepth = config.rootDepth;
      this.order = config.order;
      this.lastCommentId = config.lastCommentId;
      this.pollingInterval = config.pollingInterval || 15000;
      this.id = this.$element.attr("id") || this._getUID();
      this.mounted = false;
    }

    /**
     * Handles the logic for mounting the component
     * @public
     * @returns {Void} - Returns nothing
     */

    _createClass(CommentsComponent, [{
      key: "mountComponent",
      value: function mountComponent() {
        var _this = this;

        if (this.$element.length > 0 && !this.mounted) {
          this.mounted = true;
          this._initializeComments(this.$element);

          $(".order-by__dropdown .is-submenu-item a", this.$element).on("click.decidim-comments", function () {
            _this._onInitOrder();
          });
        }
      }

      /**
       * Handles the logic for unmounting the component
       * @public
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "unmountComponent",
      value: function unmountComponent() {
        if (this.mounted) {
          this.mounted = false;
          this._stopPolling();

          $(".add-comment .opinion-toggle .button", this.$element).off("click.decidim-comments");
          $(".add-comment textarea", this.$element).off("input.decidim-comments");
          $(".order-by__dropdown .is-submenu-item a", this.$element).off("click.decidim-comments");
          $(".add-comment form", this.$element).off("submit.decidim-comments");
        }
      }

      /**
       * Adds a new thread to the comments section.
       * @public
       * @param {String} threadHtml - The HTML content for the thread.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "addThread",
      value: function addThread(threadHtml) {
        var $parent = $(".comments:first", this.$element);
        var $comment = $(threadHtml);
        var $threads = $(".comment-threads", this.$element);
        this._addComment($threads, $comment);
        this._finalizeCommentCreation($parent);
      }

      /**
       * Adds a new reply to an existing comment.
       * @public
       * @param {Number} commentId - The ID of the comment for which to add the
       *   reply to.
       * @param {String} replyHtml - The HTML content for the reply.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "addReply",
      value: function addReply(commentId, replyHtml) {
        var $parent = $("#comment_" + commentId);
        var $comment = $(replyHtml);
        var $replies = $("#comment-" + commentId + "-replies");
        this._addComment($replies, $comment);
        $replies.siblings(".comment__additionalreply").removeClass("hide");
        this._finalizeCommentCreation($parent);
      }

      /**
       * Generates a unique identifier for the form.
       * @private
       * @returns {String} - Returns a unique identifier
       */
    }, {
      key: "_getUID",
      value: function _getUID() {
        return "comments-" + new Date().setUTCMilliseconds() + "-" + Math.floor(Math.random() * 10000000);
      }

      /**
       * Initializes the comments for the given parent element.
       * @private
       * @param {jQuery} $parent The parent element to initialize.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_initializeComments",
      value: function _initializeComments($parent) {
        var _this2 = this;

        $(".add-comment", $parent).each(function (_i, el) {
          var $add = $(el);
          var $form = $("form", $add);
          var $opinionButtons = $(".opinion-toggle .button", $add);
          var $text = $("textarea", $form);

          $opinionButtons.on("click.decidim-comments", _this2._onToggleOpinion);
          $text.on("input.decidim-comments", _this2._onTextInput);

          $(document).trigger("attach-mentions-element", [$text.get(0)]);

          $form.on("submit.decidim-comments", function () {
            var $submit = $("button[type='submit']", $form);

            $submit.attr("disabled", "disabled");
            _this2._stopPolling();
          });
        });

        this._pollComments();
      }

      /**
       * Adds the given comment element to the given target element and
       * initializes it.
       * @private
       * @param {jQuery} $target - The target element to add the comment to.
       * @param {jQuery} $container - The comment container element to add.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_addComment",
      value: function _addComment($target, $container) {
        var $comment = $(".comment", $container);
        if ($comment.length < 1) {
          // In case of a reply
          $comment = $container;
        }
        this.lastCommentId = parseInt($comment.data("comment-id"), 10);

        $target.append($container);
        $container.foundation();
        this._initializeComments($container);
        if (exports.Decidim.createCharacterCounter) {
          exports.Decidim.createCharacterCounter($(".add-comment textarea", $container));
        }
      }

      /**
       * Finalizes the new comment creation after the comment adding finishes
       * successfully.
       * @private
       * @param {jQuery} $parent - The parent comment element to finalize.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_finalizeCommentCreation",
      value: function _finalizeCommentCreation($parent) {
        var $add = $("> .add-comment", $parent);
        var $text = $("textarea", $add);
        var characterCounter = $text.data("remaining-characters-counter");
        $text.val("");
        if (characterCounter) {
          characterCounter.updateStatus();
        }
        if (!$add.parent().is(".comments")) {
          $add.addClass("hide");
        }

        // Restart the polling
        this._pollComments();
      }

      /**
       * Sets a timeout to poll new comments.
       * @private
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_pollComments",
      value: function _pollComments() {
        var _this3 = this;

        this._stopPolling();

        this.pollTimeout = setTimeout(function () {
          $.ajax({
            url: _this3.commentsUrl,
            method: "GET",
            contentType: "application/javascript",
            data: {
              "commentable_gid": _this3.commentableGid,
              "root_depth": _this3.rootDepth,
              order: _this3.order,
              after: _this3.lastCommentId
            }
          }).done(function () {
            _this3._pollComments();
          });
        }, this.pollingInterval);
      }

      /**
       * Stops polling for new comments.
       * @private
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_stopPolling",
      value: function _stopPolling() {
        if (this.pollTimeout) {
          clearTimeout(this.pollTimeout);
        }
      }

      /**
       * Sets the loading comments element visible in the view.
       * @private
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_setLoading",
      value: function _setLoading() {
        var $container = $("> .comments-container", this.$element);
        $("> .comments", $container).addClass("hide");
        $("> .loading-comments", $container).removeClass("hide");
      }

      /**
       * Event listener for the ordering links.
       * @private
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_onInitOrder",
      value: function _onInitOrder() {
        this._stopPolling();
        this._setLoading();
      }

      /**
       * Event listener for the opinion toggle buttons.
       * @private
       * @param {Event} ev - The event object.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_onToggleOpinion",
      value: function _onToggleOpinion(ev) {
        var $btn = $(ev.target);
        if (!$btn.is(".button")) {
          $btn = $btn.parents(".button");
        }

        var $add = $btn.closest(".add-comment");
        var $form = $("form", $add);
        var $opinionButtons = $(".opinion-toggle .button", $add);
        var $alignment = $(".alignment-input", $form);

        $opinionButtons.removeClass("is-active");
        $btn.addClass("is-active");

        if ($btn.is(".opinion-toggle--ok")) {
          $alignment.val(1);
        } else if ($btn.is(".opinion-toggle--meh")) {
          $alignment.val(0);
        } else if ($btn.is(".opinion-toggle--ko")) {
          $alignment.val(-1);
        }
      }

      /**
       * Event listener for the comment field text input.
       * @private
       * @param {Event} ev - The event object.
       * @returns {Void} - Returns nothing
       */
    }, {
      key: "_onTextInput",
      value: function _onTextInput(ev) {
        var $text = $(ev.target);
        var $add = $text.closest(".add-comment");
        var $form = $("form", $add);
        var $submit = $("button[type='submit']", $form);

        if ($text.val().length > 0) {
          $submit.removeAttr("disabled");
        } else {
          $submit.attr("disabled", "disabled");
        }
      }
    }]);

    return CommentsComponent;
  })();

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.CommentsComponent = CommentsComponent;

  $(function () {
    $("[data-decidim-comments]").each(function (_i, el) {
      var $el = $(el);
      var comments = new CommentsComponent($el, $el.data("decidim-comments"));
      comments.mountComponent();
      $(el).data("comments", comments);
    });
  });
})(window);
