class Recipient
  class Repo
    # -- queries --
    # -- queries/one
    def find_one(id)
      record = Recipient::Record
        .find(id)

      entity_from(record)
    end

    def find_one_by_phone_number(phone_number)
      record = Recipient::Record
        .find_by(phone_number: phone_number)

      entity_from(record)
    end

    # -- commands --
    def save_registered(recipient)
      # create or update the db record
      record = recipient.record
      if record.nil?
        record = Recipient::Record.new
      end

      # write to the record
      recipient.profile.tap do |p|
        record.assign_attributes(
          phone_number: p.phone.number,
        )
      end

      recipient.profile.name.tap do |n|
        record.assign_attributes(
          first_name: n.first,
          last_name: n.last,
        )
      end

      recipient.profile.address.tap do |a|
        record.assign_attributes(
          street: a.street,
          street2: a.street2,
          city: a.city,
          state: a.state,
          zip: a.zip
        )
      end

      record.save!

      # send save events back to the domain object
      recipient.did_save(record)
    end

    def save_new_documents(recipient)
      if recipient.record.nil?
        raise "unsaved recipient can't be updated with new doucments!"
      end

      documents = recipient.new_documents
      if documents.empty?
        return
      end

      records = recipient.record.documents.create!(documents.map { |d|
        { source_url: d.source_url }
      })

      records.each_with_index do |r, i|
        documents[i].did_save(r)
      end
    end

    # -- helpers --
    private def entity_from(record)
      record.nil? ? nil : Repo.map_entity(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end

    # -- factories --
    def self.map_entity(r)
      Recipient.new(
        record: r,
        id: r.id,
        profile: Profile.new(
          phone: Phone.new(
            number: r.phone_number
          ),
          name: Name.new(
            first: r.first_name,
            last: r.last_name
          ),
          address: Address.new(
            street: r.street,
            street2: r.street2,
            city: r.city,
            state: r.state,
            zip: r.zip
          ),
        ),
        dhs_account: DhsAccount.new(
          number: r.dhs_number,
          household: r.household&.then { |h|
            Household.new(
              size: h.size,
              income_history: h.income_history.map { |a|
                Income.new(**a.symbolize_keys)
              }
            )
          }
        ),
        documents: r.documents.map { |d|
          Document::from_record(d)
        }
      )
    end
  end
end
