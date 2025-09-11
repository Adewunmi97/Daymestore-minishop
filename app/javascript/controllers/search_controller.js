import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.suggestions = this.suggestionsTarget
  }

  search() {
    let query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.suggestions.innerHTML = ""
      this.suggestions.classList.add("hidden")
      return
    }

    fetch(`/products/search_suggestions?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          this.suggestions.innerHTML = data.map(item => 
            `<li class="px-4 py-2 hover:bg-gray-100 cursor-pointer">${item}</li>`
          ).join("")
          this.suggestions.classList.remove("hidden")

          // Click to autofill input
          this.suggestions.querySelectorAll("li").forEach(li => {
            li.addEventListener("click", () => {
              this.inputTarget.value = li.textContent
              this.suggestions.classList.add("hidden")
            })
          })
        } else {
          this.suggestions.classList.add("hidden")
        }
      })
  }
}
