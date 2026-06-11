import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.intervalo = null
    this.verificar()

    this.intervalo = setInterval(() => {
      this.verificar()
    }, 10000)
  }

  disconnect() {
    if (this.intervalo) {
      clearInterval(this.intervalo)
    }
  }

  async verificar() {
    if (!this.urlValue) return

    try {
      const response = await fetch(this.urlValue, {
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) return

      const data = await response.json()

      if (!data.transferencias || data.transferencias.length === 0) {
        return
      }

      data.transferencias.forEach((transferencia) => {
        this.notificarSeNova(transferencia)
      })
    } catch (error) {
      console.warn("Erro ao verificar notificações de estoque", error)
    }
  }

  notificarSeNova(transferencia) {
    const chave = `estoque_transferencia_notificada_${transferencia.id}`

    if (localStorage.getItem(chave)) {
      return
    }

    localStorage.setItem(chave, "1")
    this.exibirPopup(transferencia)
  }

  exibirPopup(transferencia) {
    const popupExistente = document.getElementById("popup-transferencia-estoque")
    if (popupExistente) popupExistente.remove()

    const popup = document.createElement("div")
    popup.id = "popup-transferencia-estoque"
    popup.className = "fixed right-6 bottom-6 z-50 w-full max-w-md bg-zinc-900 border border-amber-500/60 shadow-2xl rounded-2xl overflow-hidden"

    popup.innerHTML = `
      <div class="p-5">
        <div class="flex items-start justify-between gap-4">
          <div>
            <div class="text-amber-400 text-sm font-bold uppercase tracking-wide">
              Transferência pendente
            </div>

            <h3 class="text-zinc-100 text-lg font-bold mt-1">
              Novo material enviado para seu estoque
            </h3>
          </div>

          <button
            type="button"
            data-action="click->notificacoes-estoque#fechar"
            class="text-zinc-500 hover:text-zinc-200 text-xl leading-none"
          >
            ×
          </button>
        </div>

        <div class="mt-4 space-y-2 text-sm">
          <div class="flex justify-between gap-4">
            <span class="text-zinc-500">Produto</span>
            <span class="text-zinc-100 font-semibold text-right">${transferencia.produto}</span>
          </div>

          <div class="flex justify-between gap-4">
            <span class="text-zinc-500">Quantidade</span>
            <span class="text-amber-400 font-bold">${transferencia.quantidade}</span>
          </div>

          <div class="flex justify-between gap-4">
            <span class="text-zinc-500">Origem</span>
            <span class="text-zinc-300 text-right">${transferencia.origem || "-"}</span>
          </div>

          <div class="flex justify-between gap-4">
            <span class="text-zinc-500">Destino</span>
            <span class="text-zinc-300 text-right">${transferencia.destino || "-"}</span>
          </div>

          <div class="flex justify-between gap-4">
            <span class="text-zinc-500">Enviado por</span>
            <span class="text-zinc-300 text-right">${transferencia.enviado_por}</span>
          </div>
        </div>

        <div class="mt-5 grid grid-cols-2 gap-3">
          <a
            href="${transferencia.recebimentos_url}"
            class="px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 text-center text-sm font-semibold"
          >
            Ver pendências
          </a>

          <a
            href="${transferencia.url}"
            class="px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-400 text-zinc-950 text-center text-sm font-bold"
          >
            Conferir agora
          </a>
        </div>
      </div>
    `

    document.body.appendChild(popup)
  }

  fechar() {
    const popup = document.getElementById("popup-transferencia-estoque")
    if (popup) popup.remove()
  }
}