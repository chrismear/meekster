require File.expand_path('../meekster', File.dirname(__FILE__))

class Meekster::Ballot
  attr_accessor :ranking, :weight

  def initialize(ranking=nil)
    self.ranking = ranking
  end
end
