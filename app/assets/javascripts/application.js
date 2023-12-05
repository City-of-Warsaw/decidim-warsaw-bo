// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
// require_tree .
//= require decidim 
//= require jquery.MultiFile.modCS
//= require jquery.multiselect.modCS
//= require leaflet-src.1.8.0.modCS 
//= require autocomplete.min
//= require polyfill
//= require words-limit 

$(document).ready(function () {
  initializeActivityMonitor();

  $(".row.home-bullets").slick({
    arrows: false,
    slide: ".home-bullets .column",
    infinite: true,
    slidesToShow: 5,
    slidesToScroll: 5,
    accessibility: false, // not clickable element
    responsive: [
      {
        breakpoint: 880,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 2,
          infinite: true,
          dots: true,
          autoplay: false,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 10000,
        settings: "unslick", // destroys slick
      },
    ],
  });

  $(".costs-section .slicked").slick({
    arrows: true,
    prevArrow: '<button type="button" class="slick-prev">Poprzedni</button>',
    nextArrow: '<button type="button" class="slick-next">Następny</button>',
    // slide: ".home-bullets .column",
    infinite: true,
    slidesToShow: 3,
    slidesToScroll: 3,
    // autoplay: true,
    autoplaySpeed: 2000,
    accessibility: false, // not clickable element
    responsive: [
      {
        breakpoint: 1570,
        settings: {
          slidesToShow: 3,
          slidesToScroll: 3,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 880,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 2,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 660,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      // {
      //   breakpoint: 300,
      //   settings: "unslick" // destroys slick
      // }
    ],
  });

  $(".archive-section .slicked").slick({
    arrows: true,
    prevArrow: '<button type="button" class="slick-prev">Poprzedni</button>',
    nextArrow: '<button type="button" class="slick-next">Następny</button>',
    // slide: ".home-bullets .column",
    infinite: true,
    slidesToShow: 3,
    slidesToScroll: 3,
    // autoplay: true,
    autoplaySpeed: 2000,
    responsive: [
      {
        breakpoint: 1570,
        settings: {
          slidesToShow: 3,
          slidesToScroll: 3,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 880,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 2,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 660,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      // {
      //   breakpoint: 300,
      //   settings: "unslick" // destroys slick
      // }
    ],
  });

  $(".implementation-photos .slicked").slick({
    arrows: false,
    dots: true,
    slide: ".implementation-photos .columns",
    infinite: true,
    slidesToShow: 1,
    slidesToScroll: 1,
    // autoplay: true,
    autoplaySpeed: 2000,
    // responsive: [
    //   {
    //     breakpoint: 300,
    //     settings: "unslick" // destroys slick
    //   }
    // ]
  });

  $(".proposals-slider .slider-element").slick({
    arrows: true,
    slide: ".proposals-slider .card--project",
    prevArrow: '<button type="button" class="slick-prev">Poprzedni</button>',
    nextArrow: '<button type="button" class="slick-next">Następny</button>',
    infinite: true,
    slidesToShow: 1,
    slidesToScroll: 1,
    // autoplay: true,
    autoplaySpeed: 2000,
    responsive: [
      {
        breakpoint: 1570,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      {
        breakpoint: 880,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
          arrows: false,
          // autoplay: true,
          autoplaySpeed: 2000,
        },
      },
      // {
      //   breakpoint: 300,
      //   settings: "unslick" // destroys slick
      // }
    ],
  });

  $(".box-with-target-link-js").click(function () {
    var target = $(this).data("target");
    var href = $(target).attr("href");

    window.location.href = href;
  });

  $(".box-with-target-link-js").keypress(function (event) {
    if (event.keyCode == 13) {
      $(".box-with-target-link-js").click();
    }
  });
});

function detectActivity() {
  const currentTimestamp = +new Date();

  localStorage.setItem("activeAt", currentTimestamp);
}

function initializeActivityMonitor() {
  detectActivity();

  window.document.body.onmousemove = detectActivity;
  window.onfocus = detectActivity;
  window.onblur = detectActivity;
}

function hasTouch() {
  return (
    "ontouchstart" in document.documentElement ||
    navigator.maxTouchPoints > 0 ||
    navigator.msMaxTouchPoints > 0
  );
}

if (hasTouch()) {
  // remove all the :hover stylesheets
  try {
    // prevent exception on browsers not supporting DOM styleSheets properly
    for (var si in document.styleSheets) {
      var styleSheet = document.styleSheets[si];
      if (!styleSheet.rules) continue;

      for (var ri = styleSheet.rules.length - 1; ri >= 0; ri--) {
        if (!styleSheet.rules[ri].selectorText) continue;

        if (styleSheet.rules[ri].selectorText.match(":hover")) {
          styleSheet.deleteRule(ri);
        }
      }
    }
  } catch (ex) {}
}
