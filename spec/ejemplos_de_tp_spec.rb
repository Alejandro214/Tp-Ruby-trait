require_relative '../lib/trait'

describe 'Ejemplos de TP Suite' do

  around do |test|
    constantes_ya_definidas = Object.constants

    test.run

    constantes_definidas_por_el_test = Object.constants - constantes_ya_definidas
    constantes_definidas_por_el_test.each do |nombre_constante|
      Object.send(:remove_const, nombre_constante)
    end
  end

  it 'Ejemplo de primer requerimiento' do

    trait Atacante do
      def ataque
        10
      end
    end
    class Fantasma
      uses Atacante
      def nombre(sufijo)
        "Casper" + sufijo
      end
    end

    fantasma = Fantasma.new

    expect(fantasma.ataque).to eq 10
    expect(fantasma.nombre('!')).to eq "Casper!"
  end

  it 'Ejemplo de primer conflicto en el uso de traits' do

    trait Atacante do
      def ataque
        10
      end
    end
    class Fantasma
      uses Atacante

        def ataque
        20
      end
    end

    fantasma = Fantasma.new

    expect(fantasma.ataque).to eq 20
  end

  it 'Ejemplo de composicion de traits' do

    trait Atacante do
      def ataque
        10
      end
    end
    trait Defensor do
      def defensa
        10
      end
    end
    class Guerrero
      uses Atacante + Defensor
    end

    guerrero = Guerrero.new

    expect(guerrero.ataque).to eq 10
    expect(guerrero.defensa).to eq 10
  end

  it "Primer ejemplo de conflicto en composicion de traits " do

    trait Atacante do
      def recuperarse
        "recuperarse como Atacante"
      end
    end

    trait Defensor do
      def recuperarse
        "recuperarse como Defensor"
      end
    end

    expect {
      class Guerrero
        uses Atacante + Defensor
      end

    }.to raise_error(UndefinedStrategyForMethod)

  end

  it "Primer ejemplo de alias method en traits " do

    trait Atacante do
      def recuperarse
        "recuperarse como Atacante"
      end
      def ataque
        10
      end
    end

    trait Defensor do
      def recuperarse
        "recuperarse como Defensor"
      end
    end

    class Guerrero
      uses (Atacante << {recuperarse: :recuperarse_como_atacante}) + (Defensor << {recuperarse: :recuperarse_como_defensor})

      def recuperarse
        recuperarse_como_atacante + " y " + recuperarse_como_defensor
      end
    end

    guerrero = Guerrero.new

    expect(guerrero.recuperarse).to eq "recuperarse como Atacante y recuperarse como Defensor"

  end
end