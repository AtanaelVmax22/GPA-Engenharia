module EstoqueHelper
  def formatar_quantidade(valor)
    numero = BigDecimal(valor.to_s)

    if numero.frac.zero?
      numero.to_i.to_s
    else
      numero.to_s("F").sub(/0+\z/, "").sub(/\.\z/, "")
    end
  end
end