
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sidebar",
    "backdrop",
    "menuButton",
    "themeButton"
  ]

  connect() {
    console.log("[GPA] Controller do layout conectado")

    const savedTheme = this.getStorage("gpa-theme")

    const systemTheme = window.matchMedia(
      "(prefers-color-scheme: light)"
    ).matches ? "light" : "dark"

    this.setTheme(
      ["light", "dark"].includes(savedTheme)
        ? savedTheme
        : systemTheme
    )

    const collapsed =
      this.getStorage("gpa-sidebar-collapsed") === "true"

    this.element.classList.toggle("is-collapsed", collapsed)

    this.closeMenu()
  }

  disconnect() {
    document.body.classList.remove("gpa-menu-open")
  }

  getStorage(key) {
    try {
      return localStorage.getItem(key)
    } catch (error) {
      return null
    }
  }

  setStorage(key, value) {
    try {
      localStorage.setItem(key, value)
    } catch (error) {
      console.warn("[GPA] Não foi possível salvar preferência", error)
    }
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)

    if (this.hasThemeButtonTarget) {
      const isLight = theme === "light"

      this.themeButtonTarget.setAttribute(
        "aria-pressed",
        String(isLight)
      )

      this.themeButtonTarget.setAttribute(
        "aria-label",
        isLight ? "Ativar tema escuro" : "Ativar tema claro"
      )

      this.themeButtonTarget.title =
        isLight ? "Ativar tema escuro" : "Ativar tema claro"
    }
  }

  toggleTheme() {
    const current =
      document.documentElement.getAttribute("data-theme")

    const next = current === "dark" ? "light" : "dark"

    this.setTheme(next)
    this.setStorage("gpa-theme", next)

    console.log("[GPA] Tema alterado:", next)
  }

  toggleCollapse() {
    const collapsed =
      this.element.classList.toggle("is-collapsed")

    this.setStorage(
      "gpa-sidebar-collapsed",
      String(collapsed)
    )
  }

  toggleMenu() {
    if (this.element.classList.contains("is-menu-open")) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    this.element.classList.add("is-menu-open")
    document.body.classList.add("gpa-menu-open")

    if (this.hasBackdropTarget) {
      this.backdropTarget.hidden = false
    }

    if (this.hasMenuButtonTarget) {
      this.menuButtonTarget.setAttribute(
        "aria-expanded",
        "true"
      )
    }
  }

  closeMenu() {
    this.element.classList.remove("is-menu-open")
    document.body.classList.remove("gpa-menu-open")

    if (this.hasBackdropTarget) {
      this.backdropTarget.hidden = true
    }

    if (this.hasMenuButtonTarget) {
      this.menuButtonTarget.setAttribute(
        "aria-expanded",
        "false"
      )
    }
  }

  navigate() {
    this.closeMenu()
  }
}
