# frozen_string_literal: true

describe Agents::PlageOuvertureMailer, type: :mailer do
  { created: "créée", updated: "modifiée", destroyed: "supprimée" }.each do |action, verb|
    context "when #{action}" do
      let(:ics_payload) do
        {
          name: "plage-ouverture--.ics",
          object: "plage_ouverture",
          action: action,
          agent_email: "bob@demo.rdv-solidarites.fr",
          starts_at: Time.zone.parse("20190423 13h00"),
          ical_uid: "plage_ouverture_@RDV Solidarités",
          title: "Plage d'ouverture #{verb}",
          first_occurrence_ends_at: Time.zone.parse("20190423 18h00"),
          address: "une adresse"
        }
      end

      it "mail to plage ouverture's agent" do
        mail = described_class.send("plage_ouverture_#{action}", ics_payload)
        expect(mail.to).to eq(["bob@demo.rdv-solidarites.fr"])
      end

      it "have a good subject" do
        mail = described_class.send("plage_ouverture_#{action}", ics_payload)
        expect(mail.subject).to eq("RDV Solidarités - Plage d'ouverture #{verb}")
      end

      it "has a ICS file join with UID" do
        mail = described_class.send("plage_ouverture_#{action}", ics_payload)
        cal = mail.find_first_mime_type("text/calendar")
        expect(cal.decoded).to match("UID:plage_ouverture_@RDV Solidarités")
      end
    end
  end

  describe "#plage_ouverture_destroyed" do
    it "have a STATUS:CANCELLED in ICS file joined" do
      ics_payload = {
        name: "plage-ouverture--.ics",
        object: "plage_ouverture",
        action: :destroy,
        agent_email: "bob@demo.rdv-solidarites.fr",
        starts_at: Time.zone.parse("20190423 13h00"),
        ical_uid: "plage_ouverture_@RDV Solidarités",
        title: "Plage d'ouverture supprimée",
        first_occurrence_ends_at: Time.zone.parse("20190423 18h00"),
        address: "une adresse"
      }
      mail = described_class.send("plage_ouverture_destroyed", ics_payload)
      cal = mail.find_first_mime_type("text/calendar")
      expect(cal.decoded).to match("STATUS:CANCELLED")
    end
  end
end
