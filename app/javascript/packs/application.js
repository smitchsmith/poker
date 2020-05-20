// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
window.$ = window.jQuery = require("jquery");
require("chosen-js")
require("cocoon-js")
// require("popper")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

window.Poker = {}

window.Poker.handTimer = function () {
  const elementsToFlash = $(".actions-container .btn")
  setTimeout(function () {
    window.Poker.handTimerInterval = setInterval(function () {
      if (elementsToFlash.css("filter") === "invert(1)") {
        elementsToFlash.css("filter", "invert(0)")
      } else {
        elementsToFlash.css("filter", "invert(1)")
      }
    }, 500)
    const beep = new Audio('/assets/tone-7db2e0a85e47c75f7b64a4b89040f2a3129e2b5e2d03200d9aebea71d6b6572b.wav')
    beep.play()
  }, 15000)

  $(document).click(function() {
    elementsToFlash.css("filter", "")
    clearInterval(window.Poker.handTimerInterval)
  })
}

$(document).on("turbolinks:load", function () {
  const fixRaiseButtonName = function () {
    const input = $(".raise-form #bet_amount")
    const button = input.closest("form").find("input[type=submit]")
    const maxBetAmount = parseInt(input.attr("max"))
    const currentBetAmount = parseInt(input.val())
    if (currentBetAmount >= maxBetAmount) {
      button.val("All In")
    } else {
      button.val("Raise To")
    }
  }

  $(".raise-form #bet_amount").on("input", function () {
    fixRaiseButtonName()
  })

  fixRaiseButtonName()

  $('select').chosen({search_contains: true, allow_single_deselect: true});

  $("#table_players").on('click', function(event) {
    setTimeout(function () {
      $('select').chosen({search_contains: true, allow_single_deselect: true});
    }, 100)
  });
})
