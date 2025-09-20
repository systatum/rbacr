require "../spec_helper"

describe Rbacr::Privilege do
  describe "#initialize" do
    it "creates a privilege with the given act and resource" do
      create_act = Rbacr::Act.new(:create)
      privilege = Rbacr::Privilege.new(create_act, "candidate")
      privilege.act.should eq(create_act)
      privilege.resource.should eq("candidate")
    end
  end

  describe "#id" do
    it "generates a unique identifier for the privilege" do
      create_act = Rbacr::Act.new(:create)
      privilege = Rbacr::Privilege.new(create_act, "billing")
      privilege.id.should eq("can_create_billing")
    end

    it "caches the generated id" do
      delete_act = Rbacr::Act.new(:delete)
      privilege = Rbacr::Privilege.new(delete_act, "user")
      first_call = privilege.id
      second_call = privilege.id
      first_call.should eq(second_call)
      first_call.should eq("can_delete_user")
    end
  end

  describe "#matches?" do
    context "when matching against act and resource" do
      it "returns true for matching act and resource" do
        create_act = Rbacr::Act.new(:create)
        privilege = Rbacr::Privilege.new(create_act, "candidate")
        privilege.matches?(create_act, "candidate").should be_true
      end

      it "returns false for different act" do
        create_act = Rbacr::Act.new(:create)
        delete_act = Rbacr::Act.new(:delete)
        privilege = Rbacr::Privilege.new(create_act, "candidate")
        privilege.matches?(delete_act, "candidate").should be_false
      end

      it "returns false for different resource" do
        create_act = Rbacr::Act.new(:create)
        privilege = Rbacr::Privilege.new(create_act, "candidate")
        privilege.matches?(create_act, "billing").should be_false
      end

      it "works with class resources" do
        create_act = Rbacr::Act.new(:create)
        privilege = Rbacr::Privilege.new(create_act, "candidate")
        privilege.matches?(create_act, Candidate).should be_true
      end

      it "works with instance resources" do
        create_act = Rbacr::Act.new(:create)
        privilege = Rbacr::Privilege.new(create_act, "candidate")
        candidate = Candidate.new
        privilege.matches?(create_act, candidate).should be_true
      end
    end
  end

  describe "#to_s" do
    it "returns the privilege ID as string representation" do
      create_act = Rbacr::Act.new(:create)
      privilege = Rbacr::Privilege.new(create_act, "user")
      privilege.to_s.should eq("can_create_user")
    end
  end

  describe "#==" do
    it "returns true for privileges with the same ID" do
      create_act = Rbacr::Act.new(:create)
      priv1 = Rbacr::Privilege.new(create_act, "billing")
      priv2 = Rbacr::Privilege.new(create_act, "billing")
      (priv1 == priv2).should be_true
    end

    it "returns false for privileges with different IDs" do
      create_act = Rbacr::Act.new(:create)
      delete_act = Rbacr::Act.new(:delete)
      priv1 = Rbacr::Privilege.new(create_act, "billing")
      priv2 = Rbacr::Privilege.new(delete_act, "billing")
      (priv1 == priv2).should be_false
    end
  end
end
