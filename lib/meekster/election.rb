require 'bigdecimal'
require File.expand_path('../round', __FILE__)

class Election
  attr_accessor :ballots, :candidates, :seats

  def initialize(parameters={})
    if parameters[:ballot_file]
      bf = parameters[:ballot_file]
      bf.read! unless bf.read?
      self.ballots = bf.ballots
      self.candidates = bf.candidates
      self.seats = bf.seats
    end
    if parameters[:ballots]
      self.ballots = parameters[:ballots]
    end
    if parameters[:candidates]
      self.candidates = parameters[:candidates]
    end
    if parameters[:seats]
      self.seats = parameters[:seats]
    end
  end



  def run!
    raise RuntimeError, "ballots not found" unless ballots
    raise RuntimeError, "candidates not found" unless candidates
    raise RuntimeError, "seats not found" unless seats

    candidates.each do |candidate|
      candidate.state = :hopeful
    end

    @omega = BigDecimal("0.000001")

    @rounds = []

    while true do

      round = Round.new(
        :ballots => ballots,
        :candidates => candidates,
        :seats => seats,
        :omega => @omega
      )

      round.run!

      break if round.count_complete?

      @rounds.push(round)
    end

    elected_candidates_count = candidates.select{|c| c.state == :elected}.length
    hopeful_candidates = candidates.select{|c| c.state == :hopeful}
    if elected_candidates_count < seats
      hopeful_candidates.each do |hopeful_candidate|
        hopeful_candidate.state = :elected
      end
    else
      hopeful_candidates.each do |hopeful_candidate|
        hopeful_candidate.state = :defeated
      end
    end

    candidates
  end

  def results
    output = ""
    elected_candidates = candidates.select{|c| c.state == :elected}.sort{|a, b| a.votes <=> b.votes}
    defeated_candidates = candidates.select{|c| c.state == :defeated}.sort{|a, b| a.name <=> b.name}

    elected_candidates.each do |ec|
      output << "Elected: #{ec.name} (#{ec.votes.to_f})\n"
    end
    output << "Defeated: "
    output << defeated_candidates.map{|dc| dc.name}.join(', ')
    output << "\n"
    output
  end
end
