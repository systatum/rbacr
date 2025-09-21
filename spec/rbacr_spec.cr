require "./spec_helper"

describe Authorizer do
  context "when working with constants" do
    context "when examining act constants" do
      it "defines CREATE act" do
        Authorizer::CREATE.should be_a(Rbacr::Act)
        Authorizer::CREATE.action.should eq(:create)
      end

      it "defines READ act" do
        Authorizer::READ.should be_a(Rbacr::Act)
        Authorizer::READ.action.should eq(:read)
      end

      it "defines DELETE act" do
        Authorizer::DELETE.should be_a(Rbacr::Act)
        Authorizer::DELETE.action.should eq(:delete)
      end

      it "defines LIST_ALL act" do
        Authorizer::LIST_ALL.should be_a(Rbacr::Act)
        Authorizer::LIST_ALL.action.should eq(:list_all)
      end

      it "defines CHAT act" do
        Authorizer::CHAT.should be_a(Rbacr::Act)
        Authorizer::CHAT.action.should eq(:chat)
      end

      it "defines BROWSE act" do
        Authorizer::BROWSE.should be_a(Rbacr::Act)
        Authorizer::BROWSE.action.should eq(:browse)
      end
    end

    context "when examining role constants and their privileges" do
      context "when working with SUPER_ADMIN_ROLE" do
        it "defines SUPER_ADMIN_ROLE" do
          Authorizer::SUPER_ADMIN_ROLE.should be_a(Rbacr::Role)
          Authorizer::SUPER_ADMIN_ROLE.name.should eq(:super_admin)
          Authorizer::SUPER_ADMIN_ROLE.privileges.size.should eq(3)
        end

        it "has CAN_CREATE_CANDIDATE privilege" do
          Authorizer::CAN_CREATE_CANDIDATE.should be_a(Rbacr::Privilege)
          Authorizer::CAN_CREATE_CANDIDATE.id.should eq("can_create_candidate")
          Authorizer::SUPER_ADMIN_ROLE.privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        end

        it "has CAN_DELETE_CANDIDATE privilege" do
          Authorizer::CAN_DELETE_CANDIDATE.should be_a(Rbacr::Privilege)
          Authorizer::CAN_DELETE_CANDIDATE.id.should eq("can_delete_candidate")
          Authorizer::SUPER_ADMIN_ROLE.privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
        end

        it "has CAN_CREATE_BILLING privilege" do
          Authorizer::CAN_CREATE_BILLING.should be_a(Rbacr::Privilege)
          Authorizer::CAN_CREATE_BILLING.id.should eq("can_create_billing")
          Authorizer::SUPER_ADMIN_ROLE.privileges.should contain(Authorizer::CAN_CREATE_BILLING)
        end
      end

      context "when working with ENGINEER_ROLE" do
        it "defines ENGINEER_ROLE" do
          Authorizer::ENGINEER_ROLE.should be_a(Rbacr::Role)
          Authorizer::ENGINEER_ROLE.name.should eq(:engineer)
          Authorizer::ENGINEER_ROLE.privileges.size.should eq(1)
        end

        it "has CAN_CREATE_CANDIDATE privilege" do
          Authorizer::ENGINEER_ROLE.privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        end
      end

      context "when working with HR_ROLE" do
        it "defines HR_ROLE" do
          Authorizer::HR_ROLE.should be_a(Rbacr::Role)
          Authorizer::HR_ROLE.name.should eq(:hr)
          Authorizer::HR_ROLE.privileges.size.should eq(2)
        end

        it "has CAN_CREATE_CANDIDATE privilege" do
          Authorizer::HR_ROLE.privileges.should contain(Authorizer::CAN_CREATE_CANDIDATE)
        end

        it "has CAN_DELETE_CANDIDATE privilege" do
          Authorizer::HR_ROLE.privileges.should contain(Authorizer::CAN_DELETE_CANDIDATE)
        end
      end

      context "when working with FINANCE_ROLE" do
        it "defines FINANCE_ROLE" do
          Authorizer::FINANCE_ROLE.should be_a(Rbacr::Role)
          Authorizer::FINANCE_ROLE.name.should eq(:finance)
          Authorizer::FINANCE_ROLE.privileges.size.should eq(1)
        end

        it "has CAN_CREATE_BILLING privilege" do
          Authorizer::FINANCE_ROLE.privileges.should contain(Authorizer::CAN_CREATE_BILLING)
        end
      end

      context "when working with CHAT_ROLE" do
        it "defines CHAT_ROLE" do
          Authorizer::CHAT_ROLE.should be_a(Rbacr::Role)
          Authorizer::CHAT_ROLE.name.should eq(:chat_user)
          Authorizer::CHAT_ROLE.privileges.size.should eq(2)
        end

        it "has CAN_CHAT_CHATGPT privilege" do
          Authorizer::CAN_CHAT_CHATGPT.should be_a(Rbacr::Privilege)
          Authorizer::CAN_CHAT_CHATGPT.id.should eq("can_chat_ai_chatgpt")
          Authorizer::CHAT_ROLE.privileges.should contain(Authorizer::CAN_CHAT_CHATGPT)
        end

        it "has CAN_BROWSE_PICTURES privilege" do
          Authorizer::CAN_BROWSE_PICTURES.should be_a(Rbacr::Privilege)
          Authorizer::CAN_BROWSE_PICTURES.id.should eq("can_browse_pictures")
          Authorizer::CHAT_ROLE.privileges.should contain(Authorizer::CAN_BROWSE_PICTURES)
        end
      end
    end
  end
end
