// app/javascript/controllers/subscription_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  subscribe() {
    const token = document.querySelector('meta[name="csrf-token"]').content;

    fetch("/subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      }
    })
    .then(res => res.json())
    .then(data => {
      if (data.approval_url) {
        window.location.href = data.approval_url; // redirect to PayPal
      } else {
        alert("Error: " + JSON.stringify(data));
      }
    });
  }
}
