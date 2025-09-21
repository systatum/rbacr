require "../spec_helper"

describe Rbacr::Definer do
  describe "#privileges_of" do
    context "when role exists" do
      it "returns privileges for valid role using symbol" do
        privileges = Authorizer.privileges_of(:super_admin)
        privileges.size.should eq(3)
        privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
        privileges.should contain(Authorizer::CAN_CREATE_BILLING)
      end

      it "returns privileges for valid role using string" do
        privileges = Authorizer.privileges_of("super_admin")
        privileges.size.should eq(3)
        privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
        privileges.should contain(Authorizer::CAN_CREATE_BILLING)
      end

      it "works with different role types" do
        engineer_privileges = Authorizer.privileges_of(:engineer)
        engineer_privileges.size.should eq(1)
        engineer_privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)

        finance_privileges = Authorizer.privileges_of("finance")
        finance_privileges.size.should eq(1)
        finance_privileges.should contain(Authorizer::CAN_CREATE_BILLING)

        hr_privileges = Authorizer.privileges_of(:hr)
        hr_privileges.size.should eq(2)
        hr_privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        hr_privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)

        chat_privileges = Authorizer.privileges_of("chat_user")
        chat_privileges.size.should eq(2)
        chat_privileges.should contain(Authorizer::CAN_CHAT_CHATGPT)
        chat_privileges.should contain(Authorizer::CAN_BROWSE_PICTURES)
      end
    end
  end

  describe "#role_of" do
    context "when role exists" do
      it "returns role instance for valid role using symbol" do
        role = Authorizer.role_of(:super_admin)
        role.should eq(Authorizer::SUPER_ADMIN_ROLE)
        role.name.should eq(:super_admin)
      end

      it "returns role instance for valid role using string" do
        role = Authorizer.role_of("super_admin")
        role.should eq(Authorizer::SUPER_ADMIN_ROLE)
        role.name.should eq(:super_admin)
      end

      it "allows checking privileges on role instance" do
        super_admin = Authorizer.role_of("super_admin")

        super_admin.has_privilege?("can_create_candidate").should be_true
        super_admin.has_privilege?("can_create_billing").should be_true
        super_admin.has_privilege?("can_browse_pictures").should be_false

        super_admin.has_privilege?(:can_create_billing).should be_true
        super_admin.has_privilege?(:can_browse_pictures).should be_false

        super_admin.has_privilege?(Authorizer::CREATE, Candidate).should be_true
        super_admin.has_privilege?(Authorizer::CREATE, Billing).should be_true
        super_admin.has_privilege?(Authorizer::BROWSE, :pictures).should be_false

        super_admin.has_privilege?(Authorizer::CREATE, Candidate.new).should be_true
      end
    end
  end

  describe "#role" do
    context "when creating a new role" do
      it "creates a role with name and privileges" do
        create_privilege = Authorizer.can(Authorizer.act(:create), Candidate)
        test_role = Authorizer.role(:test_role, [create_privilege])

        test_role.should be_a(Rbacr::Role)
        test_role.name.should eq(:test_role)
        test_role.privileges.should contain(create_privilege)
      end

      it "creates role with multiple privileges" do
        create_privilege = Authorizer.can(Authorizer.act(:create), Candidate)
        delete_privilege = Authorizer.can(Authorizer.act(:delete), Candidate)
        multi_role = Authorizer.role(:multi_role, [create_privilege, delete_privilege])

        multi_role.privileges.size.should eq(2)
        multi_role.privileges.should contain(create_privilege)
        multi_role.privileges.should contain(delete_privilege)
      end

      it "creates role with empty privileges array" do
        empty_role = Authorizer.role(:empty_role, [] of Rbacr::Privilege)

        empty_role.privileges.size.should eq(0)
        empty_role.name.should eq(:empty_role)
      end

      it "accepts symbol role names" do
        privilege = Authorizer.can(Authorizer.act(:read), Billing)
        symbol_role = Authorizer.role(:symbol_role, [privilege])

        symbol_role.name.should eq(:symbol_role)
        symbol_role.privileges.should contain(privilege)
      end

      it "creates role that can be used for authorization" do
        privilege = Authorizer.can(Authorizer.act(:manage), :documents)
        manager_role = Authorizer.role(:document_manager, [privilege])

        manager_role.has_privilege?(Authorizer.act(:manage), :documents).should be_true
        manager_role.has_privilege?(Authorizer.act(:delete), :documents).should be_false
      end
    end

    context "when working with existing role constants" do
      it "matches the behavior of predefined roles" do
        create_candidate = Authorizer::CAN_CREATE_CANDIDATE
        delete_candidate = Authorizer::CAN_DELETE_CANDIDATE
        custom_hr = Authorizer.role(:custom_hr, [create_candidate, delete_candidate])

        custom_hr.privileges.size.should eq(2)
        custom_hr.privileges.should contain(create_candidate)
        custom_hr.privileges.should contain(delete_candidate)

        custom_hr.has_privilege?(create_candidate).should be_true
        custom_hr.has_privilege?(delete_candidate).should be_true
      end
    end
  end
end
