#una estrategia que recibi un string first para tomar el primer metodo sino por
#default toma el ultimo metodo
class EasyStrategy

    def initialize(metodo_a_tomar="last")
       @metodo_a_tomar=metodo_a_tomar
    end

    def resolver_metodos_conflictivos(metodos_en_conflicto)
         if (@metodo_a_tomar == "first")
            metodos_en_conflicto.first
         else
            metodos_en_conflicto.last
         end 
    end

end     