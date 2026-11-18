
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tipo",
    "origem",
    "destino",
    "erro",
    "dica"
  ]

  connect() {
    this.atualizar()
  }

  atualizar() {
    if (!this.hasTipoTarget ||
        !this.hasOrigemTarget ||
        !this.hasDestinoTarget) {
      return
    }

    const tipo = this.tipoTarget.value
    const origem = this.origemTarget.value
    const destino = this.destinoTarget.value

    const exigeLocaisDiferentes =
      tipo === "transferencia" ||
      tipo === "devolucao"

    // Em entradas e ajustes, a regra de igualdade
    // entre os locais não se aplica.
    this.dicaTarget.classList.toggle(
      "hidden",
      !exigeLocaisDiferentes
    )

    // Reabilita todas as opções antes de recalcular.
    Array.from(this.destinoTarget.options).forEach((option) => {
      option.disabled = false
    })

    if (exigeLocaisDiferentes && origem !== "") {
      // Bloqueia no destino o mesmo local
      // selecionado na origem.
      Array.from(this.destinoTarget.options).forEach((option) => {
        if (option.value === origem) {
          option.disabled = true
        }
      })
    }

    // Se a origem mudou e ficou igual ao destino
    // selecionado anteriormente, limpa o destino.
    if (
      exigeLocaisDiferentes &&
      origem !== "" &&
      destino !== "" &&
      origem === destino
    ) {
      this.destinoTarget.value = ""

      // Informa outros controllers que houve alteração.
      this.destinoTarget.dispatchEvent(
        new Event("change", { bubbles: true })
      )

      this.mostrarErro(
        "O estoque de destino não pode ser igual ao estoque de origem. Selecione outro destino."
      )

      return
    }

    this.limparErro()
  }

  validarEnvio(event) {
    const tipo = this.tipoTarget.value
    const origem = this.origemTarget.value
    const destino = this.destinoTarget.value

    const exigeLocaisDiferentes =
      tipo === "transferencia" ||
      tipo === "devolucao"

    if (!exigeLocaisDiferentes) {
      return
    }

    if (!origem) {
      this.bloquearEnvio(
        event,
        "Selecione o estoque de origem."
      )
      return
    }

    if (!destino) {
      this.bloquearEnvio(
        event,
        "Selecione um estoque de destino diferente da origem."
      )
      return
    }

    if (origem === destino) {
      this.bloquearEnvio(
        event,
        "Não é permitido transferir materiais para o próprio estoque."
      )
    }
  }

  bloquearEnvio(event, mensagem) {
    event.preventDefault()
    event.stopImmediatePropagation()

    this.mostrarErro(mensagem)
  }

  mostrarErro(mensagem) {
    if (!this.hasErroTarget) return

    this.erroTarget.textContent = mensagem
    this.erroTarget.classList.remove("hidden")
  }

  limparErro() {
    if (!this.hasErroTarget) return

    this.erroTarget.textContent = ""
    this.erroTarget.classList.add("hidden")
  }
}
