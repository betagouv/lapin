describe Agents::Creneaux::AgentSearchesController, type: :controller do
  context "with a secretaire signed_in" do
    let!(:agent) { create(:agent, :secretaire) }
    before(:each) { sign_in agent }

    describe "GET index html format" do
      let!(:organisation_id) { agent.organisation_ids.first }

      it "should return success" do
        get :index, params: { organisation_id: organisation_id, user: 1 }
        expect(response).to have_http_status(:success)
      end

      it "should return success" do
        get :index, params: { organisation_id: organisation_id, user: 1 }
        expect(assigns(:user)).to eq("1")
      end

      it "should render template index" do
        get :index, params: { organisation_id: organisation_id, user: 1 }
        expect(response).to render_template("index")
      end
    end
  end
end
