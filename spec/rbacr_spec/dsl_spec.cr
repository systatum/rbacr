require "../spec_helper"

describe Rbacr::DSL do
  describe "#act" do
    it "creates an Act with the given action" do
      create_act = Authorizer.act(:create)
      create_act.should be_a(Rbacr::Act)
      create_act.action.should eq(:create)
    end

    it "creates different acts for different actions" do
      read_act = Authorizer.act(:read)
      delete_act = Authorizer.act(:delete)

      read_act.action.should eq(:read)
      delete_act.action.should eq(:delete)
      read_act.should_not eq(delete_act)
    end
  end

  describe "#can" do
    it "creates a Privilege with act and resource" do
      create_act = TestDefiner.act(:create)
      privilege = TestDefiner.can(create_act, User)

      privilege.should be_a(Rbacr::Privilege)
      privilege.id.should eq("can_create_user")
    end

    it "works with different resource types" do
      browse_act = TestDefiner.act(:browse)
      symbol_privilege = TestDefiner.can(browse_act, :videos)
      class_privilege = TestDefiner.can(browse_act, User)

      symbol_privilege.id.should eq("can_browse_videos")
      class_privilege.id.should eq("can_browse_user")
    end

    it "works with namespaced classes" do
      chat_act = TestDefiner.act(:chat)
      privilege = TestDefiner.can(chat_act, SingleRoleUser)

      privilege.id.should eq("can_chat_singleroleuser")
    end
  end
end
