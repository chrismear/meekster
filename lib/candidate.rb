require 'bigdecimal'

class Candidate
  STATES = [:hopeful, :withdrawn, :elected, :defeated]

  attr_accessor :name, :state, :keep_factor, :votes

  def initialize(name=nil)
    self.name = name
    self.keep_factor = BigDecimal("1")
    self.votes = BigDecimal('0')
  end
end
