// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

var toFilter = [].slice.call(document.getElementsByClassName('filters'));
var filter = document.getElementById('filter_button')

toFilter.forEach(function (element) {
  element.className += " sr-only";
})
filter.addEventListener('click', function (e) {
    e.preventDefault();
    toFilter.forEach(function (element) {
      if (element.className.includes("sr-only")) {
        element.className = element.className.replace(" sr-only", "");
      } else {
        element.className += " sr-only";
      }
    })
  });

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
