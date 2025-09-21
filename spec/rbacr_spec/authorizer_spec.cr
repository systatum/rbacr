require "../spec_helper"

describe Rbacr::Authorizer do
  describe "#can?" do
    context "when user has a single role" do
      it "works with a string-role" do
        user = SingleRoleUser.new("finance")

        Authorizer.can?(Authorizer::CREATE, Billing, user.role).should be_true
        Authorizer.can?(Authorizer::CREATE, Candidate, user.role).should be_false
      end

      it "works with an array of roles" do
        user = User.new(roles: ["super_admin"])
        candidate = Candidate.new

        Authorizer.can?(Authorizer::CREATE, candidate, user.roles).should be_true
        Authorizer.can?(Authorizer::DELETE, candidate, user.roles).should be_true
        Authorizer.can?(Authorizer::BROWSE, :pictures, user.roles).should be_false
      end
    end

    context "when user has multiple roles" do
      it "works with multiple roles" do
        user = User.new(roles: ["engineer", "finance"])

        Authorizer.can?(Authorizer::CREATE, Candidate, user.roles).should be_true
        Authorizer.can?(Authorizer::CREATE, Billing, user.roles).should be_true
        Authorizer.can?(Authorizer::DELETE, Candidate, user.roles).should be_false
      end
    end

    context "when checking with privilege IDs" do
      it "works with privilege IDs" do
        user = User.new(roles: ["finance"])

        Authorizer.can?(:can_create_billing, user.roles).should be_true
        Authorizer.can?("can_create_billing", user.roles).should be_true
        Authorizer.can?(:can_create_candidate, user.roles).should be_false
      end
    end

    context "when checking with privilege objects" do
      it "works with privilege resources" do
        user = User.new(roles: ["engineer"])

        Authorizer.can?(Authorizer::CAN_CREATE_CANDIDATE, user.roles).should be_true
        Authorizer.can?(Authorizer::CAN_CREATE_BILLING, user.roles).should be_false
      end
    end
  end

  describe "#require_privilege!" do
    context "when using act and resource" do
      context "when user is authorized" do
        it "passes for authorized users" do
          user = User.new(roles: ["super_admin"])
          candidate = Candidate.new

          Authorizer.require_privilege!(Authorizer::CREATE, candidate, user.roles)
        end
      end
    end

    context "when using privilege ID" do
      context "when user is authorized" do
        it "passes for authorized user" do
          user = User.new(roles: ["finance"])

          Authorizer.require_privilege!(:can_create_billing, user.roles)
          Authorizer.require_privilege!("can_create_billing", user.roles)
        end
      end
    end

    context "when using privilege object" do
      context "when user is authorized" do
        it "passes for authorized users" do
          user = User.new(roles: ["finance"])

          Authorizer.require_privilege!(Authorizer::CAN_CREATE_BILLING, user.roles)
        end
      end
    end
  end

  describe "#require_role!" do
    context "when user has required role" do
      it "passes when user has required role" do
        user = User.new(roles: ["finance", "hr"])

        Authorizer.require_role!(:finance, user.roles)
        Authorizer.require_role!("hr", user.roles)
        Authorizer.require_role!(Authorizer::FINANCE_ROLE, user.roles)
      end

      it "works with all role constants" do
        Authorizer.require_role!(Authorizer::SUPER_ADMIN_ROLE, ["super_admin"])
        Authorizer.require_role!(Authorizer::ENGINEER_ROLE, ["engineer"])
        Authorizer.require_role!(Authorizer::HR_ROLE, ["hr"])
        Authorizer.require_role!(Authorizer::FINANCE_ROLE, ["finance"])
        Authorizer.require_role!(Authorizer::CHAT_ROLE, ["chat_user"])
      end
    end
  end

  describe "#find_roles_by_tier" do
    it "returns director roles" do
      director_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::DIRECTOR)
      director_roles.size.should eq(1)
      director_roles.should contain(Authorizer::SUPER_ADMIN_ROLE)
    end

    it "returns manager roles" do
      manager_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::MANAGER)
      manager_roles.size.should eq(2)
      manager_roles.should contain(Authorizer::HR_ROLE)
      manager_roles.should contain(Authorizer::FINANCE_ROLE)
    end

    it "returns worker roles" do
      worker_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::WORKER)
      worker_roles.size.should eq(2)
      worker_roles.should contain(Authorizer::ENGINEER_ROLE)
      worker_roles.should contain(Authorizer::CHAT_ROLE)
    end

    it "returns empty array for non-existent tier scenarios" do
      all_roles = Authorizer.find_roles_by_tier(Rbacr::Tier::DIRECTOR) +
                  Authorizer.find_roles_by_tier(Rbacr::Tier::MANAGER) +
                  Authorizer.find_roles_by_tier(Rbacr::Tier::WORKER)
      all_roles.size.should eq(5)
    end
  end

  describe "#director_roles" do
    it "returns all director tier roles" do
      director_roles = Authorizer.director_roles
      director_roles.size.should eq(1)
      director_roles.first.should eq(Authorizer::SUPER_ADMIN_ROLE)
      director_roles.first.tier.should eq(Rbacr::Tier::DIRECTOR)
      director_roles.all?(&.director?).should be_true
    end
  end

  describe "#manager_roles" do
    it "returns all manager tier roles" do
      manager_roles = Authorizer.manager_roles
      manager_roles.size.should eq(2)
      manager_roles.should contain(Authorizer::HR_ROLE)
      manager_roles.should contain(Authorizer::FINANCE_ROLE)
      manager_roles.all?(&.manager?).should be_true
      manager_roles.all?(&.managerial?).should be_true
    end
  end

  describe "#worker_roles" do
    it "returns all worker tier roles" do
      worker_roles = Authorizer.worker_roles
      worker_roles.size.should eq(2)
      worker_roles.should contain(Authorizer::ENGINEER_ROLE)
      worker_roles.should contain(Authorizer::CHAT_ROLE)
      worker_roles.all?(&.worker?).should be_true
      worker_roles.none?(&.managerial?).should be_true
    end
  end
end
