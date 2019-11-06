class Case
  module Notes
    class OpenedCase
      def initialize(
        case_id,
        user_id,
        users: User::Repo.get,
        cases: Case::Repo.get
      )
        # dependencies
        @users = users
        @cases = cases

        # props
        @case_id = case_id
        @user_id = user_id
      end

      # -- queries --
      def title
        "Cohere Pilot -- A new case was opened!"
      end

      # -- queries/entities
      def case
        @case ||= @cases.find_one(@case_id)
      end

      def recipient_name
        @case.recipient.profile.name
      end

      def receiver
        @receiver ||= @users.find_one(@user_id)
      end

      def receiver_email
        receiver.email
      end

      # -- broadcast --
      class Broadcast
        def initialize(users: User::Repo.get)
          @users = users
        end

        # -- broadcast/queries
        def receiver_ids
          @users.find_opened_case_contributors.map(&:id)
        end
      end
    end
  end
end
