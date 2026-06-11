import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["produto", "tipo", "quantidade", "origem", "aviso"]

  async verificar() {
    this.limparAviso()

    const tipo = this.tipoTarget.value
    const produtoId = this.produtoTarget.value
    const origemId = this.origemTarget.value
    const quantidade = parseFloat(this.quantidadeTarget.value || "0")

    const tiposQueSaemDoEstoque = [
      "saida",
      "perda",
      "defeito",
      "uso_servico",
      "transferencia",
      "devolucao"
    ]

    if (!tiposQueSaemDoEstoque.includes(tipo)) {
      return
    }

    if (!produtoId || !origemId || !quantidade || quantidade <= 0) {
      return
    }

    const url = `/estoque/saldos/consulta?produto_id=${produtoId}&local_id=${origemId}`

    const response = await fetch(url, {
      headers: {
        "Accept": "application/json"
      }
    })

    if (!response.ok) {
      return
    }

    const data = await response.json()
    const saldoDisponivel = parseFloat(data.quantidade || "0")

    if (quantidade > saldoDisponivel) {
      this.quantidadeTarget.classList.remove("border-zinc-700")
      this.quantidadeTarget.classList.add("border-red-500", "text-red-400", "focus:border-red-500")

      this.avisoTarget.classList.remove("hidden")
      this.avisoTarget.classList.add(
        "bg-red-900/40",
        "border-red-700",
        "text-red-300"
      )

      this.avisoTarget.innerHTML = `
        <strong>Saldo insuficiente.</strong>
        Saldo disponível neste estoque: ${data.quantidade_formatada}.
        Se confirmar mesmo assim, o sistema vai bloquear a movimentação.
      `
    } else {
      this.quantidadeTarget.classList.remove("border-red-500", "text-red-400", "focus:border-red-500")
      this.quantidadeTarget.classList.add("border-emerald-600")

      this.avisoTarget.classList.remove("hidden")
      this.avisoTarget.classList.add(
        "bg-emerald-900/30",
        "border-emerald-700",
        "text-emerald-300"
      )

      this.avisoTarget.innerHTML = `
        Saldo disponível: ${data.quantidade_formatada}.
      `
    }
  }

  limparAviso() {
    this.quantidadeTarget.classList.remove(
      "border-red-500",
      "text-red-400",
      "focus:border-red-500",
      "border-emerald-600"
    )

    this.quantidadeTarget.classList.add("border-zinc-700")

    this.avisoTarget.classList.add("hidden")
    this.avisoTarget.classList.remove(
      "bg-red-900/40",
      "border-red-700",
      "text-red-300",
      "bg-emerald-900/30",
      "border-emerald-700",
      "text-emerald-300"
    )

    this.avisoTarget.innerHTML = ""
  }
}localStorage