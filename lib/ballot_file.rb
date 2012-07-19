require File.expand_path('ballot', File.dirname(__FILE__))
require File.expand_path('candidate', File.dirname(__FILE__))

class BallotFile
  attr_accessor :candidates, :ballots, :seats

  def initialize(options={})
    if options[:filename]
      @file = File.open(options[:filename], 'r')
    elsif options[:string]
      @file = StringIO.new(options[:string])
    elsif options[:file]
      @file = options[:file]
    end
  end

  def read!
    @file.rewind

    @ballots = []
    
    candidates_and_seats = @file.gets
    @candidate_count, @seats = candidates_and_seats.split(' ').map{|n| n.to_i}

    @candidates = Array.new(@candidate_count){Candidate.new}

    ballot_line = @file.gets

    until ballot_line.match(/^0/)
      line_atoms = ballot_line.split(' ')
      
      count = line_atoms.delete_at(0).to_i
      line_atoms.delete_at(-1)

      ranking = line_atoms.map{|id| @candidates[id.to_i - 1]}

      count.times do
        @ballots << Ballot.new(ranking)
      end

      ballot_line = @file.gets
    end

    @candidate_count.times do |i|
      candidate_name = @file.gets.strip
      # Remove double-quotes
      candidate_name = candidate_name.match(/\A\"(.*)\"\Z/)[1]
      @candidates[i].name = candidate_name
    end
  end
end
