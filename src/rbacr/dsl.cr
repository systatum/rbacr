module Rbacr::DSL
  def act(action : Symbol) : Rbacr::Act
    Rbacr::Act.new(action: action)
  end

  def can(act : Rbacr::Act, resource) : Rbacr::Privilege
    resource_str = Rbacr::Util.normalize_resource(resource: resource)
    Rbacr::Privilege.new(act: act, resource: resource_str)
  end
end
