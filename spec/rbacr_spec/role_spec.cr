require "../spec_helper"

describe Rbacr::Role do
  describe "#initialize" do
    it "creates a role with the given name and privileges" do
      create_act = Rbacr::Act.new(:create)
      privilege1 = Rbacr::Privilege.new(create_act, "candidate")
      role = Rbacr::Role.new(:engineer, [privilege1])
      role.name.should eq(:engineer)
      role.privileges.should eq([privilege1])
    end
  end

  describe "#has_privilege?" do
    context "when checking with a Privilege object" do
      it "returns true if the role has the privilege" do
        create_act = Rbacr::Act.new(:create)
        delete_act = Rbacr::Act.new(:delete)
        privilege1 = Rbacr::Privilege.new(create_act, "candidate")
        privilege2 = Rbacr::Privilege.new(delete_act, "candidate")
        role = Rbacr::Role.new(:engineer, [privilege1, privilege2])
        role.has_privilege?(privilege1).should be_true
      end

      it "returns false if the role doesn't have the privilege" do
        create_act = Rbacr::Act.new(:create)
        privilege1 = Rbacr::Privilege.new(create_act, "candidate")
        privilege3 = Rbacr::Privilege.new(create_act, "billing")
        role = Rbacr::Role.new(:engineer, [privilege1])
        role.has_privilege?(privilege3).should be_false
      end
    end

    context "when checking with act and resource" do
      it "returns true if the role has a matching privilege" do
        create_act = Rbacr::Act.new(:create)
        privilege1 = Rbacr::Privilege.new(create_act, "candidate")
        role = Rbacr::Role.new(:engineer, [privilege1])
        role.has_privilege?(create_act, "candidate").should be_true
      end

      it "returns false if the role doesn't have a matching privilege" do
        create_act = Rbacr::Act.new(:create)
        delete_act = Rbacr::Act.new(:delete)
        privilege1 = Rbacr::Privilege.new(create_act, "candidate")
        role = Rbacr::Role.new(:engineer, [privilege1])
        role.has_privilege?(delete_act, "candidate").should be_false
      end

      it "works with class resources" do
        create_act = Rbacr::Act.new(:create)
        privilege1 = Rbacr::Privilege.new(create_act, "candidate")
        role = Rbacr::Role.new(:engineer, [privilege1])
        role.has_privilege?(create_act, Candidate).should be_true
      end
    end
  end

  describe "#privilege_ids" do
    it "returns an array of privilege IDs" do
      create_act = Rbacr::Act.new(:create)
      delete_act = Rbacr::Act.new(:delete)
      privilege1 = Rbacr::Privilege.new(create_act, "candidate")
      privilege2 = Rbacr::Privilege.new(delete_act, "candidate")
      role = Rbacr::Role.new(:admin, [privilege1, privilege2])
      expected_ids = ["can_create_candidate", "can_delete_candidate"]
      role.privilege_ids.should eq(expected_ids)
    end

    it "returns empty array for role with no privileges" do
      role = Rbacr::Role.new(:guest, [] of Rbacr::Privilege)
      role.privilege_ids.should eq([] of String)
    end
  end

  describe "#to_s" do
    it "includes role name and privilege IDs in string representation" do
      create_act = Rbacr::Act.new(:create)
      privilege1 = Rbacr::Privilege.new(create_act, "candidate")
      role = Rbacr::Role.new(:hr, [privilege1])
      role.to_s.should contain("Role(hr:")
      role.to_s.should contain("can_create_candidate")
    end
  end

  describe "#==" do
    it "returns true for roles with the same name" do
      create_act = Rbacr::Act.new(:create)
      delete_act = Rbacr::Act.new(:delete)
      privilege1 = Rbacr::Privilege.new(create_act, "candidate")
      privilege2 = Rbacr::Privilege.new(delete_act, "candidate")
      role1 = Rbacr::Role.new(:admin, [privilege1])
      role2 = Rbacr::Role.new(:admin, [privilege2])
      (role1 == role2).should be_true
    end

    it "returns false for roles with different names" do
      create_act = Rbacr::Act.new(:create)
      privilege1 = Rbacr::Privilege.new(create_act, "candidate")
      role1 = Rbacr::Role.new(:admin, [privilege1])
      role2 = Rbacr::Role.new(:user, [privilege1])
      (role1 == role2).should be_false
    end
  end
end
