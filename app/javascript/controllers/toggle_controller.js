import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"];

  connect() {
    this.open = false;
    this.closeIconTarget.classList.add("hidden");
  }

  menu() {
    this.open = !this.open;

    this.menuTarget.classList.toggle("hidden", !this.open);
    this.openIconTarget.classList.toggle("hidden", this.open);
    this.closeIconTarget.classList.toggle("hidden", !this.open);
  }
}
