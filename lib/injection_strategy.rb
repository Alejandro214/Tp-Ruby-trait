class InjectionStrategy

  def initialize(funcion_sobre_resultados)
    @solucion = funcion_sobre_resultados
  end

  def resolver_metodos_conflictivos(metodos_en_conflicto)
    mi_solucion = @solucion
    proc do |*args|
      resultados_de_metodos = metodos_en_conflicto.map { |metodo| metodo.bind(self).call(*args) }
      mi_solucion.call resultados_de_metodos
    end
  end
end
