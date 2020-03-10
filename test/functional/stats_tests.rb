require "test_helper"

class StatsTests < ActionDispatch::IntegrationTest
  TimeOffset = Partners::Stats::ProcessCaseEvents::EventTimeOffset

  # -- stats:process-case-events --
  test "processes case events" do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require("tasks/stats")

    case1 = cases(:approved_1)
    case2 = cases(:approved_2)

    case_t1 = case1.created_at.to_i
    case_t2 = case2.created_at.to_i

    def etime(base, minutes)
      return (base + minutes * 60 - TimeOffset) * 1000
    end

    input = <<-CSV.strip_heredoc
      "name","distinct_id","time","sampling_factor","dataset","properties.$insert_id","properties.$lib_version","properties.case_is_referred","properties.case_program","properties.mp_lib","properties.mp_processing_time_ms","properties.user_id","properties.case_status","properties.is_first","properties.case_is_referral"
      "Did Become Pending","#{case1.id}",#{etime(case_t1, 2)},1,"$mixpanel","ACakkreDdwEBnDFc","2.2.1",false,"meap","ruby",1582208110812,4,,,
      "Did Open","#{case1.id}",#{etime(case_t1, 0)},1,"$mixpanel","CmtvikxbvCzCdiuw","2.2.1",false,"meap","ruby",1582208153971,14,,,
      "Did Submit","#{case1.id}",#{etime(case_t1, 3)},1,"$mixpanel","yoefpusnAvkqABFk","2.2.1",false,"meap","ruby",1582208448197,42,,,
      "Did View Dhs Form","#{case1.id}",#{etime(case_t1, 1)},1,"$mixpanel","rBzbnzysdnAzthAt","2.2.1",false,"meap","ruby",1582208110737,4,,,
      "Did View Enroller Case","#{case1.id}",#{etime(case_t1, 4)},1,"$mixpanel","lbqhrafAEczbsmxy","2.2.1",false,"meap","ruby",1582238410878,12,,,
      "Did Become Pending","#{case2.id}",#{etime(case_t2, 2)},1,"$mixpanel","dxAsftsFmtacwvmn","2.2.1",false,"meap","ruby",1583429111488,5,,,
      "Did Receive Message","#{case2.id}",#{etime(case_t2, 1)},1,"$mixpanel","fkAetxhkBdaBzgnt","2.2.1",false,"meap","ruby",1583428823098,,,true,
      "Did Receive Message","#{case2.id}",#{etime(case_t2, 2)},1,"$mixpanel","qmyxrapvfygxpDnz","2.2.1",false,"meap","ruby",1583429111366,,,false,
      "Did Submit","#{case2.id}",#{etime(case_t2, 3)},1,"$mixpanel","DwpzEADwCkccvksu","2.2.1",false,"meap","ruby",1583429736122,42,,,
      "Did View Dhs Form","#{case2.id}",#{etime(case_t2, 1)},1,"$mixpanel","CveEbrmByshsksdn","2.2.1",false,"meap","ruby",1583428822968,5,,,
      "Did View Enroller Case","#{case2.id}",#{etime(case_t2, 4)},1,"$mixpanel","nfhraauryDdqfqyc","2.2.1",false,"meap","ruby",1583430001328,12,,,
    CSV

    with_stdin(StringIO.new(input)) do
      Rake.application.invoke_task("stats:process-case-events")
    end

    stats = Stats::Repo.get.find_current

    d = stats.durations
    assert_equal(d.dhs.avg_seconds, 120)
    assert_equal(d.enroller.avg_seconds, 86220)
    assert_equal(d.recipient.avg_seconds, 120)
  end
end
