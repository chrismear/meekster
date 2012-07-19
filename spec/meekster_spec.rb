require './meekster'

describe "meekster" do

  describe "simplest election" do
    it "elects the candidate" do
      c1 = Candidate.new
      c1.name = "Adam"
      candidates = [c1]

      b1 = Ballot.new
      b1.ranking = [c1]
      ballots = [b1]

      election = Election.new
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
        @oranges = Candidate.new('Oranges'),
        @pears = Candidate.new('Pears'),
        @chocolate = Candidate.new('Chocolate'),
        @strawberries = Candidate.new('Stawberries'),
        @sweets = Candidate.new('Sweets')
      ]

      ballots = [
        Ballot.new([@oranges]),
        Ballot.new([@oranges]),
        Ballot.new([@oranges]),
        Ballot.new([@oranges]),
        Ballot.new([@pears, @oranges]),
        Ballot.new([@pears, @oranges]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @strawberries]),
        Ballot.new([@chocolate, @sweets]),
        Ballot.new([@chocolate, @sweets]),
        Ballot.new([@chocolate, @sweets]),
        Ballot.new([@chocolate, @sweets]),
        Ballot.new([@strawberries]),
        Ballot.new([@sweets])
      ]

      election = Election.new
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

end
