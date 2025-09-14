require "./spec_helper"

describe "RBACR Usage Cases" do
  describe "Retrieve privileges" do
    it "returns privileges for valid role using symbol" do
      privileges = Authorizer.privileges_of(name: :super_admin)
      privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
      privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
      privileges.should contain(Authorizer::CAN_CREATE_BILLING)
      privileges.size.should eq(3)
    end

    it "returns privileges for valid role using string" do
      privileges = Authorizer.privileges_of(name: "super_admin")
      privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
      privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
      privileges.should contain(Authorizer::CAN_CREATE_BILLING)
      privileges.size.should eq(3)
    end

    it "raises error for undefined role" do
      expect_raises(Rbacr::UnknownRoleError, "Unknown role: undefined") do
        Authorizer.privileges_of(name: :undefined)
      end
    end

    it "works with different role types" do
      engineer_privileges = Authorizer.privileges_of(name: :engineer)
      engineer_privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
      engineer_privileges.size.should eq(1)

      finance_privileges = Authorizer.privileges_of(name: "finance")
      finance_privileges.should contain(Authorizer::CAN_CREATE_BILLING)
      finance_privileges.size.should eq(1)

      hr_privileges = Authorizer.privileges_of(name: :hr)
      hr_privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
      hr_privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
      hr_privileges.size.should eq(2)

      chat_privileges = Authorizer.privileges_of(name: "chat_user")
      chat_privileges.should contain(Authorizer::CAN_CHAT_CHATGPT)
      chat_privileges.should contain(Authorizer::CAN_BROWSE_PICTURES)
      chat_privileges.size.should eq(2)
    end
  end

  describe "Find role" do
    it "returns role instance for valid role using symbol" do
      role = Authorizer.role_of(name: :super_admin)
      role.should eq(Authorizer::SUPER_ADMIN_ROLE)
      role.name.should eq(:super_admin)
    end

    it "returns role instance for valid role using string" do
      role = Authorizer.role_of(name: "super_admin")
      role.should eq(Authorizer::SUPER_ADMIN_ROLE)
      role.name.should eq(:super_admin)
    end

    it "raises error for unknown role" do
      expect_raises(Rbacr::UnknownRoleError, "Unknown role: unknown") do
        Authorizer.role_of(name: "unknown")
      end
    end

    it "allows checking privileges on role instance" do
      super_admin = Authorizer.role_of("super_admin")

      super_admin.has_privilege?(privilege_id: "can_create_candidate").should be_true
      super_admin.has_privilege?(privilege_id: "can_create_billing").should be_true
      super_admin.has_privilege?(privilege_id: "can_browse_pictures").should be_false

      super_admin.has_privilege?(privilege_id: :can_create_billing).should be_true
      super_admin.has_privilege?(privilege_id: :can_browse_pictures).should be_false

      super_admin.has_privilege?(act: Authorizer::CREATE, object: Candidate).should be_true
      super_admin.has_privilege?(act: Authorizer::CREATE, object: Billing).should be_true
      super_admin.has_privilege?(act: Authorizer::BROWSE, object: :pictures).should be_false

      candidate = Candidate.new
      super_admin.has_privilege?(act: Authorizer::CREATE, object: candidate).should be_true
    end
  end

  describe "Check privilege via can?" do
    it "works with user having array of roles" do
      user = User.new(roles: ["super_admin"])
      candidate = Candidate.new

      Authorizer.can?(roles: user.roles, act: Authorizer::CREATE, resource: candidate).should be_true
      Authorizer.can?(roles: user.roles, act: Authorizer::DELETE, resource: candidate).should be_true
      Authorizer.can?(roles: user.roles, act: Authorizer::BROWSE, resource: :pictures).should be_false
    end

    it "works with user having single role as string" do
      user = SingleRoleUser.new("finance")

      Authorizer.can?(roles: user.role, act: Authorizer::CREATE, resource: Billing).should be_true
      Authorizer.can?(roles: user.role, act: Authorizer::CREATE, resource: Candidate).should be_false
    end

    it "works with multiple roles" do
      user = User.new(roles: ["engineer", "finance"])

      Authorizer.can?(roles: user.roles, act: Authorizer::CREATE, resource: Candidate).should be_true
      Authorizer.can?(roles: user.roles, act: Authorizer::CREATE, resource: Billing).should be_true
      Authorizer.can?(roles: user.roles, act: Authorizer::DELETE, resource: Candidate).should be_false
    end

    it "works with privilege IDs" do
      user = User.new(roles: ["finance"])

      Authorizer.can?(roles: user.roles, privilege_id: :can_create_billing).should be_true
      Authorizer.can?(roles: user.roles, privilege_id: "can_create_billing").should be_true
      Authorizer.can?(roles: user.roles, privilege_id: :can_create_candidate).should be_false
    end

    it "works with privilege resources" do
      user = User.new(roles: ["engineer"])

      Authorizer.can?(roles: user.roles, privilege: Authorizer::CAN_CREATE_CANDIDATE).should be_true
      Authorizer.can?(roles: user.roles, privilege: Authorizer::CAN_CREATE_BILLING).should be_false
    end
  end

  describe "Require privilege" do
    describe "with act and resource" do
      it "passes for authorized users" do
        user = User.new(roles: ["super_admin"])
        candidate = Candidate.new

        Authorizer.require_privilege!(roles: user.roles, act: Authorizer::CREATE, resource: candidate)
      end

      it "raises AuthorizationError for unauthorized users" do
        user = User.new(roles: ["finance"])
        candidate = Candidate.new

        expect_raises(Rbacr::AuthorizationError, "Access denied for create on candidate") do
          Authorizer.require_privilege!(roles: user.roles, act: Authorizer::CREATE, resource: candidate)
        end
      end
    end

    describe "with privilege ID" do
      it "passes for authorized users" do
        user = User.new(roles: ["finance"])

        Authorizer.require_privilege!(roles: user.roles, privilege_id: :can_create_billing)
        Authorizer.require_privilege!(roles: user.roles, privilege_id: "can_create_billing")
      end

      it "raises AuthorizationError for unauthorized users" do
        user = User.new(roles: ["engineer"])

        expect_raises(Rbacr::AuthorizationError, "Access denied for privilege can_create_billing") do
          Authorizer.require_privilege!(roles: user.roles, privilege_id: :can_create_billing)
        end
      end

      it "raises UnknownPrivilegeError for non-existent privileges" do
        user = User.new(roles: ["super_admin"])

        expect_raises(Rbacr::UnknownPrivilegeError, "Unknown privilege: non_existent_privilege") do
          Authorizer.require_privilege!(roles: user.roles, privilege_id: :non_existent_privilege)
        end
      end
    end

    describe "with privilege resource" do
      it "passes for authorized users" do
        user = User.new(roles: ["finance"])

        Authorizer.require_privilege!(roles: user.roles, privilege: Authorizer::CAN_CREATE_BILLING)
      end

      it "raises AuthorizationError for unauthorized users" do
        user = User.new(roles: ["engineer"])

        expect_raises(Rbacr::AuthorizationError, "Access denied for privilege can_create_billing") do
          Authorizer.require_privilege!(roles: user.roles, privilege: Authorizer::CAN_CREATE_BILLING)
        end
      end
    end
  end

  describe "Require role" do
    it "passes when user has required role" do
      user = User.new(roles: ["finance", "hr"])

      Authorizer.require_role!(roles: user.roles, required_role: :finance)
      Authorizer.require_role!(roles: user.roles, required_role: "hr")
    end

    it "raises error when user doesn't have required role" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "Role finance is required") do
        Authorizer.require_role!(roles: user.roles, required_role: :finance)
      end
    end

    it "works with role resources" do
      user = User.new(roles: ["finance"])

      Authorizer.require_role!(roles: user.roles, required_role: Authorizer::FINANCE_ROLE)
    end

    it "works with all role resource constants" do
      Authorizer.require_role!(roles: ["super_admin"], required_role: Authorizer::SUPER_ADMIN_ROLE)
      Authorizer.require_role!(roles: ["engineer"], required_role: Authorizer::ENGINEER_ROLE)
      Authorizer.require_role!(roles: ["hr"], required_role: Authorizer::HR_ROLE)
      Authorizer.require_role!(roles: ["finance"], required_role: Authorizer::FINANCE_ROLE)
      Authorizer.require_role!(roles: ["chat_user"], required_role: Authorizer::CHAT_ROLE)
    end

    it "raises error with role resources when unauthorized" do
      user = User.new(roles: ["engineer"])

      expect_raises(Rbacr::AuthorizationError, "Role finance is required") do
        Authorizer.require_role!(roles: user.roles, required_role: Authorizer::FINANCE_ROLE)
      end
    end
  end
end
