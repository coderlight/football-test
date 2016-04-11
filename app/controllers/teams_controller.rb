class TeamsController < ApplicationController
  before_action :find_team, only: [:show, :destroy]

  def index
    @teams = Team.includes(:users).where('tournament_id = ?', params[:tournament_id])
  end

  def show
  end

  def create
    if params[:batch_create]
      # TODO - ...
    else
      Team.create!(team_params)
    end
  end

  def destroy
    @team.destroy

    render nothing: true
  end

  private

  def team_params
    params.require(:team).permit(:name, user_ids: [])
  end

  def find_team
    @team = Team.find(params[:id])
  end
end
