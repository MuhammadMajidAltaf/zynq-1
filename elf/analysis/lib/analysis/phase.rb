class Phase
  #Base class for all the phases, used to enable the independent running/re-
  #running of them all

  def self.load_state s
    #Must overload
    raise NotYetImplemented
  end

  def self.save_state s
    #Must overload
    raise NotYetImplemented
  end

  def self.run s
    #Must overload
    raise MustOverloadThis
  end

  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end
end
