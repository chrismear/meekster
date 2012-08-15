require File.expand_path("../lib/meekster/ballot_file", File.dirname(__FILE__))

describe Meekster::BallotFile do
  it "can be initialized with a file" do
    @file = File.open(File.expand_path('ballot_files/42.blt', File.dirname(__FILE__)), 'r')
    expect {Meekster::BallotFile.new(:file => @file)}.to_not raise_error
  end

  describe "reading" do
    before(:each) do
      file = File.open(File.expand_path('ballot_files/42.blt', File.dirname(__FILE__)), 'r')
      @bf = Meekster::BallotFile.new(:file => file)
    end

    it "reads the ballot file" do
      expect {@bf.read!}.to_not raise_error
    end

    it "parses the candidates" do
      @bf.read!
      candidates = @bf.candidates

      candidates.length.should == 3
      candidates.map{|c| c.name}.should == ['Castor', 'Pollux', 'Helen']
    end

    it "parses the ballots" do
      @bf.read!
      candidates = @bf.candidates

      ballots = @bf.ballots

      ballots.length.should == 6

      rankings = ballots.map{|b| b.ranking}
      rankings.grep([candidates[0], candidates[1]]).length.should == 4
      rankings.grep([candidates[2]]).length.should == 2
    end
  end
end
