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
      role = Rbacr::Role.new(name: name, tier: tier, privileges: privileges)
      Rbacr::Definer::ROLE_MAP[name.to_s] = role
      role
    end

    def self.role_of(name : String | Symbol) : Rbacr::Role
      auto_register_role_constants
      key = name.to_s
      Rbacr::Definer::ROLE_MAP[key]? || raise Rbacr::UnknownRoleError.new(key)
    end

    def self.privileges_of(name : String | Symbol) : Array(Rbacr::Privilege)
      role_of(name).privileges
    end
  end

  macro auto_register_role_constants
    {% for constant in @type.constants %}
      {% if constant.stringify.ends_with?("_ROLE") %}
        {{ constant.id }}
      {% end %}
    {% end %}
  end
end
