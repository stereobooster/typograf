# encoding: utf-8
require 'typograf'
require 'rspec'

describe Typograf do
  it ".process" do
    Typograf.process("- Это \"Типограф\"?\n— Нет, это «Типограф»!").should eq "<p>&mdash;&nbsp;Это &laquo;Типограф&raquo;?<br />\n&mdash;&nbsp;Нет, это &laquo;Типограф&raquo;!</p>"
  end

  it ".process support options" do
    Typograf.process("- Это \"Типограф\"?\n— Нет, это «Типограф»!", :paragraph => {:insert => 0}).should eq "&mdash;&nbsp;Это &laquo;Типограф&raquo;?<br />\n&mdash;&nbsp;Нет, это &laquo;Типограф&raquo;!"
  end

  it ".process support nowraped and symbols options" do
    Typograf.process("В  этом   тексте \t много пробелов.", :nowraped => {:nonbsp => 0}, :paragraph => {:insert => 0}, :symbols => 2 ).should eq 'В этом тексте много пробелов.'
  end

  it "should raise 404 error" do
    lambda {Typograf.process("Тест", :url => 'http://www.typograf.ru/404')}.should raise_error Typograf::NetworkError
  end

  # TODO: mock server for offline testing, for detecting service change
  # TODO: test every option
end

describe Typograf::Client do
  it ".deep_merge"
  it ".form_xml"
end