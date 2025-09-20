class Rbacr::Privilege
  getter act : Rbacr::Act
  getter resource : String
  @id : String?

  def initialize(@act : Rbacr::Act, @resource : String)
  end

  def id : String
    @id ||= generate_id
  end

  def matches?(act : Rbacr::Act, resource) : Bool
    return false unless @act == act

    @resource == Rbacr::Util.normalize_resource(resource)
  end

  def matches?(privilege_id : String | Symbol) : Bool
    case privilege_id
    when String
      id == privilege_id
    when Symbol
      id == privilege_id.to_s
    end
  end

  def to_s(io : IO) : Nil
    io << id.to_s
  end

  def ==(other : Rbacr::Privilege) : Bool
    id == other.id
  end

  private def generate_id : String
    "can_#{@act}_#{@resource}"
  end
end
