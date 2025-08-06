import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["display"]
  connect() {
  }

  display(){
    this.displayTarget.src = event.currentTarget.src
  }
}
