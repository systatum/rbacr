module Rbacr::Authorizer
  def require_privilege!(act : Rbacr::Act, resource, roles : String | Array(String))
    unless privilege_exists?(act, resource)
      resource_str = Rbacr::Util.normalize_resource(resource)
      raise Rbacr::UnknownPrivilegeError.new("#{act.action} on #{resource_str}")
    end

    unless can?(act, resource, roles)
      resource_str = Rbacr::Util.normalize_resource(resource)
      privilege_id = "#{act.action}_#{resource_str}"
      raise Rbacr::AuthorizationError.new("The privilege `#{privilege_id}` is required")
    end
  end

  def require_privilege!(privilege_id : String | Symbol, roles : String | Array(String))
    unless privilege_exists?(privilege_id)
      raise Rbacr::UnknownPrivilegeError.new(privilege_id.to_s)
    end

    unless can?(privilege_id, roles)
      raise Rbacr::AuthorizationError.new("The privilege `#{privilege_id}` is required")
    end
  end

  def require_privilege!(privilege : Rbacr::Privilege, roles : String | Array(String))
    unless privilege_exists?(privilege)
      raise Rbacr::UnknownPrivilegeError.new(privilege.id)
    end

    unless can?(privilege, roles)
      raise Rbacr::AuthorizationError.new("The privilege `#{privilege.id}` is required")
    end
  end

  def require_role!(required_role : String | Symbol | Rbacr::Role, roles : String | Array(String))
    role_list = Rbacr::Util.normalize_roles(roles)
    required_role_name =
      case required_role
      when String, Symbol
        required_role.to_s
      when Rbacr::Role
        required_role.name.to_s
      else
        raise ArgumentError.new("Invalid role type")
      end

    unless role_list.includes?(required_role_name)
      raise Rbacr::AuthorizationError.new("The role `#{required_role_name}` is required")
    end
  end

  private def get_role(role_name : String | Symbol) : Rbacr::Role | Nil
    role_str = role_name.to_s
    role_map.fetch(role_str, nil)
  end

  private def get_role!(role_name : String | Symbol) : Rbacr::Role
    role = get_role(role_name)
    raise Rbacr::UnknownRoleError.new(role_name) unless role
    role
  end

  def can?(act : Rbacr::Act, resource, roles : String | Array(String)) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)

    role_list.any? do |role_name|
      role = get_role(role_name)
      role ? role.has_privilege?(act, resource) : false
    end
  end

  def can?(privilege_id : String | Symbol, roles : String | Array(String)) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)
    privilege_str = privilege_id.to_s
    role_list.any? do |role_name|
      role = get_role(role_name)
      role ? role.has_privilege?(privilege_str) : false
    end
  end

  def can?(privilege : Rbacr::Privilege, roles : String | Array(String)) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)

    role_list.any? do |role_name|
      role = get_role(role_name)
      role ? role.has_privilege?(privilege) : false
    end
  end

  private def privilege_exists?(act : Rbacr::Act, resource) : Bool
    role_map.values.any? do |role|
      role.privileges.any? { |p| p.matches?(act, resource) }
    end
  end

  private def privilege_exists?(privilege_id : String | Symbol) : Bool
    privilege_str = privilege_id.to_s
    role_map.values.any? do |role|
      role.privileges.any? { |p| p.id == privilege_str }
    end
  end

  private def privilege_exists?(privilege : Rbacr::Privilege) : Bool
    role_map.values.any? do |role|
      role.privileges.includes?(privilege)
    end
  end

  def find_roles_by_tier(tier : Rbacr::Tier) : Array(Rbacr::Role)
    role_map.values.select { |role| role.tier == tier }
  end

  def director_roles : Array(Rbacr::Role)
    find_roles_by_tier(Rbacr::Tier::DIRECTOR)
  end

  def manager_roles : Array(Rbacr::Role)
    find_roles_by_tier(Rbacr::Tier::MANAGER)
  end

  def worker_roles : Array(Rbacr::Role)
    find_roles_by_tier(Rbacr::Tier::WORKER)
  end
end
