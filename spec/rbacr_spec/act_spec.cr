require "../spec_helper"

describe Rbacr::Act do
  describe "#initialize" do
    it "creates an act with the given action symbol" do
      act = Rbacr::Act.new(:create)
      act.action.should eq(:create)
    end
  end

  describe "#act" do
    it "is an alias for the action getter" do
      act = Rbacr::Act.new(:browse)
      act.act.should eq(act.action)
    end

    it "returns the action symbol" do
      act = Rbacr::Act.new(:update)
      act.act.should eq(:update)
    end
  end

  describe "#to_s" do
    it "converts the action to a string representation" do
      act = Rbacr::Act.new(:browse)
      act.to_s.should eq("browse")
    end
  end

  describe "#==" do
    context "when comparing with another Rbacr::Act" do
      it "returns true for acts with the same action" do
        act1 = Rbacr::Act.new(:create)
        act2 = Rbacr::Act.new(:create)
        (act1 == act2).should be_true
      end

      it "returns false for acts with different actions" do
        act1 = Rbacr::Act.new(:create)
        act2 = Rbacr::Act.new(:delete)
        (act1 == act2).should be_false
      end
    end

    context "when comparing with a Symbol" do
      it "returns true when the symbol matches the action" do
        act = Rbacr::Act.new(:update)
        (act == :update).should be_true
      end

      it "returns false when the symbol doesn't match the action" do
        act = Rbacr::Act.new(:update)
        (act == :delete).should be_false
      end
    end
  end
end
