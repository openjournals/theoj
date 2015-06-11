require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do

  class TestMailer < ApplicationMailer
    def test(user)
      mail to:user, subject:'A Subject' do |format|
        format.text { render plain: "[Inserted Text]", layout:'mailer' }
        format.html { render html: "[Inserted HTML]" , layout:'mailer' }
      end
    end
  end

  let(:user) { create(:user, name:'Joe Smith', email:'jsmith@example.com') }
  let(:mail) { TestMailer.test(user) }

  it "sets the from and to addresses" do
    expect(mail.header[:from].value).to eq('"The OJ Team" <robot@theoj.org>')
    expect(mail.header[:to  ].value).to eq(['"Joe Smith" <jsmith@example.com>'])
  end

  it "prefixes the subject" do
    expect(mail.subject).to eq('[TheOJ] A Subject')
    content = mail.parts[1].body.encoded
    expect(content).to match(/<title>\[TheOJ\] A Subject<\/title>/)
  end

  it "renders the body in text" do
    expect( mail.parts[0].content_type ).to match(Mime::TEXT)

    content = mail.parts[0].body.encoded
    expect(content).to start_with("Hi Joe Smith,\r\n")
    expect(content).to include("[Inserted Text]")
  end

  it "renders the body in html" do
    expect( mail.parts[1].content_type ).to match(Mime::HTML)

    content = mail.parts[1].body.encoded
    expect(content).to match(/<body>\s*<p>Hi Joe Smith,<\/p>/)
    expect(content).to include("[Inserted HTML]")
  end

  it "handles user's without an email address" do
    user.email = nil
    expect( mail.message). to be_a(ActionMailer::Base::NullMail)
  end

end
