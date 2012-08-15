class Ballot
  attr_accessor :ranking, :weight

  def initialize(ranking=nil)
    self.ranking = ranking
  end
end
