RSpec.describe Admin::AbsencesController, type: :controller do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }
  let!(:absence) { create(:absence, agent_id: agent.id, organisation: organisation) }
  let!(:absence_with_recurrence) do
    create(:absence, :weekly, agent: agent, first_day: Date.new(2020, 7, 15), start_time: Tod::TimeOfDay.new(8), end_day: Date.new(2020, 7, 17), end_time: Tod::TimeOfDay.new(10),
                              organisation: organisation)
  end

  shared_examples "agent can CRUD absences" do
    describe "GET #index" do
      it "returns a success response" do
        get :index, params: { organisation_id: organisation.id, agent_id: agent.id }
        expect(response).to be_successful
      end

      describe "for json format" do
        subject { get :index, params: { format: "json", organisation_id: organisation.id, agent_id: agent.id, start: start_time, end: end_time } }

        let!(:absence1) { create(:absence, agent: agent, first_day: Date.new(2019, 7, 21), start_time: Tod::TimeOfDay.new(8), end_time: Tod::TimeOfDay.new(10), organisation: organisation) }
        let(:expected_absence_starts_at) { expected_absence.starts_at }
        let(:expected_absence_ends_at) { expected_absence.ends_at }
        let!(:absence2) do
          create(:absence, agent: agent, first_day: Date.new(2019, 8, 20), start_time: Tod::TimeOfDay.new(8), end_day: Date.new(2019, 8, 31), end_time: Tod::TimeOfDay.new(22),
                           organisation: organisation)
        end

        before do
          sign_in agent
          subject
          @parsed_response = JSON.parse(response.body)
        end

        shared_examples "returns expected_absence" do
          it { expect(response).to have_http_status(:ok) }

          it "returns absence1" do
            expect(@parsed_response.size).to eq(1)

            first = @parsed_response[0]
            expect(first.size).to eq(5)
            expect(first["title"]).to eq(expected_absence.title)
            expect(first["start"]).to eq(expected_absence_starts_at.as_json)
            expect(first["end"]).to eq(expected_absence_ends_at.as_json)
            expect(first["backgroundColor"]).to eq("#7f8c8d")
            expect(first["url"]).to eq(edit_admin_organisation_absence_path(absence.organisation, expected_absence))
          end
        end

        context "when the absence is in window" do
          let(:start_time) { Time.zone.parse("20/07/2019 00:00") }
          let(:end_time) { Time.zone.parse("27/07/2019 00:00") }

          let(:expected_absence) { absence1 }

          it_behaves_like "returns expected_absence"
        end

        context "when the absence starts in window" do
          let(:start_time) { Time.zone.parse("19/08/2019 00:00") }
          let(:end_time) { Time.zone.parse("21/08/2019 00:00") }

          let(:expected_absence) { absence2 }

          it_behaves_like "returns expected_absence"
        end

        context "when the absence ends in window" do
          let(:start_time) { Time.zone.parse("31/08/2019 00:00") }
          let(:end_time) { Time.zone.parse("1/09/2019 00:00") }

          let(:expected_absence) { absence2 }

          it_behaves_like "returns expected_absence"
        end

        context "when the absence is around window" do
          let(:start_time) { Time.zone.parse("23/08/2019 00:00") }
          let(:end_time) { Time.zone.parse("27/08/2019 00:00") }

          let(:expected_absence) { absence2 }

          it_behaves_like "returns expected_absence"
        end

        describe "when the absence has a recurrence" do
          context "and the absence is in window" do
            let(:start_time) { Time.zone.parse("20/07/2020 00:00") }
            let(:end_time) { Time.zone.parse("27/07/2020 00:00") }

            let(:expected_absence) { absence_with_recurrence }
            let(:expected_absence_starts_at) { Time.zone.parse("22/07/2020 08:00") }
            let(:expected_absence_ends_at) { Time.zone.parse("24/07/2020 10:00") }

            it_behaves_like "returns expected_absence"
          end

          context "when the absence ends in window" do
            let(:start_time) { Time.zone.parse("23/07/2020 00:00") }
            let(:end_time) { Time.zone.parse("26/07/2020 00:00") }

            let(:expected_absence) { absence_with_recurrence }
            let(:expected_absence_starts_at) { Time.zone.parse("22/07/2020 08:00") }
            let(:expected_absence_ends_at) { Time.zone.parse("24/07/2020 10:00") }

            it_behaves_like "returns expected_absence"
          end
        end
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new, params: { organisation_id: organisation.id, agent_id: agent.id }
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        get :edit, params: { organisation_id: organisation.id, agent_id: agent.id, id: absence.to_param }
        expect(response).to be_successful
      end
    end

    describe "POST #create" do
      context "with valid params" do
        let(:valid_attributes) do
          build(:absence, agent: agent, organisation: organisation).attributes
        end

        it "creates a new Absence" do
          expect do
            post :create, params: { organisation_id: organisation.id, absence: valid_attributes }
          end.to change(Absence, :count).by(1)
        end

        it "redirects to the created absence" do
          post :create, params: { organisation_id: organisation.id, absence: valid_attributes }
          expect(response).to redirect_to(admin_organisation_agent_absences_path(organisation, absence.agent_id))
        end
      end

      context "with invalid params" do
        let(:invalid_attributes) do
          {
            agent_id: agent.id,
            first_day: "12/09/2019",
            start_time: "09:00",
            end_time: "07:00"
          }
        end

        it "does not create a new Absence" do
          expect do
            post :create, params: { organisation_id: organisation.id, absence: invalid_attributes }
          end.not_to change(Absence, :count)
        end

        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { organisation_id: organisation.id, absence: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe "PUT #update" do
      subject { put :update, params: { organisation_id: organisation.id, id: absence.to_param, absence: new_attributes } }

      before { subject }

      context "with valid params" do
        let(:new_attributes) do
          {
            title: "Le nouveau nom"
          }
        end

        it "updates the requested absence" do
          absence.reload
          expect(absence.title).to eq("Le nouveau nom")
        end

        it "redirects to the absence" do
          expect(response).to redirect_to(admin_organisation_agent_absences_path(organisation, absence.agent_id))
        end
      end

      context "with invalid params" do
        let(:new_attributes) do
          {
            start_time: "09:00",
            end_time: "07:00"
          }
        end

        it "returns a success response (i.e. to display the 'edit' template)" do
          expect(response).to be_successful
        end

        it "does not change absence name" do
          absence.reload
          expect(absence.starts_at.to_s).not_to eq("2019-09-12 16:00:00 +0200")
          expect(absence.ends_at.to_s).not_to eq("2019-09-12 15:00:00 +0200")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested absence" do
        expect do
          delete :destroy, params: { organisation_id: organisation.id, id: absence.to_param }
        end.to change(Absence, :count).by(-1)
      end

      it "redirects to the absences list" do
        delete :destroy, params: { organisation_id: organisation.id, id: absence.to_param }
        expect(response).to redirect_to(admin_organisation_agent_absences_path(organisation, absence.agent_id))
      end
    end
  end

  context "agent can CRUD on his absences" do
    before { sign_in agent }

    it_behaves_like "agent can CRUD absences"
  end

  context "admin can CRUD on an agent's absences" do
    let!(:admin) { create(:agent, admin_role_in_organisations: [organisation]) }

    before { sign_in admin }

    it_behaves_like "agent can CRUD absences"
  end
end
