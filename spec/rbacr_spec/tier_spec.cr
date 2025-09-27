require "../spec_helper"

describe Rbacr::Tier do
  describe "#value" do
    it "has correct numeric values" do
      Rbacr::Tier::DIRECTOR.value.should eq(1)
      Rbacr::Tier::MANAGER.value.should eq(2)
      Rbacr::Tier::WORKER.value.should eq(3)
    end
  end

  describe "#director?" do
    it "returns true for DIRECTOR tier" do
      Rbacr::Tier::DIRECTOR.director?.should be_true
    end

    it "returns false for MANAGER tier" do
      Rbacr::Tier::MANAGER.director?.should be_false
    end

    it "returns false for WORKER tier" do
      Rbacr::Tier::WORKER.director?.should be_false
    end
  end

  describe "#manager?" do
    it "returns false for DIRECTOR tier" do
      Rbacr::Tier::DIRECTOR.manager?.should be_false
    end

    it "returns true for MANAGER tier" do
      Rbacr::Tier::MANAGER.manager?.should be_true
    end

    it "returns false for WORKER tier" do
      Rbacr::Tier::WORKER.manager?.should be_false
    end
  end

  describe "#worker?" do
    it "returns false for DIRECTOR tier" do
      Rbacr::Tier::DIRECTOR.worker?.should be_false
    end

    it "returns false for MANAGER tier" do
      Rbacr::Tier::MANAGER.worker?.should be_false
    end

    it "returns true for WORKER tier" do
      Rbacr::Tier::WORKER.worker?.should be_true
    end
  end

  describe "#managerial?" do
    it "returns true for DIRECTOR tier" do
      Rbacr::Tier::DIRECTOR.managerial?.should be_true
    end

    it "returns true for MANAGER tier" do
      Rbacr::Tier::MANAGER.managerial?.should be_true
    end

    it "returns false for WORKER tier" do
      Rbacr::Tier::WORKER.managerial?.should be_false
    end
  end

  describe "#>=" do
    it "returns true when comparing same tiers" do
      (Rbacr::Tier::DIRECTOR >= Rbacr::Tier::DIRECTOR).should be_true
      (Rbacr::Tier::MANAGER >= Rbacr::Tier::MANAGER).should be_true
      (Rbacr::Tier::WORKER >= Rbacr::Tier::WORKER).should be_true
    end

    it "returns true when left tier has higher or equal authority (lower numeric value)" do
      (Rbacr::Tier::DIRECTOR >= Rbacr::Tier::MANAGER).should be_true
      (Rbacr::Tier::DIRECTOR >= Rbacr::Tier::WORKER).should be_true
      (Rbacr::Tier::MANAGER >= Rbacr::Tier::WORKER).should be_true
    end

    it "returns false when left tier has lower authority (higher numeric value)" do
      (Rbacr::Tier::MANAGER >= Rbacr::Tier::DIRECTOR).should be_false
      (Rbacr::Tier::WORKER >= Rbacr::Tier::DIRECTOR).should be_false
      (Rbacr::Tier::WORKER >= Rbacr::Tier::MANAGER).should be_false
    end
  end

  describe "#>" do
    it "returns false when comparing same tiers" do
      (Rbacr::Tier::DIRECTOR > Rbacr::Tier::DIRECTOR).should be_false
      (Rbacr::Tier::MANAGER > Rbacr::Tier::MANAGER).should be_false
      (Rbacr::Tier::WORKER > Rbacr::Tier::WORKER).should be_false
    end

    it "returns true when left tier has strictly higher authority (lower numeric value)" do
      (Rbacr::Tier::DIRECTOR > Rbacr::Tier::MANAGER).should be_true
      (Rbacr::Tier::DIRECTOR > Rbacr::Tier::WORKER).should be_true
      (Rbacr::Tier::MANAGER > Rbacr::Tier::WORKER).should be_true
    end

    it "returns false when left tier has lower or equal authority" do
      (Rbacr::Tier::MANAGER > Rbacr::Tier::DIRECTOR).should be_false
      (Rbacr::Tier::WORKER > Rbacr::Tier::DIRECTOR).should be_false
      (Rbacr::Tier::WORKER > Rbacr::Tier::MANAGER).should be_false
    end
  end
end
