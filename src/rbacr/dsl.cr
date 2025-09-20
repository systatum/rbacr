module Rbacr::DSL
  def act(action : Symbol) : Rbacr::Act
    Rbacr::Act.new(action)
  end

  def can(act : Rbacr::Act, resource) : Rbacr::Privilege
    resource_str = Rbacr::Util.normalize_resource(resource)
    Rbacr::Privilege.new(act, resource_str)
  end
end
