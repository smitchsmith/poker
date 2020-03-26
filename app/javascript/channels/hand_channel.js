import consumer from "./consumer"

const id = String(window.location).split("/").slice(-1)[0]

consumer.subscriptions.create({ channel: "HandChannel", id: id }, {
  received(data) {
    setTimeout(function () {
      if (data === id) {
        window.location.reload(true)
      } else {
        window.location = `/hands/${data}`
      };
    }, 500);
  }
})
