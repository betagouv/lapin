RSpec.describe Users::RdvsController, type: :controller do
  render_views

  describe "POST create" do
    let!(:organisation) { create(:organisation) }
    let(:user) { create(:user) }
    let(:motif) { create(:motif, organisation: organisation) }
    let(:lieu) { create(:lieu, organisation: organisation) }
    let(:starts_at) { DateTime.parse("2020-10-20 10h30") }

    subject { post :create, params: { organisation_id: organisation.id, lieu_id: lieu.id, departement: "12", where: "1 rue de la, ville 12345", motif_id: motif.id, starts_at: starts_at } }

    before do
      travel_to(Time.zone.local(2019, 7, 20))
      sign_in user
      expect(Users::CreneauSearch).to receive(:creneau_for)
        .with(user: user, starts_at: starts_at, motif: motif, lieu: lieu)
        .and_return(mock_creneau)
      subject
    end

    after { travel_back }

    describe "when there is an available creneau" do
      let!(:agent) { create(:agent, organisations: [organisation]) }
      let(:mock_creneau) do
        instance_double(Creneau, agent: agent, motif: motif, lieu: lieu, starts_at: starts_at, duration_in_min: 30)
      end

      it "creates rdv" do
        expect(Rdv.count).to eq(1)
        expect(response).to redirect_to users_rdvs_path
        expect(user.rdvs.last.created_by_user?).to be(true)
      end
    end

    describe "when there is no available creneau" do
      let(:mock_creneau) { nil }

      it "creates rdv" do
        expect(Rdv.count).to eq(0)
        expect(response).to redirect_to lieux_path(search: { departement: "12", service: motif.service_id, motif_name: motif.name, where: "1 rue de la, ville 12345" })
        expect(flash[:error]).to eq "Ce creneau n'est plus disponible. Veuillez en sélectionner un autre."
      end
    end
  end

  describe "PUT #cancel" do
    let(:now) { "01/01/2019 14:20".to_datetime }
    let(:rdv) { create(:rdv, starts_at: 5.hours.from_now) }
    let!(:user) { create(:user) }

    subject do
      put :cancel, params: { rdv_id: rdv.id }
      rdv.reload
    end

    before do
      travel_to(now)
      sign_in signed_in_user
    end

    context "when user belongs to rdv" do
      let(:signed_in_user) { rdv.users.first }

      it { expect { subject }.to change(rdv, :cancelled_at).from(nil).to(now) }

      it "redirects to rdvs" do
        subject
        expect(response).to redirect_to users_rdvs_path
      end

      context "when rdv is not cancellable" do
        let(:rdv) { create(:rdv, starts_at: 3.hours.from_now) }

        it { expect { subject }.not_to change(rdv, :cancelled_at) }
      end
    end

    context "when user does not belongs to rdv" do
      let(:signed_in_user) { create(:user) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
