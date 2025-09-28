module Rbacr::Definer
  macro included
    extend Rbacr::DSL
    extend Rbacr::Authorizer

    ROLE_MAP = Hash(String, Rbacr::Role).new
    @@_privileges : Set(String) = Set(String).new

    def self.role_map
      ROLE_MAP
    end

    def self.role(
      name : Symbol,
      privileges : Array(Rbacr::Privilege) = [] of Rbacr::Privilege,
      tier : Rbacr::Tier = Rbacr::Tier::WORKER,
    ) : Rbacr::Role
      role = Rbacr::Role.new(name, privileges, tier)
      ROLE_MAP[name.to_s] = role
      role
    end

    def self.role_of(name : String | Symbol) : Rbacr::Role
      get_role!(name)
    end

    def self.privileges_of(name : String | Symbol) : Array(Rbacr::Privilege)
      role_of(name).privileges
    end

    macro finished
      evaluate_constants
    end
  end

  macro evaluate_constants
    {% for constant in @type.constants %}
      {{ constant.id }}
    {% end %}
  end
end
