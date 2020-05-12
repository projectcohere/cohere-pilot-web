require "test_helper"

class CaseNotesTests < ActionDispatch::IntegrationTest
  # -- create --
  test "can't add a case note without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      post("/cases/3/notes")
    end

    assert_raises(ActionController::RoutingError) do
      post(auth("/cases/3/notes", as: user_rec))
    end
  end

  test "add a case note as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_1)

    act = -> do
      post(auth("/cases/#{case_rec.id}/notes", as: user_rec), params: {
        case_note: { body: "Test note." },
      })
    end

    assert_difference(
      -> { Case::Note::Record.count } => 1,
      &act
    )
  end

  test "can't add a case note to another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      post(auth("/cases/#{case_rec.id}/notes", as: user_rec), params: {
        case_note: { body: "Ignored." },
      })
    end
  end

  test "add a case note as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    act = -> do
      post(auth("/cases/#{case_rec.id}/notes", as: user_rec), params: {
        case_note: { body: "Test note." },
      })
    end

    assert_difference(
      -> { Case::Note::Record.count } => 1,
      &act
    )
  end
end
