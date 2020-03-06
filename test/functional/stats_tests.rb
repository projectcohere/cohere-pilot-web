require "test_helper"

class StatsTests < ActionDispatch::IntegrationTest
  # -- stats:process-case-events --
  test "processes case events" do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require("tasks/stats")

    case_id_1 = cases(:approved_1).id
    case_id_2 = cases(:approved_2).id

    input = <<-CSV.strip_heredoc
      "name","distinct_id","time","sampling_factor","dataset","properties.$insert_id","properties.$lib_version","properties.case_is_referred","properties.case_program","properties.mp_lib","properties.mp_processing_time_ms","properties.user_id","properties.case_status","properties.is_first","properties.case_is_referral"
      "Did Become Pending","#{case_id_1}",1582179257000,1,"$mixpanel","ACakkreDdwEBnDFc","2.2.1",false,"meap","ruby",1582208110812,4,,,
      "Did Open","#{case_id_1}",1582179128000,1,"$mixpanel","CmtvikxbvCzCdiuw","2.2.1",false,"meap","ruby",1582208153971,14,,,
      "Did Submit","#{case_id_1}",1582179484000,1,"$mixpanel","yoefpusnAvkqABFk","2.2.1",false,"meap","ruby",1582208448197,42,,,
      "Did View Dhs Form","#{case_id_1}",1582179192000,1,"$mixpanel","rBzbnzysdnAzthAt","2.2.1",false,"meap","ruby",1582208110737,4,,,
      "Did View Enroller Case","#{case_id_1}",1582209519000,1,"$mixpanel","lbqhrafAEczbsmxy","2.2.1",false,"meap","ruby",1582238410878,12,,,
      "Did Become Pending","#{case_id_2}",1583400071000,1,"$mixpanel","dxAsftsFmtacwvmn","2.2.1",false,"meap","ruby",1583429111488,5,,,
      "Did Receive Message","#{case_id_2}",1583399983000,1,"$mixpanel","fkAetxhkBdaBzgnt","2.2.1",false,"meap","ruby",1583428823098,,,true,
      "Did Receive Message","#{case_id_2}",1583400036000,1,"$mixpanel","qmyxrapvfygxpDnz","2.2.1",false,"meap","ruby",1583429111366,,,false,
      "Did Submit","#{case_id_2}",1583400879000,1,"$mixpanel","DwpzEADwCkccvksu","2.2.1",false,"meap","ruby",1583429736122,42,,,
      "Did View Dhs Form","#{case_id_2}",1583399879000,1,"$mixpanel","CveEbrmByshsksdn","2.2.1",false,"meap","ruby",1583428822968,5,,,
      "Did View Enroller Case","#{case_id_2}",1583401171000,1,"$mixpanel","nfhraauryDdqfqyc","2.2.1",false,"meap","ruby",1583430001328,12,,,
    CSV

    with_stdin(StringIO.new(input)) do
      Rake.application.invoke_task("stats:process-case-events")
    end

    stats = Stats::Repo.get.find_current
    binding.pry
    assert_equal(stats.durations.count, 1)
  end
end
