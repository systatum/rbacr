class Rbacr::Role
  getter name : Symbol
  getter privileges : Array(Rbacr::Privilege)
  getter tier : Rbacr::Tier

  def initialize(
    @name : Symbol,
    @privileges : Array(Rbacr::Privilege) = [] of Rbacr::Privilege,
    @tier : Rbacr::Tier = Rbacr::Tier::WORKER,
  )
  end

  def has_privilege?(privilege : Rbacr::Privilege) : Bool
    @privileges.includes?(privilege)
  end

  def has_privilege?(privilege_id : String | Symbol) : Bool
    privilege_str = privilege_id.to_s
    @privileges.any? { |p| p.id == privilege_str }
  end

  def has_privilege?(act : Rbacr::Act, resource) : Bool
    @privileges.any? { |p| p.matches?(act, resource) }
  end

  def privilege_ids : Array(String)
    @privileges.map(&.id)
  end

  def director? : Bool
    @tier.director?
  end

  def manager? : Bool
    @tier.manager?
  end

  def worker? : Bool
    @tier.worker?
  end

  def managerial? : Bool
    @tier.managerial?
  end

  def to_s(io : IO) : Nil
    io << "Role(#{@name}[#{@tier}]: #{privilege_ids})"
  end

  def ==(other : Rbacr::Role) : Bool
    @name == other.name
  end
end
