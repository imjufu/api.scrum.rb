require "spec_helper"
module Backlog
  describe StoriesController do

    render_views

    before(:each) do
      @product = FactoryGirl.create :product_with_stories_and_sprints
      @sprint = @product.sprints.first
      @story = @product.stories.first
    end

    describe "GET #index" do
      it "responds successfully with an HTTP 200 status code and ordered elements" do
        last_story = @product.stories.last
        @sprint.sprint_backlogs.new(story_id: @story.id, order: 1).save
        @sprint.sprint_backlogs.new(story_id: last_story.id, order: 2).save
        get :index, :product_id => @product.id, :sprint_id => @sprint.id
        response.should be_success
        response.code.should eq "200"
        previous_order = 0
        JSON.parse(response.body).each do |sb|
          sb["order"].to_i.should be >= previous_order, "Stories in the backlog are not sorted correctly"
          previous_order = sb["order"]
        end
      end
    end

    describe "POST #create" do
      it "responds successfully with an HTTP 201 status code" do
        post :create, :product_id => @product.id, :sprint_id => @sprint.id, :backlog => { :story_id => @story.id }
        response.should be_success
        response.code.should eq "201"
      end
      it "responds with a 422 status code if the story is already associated to the backlog" do
        @sprint.sprint_backlogs.new(story_id: @story.id).save
        post :create, :product_id => @product.id, :sprint_id => @sprint.id, :backlog => { :story_id => @story.id }
        response.should_not be_success
        response.code.should eq "422"
      end
    end

    describe "PATCH #update" do
      it "responds successfully with an HTTP 204 status code" do
        sprint_backlog = @sprint.sprint_backlogs.new(story_id: @story.id)
        sprint_backlog.save
        patch :update, :product_id => @product.id, :sprint_id => @sprint.id, :id => sprint_backlog.id, :backlog => { :story_id => @story.id }
        response.should be_success
        response.code.should eq "204"
      end
      it "responds with a 404 status code if the story is not pulled in the backlog" do
        patch :update, :product_id => @product.id, :sprint_id => @sprint.id, :id => 7777, :backlog => { }
        response.should_not be_success
        response.code.should eq "404"
      end
    end

    describe "DELETE #destroy" do
      it "responds successfully with an HTTP 204 status code" do
        sprint_backlog = @sprint.sprint_backlogs.new(story_id: @story.id)
        sprint_backlog.save
        delete :destroy, :product_id => @product.id, :sprint_id => @sprint.id, :id => sprint_backlog.id
        response.should be_success
        response.code.should eq "204"
      end
    end
  end
end