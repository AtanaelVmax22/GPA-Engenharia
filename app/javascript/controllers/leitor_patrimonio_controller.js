
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "serie", "mensagem"]

  connect() {
    this.stream = null
    this.ativo = false
    this.detector = null
    this.timer = null
  }

  async iniciar() {
    if (this.ativo) return

    if (!("BarcodeDetector" in window)) {
      this.avisar(
        "Leitura pela câmera indisponível neste navegador. Use um leitor USB/Bluetooth ou digite o número de série."
      )
      return
    }

    if (!navigator.mediaDevices?.getUserMedia) {
      this.avisar(
        "Câmera indisponível. Verifique a permissão e o acesso HTTPS."
      )
      return
    }

    try {
      const formatos = await BarcodeDetector.getSupportedFormats()

      const desejados = [
        "code_128",
        "code_39",
        "qr_code",
        "data_matrix"
      ]

      const suportados = desejados.filter(
        (formato) => formatos.includes(formato)
      )

      if (suportados.length === 0) {
        this.avisar("Nenhum formato de etiqueta compatível foi encontrado.")
        return
      }

      this.detector = new BarcodeDetector({
        formats: suportados
      })

      this.stream = await navigator.mediaDevices.getUserMedia({
        audio: false,
        video: {
          facingMode: { ideal: "environment" }
        }
      })

      this.videoTarget.srcObject = this.stream
      this.videoTarget.classList.remove("hidden")

      await this.videoTarget.play()

      this.ativo = true
      this.avisar("Aponte a câmera para a etiqueta do número de série.")

      this.ler()
    } catch (erro) {
      this.parar()
      this.avisar(
        "Não foi possível iniciar a câmera. Verifique as permissões."
      )
      console.error("[GPA] Erro no scanner:", erro)
    }
  }

  async ler() {
    if (!this.ativo) return

    try {
      const codigos = await this.detector.detect(this.videoTarget)

      if (codigos.length > 0) {
        const valor = codigos[0].rawValue?.trim()

        if (valor) {
          this.serieTarget.value = valor
          this.serieTarget.dispatchEvent(
            new Event("input", { bubbles: true })
          )

          this.parar()
          this.avisar(
            `Código capturado: ${valor}. Confirme que é o número de série.`
          )

          return
        }
      }
    } catch (erro) {
      console.warn("[GPA] Falha na leitura:", erro)
    }

    if (this.ativo) {
      this.timer = setTimeout(() => this.ler(), 250)
    }
  }

  parar() {
    this.ativo = false

    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }

    if (this.stream) {
      this.stream.getTracks().forEach((track) => track.stop())
      this.stream = null
    }

    if (this.hasVideoTarget) {
      this.videoTarget.pause()
      this.videoTarget.srcObject = null
      this.videoTarget.classList.add("hidden")
    }
  }

  avisar(mensagem) {
    if (this.hasMensagemTarget) {
      this.mensagemTarget.textContent = mensagem
    }
  }

  disconnect() {
    this.parar()
  }
}
