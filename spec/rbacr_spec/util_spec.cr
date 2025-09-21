require "../spec_helper"

describe Rbacr::Util do
  describe ".normalize_class_name" do
    it "converts class names to lowercase underscore format" do
      Rbacr::Util.normalize_class_name(Candidate).should eq("candidate")
    end

    it "handles namespaced classes" do
      Rbacr::Util.normalize_class_name(Rbacr::Role).should eq("rbacr_role")
    end
  end

  describe ".normalize_resource" do
    context "with string input" do
      it "returns the string as-is" do
        Rbacr::Util.normalize_resource("user").should eq("user")
      end
    end

    context "with symbol input" do
      it "converts symbol to string" do
        Rbacr::Util.normalize_resource(:user).should eq("user")
      end
    end

    context "with class input" do
      it "normalizes class name" do
        Rbacr::Util.normalize_resource(Candidate).should eq("candidate")
      end
    end

    context "with instance input" do
      it "normalizes the instance's class name" do
        candidate = Candidate.new
        Rbacr::Util.normalize_resource(candidate).should eq("candidate")
      end
    end
  end

  describe ".normalize_roles" do
    context "with string input" do
      it "wraps single string in array" do
        Rbacr::Util.normalize_roles("admin").should eq(["admin"])
      end
    end

    context "with array input" do
      it "returns the array as-is" do
        roles = ["admin", "user"]
        Rbacr::Util.normalize_roles(roles).should eq(roles)
      end
    end
  end
end
