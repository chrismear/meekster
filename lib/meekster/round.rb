require 'bigdecimal'

class Round
  attr_accessor :ballots, :candidates, :seats, :omega, :quota, :surplus

  def initialize(parameters={})
    self.ballots = parameters[:ballots]
    self.candidates = parameters[:candidates]
    self.seats = parameters[:seats]
    self.omega = parameters[:omega]

    @candidate_elected_this_round = false
  end

  def run!
    if count_complete?
      return # actually return something?
    end

    @previous_surpluses = []

    while true do
      log "STARTING NEW ITERATION"

      log "Keep factors:"
      candidates.each do |candidate|
        log "  #{candidate.name} | #{candidate.keep_factor.to_f}"
      end

      reset_votes!

      distribute_votes!

      log "Counted votes:"
      candidates.each do |candidate|
        log "  #{candidate.name} | #{candidate.votes.to_f}"
      end


      update_quota!
      find_winners!
      calculate_total_surplus!

      if candidate_elected_this_round?
        return
      end

      if need_to_defeat_low_candidate?
        defeat_low_candidate!
        return
      end

      update_keep_factors!
    end
  end

  def count_complete?
    # Are all seats filled?
    elected_candidates_count = candidates.select{|c| c.state == :elected}.length
    if elected_candidates_count >= seats
      log "Count complete: enough elected candidates to fill the seats"
      return true
    end

    # Is number of elected plus hopeful candidates less than or equal to number of seats?
    hopeful_candidates_count = candidates.select{|c| c.state == :hopeful}.length
    if (elected_candidates_count + hopeful_candidates_count) <= seats
      log "Count complete: elected+hopeful candidates less than or equal to seats"
      return true
    end

    false
  end

  def reset_votes!
    candidates.each do |candidate|
      candidate.votes = BigDecimal('0')
    end
  end

  def distribute_votes!
    ballots.each do |ballot|
      ballot.weight = BigDecimal('1')
      
      ballot.ranking.each do |ranked_candidate|

        weight_times_keep_factor = ballot.weight * ranked_candidate.keep_factor
        weight_times_keep_factor = Round.round_up_to_nine_decimal_places(weight_times_keep_factor)

        ranked_candidate.votes += weight_times_keep_factor

        ballot.weight -= weight_times_keep_factor

        break if ballot.weight <= 0
      end
    end
  end

  def update_quota!
    sum_of_votes = candidates.inject(BigDecimal('0')){|sum, c| sum + c.votes}
    new_quota = sum_of_votes / (seats + 1)
    # TODO truncate to nine decimal places
    new_quota += BigDecimal('0.000000001')
    log "Updating quota: #{new_quota.to_f}"
    self.quota = new_quota
  end

  def find_winners!
    candidates.select{|c| c.state == :hopeful}.each do |candidate|
      if candidate.votes >= quota
        log "Found winner: #{candidate.name}"
        candidate.state = :elected
        @candidate_elected_this_round = true
      end
    end
  end

  def calculate_total_surplus!
    elected_candidates = candidates.select{|c| c.state == :elected}
    sum_of_surpluses = elected_candidates.inject(BigDecimal('0')){|memo, c| memo + (c.votes - quota)}
    log "Calculating total surplus. Sum of surpluses: #{sum_of_surpluses.to_f}"
    if sum_of_surpluses < 0
      self.surplus = 0
      @previous_surpluses.push(surplus)
    else
      self.surplus = sum_of_surpluses
      @previous_surpluses.push(surplus)
    end
  end

  def candidate_elected_this_round?
    !!@candidate_elected_this_round
  end

  def need_to_defeat_low_candidate?
    if surplus < omega
      log "Need to defeat low candidate."
      return true
    end

    if @previous_surpluses.length > 1 && (surplus >= @previous_surpluses[-2])
      log "Need to defeat low candidate (surplus greater than previous iteration)."
      return true
    end

    log "Do not need to defeat low candidate."
    false
  end

  def defeat_low_candidate!
    log "Defeating lowest candidate:"
    hopeful_candidates = candidates.select{|c| c.state == :hopeful}
    candidate_with_lowest_vote = nil
    hopeful_candidates.each do |hopeful_candidate|
      if candidate_with_lowest_vote.nil? || hopeful_candidate.votes < candidate_with_lowest_vote.votes
        candidate_with_lowest_vote = hopeful_candidate
      end
    end

    log "  Lowest candidate: #{candidate_with_lowest_vote.name}"

    # Detect ties

    hopeful_candidates.delete(candidate_with_lowest_vote)
    tied_candidates = hopeful_candidates.select{|c| c.votes <= (candidate_with_lowest_vote.votes + surplus)}

    if tied_candidates.empty?
      candidate_to_defeat = candidate_with_lowest_vote
    else
      candidates_with_lowest_votes = tied_candidates
      candidates_with_lowest_votes.push(candidate_with_lowest_vote)
      candidate_to_defeat = tiebreaker_select(candidates_with_lowest_votes)
    end

    candidate_to_defeat.state = :defeated
    candidate_to_defeat.keep_factor = BigDecimal.new('0')
  end

  def update_keep_factors!
    log "Updating keep factors:"
    elected_candidates = candidates.select{|c| c.state == :elected}
    quota_rounded = Round.round_up_to_nine_decimal_places(quota)
    elected_candidates.each do |elected_candidate|
      elected_candidate_votes_rounded = Round.round_up_to_nine_decimal_places(elected_candidate.votes)
      new_keep_factor = elected_candidate.keep_factor * quota_rounded
      new_keep_factor = new_keep_factor / elected_candidate_votes_rounded
      log "  Candidate #{elected_candidate.name}: #{elected_candidate.keep_factor.to_f} -> #{new_keep_factor.to_f}"
      elected_candidate.keep_factor = new_keep_factor
    end
  end

  def self.round_up_to_nine_decimal_places(x)
    ((x * BigDecimal('1E9')).ceil)/BigDecimal('1E9')
  end

  def self.truncate_to_nine_decimal_places(x)
    ((x * BigDecimal('1E9')).floor)/BigDecimal('1E9')
  end

  def tiebreaker_select(array)
    array[rand(array.length)]
  end

  # DEBUGGING

  def log(msg)
    return # Comment out to enable debugging
    puts msg
    gets
  end
end
