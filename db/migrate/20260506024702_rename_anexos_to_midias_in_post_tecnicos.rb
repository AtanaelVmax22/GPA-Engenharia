class RenameAnexosToMidiasInPostTecnicos < ActiveRecord::Migration[8.0]
  def change
    # Active Storage usa a tabela active_storage_attachments com record_type e name
    # Renomeia fotos -> midias nos registros existentes
    ActiveStorage::Attachment.where(record_type: "PostTecnico", name: "fotos")
                             .update_all(name: "midias")
  end
end
