import consumer from "./consumer"

consumer.subscriptions.create({ channel: "HandChannel", id: 16 }, {
  received(data) {
    setTimeout(function () { window.location.reload(true); }, 500);
  }
})
