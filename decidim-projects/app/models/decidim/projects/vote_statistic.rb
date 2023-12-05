# frozen_string_literal: true

module Decidim
  module Projects
    # VoteStatistic is the model that gathers statistics for every attempt
    # of users voting
    class VoteStatistic < ApplicationRecord
      belongs_to :vote_card,
                 class_name: "Decidim::Projects::VoteCard",
                 foreign_key: :vote_card_id

      # Public class method that closes all of open voting statistics
      # with time set as 30 minutes after last step entry or creation time
      def self.close_all!
        self.where(finished_voting_time: nil).each do |s|
          time = if s.voting_timetable.any?
            last_entry = s.voting_timetable.map { |key, v| key }.last
            s.voting_timetable[last_entry].map { |view_name, entrance_time| entrance_time }.first.to_time || s.created_at
          else
            s.created_at
          end
          s.update_column('finished_voting_time', time + 30.minutes)
        end
      end

      # Public method it adds to the voting_timetable Hash new values
      # - Keys are numbers that show order of visited views
      # - Values ate Hashes of with voting wizard steps (Decidim::Project::Wizard::TIMETABLE) as keys
      #   and times of entry for every view (refresh likewise)
      #
      # returns nothing
      def add_new_time!(key, time)
        self.voting_timetable[voting_timetable.size] = { key => time }
        save
      end

      # Public method that finishes statistic setting time of finish
      #
      # returns nothing
      def finish!
        update(finished_voting_time: DateTime.current)
      end

      def time_spent_in_district_voting
        return 0 if voting_timetable.empty?

        step_summed_time(Decidim::Projects::VotingWizard::STEPS::DISTRICT_LIST)
      end

      def time_spent_in_global_voting
        return 0 if voting_timetable.empty?

        step_summed_time(Decidim::Projects::VotingWizard::STEPS::GLOBAL_SCOPE_LIST)
      end

      def time_spent_in_whole_voting
        return 'Głosowanie nie zostalo jeszcze przerwane' if finished_voting_time.blank?

        Time.at(finished_voting_time - created_at).utc.strftime("%kh %Mm %Ss")
      end

      private

      # Private method that maps all ythe keys that hold Hash with a given string as a key
      #
      # returns Array
      def all_entries_for_step(key)
        main_keys = []
        voting_timetable.each do |main_key, step_key|
          main_keys << main_key if voting_timetable.dig(main_key, key)
        end

        # voting_timetable.select { |k,v| main_keys.include?(k) }
        main_keys
      end

      # Private method mapiing times for every step
      # keys - Array of keys that hold time value for given step
      # step - name for inner Hash key (to retrieve time value)
      #
      # Method iterates voting_timetable Hash and pairs time from the provided key,
      # with the time from next entry no matter the key.
      #
      # returns Array[Array] => [[Time, Time], [Time, Time]]
      def pair_up_time_with_keys(keys, step)
        pairs = []
        keys.each do |key|
          pairs << if voting_timetable["#{key.to_i + 1}"]
                    [voting_timetable.dig(key, step).to_time, voting_timetable["#{key.to_i + 1}"].map { |k, v| v }.first.to_time]
                  else
                    [voting_timetable.dig(key, step).to_time, finished_voting_time&.to_time.presence || Time.now]
                  end
        end
        pairs
      end

      # Private method that provided given step name, returns summed up time for all the entries.
      #
      # Returns String: outcome of the time_count method
      def step_summed_time(step)
        keys = all_entries_for_step(step)
        return 0 if keys.none?

        pairs = pair_up_time_with_keys(keys, step)
        time_count(pairs.first.first.to_time, pairs.first.last.to_time, pairs[1..-1])
      end

      # Private method parsing date time parematers into a time period
      #
      #  start_time - DateTime from which we start counting
      #  end_time - DateTime from which we start counting
      #  pairs - variable takes Arrays of two elements, that are Time objects -> [[Time, Time], [Time, Time]]
      #
      # Returns string that holds info about summed up times of all the pairs
      def time_count(time_start, time_end, *pairs)
        return 0 if time_start.blank? || time_end.blank?
        return 0 unless time_start.is_a?(Time) || time_start.is_a?(DateTime)
        return 0 unless time_end.is_a?(Time) || time_end.is_a?(DateTime)

        initial_pair = Time.at(time_end - time_start).utc
        if pairs.none?
          initial_pair.strftime("%kh %Mm %Ss")
        else
          # we pass a whole Array of arrays, not individual Arrays of two elements
          pairs.first.each_with_index do |pair, i|
            next unless pair.is_a?(Array)
            next unless pair.size == 2
            next unless pair.first.is_a?(Time) || pair.first.is_a?(DateTime)
            next unless pair.last.is_a?(Time) || pair.last.is_a?(DateTime)

            counted_pair_time = time_count(pair.first.to_time, pair.last.to_time)
            initial_pair = add_times(initial_pair, counted_pair_time)
          end
        end
        initial_pair.strftime("%kh %Mm %Ss")
      end

      # Private method adding stringified time to Time
      #
      #  time - Time
      #  stringified_time - Time in a stringified form: strftime("%kh %Mm %Ss %Ss")
      #  pairs - variable takes Arrays of two elements, that are Time objects
      #
      # Returns Time
      def add_times(time, stringified_time)
        hours = stringified_time.split(' ').first.to_i # '1h' -> 1
        minutes = stringified_time.split(' ')[1].to_i # '1m' -> 1
        seconds = stringified_time.split(' ').last.to_i # '1s' -> 1

        (time + hours.hours + minutes.minutes + seconds.seconds)
      end
    end
  end
end
