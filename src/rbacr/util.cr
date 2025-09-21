module Rbacr::Util
  extend self

  def normalize_class_name(class_ref : Class) : String
    name = class_ref.name
    name.gsub("::", "_").downcase
  end

  def normalize_resource(resource : String | Symbol | Class | _) : String
    case resource
    when String
      resource
    when Symbol
      resource.to_s
    when Class
      normalize_class_name(resource)
    else
      normalize_class_name(resource.class)
    end
  end

  def normalize_roles(roles : String | Array(String)) : Array(String)
    case roles
    when String
      [roles]
    when Array(String)
      roles
    else
      raise ArgumentError.new("Roles must be String or Array(String)")
    end
  end
end
