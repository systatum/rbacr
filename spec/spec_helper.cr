require "spec"
require "../src/rbacr"

class Candidate
end

class Billing
end

module AI
  class ChatGPT
  end
end

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

class Authorizer
  include Rbacr::Definer

  CREATE   = act(:create)
  READ     = act(:read)
  DELETE   = act(:delete)
  LIST_ALL = act(:list_all)
  CHAT     = act(:chat)
  BROWSE   = act(:browse)

  CAN_CREATE_CANDIDATE = can(CREATE, Candidate)
  CAN_DELETE_CANDIDATE = can(DELETE, Candidate)
  CAN_CREATE_BILLING   = can(CREATE, Billing)
  CAN_CHAT_CHATGPT     = can(CHAT, AI::ChatGPT)
  CAN_BROWSE_PICTURES  = can(BROWSE, :pictures)

  SUPER_ADMIN_ROLE = role(
    :super_admin,
    [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE, CAN_CREATE_BILLING],
    Rbacr::Tier::DIRECTOR
  )
  ENGINEER_ROLE    = role(:engineer, [CAN_CREATE_CANDIDATE])
  HR_ROLE          = role(
    :hr,
    [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE],
    Rbacr::Tier::MANAGER
  )
  FINANCE_ROLE     = role(
    :finance,
    [CAN_CREATE_BILLING],
    Rbacr::Tier::MANAGER
  )
  CHAT_ROLE        = role(:chat_user, [CAN_CHAT_CHATGPT, CAN_BROWSE_PICTURES])
end
