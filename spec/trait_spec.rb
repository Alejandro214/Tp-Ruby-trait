require_relative '../lib/trait'

trait GlobalTrait do
  def metodo_principal (valor)
    valor
  end
end

describe 'prueba trait 2' do

  around do |test|
    constantes_ya_definidas = Object.constants

    test.run

    constantes_definidas_por_el_test = Object.constants - constantes_ya_definidas
    constantes_definidas_por_el_test.each do |nombre_constante|
      Object.send(:remove_const, nombre_constante)
    end
  end

  it "should " do

    trait MiTrait do
      def m1
        10
      end



      def m2 (valor)
        valor
      end

      def m3
        self
      end
    end

    class Clase1
      uses MiTrait
    end

    instancia = Clase1.new

    expect {
      Clase1.m1
    }.to raise_error NoMethodError

    expect {
      Clase1.m2("kajskdjasd")
    }.to raise_error NoMethodError

    expect {
      Clase1.m3
    }.to raise_error NoMethodError

    expect(instancia.m1).to eq 10
    expect(instancia.m2("texto")).to eq "texto"
    expect(instancia.m2(3123)).to eq 3123
    expect(instancia.m2(:simbolo)).to eq :simbolo
    expect(instancia.m3).to eq instancia
  end

  it 'Puedo combinar traits' do
    trait Trait1 do
      def metodo_1(valor)
        valor
      end
    end

    trait Trait2 do
      def metodo_2
        "metodo_2"
      end
    end
    class MiClase
      uses Trait1 + Trait2
    end

    instancia_MiClase = MiClase.new
    expect(instancia_MiClase.metodo_1(10)).to eq 10
    expect(instancia_MiClase.metodo_2).to eq "metodo_2"
  end

  it 'Puedo renombrar un metodo en un trait utilizando <<' do

    trait MiTrait do
      def metodo_principal(valor)
        valor
      end
    end

    class MiClase
      uses MiTrait<<{:metodo_principal => :nuevo_nombre}
    end

    instancia = MiClase.new

    expect(instancia.nuevo_nombre 3) .to eq(3)
  end

  it 'Puedo eliminar metodos de un trait que no quiera utilizar utilizando -' do

    trait MiTrait do
      def metodo_principal(valor)
        valor
      end
      def metodo_sin_uso
        "no tengo uso"
      end
    end

    class MiClase
      uses MiTrait - [:metodo_sin_uso]
    end

    instancia = MiClase.new

    expect(instancia.metodo_principal 3) .to eq(3)
    expect {
      instancia.metodo_sin_uso
    }.to raise_error NoMethodError
  end

  it 'Elimino varios metodos del trait' do
    trait MiTrait do
      def metodo_principal(valor)
        valor
      end
      def metodo_sin_uso
        "no tengo uso"
      end
    end

    class MiClase
      uses MiTrait - [:metodo_sin_uso,:metodo_principal]
    end

    instancia = MiClase.new

    expect {
      instancia.metodo_principal 3
    }.to raise_error(NoMethodError)
    expect {
      instancia.metodo_sin_uso
    }.to raise_error(NoMethodError)
  end
  it 'Elimino varios metodos del trait con anidacion de restas' do
    trait TraitConDosMetodos do
      def metodo1
        "metodo 1"
      end
      def metodo2
        "metodo 2"
      end
    end

    class ClaseConDosMetodos
      uses TraitConDosMetodos - :metodo1 - :metodo2

      def metodo3
        "metodo 3"
      end
    end
    instancia_sin_metodos = ClaseConDosMetodos.new
    expect{
      instancia_sin_metodos.metodo1
    }.to raise_error(NoMethodError)
    expect{
      instancia_sin_metodos.metodo2
    }.to raise_error(NoMethodError)

  end

  it 'Al eliminar un metodo que no existe en un trait no pasa nada'do
    trait TraitConDosMetodos do
      def metodo1
        "metodo 1"
      end
      def metodo2
        "metodo 2"
      end
    end
    class ClaseConDosMetodos
      uses TraitConDosMetodos - :metodo3
    end

    instancia_con_metodos=ClaseConDosMetodos.new
    expect(instancia_con_metodos.methods).to include(:metodo1)
    expect(instancia_con_metodos.methods).to include(:metodo2)
  end


  it 'elimino metodos de una combinacion de traits con metodos conflictivos'do
    trait Trait1 do
      def metodo_1
        "metodo_1"
      end
      def metodo_2
        "metodo_2"
      end
      def saludar
        "Hola"
      end
    end

    trait Trait2 do
      def metodo_1
        "metodo_1"
      end
      def metodo_2
        "metodo_2"
      end

      def decir_Adios
        "Adios"
      end
    end

    class MiClase
      uses Trait1 + Trait2 - [:metodo_1, :metodo_2]
    end

    instancia_MiClase = MiClase.new
    expect(instancia_MiClase.saludar).to eq "Hola"
    expect(instancia_MiClase.decir_Adios).to eq "Adios"
    expect {
      instancia_MiClase.metodo1
    }.to raise_error(NoMethodError)
    expect {
      instancia_MiClase.metodo2
    }.to raise_error(NoMethodError)
  end

  it "Combinacion de dos traits conflictivos pero son el mismo" do
    trait Nuevo_Trait do
      def metodo_1
        "metodo_1"
      end
    end

    class NuevaClase
      uses Nuevo_Trait + Nuevo_Trait
    end
    instancia_nueva = NuevaClase.new
    expect(instancia_nueva.metodo_1).to eq('metodo_1')

  end

  it 'Puedo renombrar un metodo conflictivo en combinacion de traits conflictivos'do
    trait MiTrait do
      def valor
        10
      end
    end

    trait Trait2 do
      def valor
        20
      end
    end
    class MiClase
      conflicts({metodo_1:EasyStrategy.new("first")})
      uses MiTrait + Trait2 << {:valor => :metodo_1}
    end

    instancia_MiClase = MiClase.new
    expect(instancia_MiClase.metodo_1).to eq 10
  end




  it 'Puedo renombrar un metodo no conflictivo en suma de traits conflictivos' do

    trait Trait1 do
      def nombre_metodo
        "metodo1"
      end
      def metodo_trait_1
        10
      end
      def metodo_sin_renombre_ni_conflicto
        "sin problemas"
      end
    end

    trait Trait2 do
      def nombre_metodo
        "metodo2"
      end
      def metodo_trait_2
        20
      end
    end

    class NuevaClase
      conflicts({nombre_metodo:EasyStrategy.new("first")})

      uses Trait1 + Trait2 << {:metodo_trait_1 => :nuevo_nombre1, :metodo_trait_2 => :nuevo_nombre2}

    end

    instancia = NuevaClase.new

    expect(instancia.nombre_metodo).to start_with("metodo")
    expect(instancia.nuevo_nombre1).to eq 10
    expect(instancia.nuevo_nombre2).to eq 20
    expect(instancia.metodo_sin_renombre_ni_conflicto).to eq "sin problemas"
  end

  it 'una clase usa todos los metodos definidos en el trait y la otra clase usa solo algunos' do 
    trait TraitCon3Metodos do
       def metodo1(valor)
         valor
       end   
       def metodo2
        "metodo 2"
      end   
      def metodo3
        "metodo 3"
      end   
    end
    class ClaseUsa1MetodoDelTrait 
      uses TraitCon3Metodos - [:metodo1,:metodo2]
    end  
    class ClaseUsaTodosLosMetodosDelTrait 
      uses TraitCon3Metodos
    end 
    instancia_con_un_metodo = ClaseUsa1MetodoDelTrait.new
    expect {
     instancia_con_un_metodo.metodo1
    }.to raise_error(NoMethodError)  
    expect {
     instancia_con_un_metodo.metodo2
    }.to raise_error(NoMethodError) 
    expect("metodo 3").to eq(instancia_con_un_metodo.metodo3)

    instancia_con_3_metodos=ClaseUsaTodosLosMetodosDelTrait.new
    expect(10).to eq(instancia_con_3_metodos.metodo1(10))
    expect("metodo 2").to eq(instancia_con_3_metodos.metodo2)
    expect("metodo 3").to eq(instancia_con_3_metodos.metodo3)

  end  
  it 'Puedo renombrar un metodo varias veces utilizando << continuos' do

    class NuevaClase
      uses GlobalTrait << {:metodo_principal => :nuevo_nombre} << {:nuevo_nombre => :otro_nombre}
    end

    instancia = NuevaClase.new
    texto = "Acabo de cambiar mi nombre"

    expect(instancia.otro_nombre texto).to eq(texto)
  end

  it 'Resolver un conflicto utilizando una estrategia simple, elijo alguna de las implmentaciones' do

    trait Atacante do
      def atacar
        puts "estoy atacando"
        poder_de_ataque * 0.7
      end
      def poder_de_ataque
        10
      end
      def nombre
        "soy atacante"
      end
      def metodo(valor)
        valor + 10
      end
    end

    trait Defensor do
      def defender
        puts "estoy defendiendo"
        poder_de_defensa * 0.5
      end
      def poder_de_defensa
        8
      end
      def nombre
        "soy defensor"
      end
      def metodo(valor)
        valor + 20
      end
    end
    class Guerrero
      conflicts({nombre:EasyStrategy.new("first"),metodo:EasyStrategy.new("first")})
      uses Atacante + Defensor

    end

    gengis = Guerrero.new

    expect(gengis.poder_de_ataque).to eq 10
    expect(gengis.poder_de_defensa).to eq 8
    expect(gengis.nombre).to eq "soy atacante"
    expect(gengis.metodo 15).to eq 25
  end

  it 'No defino ninguna estrategia para metodos conflictivos asi que lanzo una excepcion'do
    trait Trait1 do
      def metodo1
        "soy el metodo1"
      end

    end

    trait Trait2 do
      def metodo1
        "soy el metodo1"
      end
    end
    expect{
      class MiClase
        uses Trait1 + Trait2
      end
    }.to raise_error(UndefinedStrategyForMethod)
  end

  it 'No defino en las estrategias la resolucion de uno de los metodos conflictivos asi que lanza
  una exception' do 
    trait Atacante do
      def atacar
        puts "estoy atacando"
        poder_de_ataque * 0.7
      end
      def poder_de_ataque
        10
      end
      def nombre
        "soy atacante"
      end
      def metodo(valor)
        valor + 10
      end
    end

    trait Defensor do
      def defender
        puts "estoy defendiendo"
        poder_de_defensa * 0.5
      end
      def poder_de_defensa
        8
      end
      def nombre
        "soy defensor"
      end
      def metodo(valor)
        valor + 20
      end
    end
    expect {
      class Guerrero
        conflicts({metodo:EasyStrategy.new("first")})
        
        uses Atacante + Defensor
  
      end
  
    }.to raise_error(UndefinedStrategyForMethod)
  end

  it 'Puedo resolver conflictos utilizando function de condicion para la resolucion de los metodos' do
        trait Trait1 do
          def metodo_conflictivo
            -2
          end
        end
    
        trait Trait2 do
          def metodo_conflictivo
            20
          end
        end
    
        class UnaClase
          conflicts({metodo_conflictivo:Flag_strategy.new(
          proc do |valor|
            valor > 0
          end)})

          uses Trait1 + Trait2
        end
    
        instancia = UnaClase.new
    
        expect(instancia.metodo_conflictivo).to eq 20
  end

  it 'Puedo resolver conflictos utilizando una composicion de los metodos' do
    trait DefensaMagica do
      def aplicar_defensa (valor_de_defensa)
        @defensa += valor_de_defensa + 10
      end
    end

    trait DefensaFisica do
      def aplicar_defensa (valor_de_defensa)
        @defensa += valor_de_defensa + 5
      end
    end

    class GuerreroMagico < Object

      attr_accessor :defensa

      def initialize
        @defensa = 100
      end

      conflicts(aplicar_defensa: CompositionStrategy.new)

      uses DefensaMagica + DefensaFisica
    end

    mi_guerrero = GuerreroMagico.new
    mi_guerrero.aplicar_defensa 50

    expect(mi_guerrero.defensa).to eq 215
  end

  it 'Puedo resolver conflictos utilizando una estrategia de inyeccion sobre los resultados de cada metodo' do
    trait PuntaIncendiada do
      def calidad
        11
      end

      def nombre_arcano
        "Flaming"
      end
    end

    trait EmpuniaduraDemoniaca do
      def calidad
        6
      end

      def nombre_arcano
        "Demonic"
      end
    end

    class EspadaDelDiablo

      conflicts( {
         calidad: InjectionStrategy.new(proc { |calidades| calidades.reduce(:+) }),
         nombre_arcano: InjectionStrategy.new(proc do |nombres|
           nombres.reduce { |inicial, actual| inicial + " " + actual } + " Sword"
         end)
      })

      uses PuntaIncendiada + EmpuniaduraDemoniaca
    end

    espada_mejorada = EspadaDelDiablo.new

    expect(espada_mejorada.calidad).to eq 17
    expect(espada_mejorada.nombre_arcano).to end_with " Sword"
    expect(espada_mejorada.nombre_arcano).to eq "Flaming Demonic Sword"
  end

  it 'resto el metodo conflictivo de una suma de trait y despues sumo otro trait
  que tiene el mismo metodo pero ahora ya no hay conflictos y como resultado se
  inyecta el metodo en la clase' do
    trait Trait1 do
      def valor
        50
      end
    end

    trait Trait2 do
      def valor
        20
      end
    end
    trait Trait3 do
      def valor
        100
      end
    end

    class MetodoSinConflictoInyectado
      conflicts({nombre:EasyStrategy.new("first")})
      uses Trait1 + Trait2 - :valor + Trait3
    end

    instancia_con_metodo= MetodoSinConflictoInyectado.new
    expect(instancia_con_metodo.valor).to eq(100)
  end


end