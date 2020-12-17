require_relative 'easy_strategy'
require_relative 'composition_strategy'
require_relative 'injection_strategy'
require_relative 'flag_strategy'
require_relative 'undefinedstrategyformethod'

class Trait < Object
  attr_accessor :metodos, :metodos_conflictivos

  def initialize (metodos)
    @metodos = generar_hash_de_metodos(metodos)
    @metodos_conflictivos = Hash.new
  end

  def +(un_trait)
    #Obtengo los nombres de los metodos de self y un_trait, hago una interseccion para obtener los metodos compartidos
    metodos_conflictivos =  nombres_de_metodos(@metodos) & nombres_de_metodos(un_trait.metodos)
    metodos_a_ser_definidos = nombres_de_metodos(@metodos) + nombres_de_metodos(un_trait.metodos) - metodos_conflictivos
    #Si algun metodo que voy a definir se encuentra en el hash, lo saco de la lista metodos_a_ser_definidos
    # Y lo agrego a la lista metodos_conflictivos
    sacar_metodos_a_definir_si_estan_en_hash_y_agregarlo_a_metodos_conflivitos(metodos_a_ser_definidos,metodos_conflictivos)
    new_Trait = Trait.new([])
    if metodos_conflictivos.size == 0
      define_methods(new_Trait,un_trait,metodos_a_ser_definidos)
      new_Trait
    elsif self === un_trait
      un_trait
    else
      define_methods new_Trait, un_trait,metodos_a_ser_definidos
      agregar_nuevos_metodos_conflictivos_a_hash_de_new_Trait(metodos_conflictivos,new_Trait,un_trait)
      new_Trait
    end
  end

  def -(elementos_a_eliminar)
    if elementos_a_eliminar.class == Array
      new_trait = Trait.new([])
      metodos_a_eliminar = elementos_a_eliminar
      copia_metodos=(@metodos.collect {|elem| elem}).to_h
      copia_metodos_conflictivos=(@metodos_conflictivos.collect {|elem| elem}).to_h
      metodos_a_eliminar.each do |nombre_metodo_a_eliminar|
        if exist_metodo nombre_metodo_a_eliminar
          copia_metodos.delete nombre_metodo_a_eliminar
        elsif exist_metodo_conflictivo nombre_metodo_a_eliminar
          copia_metodos_conflictivos.delete nombre_metodo_a_eliminar
        end
      end
      new_trait.metodos = copia_metodos
      new_trait.metodos_conflictivos = copia_metodos_conflictivos
      new_trait
    else
      self.-([elementos_a_eliminar])
    end
  end

  def <<(hash_de_metodos_a_reemplazar)
    new_trait = Trait.new([])

    copia_metodos = (@metodos.collect {|elem| elem}).to_h
    copia_metodos_conflictivos =(@metodos_conflictivos.collect {|elem| elem}).to_h

    hash_de_metodos_a_reemplazar.each_key do |nombre_de_metodo_a_reemplazar|
      if exist_metodo nombre_de_metodo_a_reemplazar
        metodo_asociado = @metodos[nombre_de_metodo_a_reemplazar]

        copia_metodos.delete nombre_de_metodo_a_reemplazar
        copia_metodos[hash_de_metodos_a_reemplazar[nombre_de_metodo_a_reemplazar]] = metodo_asociado

      elsif exist_metodo_conflictivo nombre_de_metodo_a_reemplazar
        metodos_asociados = @metodos_conflictivos[nombre_de_metodo_a_reemplazar]


        copia_metodos_conflictivos.delete nombre_de_metodo_a_reemplazar
        copia_metodos_conflictivos[hash_de_metodos_a_reemplazar[nombre_de_metodo_a_reemplazar]] = metodos_asociados
      end
    end
    new_trait.metodos = copia_metodos
    new_trait.metodos_conflictivos = copia_metodos_conflictivos
    new_trait
  end

  private

  def generar_hash_de_metodos (metodos)
    hash_resultado = Hash.new
    metodos.each { |metodo_a_agregar| hash_resultado[metodo_a_agregar.name] = metodo_a_agregar  }
    hash_resultado
  end

  def nombres_de_metodos(metodos)
    metodos.keys
  end

  def exist_metodo(un_metodo)
    @metodos.has_key? un_metodo
  end

  def exist_metodo_conflictivo(un_metodo)
    @metodos_conflictivos.has_key? un_metodo
  end

  def define_methods(new_trait,un_trait,metodos_a_definir)
    metodos_a_definir.each do |metodo|
      if exist_metodo(metodo)
        new_trait.metodos[metodo] = buscar_metodo(metodo,@metodos)
      else
        new_trait.metodos[metodo] = buscar_metodo(metodo, un_trait.metodos)
      end
    end
    new_trait.metodos_conflictivos = @metodos_conflictivos
  end

  def buscar_metodo(nombre_metodo, lista_metodos)
    lista_metodos[nombre_metodo]
  end

  def agregar_nuevos_metodos_conflictivos_a_hash_de_new_Trait(metodos_conflictivos,newTrait,un_trait)
    metodos_conflictivos.each do |metodo|
      if newTrait.metodos_conflictivos.has_key?(metodo)
        newTrait.metodos_conflictivos[metodo].append(buscar_metodo(metodo, un_trait.metodos))
      else
        newTrait.metodos_conflictivos[metodo] = [buscar_metodo(metodo, @metodos), buscar_metodo(metodo, un_trait.metodos)]
      end
    end
  end


  def sacar_metodos_a_definir_si_estan_en_hash_y_agregarlo_a_metodos_conflivitos(metodos_a_definir,metodos_conflictivos)
    metodos_a_definir.each do |metodo|
      if @metodos_conflictivos.include?(metodo)
        metodos_a_definir.delete(metodo)
        metodos_conflictivos.append(metodo)
      end
    end
  end



end

def Object.const_missing(const)
  const
end

class Class

  def conflicts (estrategias)
    #un hash donde la key es el metodo y el value es la estrategia definida para
    #ese metodo
    @estrategias = estrategias
  end


  def uses (trait)
    estrategias_definidas = @estrategias
    if (@estrategias == nil && trait.metodos_conflictivos.length > 0 )
      raise UndefinedStrategyForMethod.new
    end


    if (@estrategias != nil && estrategias_definidas.length == 0 && trait.metodos_conflictivos.length > 0 )
      raise UndefinedStrategyForMethod.new
    end

    # Para cada metodo {nombre_metodo => metodo} lo inyecto en la clase
    trait.metodos.each  do |nombre_de_metodo,metodo|
      self.define_method(nombre_de_metodo,metodo)
    end
    #inyecto los metodos conflictivos en la clase
    trait.metodos_conflictivos.each do |nombre_metodo,metodos|
      if !estrategias_definidas.has_key? nombre_metodo
        raise UndefinedStrategyForMethod.new
      end
      estrategia_definida_para_el_metodo = estrategias_definidas[nombre_metodo]
      metodo_resuelto = estrategia_definida_para_el_metodo.resolver_metodos_conflictivos(metodos)
      self.define_method(nombre_metodo,metodo_resuelto)
    end
  end

end

def trait(nombre, &metodos)

  modulo = Module.new
  modulo.module_eval(&metodos)
  metodos = modulo.instance_methods

  # unbound son todos los metodos definidos en el trait... y seran guardados en variable de instancia de Trait
  metodos_sin_objeto_asociado = metodos.map do |metodo|
    modulo.instance_method(metodo)
  end

  instancia = Trait.new(metodos_sin_objeto_asociado)

  Object.const_set(nombre, instancia)

  instancia
end