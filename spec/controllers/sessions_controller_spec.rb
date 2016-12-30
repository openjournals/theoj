require "rails_helper"

describe SessionsController do

  describe "#orcid_name_for" do

    it "queries the ORCID API for the username based upon the ORCID ID" do
      stub_request(:get, "https://pub.orcid.org/v1.1/0000-0001-7857-2795/orcid-bio").
        with(headers: {'Accept'=>'application/orcid+json'}).
        to_return(status: 200,
                  body: '{ "message-version":"1.1",
                           "orcid-profile":{
                              "orcid":null,
                              "orcid-identifier":{"value":null,
                                                  "uri":"https://sandbox-1.orcid.org/0000-0001-7857-2795",
                                                  "path":"0000-0001-7857-2795",
                                                  "host":"sandbox-1.orcid.org" },
                              "orcid-preferences":{ "locale":"EN" },
                              "orcid-history":{
                                 "creation-method":"WEBSITE",
                                 "submission-date":{ "value":1359385939842 },
                                 "last-modified-date":{ "value":1386071959680 },
                                 "claimed":{  "value":true },
                                 "source":null,
                                 "visibility":null
                              },
                              "orcid-bio":{
                                 "personal-details":{ "given-names":{ "value":"Albert" }, "family-name":{ "value":"Einstein"} },
                                 "biography":{ "value":"", "visibility":null },
                                 "keywords":null,
                                 "delegation":null,
                                 "applications":null,
                                 "scope":null
                              },
                              "type":"USER",
                              "group-type":null,
                              "client-type":null
                           }
                        }',
                  headers: {})

      user = create(:user, :uid => '0000-0001-7857-2795')
      
      expect(controller.send(:orcid_name_for, user.uid)).to eq("Albert Einstein")
    end

  end

end
