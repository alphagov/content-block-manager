desc "Backfill embed codes"
task backfill_embed_codes: :environment do |_t, _args|
  Document.where(embed_code: nil).find_each do |document|
    document.update_column(:embed_code, document.built_embed_code)
  rescue StandardError => e
    GovukError.notify(
      e,
      level: :error,
      extras: {
        document_id: document.id,
        content_id_alias: document.content_id_alias,
        built_embed_code: document.built_embed_code,
      },
    )
  end
end
