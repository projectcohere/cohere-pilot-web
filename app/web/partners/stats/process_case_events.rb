require "csv"

module Partners
  module Stats
    class ProcessCaseEvents < ::Command
      # -- types --
      Interval = Struct.new(
        :start,
        :end,
      )

      class Intervals < ::Value
        prop(:case_id)
        prop(:dhs, default: Interval.new)
        prop(:enroller, default: Interval.new)
        prop(:recipient, default: Interval.new)
      end

      # -- lifetime --
      def initialize(
        stats_repo: ::Stats::Repo.get,
        case_repo: ::Case::Repo.get
      )
        @stats_repo = stats_repo
        @case_repo = case_repo
      end

      # -- command --
      def call(io)
        lines = io.each_line

        # parse headers
        headers = CSV.parse_line(lines.next, converters: -> (h) {
          h.delete_prefix!("properties.")
          h.delete_prefix!("$")
          h.to_sym
        })

        # aggreagte intervals by case id
        intervals_by_case_id = {}

        # parse events and aggregate into intervals
        lines.each do |line|
          row = CSV.parse_line(line, headers: headers)
          if row[:case_program]&.to_sym != :meap
            next
          end

          # create case if necessary
          intervals = begin
            case_id = row[:distinct_id].to_i
            intervals_by_case_id[case_id] ||= Intervals.new(case_id: case_id)
          end

          # update case based on event
          time = row[:time].to_i / 1000

          case row[:name].to_sym
          when :"Did Open"
            intervals.dhs.start = time if !row[:case_is_referred]
          when :"Did Become Pending"
            intervals.dhs.end = time
          when :"Did Receive Message"
            intervals.recipient.start = time if row[:is_first]
          when :"Did Submit"
            intervals.recipient.end = time
            intervals.enroller.start = time
          when :"Did Complete"
            intervals.enroller.end = time
          end
        end

        # supplement unpopulated cases with data from db records
        cases = @case_repo.find_all_by_ids(
          intervals_by_case_id.map { |_, i| rescuable?(i) ? i.case_id : nil }.compact,
        )

        cases.each do |kase|
          intervals = intervals_by_case_id[kase.id.val]
          intervals.dhs.start = kase.created_at.to_i
          intervals.enroller.end = kase.completed_at.to_i
        end

        # filter unpopulated intervals
        populated = intervals_by_case_id.values.filter do |intervals|
          populated?(intervals)
        end

        # save new durations
        durations = ::Stats::Durations.new(
          count: populated.count,
          dhs: ::Stats::Duration.new(
            avg_seconds: median(populated.map { |i| i.dhs })
          ),
          enroller: ::Stats::Duration.new(
            avg_seconds: median(populated.map { |i| i.enroller })
          ),
          recipient: ::Stats::Duration.new(
            avg_seconds: median(populated.map { |i| i.recipient })
          ),
        )

        @stats_repo.save_durations(durations)
      end

      def rescuable?(intervals)
        return ((
          intervals.dhs.end != nil &&
          intervals.enroller.start != nil &&
          intervals.recipient.start != nil &&
          intervals.recipient.end != nil
        ) && (
          intervals.dhs.start == nil ||
          intervals.enroller.end == nil
        ))
      end

      def populated?(intervals)
        return (
          intervals.dhs.start != nil &&
          intervals.dhs.end != nil &&
          intervals.enroller.start != nil &&
          intervals.enroller.end != nil &&
          intervals.recipient.start != nil &&
          intervals.recipient.end != nil
        )
      end

      def median(intervals)
        if intervals.length == 0
          return nil
        end

        sorted = intervals.map { |i| i.end - i.start }.sort
        length = sorted.length
        median = (sorted[(length - 1) / 2] + sorted[length / 2]) / 2.0
        return median.round
      end
    end
  end
end
