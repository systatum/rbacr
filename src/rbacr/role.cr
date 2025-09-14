class Rbacr::Role
  getter name : Symbol
  getter privileges : Array(Rbacr::Privilege)

  def initialize(@name : Symbol, @privileges : Array(Rbacr::Privilege))
  end

  def has_privilege?(privilege : Rbacr::Privilege) : Bool
    @privileges.includes?(privilege)
  end

  def has_privilege?(privilege_id : String | Symbol) : Bool
    privilege_str = privilege_id.to_s
    @privileges.any? { |p| p.id == privilege_str }
  end

  def has_privilege?(act : Rbacr::Act, object) : Bool
    @privileges.any? { |p| p.matches?(act: act, resource: object) }
  end

  def privilege_ids : Array(String)
    @privileges.map(&.id)
  end

  def to_s(io : IO) : Nil
    io << "Role(#{@name}: #{privilege_ids})"
  end

  def ==(other : Rbacr::Role) : Bool
    @name == other.name
  end
end
