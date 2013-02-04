require "spec_helper"
require "microformats2"

describe Microformats2 do
  describe "::parse" do
    it "returns an array of found microformats" do
      html = "spec/support/simple.html"
      Microformats2.parse(html).should == ["YAY MICROFORMAT"]
    end
  end
  describe "::read_html" do
    before do
      @html = <<-HTML.strip
        <div class="h-card"><p class="p-name">Jessica Lynn Suttles</p></div>
      HTML
    end
    it "can be a string of html" do
      Microformats2.read_html(@html).should include @html
    end
    it "can be a file path to html" do
      html = "spec/support/simple.html"
      Microformats2.read_html(html).should include @html
    end
    it "can be a url to html" do
      html = "http://google.com"
      Microformats2.read_html(html).should include "google"
    end
  end
end
