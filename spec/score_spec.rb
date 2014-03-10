require_relative "spec_helper"

describe "score" do
  def score(choice, query)
    Score.score(choice, query)
  end

  describe "basic matching" do
    it "scores 0 when the choice is empty" do
      score("", "a").should == 0
    end

    it "scores 1 when the query is empty" do
      score("a", "").should == 1
    end

    it "scores 0 when the query is longer than the choice" do
      score("short", "longer").should == 0
    end

    it "scores 0 when the query doesn't match at all" do
      score("a", "b").should == 0
    end

    it "scores 0 when only a prefix of the query matches" do
      score("ab", "ac").should == 0
    end

    it "scores greater than 0 when it matches" do
      score("a", "a").should be > 0
      score("ab", "a").should be > 0
      score("ba", "a").should be > 0
      score("bab", "a").should be > 0
      score("babababab", "aaaa").should be > 0
    end

    it "scores 1 when the choice contains the exact substring" do
      score("a", "a").should == 1.0
      score("ab", "ab").should == 1.0
      score("a long string", "a long string").should == 1.0
      score("spec/search_spec.rb", "sear").should == 1.0
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
      score("a", "aa").should == 0.0
    end
  end

  describe "match quality" do
    it "scores higher for better matches" do
      score("selecta.gemspec", "asp").should be > score("algorithm4_spec.rb", "asp")
      score("README.md", "em").should be > score("benchmark.rb", "em")
    end

    it "sometimes scores longer strings higher if they have a better match" do
      score("long 12 long", "12").should be > score("1 long 2", "12")
    end

    it "scores the tighter of two matches, regardless of order" do
      tight = "12"
      loose = "1padding2"
      score(tight + loose, "12").should == 1.0
      score(loose + tight, "12").should == 1.0
    end
  end

  xit "prefers acronyms to normal matches" do
    score("Foo Bar", "fb").should be > score("foo bar", "fb")
  end
end
