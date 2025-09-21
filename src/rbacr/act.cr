class Rbacr::Act
  getter action : Symbol

  def initialize(@action : Symbol)
  end

  def act : Symbol
    @action
  end

  def to_s(io : IO) : Nil
    io << @action.to_s
  end

  def ==(other : Rbacr::Act) : Bool
    @action == other.action
  end

  def ==(other : Symbol) : Bool
    @action == other
  end
end
