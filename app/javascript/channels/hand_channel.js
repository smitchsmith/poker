import consumer from "./consumer"

const urlParts = window.location.toString().split("/")
const id = parseInt(urlParts.slice(-1)[0])

if ((urlParts.slice(-2)[0] === "hands") && id) {
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
}
