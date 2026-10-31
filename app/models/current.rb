# Quem está fazendo a requisição atual. Os modelos usam isto para registrar o autor de cada alteração no histórico.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
