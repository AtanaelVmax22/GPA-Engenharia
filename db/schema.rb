# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_10_234924) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "checklist_items", force: :cascade do |t|
    t.bigint "checklist_id", null: false
    t.string "descricao"
    t.boolean "concluido"
    t.integer "ordem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id"], name: "index_checklist_items_on_checklist_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.bigint "condominio_id", null: false
    t.bigint "user_id", null: false
    t.string "titulo"
    t.datetime "data_visita"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominio_id"], name: "index_checklists_on_condominio_id"
    t.index ["user_id"], name: "index_checklists_on_user_id"
  end

  create_table "comentarios", force: :cascade do |t|
    t.bigint "post_tecnico_id", null: false
    t.bigint "user_id", null: false
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_tecnico_id"], name: "index_comentarios_on_post_tecnico_id"
    t.index ["user_id"], name: "index_comentarios_on_user_id"
  end

  create_table "condominios", force: :cascade do |t|
    t.string "nome"
    t.string "endereco"
    t.string "bairro"
    t.string "cidade"
    t.string "estado"
    t.string "cep"
    t.string "sindico_nome"
    t.string "sindico_telefone"
    t.string "sindico_email"
    t.integer "unidades"
    t.integer "status"
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "curtidas", force: :cascade do |t|
    t.bigint "post_tecnico_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_tecnico_id"], name: "index_curtidas_on_post_tecnico_id"
    t.index ["user_id"], name: "index_curtidas_on_user_id"
  end

  create_table "equipamentos", force: :cascade do |t|
    t.bigint "condominio_id", null: false
    t.string "nome"
    t.string "categoria"
    t.string "marca"
    t.string "modelo"
    t.string "numero_serie"
    t.string "localizacao"
    t.integer "status"
    t.date "data_instalacao"
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominio_id"], name: "index_equipamentos_on_condominio_id"
  end

  create_table "estoque_locais", force: :cascade do |t|
    t.string "nome", null: false
    t.integer "tipo", default: 0, null: false
    t.string "cidade"
    t.string "bairro"
    t.string "endereco"
    t.text "descricao"
    t.bigint "responsavel_id"
    t.boolean "ativo", default: true, null: false
    t.string "qr_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qr_token"], name: "index_estoque_locais_on_qr_token", unique: true
    t.index ["responsavel_id"], name: "index_estoque_locais_on_responsavel_id"
  end

  create_table "estoque_movimentacoes", force: :cascade do |t|
    t.bigint "produto_id", null: false
    t.bigint "origem_local_id"
    t.bigint "destino_local_id"
    t.bigint "user_id", null: false
    t.integer "tipo", null: false
    t.decimal "quantidade", precision: 12, scale: 3, null: false
    t.decimal "saldo_origem_antes", precision: 12, scale: 3
    t.decimal "saldo_origem_depois", precision: 12, scale: 3
    t.decimal "saldo_destino_antes", precision: 12, scale: 3
    t.decimal "saldo_destino_depois", precision: 12, scale: 3
    t.text "observacao"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_recebimento", default: 0, null: false
    t.bigint "recebido_por_id"
    t.datetime "recebido_em"
    t.text "observacao_recebimento"
    t.datetime "qr_produto_confirmado_em"
    t.string "qr_produto_confirmado_token"
    t.index ["created_at"], name: "index_estoque_movimentacoes_on_created_at"
    t.index ["destino_local_id"], name: "index_estoque_movimentacoes_on_destino_local_id"
    t.index ["origem_local_id"], name: "index_estoque_movimentacoes_on_origem_local_id"
    t.index ["produto_id"], name: "index_estoque_movimentacoes_on_produto_id"
    t.index ["recebido_por_id"], name: "index_estoque_movimentacoes_on_recebido_por_id"
    t.index ["tipo"], name: "index_estoque_movimentacoes_on_tipo"
    t.index ["user_id"], name: "index_estoque_movimentacoes_on_user_id"
  end

  create_table "estoque_produtos", force: :cascade do |t|
    t.string "nome", null: false
    t.string "codigo"
    t.string "categoria"
    t.string "marca"
    t.string "modelo"
    t.string "unidade_medida", default: "unidade", null: false
    t.text "descricao"
    t.decimal "valor_custo", precision: 12, scale: 2
    t.decimal "valor_venda", precision: 12, scale: 2
    t.decimal "estoque_minimo", precision: 12, scale: 3, default: "0.0", null: false
    t.boolean "ativo", default: true, null: false
    t.string "qr_token", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_estoque_produtos_on_codigo"
    t.index ["created_by_id"], name: "index_estoque_produtos_on_created_by_id"
    t.index ["qr_token"], name: "index_estoque_produtos_on_qr_token", unique: true
  end

  create_table "estoque_saldos", force: :cascade do |t|
    t.bigint "produto_id", null: false
    t.bigint "local_id", null: false
    t.decimal "quantidade", precision: 12, scale: 3, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_id"], name: "index_estoque_saldos_on_local_id"
    t.index ["produto_id", "local_id"], name: "index_estoque_saldos_on_produto_id_and_local_id", unique: true
    t.index ["produto_id"], name: "index_estoque_saldos_on_produto_id"
  end

  create_table "historico_tecnicos", force: :cascade do |t|
    t.bigint "condominio_id", null: false
    t.bigint "equipamento_id"
    t.bigint "user_id", null: false
    t.integer "tipo"
    t.string "titulo"
    t.text "descricao"
    t.datetime "data_atendimento"
    t.integer "status"
    t.text "pecas_utilizadas"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominio_id"], name: "index_historico_tecnicos_on_condominio_id"
    t.index ["equipamento_id"], name: "index_historico_tecnicos_on_equipamento_id"
    t.index ["user_id"], name: "index_historico_tecnicos_on_user_id"
  end

  create_table "post_tecnicos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "condominio_id"
    t.string "titulo"
    t.text "conteudo"
    t.boolean "publico"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominio_id"], name: "index_post_tecnicos_on_condominio_id"
    t.index ["user_id"], name: "index_post_tecnicos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "nome"
    t.integer "role"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "checklist_items", "checklists"
  add_foreign_key "checklists", "condominios"
  add_foreign_key "checklists", "users"
  add_foreign_key "comentarios", "post_tecnicos"
  add_foreign_key "comentarios", "users"
  add_foreign_key "curtidas", "post_tecnicos"
  add_foreign_key "curtidas", "users"
  add_foreign_key "equipamentos", "condominios"
  add_foreign_key "estoque_locais", "users", column: "responsavel_id"
  add_foreign_key "estoque_movimentacoes", "estoque_locais", column: "destino_local_id"
  add_foreign_key "estoque_movimentacoes", "estoque_locais", column: "origem_local_id"
  add_foreign_key "estoque_movimentacoes", "estoque_produtos", column: "produto_id"
  add_foreign_key "estoque_movimentacoes", "users"
  add_foreign_key "estoque_movimentacoes", "users", column: "recebido_por_id"
  add_foreign_key "estoque_produtos", "users", column: "created_by_id"
  add_foreign_key "estoque_saldos", "estoque_locais", column: "local_id"
  add_foreign_key "estoque_saldos", "estoque_produtos", column: "produto_id"
  add_foreign_key "historico_tecnicos", "condominios"
  add_foreign_key "historico_tecnicos", "equipamentos"
  add_foreign_key "historico_tecnicos", "users"
  add_foreign_key "post_tecnicos", "condominios"
  add_foreign_key "post_tecnicos", "users"
end
