require 'rails_helper'

describe EventsController do

  describe "GET index" do
    it "shows all events with end times after the current time"
  end

  describe "GET show" do
    it "finds an event"
    it "errors if there is no such event"
  end

  describe "GET edit" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "redirects to the index page if the user doesn't own the event"
    it "finds an event and builds an address for it if it doesn't have one"
  end

  describe "POST create" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "creates the event"
    # validation spec, specific validation being tested is arbitrary
    it "does not create events that start after they end"
  end

  describe "PATCH update" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "redirects to the index page if the user doesn't own the event"
    it "updates the event"
  end

  describe "DELETE destroy" do
    it "redirects to the index page if the user doesn't own the event"
    it "deletes the event"
  end

end
