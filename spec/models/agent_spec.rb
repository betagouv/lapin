# frozen_string_literal: true

describe Agent, type: :model do
  describe "#soft_delete" do
    context "with remaining organisations attached" do
      let(:organisation) { create(:organisation) }
      let(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      it "raises" do
        expect { agent.soft_delete }.to raise_error SoftDeleteError
      end
    end

    context "without organisations" do
      let!(:agent) { create(:agent) }

      it "marks agent as soft deleted" do
        agent.soft_delete
        expect(agent.deleted_at).to be_present
      end
    end

    it "keep old mail in an `email_original` attribute" do
      agent = create(:agent, email: "karim@le64.fr", organisations: [])
      create(:rdv, agents: [agent])
      agent.soft_delete
      expect(agent.email_original).to eq("karim@le64.fr")
    end

    it "update mail with a unique value" do
      agent = create(:agent, basic_role_in_organisations: [])
      create(:rdv, agents: [agent])
      agent.soft_delete
      expect(agent.email).to eq("agent_#{agent.id}@deleted.rdv-solidarites.fr")
    end

    it "update UID with a unique value" do
      agent = create(:agent, basic_role_in_organisations: [])
      create(:rdv, agents: [agent])
      agent.soft_delete
      expect(agent.uid).to eq("agent_#{agent.id}@deleted.rdv-solidarites.fr")
    end
  end

  describe "#available_referents_for" do
    it "returns empty array without agents" do
      user = build(:user, agents: [])
      expect(described_class.available_referents_for(user)).to eq([])
    end

    it "returns agent that not already referents array without agents" do
      agent = create(:agent)
      already_referent = create(:agent)
      user = create(:user, agents: [already_referent])
      expect(described_class.available_referents_for(user)).to eq([agent])
    end
  end
end
