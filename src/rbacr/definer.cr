module Rbacr::Definer
  ROLE_MAP = Hash(String, Rbacr::Role).new
  @@_privileges : Set(String) = Set(String).new

  macro included
    extend Rbacr::DSL
    extend Rbacr::Authorizer

    def self.role(
      name : Symbol,
      privileges : Array(Rbacr::Privilege) = [] of Rbacr::Privilege,
      tier : Rbacr::Tier = Rbacr::Tier::WORKER,
    ) : Rbacr::Role
      key = name.to_s
      Rbacr::Definer::ROLE_MAP.fetch(key) do
        role = Rbacr::Role.new(name, privileges, tier)
        Rbacr::Definer::ROLE_MAP[key] = role
        role
      end
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
