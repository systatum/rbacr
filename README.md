# rbacr

[![CI](https://github.com/systatum/rbacr/actions/workflows/ci.yml/badge.svg)](https://github.com/systatum/rbacr/actions/workflows/ci.yml)

`rbacr` is a Crystal library for Role-Based Access Control (RBAC) system. It provides a clean, type-safe DSL for defining roles, privileges, and authorization logic in your Crystal applications.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     rbacr:
       github: systatum/rbacr
   ```

2. Run `shards install`

## Quick Start

```crystal
require "rbacr"

class Candidate
end

class Billing
end

module AI
  class ChatGPT
  end
end

class Authorizer
  include Rbacr::Definer

  # Define actions
  CREATE = act(:create)
  READ = act(:read)
  DELETE = act(:delete)
  CHAT = act(:chat)
  BROWSE = act(:browse)

  # Define privileges
  CAN_CREATE_CANDIDATE = can(CREATE, Candidate)
  CAN_DELETE_CANDIDATE = can(DELETE, Candidate)
  CAN_CREATE_BILLING = can(CREATE, Billing)
  CAN_CHAT_CHATGPT = can(CHAT, AI::ChatGPT)
  CAN_BROWSE_PICTURES = can(BROWSE, :pictures)

  # Define roles with privileges and tiers
  SUPER_ADMIN_ROLE = role(
    :super_admin,
    [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE, CAN_CREATE_BILLING],
    Rbacr::Tier::DIRECTOR
  )
  ENGINEER_ROLE = role(:engineer, [CAN_CREATE_CANDIDATE])
  HR_ROLE = role(
    :hr,
    [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE],
    Rbacr::Tier::MANAGER
  )
  FINANCE_ROLE = role(:finance, [CAN_CREATE_BILLING], Rbacr::Tier::MANAGER)
end
```

## Core Concepts

### Actions
Actions represent what can be performed in your system:

```crystal
CREATE = act(:create)    # Returns Rbacr::Act
READ = act(:read)
DELETE = act(:delete)
```

### Privileges
Privileges combine an action with a resource:

```crystal
# Privilege with class resource
CAN_CREATE_CANDIDATE = can(CREATE, Candidate)
# Privilege#id -> "can_create_candidate" (auto-generated)

# Privilege with symbol resource  
CAN_BROWSE_PICTURES = can(BROWSE, :pictures)
# Privilege#id -> "can_browse_pictures"

# Privilege with namespaced class
CAN_CHAT_CHATGPT = can(CHAT, AI::ChatGPT)
# Privilege#id -> "can_chat_ai_chatgpt"
```

### Roles & Tiers
Roles group privileges and can be assigned tiers for hierarchical organization:

```crystal
# Basic role (defaults to WORKER tier)
ENGINEER_ROLE = role(:engineer, [CAN_CREATE_CANDIDATE])

# Role with explicit tier
SUPER_ADMIN_ROLE = role(
  :super_admin,
  [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE, CAN_CREATE_BILLING],
  Rbacr::Tier::DIRECTOR
)
```

Available tiers (in order of authority):
- `Rbacr::Tier::DIRECTOR` (highest)
- `Rbacr::Tier::MANAGER` 
- `Rbacr::Tier::WORKER` (default)

## Usage Examples

### Retrieving Privileges

```crystal
# Get privileges for a role (returns Array(Rbacr::Privilege))
Authorizer.privileges_of(:super_admin)  # Works with symbols
Authorizer.privileges_of("super_admin") # Works with strings

# Raises Rbacr::UnknownRoleError if role doesn't exist
Authorizer.privileges_of(:undefined_role) # Raises error
```

### Finding Roles

```crystal
# Get role instance
super_admin = Authorizer.role_of(:super_admin)  # Returns Rbacr::Role
engineer = Authorizer.role_of("engineer")       # Works with strings

# Check if role has specific privileges
super_admin.has_privilege?(:can_create_candidate)     # true/false
super_admin.has_privilege?("can_create_candidate")    # Works with strings
super_admin.has_privilege?(CREATE, Candidate)         # Works with act + resource
super_admin.has_privilege?(CREATE, Candidate.new)     # Works with instances
```

### Authorization Checks

```crystal
class User
  property roles : Array(String)
  
  def initialize(@roles : Array(String))
  end
end

class SingleRoleUser
  property role : String
  
  def initialize(@role : String)
  end
end

user = User.new(["super_admin"])
single_user = SingleRoleUser.new("finance")

# Check permissions with can?
Authorizer.can?(CREATE, Candidate, user.roles)              # true/false
Authorizer.can?(CREATE, Billing, single_user.role)          # Works with single role
Authorizer.can?(:can_create_billing, user.roles)            # Works with privilege IDs
Authorizer.can?(Authorizer::CAN_CREATE_BILLING, user.roles) # Works with privilege objects

# Require permissions (raises Rbacr::AuthorizationError if unauthorized)
Authorizer.require_privilege!(CREATE, Candidate, user.roles)
Authorizer.require_privilege!(:can_create_billing, user.roles)
Authorizer.require_privilege!(Authorizer::CAN_CREATE_BILLING, user.roles)

# Require specific roles
Authorizer.require_role!(:finance, user.roles)
Authorizer.require_role!("super_admin", user.roles)
Authorizer.require_role!(Authorizer::FINANCE_ROLE, user.roles)
```

### Working with Tiers

```crystal
# Find roles by tier
director_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::DIRECTOR)
manager_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::MANAGER)
worker_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::WORKER)

# Convenience methods
Authorizer.director_roles  # Returns all director-tier roles
Authorizer.manager_roles   # Returns all manager-tier roles  
Authorizer.worker_roles    # Returns all worker-tier roles

# Check tier properties on roles
role = Authorizer.role_of(:super_admin)
role.director?    # true
role.manager?     # false
role.worker?      # false
role.managerial?  # true (director? || manager?)

# Tier comparisons
Rbacr::Tier::DIRECTOR > Rbacr::Tier::MANAGER  # true
Rbacr::Tier::MANAGER >= Rbacr::Tier::WORKER   # true
```

## Error Handling

RBACR provides specific exception types for different error scenarios:

```crystal
# Base exception
Rbacr::Error

# Specific exceptions (inherit from Rbacr::Error)
Rbacr::UnknownRoleError       # Role not found
Rbacr::UnknownPrivilegeError  # Privilege not found  
Rbacr::AuthorizationError     # Permission denied
Rbacr::DuplicatePrivilegeError # Privilege already registered with same ID
```

## Contributing

1. Fork it (<https://github.com/systatum/rbacr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

Created with ⸜(｡˃ ᵕ ˂ )⸝♡ at Systatum.
