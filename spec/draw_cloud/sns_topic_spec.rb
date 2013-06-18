require 'spec_helper'

describe DrawCloud::SNSTopic do
  subject { DrawCloud::SNSTopic.new(:test) }

  it "should be an SNSTopic" do
    expect(subject).to be_an_instance_of DrawCloud::SNSTopic
  end

  it "returns itself when asked for sns_topic" do
    subject.sns_topic.should == subject
  end

  describe "resource_name" do
    it "returns a styled name with SNSTopic appended" do
      subject.resource_name.should == "TestSNSTopic"
    end
  end

  describe "to_h" do
    it "should turn itself into a hash" do
      expect(subject.to_h).to be_an_instance_of Hash
    end

    it "should have a type key matching AWS::SNS::Topic" do
      subject.to_h['Type'].should == "AWS::SNS::Topic"
    end

    it "may have a DisplayName" do
      subject.display_name = "A Display Name"
      subject.to_h["Properties"]['DisplayName'].should == "A Display Name"
    end

    it "may not have a DisplayName" do
      subject.to_h["Properties"]['DisplayName'].should == nil
    end

    it "should include subscriptions" do
      subject.add_subscription("me@example.com", "email")
      subject.to_h["Properties"]['Subscription'].should == [{"Endpoint" => "me@example.com", "Protocol" => "email"}]
    end

    it "should allow multiple subscriptions" do
      subject.add_subscription("me@example.com", "email")
      subject.add_subscription("you@test.com", "sqs")
      subject.to_h["Properties"]['Subscription'].should == [{"Endpoint" => "me@example.com", "Protocol" => "email"}, {"Endpoint" => "you@test.com", "Protocol" => "sqs"}]
    end
  end
end
