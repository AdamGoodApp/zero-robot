describe Api::V1::ToolpathsController do

  let (:key) { FactoryGirl.create :api_key }
  let (:user) { FactoryGirl.create :user }
  let (:user2) { FactoryGirl.create :user2 }
  let (:toolpath)  { FactoryGirl.create :toolpath }
  let (:toolpath_params) { {"name"=>"Paint", "scene"=>"{\"metadata\":{\"speed\":1},\"waypoints\":[{\"type\":1,\"color\":\"#FC5557\",\"rotations\":[0,0,0,-1.5707963267948966,-1.5707963267948966,0]},{\"type\":1,\"color\":\"#EA33D4\",\"rotations\":[2.7944301095317314e-8,-0.518130362033844,3.6050576412982593e-10,-2.5826103687286377,-0.04085223749279976,2.8287287179296072e-8]},{\"type\":2,\"color\":\"#7AF06F\",\"rotations\":[9.897030750494196e-9,-0.5953553915023804,9.694637315149635e-10,-1.2803051471710205,-1.265932559967041,1.0914054549004959e-8]}],\"timeline\":[{\"type\":\"waypoint\",\"waypointId\":0},{\"type\":\"waypoint\",\"waypointId\":2,\"weight\":0.5},{\"type\":\"waypoint\",\"waypointId\":1},{\"type\":\"wait\",\"condition\":{\"type\":\"time\",\"duration\":500}},{\"type\":\"waypoint\",\"waypointId\":0}]}"} }

  before(:each) do
    request.headers['Authorization'] = "Token token=#{key.access_token}"
    sign_in user
    user.toolpaths << toolpath
  end

  context '.show' do
    it "returns user's toolpaths" do
      get :show
      expect(response).to be_success
      expect(json["toolpaths"]).not_to be_empty
    end
  end

  context '.create' do
    it "creates a toolpath" do
      post :create, params: { toolpath: toolpath_params }
      expect(response).to be_success
      expect(json["id"]).not_to be_nil
      expect(json["trajectory"]).not_to be_empty
    end
  end

  context '.update' do
    it "updates a toolpath" do
      put :update, params: { id: toolpath.id, toolpath: toolpath_params }
      expect(response).to be_success
      expect(json["toolpath"]).not_to be_nil
      expect(json["trajectory"]).not_to be_empty
    end
  end

  context '.destroy' do
    it "destroys toolpath" do
      delete :destroy, params: { id: toolpath.id }
      expect(response).to be_success
      expect(Toolpath.where(id: toolpath.id)).to be_empty
    end
  end

  context '.build trajectory' do
    it "builds trajectory" do
      get :build_trajectory, params: { id: toolpath.id  }
      expect(response).to be_success
      expect(json["trajectory"]).not_to be_empty
    end
  end

  context '.calc without toolpath' do
    it "calculates trajectory without toolpath" do
      get :calc_without_toolpath, params: { toolpath: toolpath_params }
      expect(response).to be_success
      expect(json["trajectory"]).not_to be_empty
    end
  end

  context '.share' do
    it "copies toolpath from user to user" do
      post :share, params: { toolpath: toolpath_params, to_user: user2.id }
      expect(response).to be_success
      expect(user2.toolpaths).not_to be_empty
    end
  end


end