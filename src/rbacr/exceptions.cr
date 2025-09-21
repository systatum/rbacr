class Rbacr::Error < Exception
end

class Rbacr::UnknownRoleError < Rbacr::Error
  def initialize(role_name : String | Symbol)
    super("Unknown role: #{role_name}")
  end
end

class Rbacr::UnknownPrivilegeError < Rbacr::Error
  def initialize(privilege_id : String | Symbol)
    super("Unknown privilege: #{privilege_id}")
  end
end

class Rbacr::AuthorizationError < Rbacr::Error
  def initialize(message : String = "Access denied")
    super(message)
  end
end

class Rbacr::DuplicatePrivilegeError < Rbacr::Error
  def initialize(privilege_id : String)
    super("Duplicate privilege definition: #{privilege_id}")
  end
end
