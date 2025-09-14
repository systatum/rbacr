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

class CustomModel
  property name : String

  def initialize(@name : String)
  end
end

class Authorizer
  include Rbacr::Definer

  CREATE   = act(action: :create)
  READ     = act(action: :read)
  DELETE   = act(action: :delete)
  LIST_ALL = act(action: :list_all)
  CHAT     = act(action: :chat)
  BROWSE   = act(action: :browse)

  CAN_CREATE_CANDIDATE = can(act: CREATE, resource: Candidate)
  CAN_DELETE_CANDIDATE = can(act: DELETE, resource: Candidate)
  CAN_CREATE_BILLING   = can(act: CREATE, resource: Billing)
  CAN_CHAT_CHATGPT     = can(act: CHAT, resource: AI::ChatGPT)
  CAN_BROWSE_PICTURES  = can(act: BROWSE, resource: :pictures)

  SUPER_ADMIN_ROLE = role(name: :super_admin, privileges: [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE, CAN_CREATE_BILLING])
  ENGINEER_ROLE    = role(name: :engineer, privileges: [CAN_CREATE_CANDIDATE])
  HR_ROLE          = role(name: :hr, privileges: [CAN_CREATE_CANDIDATE, CAN_DELETE_CANDIDATE])
  FINANCE_ROLE     = role(name: :finance, privileges: [CAN_CREATE_BILLING])
  CHAT_ROLE        = role(name: :chat_user, privileges: [CAN_CHAT_CHATGPT, CAN_BROWSE_PICTURES])
end
