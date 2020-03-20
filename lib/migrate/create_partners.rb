def execute(sql)
  ActiveRecord::Base.connection.execute(sql)
end

# -- constants --
P = Program::Name
M = Partner::MembershipClass

# -- migrations --
execute <<-SQL
  BEGIN;

  -- migrations/cohere
  INSERT INTO partners (name, membership_class)
  SELECT 'Cohere', #{M.index(M::Cohere)};

  UPDATE users AS u
  SET partner_id = p.id
  FROM partners AS p
  WHERE u.organization_type = 'cohere' AND p.name = 'Cohere';

  -- migrations/governors
  INSERT INTO partners (name, membership_class)
  SELECT 'MDHHS', #{M.index(M::Governor)};

  UPDATE users AS u
  SET partner_id = p.id
  FROM partners AS p
  WHERE u.organization_type = 'dhs' AND p.name = 'MDHHS';

  -- migrations/suppliers
  INSERT INTO partners (name, membership_class, programs)
  SELECT name, #{M.index(M::Supplier)}, Array[program]
  FROM suppliers;

  UPDATE users AS u
  SET partner_id = p.id
  FROM partners AS p, suppliers as s
  WHERE u.organization_type = 'Supplier::Record' AND s.id = u.organization_id AND s.name = p.name;

  -- migrations/enrollers
  INSERT INTO partners (name, membership_class, programs)
  SELECT name, #{M.index(M::Enroller)}, Array[#{P.index(P::Meap)}, #{P.index(P::Wrap)}]
  FROM enrollers;

  UPDATE users AS u
  SET partner_id = p.id
  FROM partners AS p, enrollers as e
  WHERE u.organization_type = 'Enroller::Record' AND e.id = u.organization_id AND e.name = p.name;

  COMMIT;
SQL
