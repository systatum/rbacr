module Rbacr::Definer
  ROLE_MAP = Hash(String, Rbacr::Role).new

  macro included
    extend Rbacr::DSL
    extend Rbacr::Authorizer

    def self.role(
      name : Symbol,
      privileges : Array(Rbacr::Privilege) = [] of Rbacr::Privilege,
      tier : Rbacr::Tier = Rbacr::Tier::WORKER
    ) : Rbacr::Role
      role = Rbacr::Role.new(name: name, tier: tier, privileges: privileges)
      Rbacr::Definer::ROLE_MAP[name.to_s] = role
      role
    end

    def self.role_of(name : String | Symbol) : Rbacr::Role
      key = name.to_s
      Rbacr::Definer::ROLE_MAP[key]? || raise Rbacr::UnknownRoleError.new(key)
    end

    def self.privileges_of(name : String | Symbol) : Array(Rbacr::Privilege)
      role_of(name).privileges
    end

    def self.find_roles_by_tier(tier : Rbacr::Tier) : Array(Rbacr::Role)
      Rbacr::Definer::ROLE_MAP.values.select { |role| role.tier == tier }
    end

    def self.director_roles : Array(Rbacr::Role)
      find_roles_by_tier(Rbacr::Tier::DIRECTOR)
    end

    def self.manager_roles : Array(Rbacr::Role)
      find_roles_by_tier(Rbacr::Tier::MANAGER)
    end

    def self.worker_roles : Array(Rbacr::Role)
      find_roles_by_tier(Rbacr::Tier::WORKER)
    end
  end
end
