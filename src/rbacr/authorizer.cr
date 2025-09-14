module Rbacr::Authorizer
  def require_privilege!(roles : String | Array(String), act : Rbacr::Act, resource)
    unless privilege_exists?(act, resource)
      resource_str = Rbacr::Util.normalize_resource(resource)
      raise Rbacr::UnknownPrivilegeError.new("#{act.action} on #{resource_str}")
    end

    unless can?(roles, act, resource)
      resource_str = Rbacr::Util.normalize_resource(resource)
      raise Rbacr::AuthorizationError.new("Access denied for #{act.action} on #{resource_str}")
    end
  end

  def require_privilege!(roles : String | Array(String), privilege_id : String | Symbol)
    unless privilege_exists?(privilege_id)
      raise Rbacr::UnknownPrivilegeError.new(privilege_id.to_s)
    end

    unless can?(roles, privilege_id)
      raise Rbacr::AuthorizationError.new("Access denied for privilege #{privilege_id}")
    end
  end

  def require_privilege!(roles : String | Array(String), privilege : Rbacr::Privilege)
    unless privilege_exists?(privilege)
      raise Rbacr::UnknownPrivilegeError.new(privilege.id)
    end

    unless can?(roles, privilege)
      raise Rbacr::AuthorizationError.new("Access denied for privilege #{privilege.id}")
    end
  end

  def require_role!(roles : String | Array(String), required_role : String | Symbol | Rbacr::Role)
    role_list = Rbacr::Util.normalize_roles(roles)
    required_role_name = case required_role
                         when String, Symbol
                           required_role.to_s
                         when Rbacr::Role
                           required_role.name.to_s
                         else
                           raise ArgumentError.new("Invalid role type")
                         end

    unless role_list.includes?(required_role_name)
      raise Rbacr::AuthorizationError.new("Role #{required_role_name} is required")
    end
  end

  private def get_role(role_name : String | Symbol) : Rbacr::Role
    role_str = role_name.to_s
    Rbacr::Definer::ROLE_MAP[role_str]? || raise Rbacr::UnknownRoleError.new(role_str)
  end

  def can?(roles : String | Array(String), act : Rbacr::Act, resource) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)

    role_list.any? do |role_name|
      role = Rbacr::Definer::ROLE_MAP[role_name.to_s]?
      role ? role.has_privilege?(act, resource) : false
    end
  end

  def can?(roles : String | Array(String), privilege_id : String | Symbol) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)
    privilege_str = privilege_id.to_s
    role_list.any? do |role_name|
      role = Rbacr::Definer::ROLE_MAP[role_name.to_s]?
      role ? role.has_privilege?(privilege_str) : false
    end
  end

  def can?(roles : String | Array(String), privilege : Rbacr::Privilege) : Bool
    role_list = Rbacr::Util.normalize_roles(roles)

    role_list.any? do |role_name|
      role = Rbacr::Definer::ROLE_MAP[role_name.to_s]?
      role ? role.has_privilege?(privilege) : false
    end
  end

  private def privilege_exists?(act : Rbacr::Act, resource) : Bool
    Rbacr::Definer::ROLE_MAP.values.any? do |role|
      role.privileges.any? { |p| p.matches?(act, resource) }
    end
  end

  private def privilege_exists?(privilege_id : String | Symbol) : Bool
    privilege_str = privilege_id.to_s
    Rbacr::Definer::ROLE_MAP.values.any? do |role|
      role.privileges.any? { |p| p.id == privilege_str }
    end
  end

  private def privilege_exists?(privilege : Rbacr::Privilege) : Bool
    Rbacr::Definer::ROLE_MAP.values.any? do |role|
      role.privileges.includes?(privilege)
    end
  end
end
