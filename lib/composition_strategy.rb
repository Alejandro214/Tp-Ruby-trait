

class CompositionStrategy

  def initialize
  end

  def resolver_metodos_conflictivos(metodos_en_conflicto)

    proc do |*args|
      metodos_en_conflicto.each { |metodo| metodo.bind(self).call(*args) }
      []
    end
  end
end
