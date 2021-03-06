require 'rails_helper'

RSpec.describe TournamentsController, type: :controller do
  include_context 'for logged-in user'

  before(:all) do
    @tournament = FactoryGirl.create(:tournament)
    @tournaments = Tournament.all[0..10] # fix pagination issue
    @valid_attrs = FactoryGirl.attributes_for(:tournament)
    @invalid_attrs = FactoryGirl.attributes_for(:invalid_tournament)
  end

  context 'GET #index' do
    let!(:call_action) { get :index }

    include_examples 'for successfull request'
    include_examples 'for assigning instance variable', :tournaments
    include_examples 'for rendering templates', [:index, :_tournament]

    it 'should match response schema "tournaments"' do
      expect(response).to match_response_schema('tournaments')
    end

    context 'when params[:status] is "completed"' do
      it 'assigns @tournaments with unrated tournaments' do
        tournament = FactoryGirl.create(:tournament, status: 'completed')
        FactoryGirl.create(:assessment, user: @admin, tournament: tournament)

        get :index, status: 'completed'
        expect(assigns(:tournaments)).not_to include(tournament)
      end
    end
  end

  context 'POST #create' do
    context 'with valid params' do
      let!(:call_action) { post :create, tournament: @valid_attrs }

      include_examples 'for successfull request'
      include_examples 'for rendering templates', [:create, :_tournament]

      it 'assigns @tournament' do
        expect(assigns(:tournament).name).to eq(@valid_attrs[:name])
      end

      it 'responds with Hash of tournament attributes' do
        expect(response.body).to match(@valid_attrs[:name])
      end
    end

    context 'with invalid params' do
      let!(:call_action) { post :create, tournament: @invalid_attrs }

      include_examples 'for render nothing with status', 422

      it 'don\'t save the record to database' do
        expect(assigns(:tournament)).to be_nil
      end
    end
  end

  context 'GET #show' do
    let!(:call_action) { get :show, id: @tournament.id }

    include_examples 'for successfull request'
    include_examples 'for rendering templates', [:show, :_tournament]

    it 'assigns @tournament' do
      expect(assigns(:tournament)).to eq(@tournament)
    end

    it 'responds with Hash of tournament attributes' do
      expect(response.body).to match(@tournament.name)
    end
  end

  context 'PATCH/PUT #update' do
    context 'with valid params' do
      let!(:call_action) do
        put :update, id: @tournament.id, tournament: @valid_attrs
      end

      include_examples 'for successfull request'
      include_examples 'for rendering templates', [:show, :_tournament]

      it 'assigns updated project to @tournament' do
        expect(assigns(:tournament).name).to eq(@valid_attrs[:name])
      end

      it 'responds with Hash of tournament attributes' do
        expect(response.body).to match(@valid_attrs[:name])
      end

      context 'when tournament status changes to "close"' do
        let!(:tournament) { FactoryGirl.create(:tournament_with_assessments) }

        let(:close_tournament) do
          put :update, id: tournament.id, tournament: { status: 'closed' }
        end

        it 'destroys all tournament assessments' do
          tournament.assessments.each do |assessment|
            tournament.users << assessment.rated_user
          end

          expect { close_tournament }.to change { Assessment.count }.by(-5)
        end
      end
    end

    context 'with invalid params' do
      let!(:call_action) do
        put :update, id: @tournament.id, tournament: @invalid_attrs
      end

      include_examples 'for render nothing with status', 422
      include_examples 'for failed update of', :tournament
    end
  end

  context 'DELETE #destroy' do
    context 'with existing tournament' do
      let!(:tournament) { FactoryGirl.create(:tournament) }
      let!(:call_action) { delete :destroy, id: tournament.id }
      let(:create_other) { FactoryGirl.create(:tournament) }

      include_examples 'for successfull request', 'text/plain'
      include_examples 'for render nothing with status', 200

      it 'assigns @tournament' do
        expect(assigns(:tournament)).to eq(tournament)
      end
    end

    context 'with unexisting tournament' do
      let!(:call_action) { delete :destroy, id: Tournament.last.id + 999 }

      include_examples 'for render nothing with status', 404
    end
  end

  context 'GET #index_teams' do
    let!(:call_action) { get :index_teams, id: @tournament.id }

    include_examples 'for successfull request'
    include_examples 'for assigning instance variable', :tournament
    include_examples 'for rendering templates', [:'teams/index']

    it 'should assign @teams' do
      expect(assigns(:teams)).to eq(@tournament.teams)
    end

    it 'should match response schema "teams"' do
      expect(response).to match_response_schema('teams')
    end
  end

  context 'DELETE #destroy_teams' do
    let(:tournament) { FactoryGirl.create(:tournament) }
    let(:call_action) { delete :destroy_teams, id: tournament.id }

    it 'should destroy all tournament teams' do
      FactoryGirl.create_list(:team, 3, tournament: tournament)

      expect { call_action }.to change { tournament.teams.count }.from(3).to(0)
    end
  end

  context 'DELETE #remove_user' do
    let(:tournament) { FactoryGirl.create(:tournament_with_participants) }

    let(:call_action) do
      delete :remove_user, id: tournament.id, user_id: tournament.users.last.id
    end

    it 'should remove association to user' do
      expect { call_action }.to change { tournament.users.count }.by(-1)
    end

    it 'should not destroy user record' do
      tournament

      expect { call_action }.not_to change { User.count }
    end

    it 'responds nothing with success status' do
      call_action

      expect(response.status).to eq(200)
      expect(response).to render_template(nil)
    end
  end

  context 'POST #join' do
    let!(:tournament) { FactoryGirl.create(:tournament) }
    let!(:call_action) do
      sign_in user
      post :join, id: tournament.id
    end

    let(:user) { FactoryGirl.create(:user) }

    include_examples 'for render nothing with status', 200

    it 'should assign @tournament' do
      expect(assigns(:tournament)).to eq(tournament)
    end

    it 'should add association for tournament and current_user' do
      expect { post :join, id: tournament.id }.to change { tournament.users.count }.by(1)
      expect(tournament.users).to include(user)
    end
  end
end
