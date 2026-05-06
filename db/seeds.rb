puts "Criando usuário admin..."
admin = User.find_or_create_by!(email: "admin@gpaengenharia.com") do |u|
  u.nome = "Administrador GPA"
  u.password = "gpa@2025"
  u.password_confirmation = "gpa@2025"
  u.role = :admin
  u.telefone = "(11) 99999-0000"
end
puts "  Admin criado: #{admin.email}"

puts "Criando técnicos..."
tecnico = User.find_or_create_by!(email: "carlos@gpaengenharia.com") do |u|
  u.nome = "Carlos Silva"
  u.password = "gpa@2025"
  u.password_confirmation = "gpa@2025"
  u.role = :tecnico
  u.telefone = "(11) 98888-1111"
end

puts "Criando condomínios..."
condominios = [
  { nome: "Ed. Solar das Flores", endereco: "R. das Flores, 123 - Centro",
    bairro: "Centro", cidade: "São Paulo", estado: "SP", cep: "01310-100",
    sindico_nome: "Carlos Andrade", sindico_telefone: "(11) 99999-9999",
    sindico_email: "sindico@solardasflores.com.br", unidades: 120 },
  { nome: "Ed. Jardim das Acácias", endereco: "Av. Moema, 456",
    bairro: "Moema", cidade: "São Paulo", estado: "SP", cep: "04077-020",
    sindico_nome: "Maria Santos", sindico_telefone: "(11) 97777-2222",
    unidades: 80 },
  { nome: "Ed. Torre Norte", endereco: "R. das Palmeiras, 789",
    bairro: "Vila Mariana", cidade: "São Paulo", estado: "SP", cep: "04116-000",
    sindico_nome: "João Oliveira", unidades: 200 },
]

condominios.each do |attrs|
  c = Condominio.find_or_create_by!(nome: attrs[:nome]) do |cond|
    cond.assign_attributes(attrs)
  end

  puts "  #{c.nome}"

  equips = [
    { nome: "Portão Veicular", categoria: "Portão Veicular", marca: "PPA", modelo: "DZ Turbo", localizacao: "Garagem subsolo", status: :operacional },
    { nome: "Interfone Portaria", categoria: "Interfone", marca: "HDL", modelo: "F8-SN", localizacao: "Portaria", status: :operacional },
    { nome: "Câmera Entrada", categoria: "Câmera CFTV", marca: "Intelbras", modelo: "VHL 1220", localizacao: "Entrada principal", status: :operacional },
  ]

  equips.each do |e|
    c.equipamentos.find_or_create_by!(nome: e[:nome]) { |eq| eq.assign_attributes(e) }
  end

  HistoricoTecnico.find_or_create_by!(titulo: "Manutenção preventiva", condominio: c) do |h|
    h.user = tecnico
    h.tipo = :preventiva
    h.descricao = "Manutenção preventiva realizada com sucesso. Todos os sistemas verificados e dentro dos padrões."
    h.data_atendimento = 13.days.ago
    h.status = :concluido
  end
end

puts "Seed concluído!"
