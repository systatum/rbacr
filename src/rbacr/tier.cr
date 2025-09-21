enum Rbacr::Tier
  DIRECTOR = 1
  MANAGER  = 2
  WORKER   = 3

  def director? : Bool
    self == DIRECTOR
  end

  def manager? : Bool
    self == MANAGER
  end

  def worker? : Bool
    self == WORKER
  end

  def managerial? : Bool
    director? || manager?  end

  def >=(other : Tier) : Bool
    self.value <= other.value
  end

  def >(other : Tier) : Bool
    self.value < other.value
  end
end
