class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Busca por texto, sem diferenciar maiúsculas. O SQLite não tem caractere de escape padrão no LIKE:
  # sem o `ESCAPE '\'`, um "%" ou "_" digitado pela pessoa viraria curinga (ou nunca casaria).
  def self.matching(colunas, termo)
    padrao = "%#{sanitize_sql_like(termo.to_s.strip)}%"
    where(Array(colunas).map { |c| "#{c} LIKE :p ESCAPE '\\'" }.join(" OR "), p: padrao)
  end
end
