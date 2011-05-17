require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "TypeController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Type.destroy_all }
  before { Property.destroy_all }
  before { Function.destroy_all }
  before { Status.destroy_all }

  before { @status = Factory(:property_status) }
  before { @intensity = Factory(:property_intensity) }
  before { @set_intensity = Factory(:set_intensity) }
  before { @turn_on = Factory(:turn_on) }
  before { @turn_off = Factory(:turn_off) }
  before { @is_setting_intensity = Factory(:is_setting_intensity) }
  before { @is_setting_max = Factory(:is_setting_max) }
  before { @has_set_intensity = Factory(:has_set_intensity) }
  before { @has_set_max = Factory(:has_set_max) }


  # GET /types
  context ".index" do
    before { @uri = "/types?page=1&per=100" }
    before { @resource = Factory(:type) }
    before { @not_owned_resource = Factory(:not_owned_type) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      before { visit @uri }
      scenario "view all resources" do
        page.status_code.should == 200
        should_have_type(@resource)
        should_not_have_type(@not_owned_resource)
        should_have_valid_json(page.body)
        should_have_root_as('resources')
      end
    end
  end


  # GET /types/{type-id}
  context ".show" do
    before { @resource = Factory(:type) }
    before { @uri = "/types/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_type) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) }
      before { visit @uri }

      scenario "view resource" do
        page.status_code.should == 200
        should_have_type(@resource)
        should_have_valid_json(page.body)
      end

      scenario "view connected properties" do
        should_have_property(@status)
        should_have_property(@intensity)
      end

      scenario "view connected functions" do
        should_have_function(@set_intensity)
        should_have_function(@turn_off)
        should_have_function(@turn_on)
      end

      scenario "view connected statuses" do
        should_have_status(@is_setting_intensity)
        should_have_status(@is_setting_max)
        should_have_status(@has_set_intensity)
        should_have_status(@has_set_max)
      end

      it_should_behave_like "a rescued 404 resource", "visit @uri", "types"
    end
  end


  # POST /types
  context ".create" do
    before { @uri =  "/types" }

    it_should_behave_like "protected resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        name: Settings.type.name,
        properties: [
          Settings.properties.status.uri, 
          Settings.properties.intensity.uri ],
        functions: [
          Settings.functions.set_intensity.uri,
          Settings.functions.turn_on.uri,
          Settings.functions.turn_off.uri ],
        statuses: [
          Settings.statuses.is_setting_max.uri,
          Settings.statuses.has_set_max.uri,
          Settings.statuses.is_setting_intensity.uri,
          Settings.statuses.has_set_intensity.uri ]
        }}

      context "with valid params" do
        before { page.driver.post(@uri, params.to_json) }
        before { @resource = Type.last }

        scenario "create resource" do
          page.status_code.should == 201
          should_have_type(@resource)
          should_have_valid_json(page.body)
        end

        scenario "connect properties" do
          should_have_property(@status)
          should_have_property(@intensity)
        end

        scenario "connect functions" do
          should_have_function(@set_intensity)
          should_have_function(@turn_off)
          should_have_function(@turn_on)
        end

        scenario "connect statuses" do
          save_and_open_page
          should_have_status(@is_setting_intensity)
          should_have_status(@is_setting_max)
          should_have_status(@has_set_intensity)
          should_have_status(@has_set_max)
        end

        scenario "create default status" do
          default = @resource.type_statuses.where(order: Settings.statuses.default_order).first
          default.should_not be_nil
        end
      end

      context "with not valid params" do
        scenario "get a not valid notification" do
          page.driver.post(@uri, {}.to_json)
          should_have_a_not_valid_resource
          should_have_valid_json(page.body)
        end
      end

      context "#properties" do
        it_should_behave_like "an array field", "properties", "page.driver.post(@uri, params.to_json)"
      end

      context "#functions" do
        it_should_behave_like "an array field", "functions", "page.driver.post(@uri, params.to_json)"
      end
    end
  end


  # PUT /types/{type-id}
  context ".update" do
    before { @resource = Factory(:type) }
    before { @uri = "/types/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_type) }

    it_should_behave_like "protected resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        name: "Set intensity updated",
        properties: [ Settings.properties.status.uri ],
        functions: [ Settings.functions.turn_on.uri, Settings.functions.turn_off.uri ]
      }}

      scenario "create resource" do
        page.driver.put(@uri, params.to_json)
        page.status_code.should == 200
        should_have_type(@resource.reload)
        should_have_property(@status)
        should_have_function(@turn_off)
        should_have_function(@turn_on)
        page.should_not have_content @intensity.reload.uri
        page.should_not have_content @set_intensity.reload.uri 
        page.should have_content "updated"
        should_have_valid_json(page.body)
      end

      scenario "not valid params" do
        page.driver.put(@uri, {name: ''}.to_json)
        should_have_a_not_valid_resource
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "types"

      context "#properties" do
        it_should_behave_like "an array field", "properties", "page.driver.put(@uri, params.to_json)"
      end

      context "#functions" do
        it_should_behave_like "an array field", "functions", "page.driver.put(@uri, params.to_json)"
      end
    end
  end


  # DELETE /types/{type-id}
  context ".destroy" do
    before { @resource = Factory(:type) }
    before { @uri = "/types/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_type) }

    it_should_behave_like "protected resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "delete resource" do
        lambda {
          page.driver.delete(@uri)
        }.should change{ Type.count }.by(-1)
        page.status_code.should == 200
        should_have_type(@resource)
        should_have_property(@status)
        should_have_property(@intensity)
        should_have_function(@set_intensity)
        should_have_function(@turn_off)
        should_have_function(@turn_on)
        should_have_valid_json(page.body)
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "types"
    end
  end
end


