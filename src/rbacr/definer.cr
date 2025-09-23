module Rbacr::Definer
  ROLE_MAP = Hash(String, Rbacr::Role).new

  macro included
    extend Rbacr::DSL
    extend Rbacr::Authorizer

    def self.role(name : Symbol, privileges : Array(Rbacr::Privilege)) : Rbacr::Role
      role = Rbacr::Role.new(name, privileges)
      Rbacr::Definer::ROLE_MAP[name.to_s] = role
      role
    end

    def self.role_of(name : String | Symbol) : Rbacr::Role
      get_role!(name)
    end

    def self.privileges_of(name : String | Symbol) : Array(Rbacr::Privilege)
      role_of(name).privileges
    end
  end
end
