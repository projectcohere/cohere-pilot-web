class Repo
  # -- queries --
  protected def find_cached(key, &query)
    @cache ||= {}

    # check for a cache hit
    hit = @cache[key]
    if not hit.nil?
      return hit
    end

    # evaluate and cache the result
    result = query.()
    if not key.nil?
      @cache[key] = result
    end

    # also cache the entities in the result by id
    if result.is_a?(Entity) && result.id != key
      @cache[result.id] = result
    elsif result.respond_to?(:each)
      result.each do |entity|
        @cache[entity.id] = entity
      end
    end

    result
  end

  # -- factories --
  protected def entity_from(record, *associations)
    if record.nil?
      nil
    else
      self.class.map_record(record, *associations)
    end
  end
end
