import consumer from "./consumer"

const id = parseInt(window.location.toString().split("/").slice(-1)[0])

consumer.subscriptions.create({ channel: "HandChannel", id: id }, {
  received(data) {
    setTimeout(function () {
      if (data === id) {
        Turbolinks.visit(window.location, {action: "replace"})
      } else {
        window.location = `/hands/${data}`
      };
    }, 500);
  }
})
