module Rbacr::DSL
  def act(action : Symbol) : Rbacr::Act
    Rbacr::Act.new(action)
  end

  def can(act : Rbacr::Act, resource) : Rbacr::Privilege
    resource_str = Rbacr::Util.normalize_resource(resource)
    privilege = Rbacr::Privilege.new(act: act, resource: resource_str)
    privilege_id = privilege.id

    if @@_privileges.includes?(privilege_id)
      raise Rbacr::DuplicatePrivilegeError.new(privilege_id)
    end

    @@_privileges.add(privilege_id)
    privilege
  end
end
