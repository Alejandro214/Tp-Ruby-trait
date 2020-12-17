class UndefinedStrategyForMethod < StandardError
    def initialize(msg="no se definio una estrategia para los metodos conflictivos")
        super
    end
end   