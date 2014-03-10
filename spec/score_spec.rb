require_relative "spec_helper"

describe "score" do
  def score(choice, query)
    Score.score(choice, query)
  end

  describe "basic matching" do
    it "scores infinity when the choice is empty" do
      score("", "a").should == Float::INFINITY
    end

    it "scores 0 when the query is empty" do
      score("a", "").should == 0.0
    end

    it "scores infinity when the query is longer than the choice" do
      score("short", "longer").should == Float::INFINITY
    end

    it "scores infinity when the query doesn't match at all" do
      score("a", "b").should == Float::INFINITY
    end

    it "scores infinity when only a prefix of the query matches" do
      score("ab", "ac").should == Float::INFINITY
    end

    it "scores less than infinity when it matches" do
      score("a", "a").should be < Float::INFINITY
      score("ab", "a").should be < Float::INFINITY
      score("ba", "a").should be < Float::INFINITY
      score("bab", "a").should be < Float::INFINITY
      score("babababab", "aaaa").should be < Float::INFINITY
    end

    it "scores the length of the query when the query is a substring" do
      score("xa", "a").should == "a".length
      score("xab", "ab").should == "ab".length
      score("xalongstring", "alongstring").should == "alongstring".length
      score("lib/search.rb", "earc").should == "earc".length
    end
  end

  describe "character matching" do
    it "matches punctuation" do
      score("/! symbols $^", "/!$^").should be > 0.0
    end

    it "is case insensitive" do
      score("a", "A").should == 1.0
      score("A", "a").should == 1.0
    end

    it "doesn't match when the same letter is repeated in the choice" do
      score("a", "aa").should == Float::INFINITY
    end
  end

  describe "match quality" do
    it "scores higher for better matches" do
      score("selecta.gemspec", "asp").should be < score("algorithm4_spec.rb", "asp")
      score("README.md", "em").should be < score("benchmark.rb", "em")
    end

    it "sometimes scores longer strings higher if they have a better match" do
      score("long12long", "12").should be < score("1long2", "12")
    end

    it "scores the tighter of two matches, regardless of order" do
      tight = "12"
      loose = "1padding2"
      score(tight + loose, "12").should == 2
      score(loose + tight, "12").should == 2
    end

    it "scores characters at word boundaries higher" do
      score("foo/bar", "ba").should be < score("foobar", "ba")
    end
  end
end
