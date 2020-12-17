class Flag_strategy
   def initialize(funcion)
      @solucion=funcion
   end 
   
   def resolver_metodos_conflictivos(metodos_en_conflicto)
      mi_solucion = @solucion
      proc do |*args|
          metodos_en_conflicto.each do |metodo|
              resultado = metodo.bind(self).call(*args)
              if mi_solucion.call(resultado)
                return resultado
              end
          end
      end
   end
end
