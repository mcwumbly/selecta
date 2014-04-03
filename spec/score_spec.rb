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
      score("/! symbols $^", "/!$^").should be < Float::INFINITY
    end

    it "is case insensitive" do
      x = score("a", "a")
      y = score("a", "A")
      z = score("A", "a")
      w = score("A", "A")
      x.should == y
      y.should == z
      z.should == w
    end

    it "doesn't match when the same letter is repeated in the choice" do
      score("a", "aa").should == Float::INFINITY
    end
  end

  describe "match quality" do
    it "scores higher for better matches" do
      score("reason", "eas").should == "eas".length
      score("beagles", "eas").should == "eagles".length

      score("README", "em").should == "EADM".length
      score("benchmark", "em").should == "enchm".length
    end

    it "sometimes scores longer strings higher if they have a better match" do
      score("xlong12long", "12").should == "12".length
      score("x1long2", "12").should == "1long2".length
    end

    it "scores the tighter of two matches, regardless of order" do
      tight = "a12"
      loose = "a1b2"
      score(tight + loose, "12").should == "12".length
      score(loose + tight, "12").should == "12".length
    end

    it "scores characters at word boundaries higher" do
      score("foo/bar", "ob").should == 1
      score("foobar", "ob").should == 2
    end
  end
end
