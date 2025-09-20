require "../spec_helper"

describe Rbacr::AuthorizationError do
  context "when raised by require_privilege!" do
    it "raises AuthorizationError for unauthorized users with act and resource" do
      user = User.new(roles: ["finance"])
      candidate = Candidate.new

      expect_raises(Rbacr::AuthorizationError, "The privilege `create_candidate` is required") do
        Authorizer.require_privilege!(Authorizer::CREATE, candidate, user.roles)
      end
    end

    it "raises AuthorizationError for unauthorized users with privilege ID" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "The privilege `can_create_billing` is required") do
        Authorizer.require_privilege!(:can_create_billing, user.roles)
      end
    end

    it "raises AuthorizationError for unauthorized users with privilege resource" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "The privilege `can_create_billing` is required") do
        Authorizer.require_privilege!(Authorizer::CAN_CREATE_BILLING, user.roles)
      end
    end
  end

  context "when raised by require_role!" do
    it "raises AuthorizationError when user doesn't have required role" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "The role `finance` is required") do
        Authorizer.require_role!(:finance, user.roles)
      end
    end

    it "raises AuthorizationError with role constant when unauthorized" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "The role `finance` is required") do
        Authorizer.require_role!(Authorizer::FINANCE_ROLE, user.roles)
      end
    end
  end
end

describe Rbacr::UnknownRoleError do
  context "when raised by privileges_of" do
    it "raises UnknownRoleError for undefined role" do
      expect_raises(Rbacr::UnknownRoleError, "Unknown role: undefined") do
        Authorizer.privileges_of(:undefined)
      end
    end
  end

  context "when raised by role_of" do
    it "raises UnknownRoleError for unknown role" do
      expect_raises(Rbacr::UnknownRoleError, "Unknown role: unknown") do
        Authorizer.role_of("unknown")
      end
    end
  end
end

describe Rbacr::UnknownPrivilegeError do
  context "when raised by require_privilege!" do
    it "raises UnknownPrivilegeError for non-existent privilege" do
      user = User.new(roles: ["super_admin"])

      expect_raises(Rbacr::UnknownPrivilegeError, "Unknown privilege: non_existent_privilege") do
        Authorizer.require_privilege!(:non_existent_privilege, user.roles)
      end
    end
  end
end
