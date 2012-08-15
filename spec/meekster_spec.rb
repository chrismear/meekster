require File.expand_path("../lib/meekster", File.dirname(__FILE__))

describe "meekster" do

  describe "simplest election" do
    it "elects the candidate" do
      c1 = Meekster::Candidate.new
      c1.name = "Adam"
      candidates = [c1]

      b1 = Meekster::Ballot.new
      b1.ranking = [c1]
      ballots = [b1]

      election = Meekster::Election.new
      election.candidates = candidates
      election.ballots = ballots
      election.seats = 1

      election.run!

      c1.state.should == :elected
    end
  end

  describe "wikipedia example STV election" do
    before(:each) do
      candidates = [
        @oranges = Meekster::Candidate.new('Oranges'),
        @pears = Meekster::Candidate.new('Pears'),
        @chocolate = Meekster::Candidate.new('Chocolate'),
        @strawberries = Meekster::Candidate.new('Stawberries'),
        @sweets = Meekster::Candidate.new('Sweets')
      ]

      ballots = [
        Meekster::Ballot.new([@oranges]),
        Meekster::Ballot.new([@oranges]),
        Meekster::Ballot.new([@oranges]),
        Meekster::Ballot.new([@oranges]),
        Meekster::Ballot.new([@pears, @oranges]),
        Meekster::Ballot.new([@pears, @oranges]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @strawberries]),
        Meekster::Ballot.new([@chocolate, @sweets]),
        Meekster::Ballot.new([@chocolate, @sweets]),
        Meekster::Ballot.new([@chocolate, @sweets]),
        Meekster::Ballot.new([@chocolate, @sweets]),
        Meekster::Ballot.new([@strawberries]),
        Meekster::Ballot.new([@sweets])
      ]

      election = Meekster::Election.new
      election.candidates = candidates
      election.ballots = ballots
      election.seats = 3

      election.run!
    end

    it "elects the correct candidates" do
      @chocolate.state.should == :elected
      @oranges.state.should == :elected
      @strawberries.state.should == :elected
    end

    it "rejects the correct candidates" do
      @pears.state.should == :defeated
      @sweets.state.should == :defeated
    end
  end

  # http://code.google.com/p/droop/wiki/Droop
  describe "sample elections from Droop" do
    describe "42" do
      before(:all) do
        @election = Meekster::Election.new(
          :ballot_file => Meekster::BallotFile.new(
            :filename => File.expand_path("ballot_files/42.blt", File.dirname(__FILE__))
          )
        )
        @election.run!
      end

      it "elects the correct candidates" do
        @election.candidates.find{|c| c.name == 'Castor'}.state.should == :elected
        @election.candidates.find{|c| c.name == 'Castor'}.votes.should be_within(0.000000001).of(2.000000004)

        @election.candidates.find{|c| c.name == 'Helen'}.state.should == :elected
        @election.candidates.find{|c| c.name == 'Helen'}.votes.should be_within(0.000000001).of(2.000000000)
      end

      it "rejects the correct candidates" do
        @election.candidates.find{|c| c.name == 'Pollux'}.state.should == :defeated
      end

      it "calculates votes for the rejected candidates correctly" do
        pending('Need to fix final round') do
          @election.candidates.find{|c| c.name == 'Pollux'}.votes.should be_within(0.000000001).of(0.000000000)
        end
      end
    end
  end

end
