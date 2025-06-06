# frozen_string_literal: true

RSpec.describe SiteSettings::TypeSupervisor do
  let :provider_local do
    SiteSettings::LocalProcessProvider.new
  end

  let :settings do
    new_settings(provider_local)
  end

  describe "constants" do
    it "validator opts are the subset of consumed opts" do
      expect(
        Set.new(SiteSettings::TypeSupervisor::CONSUMED_OPTS).superset?(
          Set.new(SiteSettings::TypeSupervisor::VALIDATOR_OPTS),
        ),
      ).to be_truthy
    end
  end

  describe "#types" do
    context "when verifying enum sequence" do
      it "'string' should be at 1st position" do
        expect(SiteSettings::TypeSupervisor.types[:string]).to eq(1)
      end
      it "'time' should be at 2nd position" do
        expect(SiteSettings::TypeSupervisor.types[:time]).to eq(2)
      end
      it "'integer' should be at 3rd position" do
        expect(SiteSettings::TypeSupervisor.types[:integer]).to eq(3)
      end
      it "'float' should be at 4th position" do
        expect(SiteSettings::TypeSupervisor.types[:float]).to eq(4)
      end
      it "'bool' should be at 5th position" do
        expect(SiteSettings::TypeSupervisor.types[:bool]).to eq(5)
      end
      it "'null' should be at 6th position" do
        expect(SiteSettings::TypeSupervisor.types[:null]).to eq(6)
      end
      it "'enum' should be at 7th position" do
        expect(SiteSettings::TypeSupervisor.types[:enum]).to eq(7)
      end
      it "'list' should be at 8th position" do
        expect(SiteSettings::TypeSupervisor.types[:list]).to eq(8)
      end
      it "'url_list' should be at 9th position" do
        expect(SiteSettings::TypeSupervisor.types[:url_list]).to eq(9)
      end
      it "'host_list' should be at 10th position" do
        expect(SiteSettings::TypeSupervisor.types[:host_list]).to eq(10)
      end
      it "'category_list' should be at 11th position" do
        expect(SiteSettings::TypeSupervisor.types[:category_list]).to eq(11)
      end
      it "'value_list' should be at 12th position" do
        expect(SiteSettings::TypeSupervisor.types[:value_list]).to eq(12)
      end
      it "'regex' should be at 13th position" do
        expect(SiteSettings::TypeSupervisor.types[:regex]).to eq(13)
      end
      it "'email' should be at 14th position" do
        expect(SiteSettings::TypeSupervisor.types[:email]).to eq(14)
      end
      it "'username' should be at 15th position" do
        expect(SiteSettings::TypeSupervisor.types[:username]).to eq(15)
      end
      it "'category' should be at 16th position" do
        expect(SiteSettings::TypeSupervisor.types[:category]).to eq(16)
      end
      it "'uploaded_image_list' should be at 17th position" do
        expect(SiteSettings::TypeSupervisor.types[:uploaded_image_list]).to eq(17)
      end
      it "'upload' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:upload]).to eq(18)
      end
      it "'group' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:group]).to eq(19)
      end
      it "'group_list' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:group_list]).to eq(20)
      end
      it "'tag_list' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:tag_list]).to eq(21)
      end
      it "'color' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:color]).to eq(22)
      end
      it "'simple_list' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:simple_list]).to eq(23)
      end
      it "'emoji_list' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:emoji_list]).to eq(24)
      end
      it "'tag_group_list' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:tag_group_list]).to eq(26)
      end
      it "'file_size_restriction' should be at the right position" do
        expect(SiteSettings::TypeSupervisor.types[:file_size_restriction]).to eq(27)
      end
    end
  end

  describe "#parse_value_type" do
    it "returns :null type when the value is nil" do
      expect(described_class.parse_value_type(nil)).to eq(SiteSetting.types[:null])
    end

    it "returns :integer type when the value is int" do
      expect(described_class.parse_value_type(2)).to eq(SiteSetting.types[:integer])
    end

    it "returns :integer type when the value is large int" do
      expect(
        described_class.parse_value_type(99_999_999_999_999_999_999_999_999_999_999_999),
      ).to eq(SiteSetting.types[:integer])
    end

    it "returns :float type when the value is float" do
      expect(described_class.parse_value_type(1.23)).to eq(SiteSetting.types[:float])
    end

    it "returns :bool type when the value is true" do
      expect(described_class.parse_value_type(true)).to eq(SiteSetting.types[:bool])
    end

    it "returns :bool type when the value is false" do
      expect(described_class.parse_value_type(false)).to eq(SiteSetting.types[:bool])
    end

    it "raises when the value is not listed" do
      expect { described_class.parse_value_type(Object.new) }.to raise_error ArgumentError
    end
  end

  context "with different data types" do
    class TestEnumClass
      def self.valid_value?(v)
        self.values.include?(v)
      end

      def self.values
        ["en"]
      end

      def self.translate_names?
        false
      end
    end

    class TestSmallThanTenValidator
      def initialize(opts)
      end

      def valid_value?(v)
        v < 10
      end

      def error_message
        ""
      end
    end

    class TestJsonSchemaClass
      def self.schema
        { type: "array", items: { type: "object", properties: { name: { type: "string" } } } }
      end
    end

    before do
      settings.setting(:type_null, nil)
      settings.setting(:type_int, 1)
      settings.setting(:type_true, true)
      settings.setting(:type_false, false)
      settings.setting(:type_float, 2.3232)
      settings.setting(:type_string, "string")
      settings.setting(:type_enum_default_string, "2", type: "enum", choices: ["2"])
      settings.setting(:type_enum_class, "en", enum: "TestEnumClass")
      settings.setting(:type_validator, 5, validator: "TestSmallThanTenValidator")
      settings.setting(:type_mock_validate_method, "no_value")
      settings.setting(:type_custom, "custom", type: "list")
      settings.setting(:type_upload, "", type: "upload")
      settings.setting(
        :type_json_schema,
        "[{\"name\":\"Brett\"}]",
        json_schema: "TestJsonSchemaClass",
      )
      settings.setting(
        :type_objects,
        "[]",
        type: "objects",
        schema: {
          name: "link",
          properties: {
            name: {
              type: "string",
              required: true,
            },
          },
        },
      )
      settings.refresh!
    end

    describe "#to_db_value" do
      let(:true_val) { "t" }
      let(:false_val) { "f" }

      it "returns nil value" do
        expect(settings.type_supervisor.to_db_value(:type_null, nil)).to eq [
             nil,
             SiteSetting.types[:null],
           ]
      end

      it "gives a second chance to guess even told :null type" do
        expect(settings.type_supervisor.to_db_value(:type_null, 1)).to eq [
             1,
             SiteSetting.types[:integer],
           ]
      end

      it "writes `t` or `f` given the possible bool value" do
        expect(settings.type_supervisor.to_db_value(:type_true, true)).to eq [
             true_val,
             SiteSetting.types[:bool],
           ]
        expect(settings.type_supervisor.to_db_value(:type_true, "t")).to eq [
             true_val,
             SiteSetting.types[:bool],
           ]
        expect(settings.type_supervisor.to_db_value(:type_true, "true")).to eq [
             true_val,
             SiteSetting.types[:bool],
           ]
        expect(settings.type_supervisor.to_db_value(:type_true, false)).to eq [
             false_val,
             SiteSetting.types[:bool],
           ]
      end

      it "writes `f` if given not `true` value" do
        expect(settings.type_supervisor.to_db_value(:type_true, "")).to eq [
             false_val,
             SiteSetting.types[:bool],
           ]
        expect(settings.type_supervisor.to_db_value(:type_true, nil)).to eq [
             false_val,
             SiteSetting.types[:bool],
           ]
      end

      it "returns floats value" do
        expect(settings.type_supervisor.to_db_value(:type_float, 1.2)).to eq [
             1.2,
             SiteSetting.types[:float],
           ]
        expect(settings.type_supervisor.to_db_value(:type_float, 1)).to eq [
             1.0,
             SiteSetting.types[:float],
           ]
      end

      it "returns string value" do
        expect(settings.type_supervisor.to_db_value(:type_string, "a")).to eq [
             "a",
             SiteSetting.types[:string],
           ]
      end

      it "returns the upload id" do
        upload = Fabricate(:upload)

        expect(settings.type_supervisor.to_db_value(:type_upload, upload)).to eq(
          [upload.id, SiteSetting.types[:upload]],
        )

        expect(settings.type_supervisor.to_db_value(:type_upload, 1)).to eq(
          [1, SiteSetting.types[:upload]],
        )
      end

      it "returns enum value with string default" do
        expect(settings.type_supervisor.to_db_value(:type_enum_default_string, 2)).to eq [
             "2",
             SiteSetting.types[:enum],
           ]
        expect(settings.type_supervisor.to_db_value(:type_enum_default_string, "2")).to eq [
             "2",
             SiteSetting.types[:enum],
           ]
      end

      it "raises when it does not in the enum choices" do
        expect {
          settings.type_supervisor.to_db_value(:type_enum_default_string, "random")
        }.to raise_error Discourse::InvalidParameters
      end

      it "returns enum value for the given enum class" do
        expect(settings.type_supervisor.to_db_value(:type_enum_class, "en")).to eq [
             "en",
             SiteSetting.types[:enum],
           ]
      end

      it "raises when it does not in the enum class" do
        expect {
          settings.type_supervisor.to_db_value(:type_enum_class, "random")
        }.to raise_error Discourse::InvalidParameters
      end

      it "validates value by validator" do
        expect(settings.type_supervisor.to_db_value(:type_validator, 1)).to eq [
             1,
             SiteSetting.types[:integer],
           ]
      end

      it "raises when the validator says so" do
        expect {
          settings.type_supervisor.to_db_value(:type_validator, 11)
        }.to raise_error Discourse::InvalidParameters
      end

      it "tries invoke validate methods" do
        settings.type_supervisor.expects(:validate_type_mock_validate_method).with("no")
        settings.type_supervisor.to_db_value(:type_mock_validate_method, "no")
      end

      it "raises when there is invalid json in a string with json schema" do
        expect {
          settings.type_supervisor.to_db_value(:type_json_schema, "not-json")
        }.to raise_error Discourse::InvalidParameters
      end

      it "returns value for the given json schema string setting" do
        expect(settings.type_supervisor.to_db_value(:type_json_schema, "{}")).to eq [
             "{}",
             SiteSetting.types[:string],
           ]
      end

      it "raises when an object is not valid for the given schema" do
        expect {
          settings.type_supervisor.to_db_value(:type_objects, "not-json")
        }.to raise_error Discourse::InvalidParameters
      end

      it "raises when an object property is not valid for the given schema" do
        expect {
          settings.type_supervisor.to_db_value(:type_objects, "[{\"nam\":\"Brett\"}]")
        }.to raise_error Discourse::InvalidParameters
      end

      it "raises when an object value is not valid for the given schema" do
        expect {
          settings.type_supervisor.to_db_value(:type_objects, "[{\"name\":1}]")
        }.to raise_error Discourse::InvalidParameters
      end

      it "returns value for the given objects schema string setting" do
        expect(
          settings.type_supervisor.to_db_value(:type_objects, "[{\"name\":\"Brett\"}]"),
        ).to eq ["[{\"name\":\"Brett\"}]", SiteSetting.types[:objects]]
      end
    end

    describe "#to_rb_value" do
      it "the type can be overridden by a parameter" do
        expect(
          settings.type_supervisor.to_rb_value(:type_null, "1", SiteSetting.types[:integer]),
        ).to eq(1)
      end

      it "returns an integer for file_size_restriction type" do
        expect(
          settings.type_supervisor.to_rb_value(
            :type_file_size_restriction,
            "1024",
            SiteSetting.types[:file_size_restriction],
          ),
        ).to eq 1024
      end

      it "returns nil value" do
        expect(settings.type_supervisor.to_rb_value(:type_null, "1")).to eq nil
        expect(settings.type_supervisor.to_rb_value(:type_null, 1)).to eq nil
        expect(settings.type_supervisor.to_rb_value(:type_null, "null")).to eq nil
        expect(settings.type_supervisor.to_rb_value(:type_null, "nil")).to eq nil
      end

      it "returns true when it is true or `t` or `true`" do
        expect(settings.type_supervisor.to_rb_value(:type_true, true)).to eq true
        expect(settings.type_supervisor.to_rb_value(:type_true, "t")).to eq true
        expect(settings.type_supervisor.to_rb_value(:type_true, "true")).to eq true
      end

      it "returns false if not one of `true` value" do
        expect(settings.type_supervisor.to_rb_value(:type_true, "tr")).to eq false
        expect(settings.type_supervisor.to_rb_value(:type_true, "")).to eq false
        expect(settings.type_supervisor.to_rb_value(:type_true, nil)).to eq false
        expect(settings.type_supervisor.to_rb_value(:type_true, false)).to eq false
        expect(settings.type_supervisor.to_rb_value(:type_true, "f")).to eq false
        expect(settings.type_supervisor.to_rb_value(:type_true, "false")).to eq false
      end

      it "returns float value" do
        expect(settings.type_supervisor.to_rb_value(:type_float, 1.2)).to eq 1.2
        expect(settings.type_supervisor.to_rb_value(:type_float, 1)).to eq 1.0
        expect(settings.type_supervisor.to_rb_value(:type_float, "2.2")).to eq 2.2
        expect(settings.type_supervisor.to_rb_value(:type_float, "2")).to eq 2
      end

      it "returns string value" do
        expect(settings.type_supervisor.to_rb_value(:type_string, "a")).to eq "a"
        expect(settings.type_supervisor.to_rb_value(:type_string, 2)).to eq "2"
      end

      it "returns the upload record" do
        upload = Fabricate(:upload)

        expect(settings.type_supervisor.to_rb_value(:type_upload, "")).to eq("")

        expect(settings.type_supervisor.to_rb_value(:type_upload, upload.id)).to eq(upload.id)
      end

      it "returns value with string default" do
        expect(settings.type_supervisor.to_rb_value(:type_enum_default_string, 2)).to eq "2"
        expect(settings.type_supervisor.to_rb_value(:type_enum_default_string, "2")).to eq "2"
      end

      it "returns value with a custom type" do
        expect(settings.type_supervisor.to_rb_value(:type_custom, 2)).to eq 2
        expect(settings.type_supervisor.to_rb_value(:type_custom, "2|3")).to eq "2|3"
      end

      it "should not modify the types of settings" do
        types = SiteSettings::TypeSupervisor.types
        settings.type_supervisor.to_rb_value(:default_locale, "fr", types[:enum])
        expect(settings.type_supervisor.to_db_value(:default_locale, "en")).to eq(
          ["en", types[:string]],
        )
      end
    end
  end

  describe "#get_type" do
    before do
      settings.setting(:type_null, nil)
      settings.setting(:type_upload, "", type: :upload)
    end

    it "should return the right type that has been registered" do
      expect(settings.type_supervisor.get_type(:type_null)).to eq(:null)
      expect(settings.type_supervisor.get_type(:type_upload)).to eq(:upload)
    end
  end

  describe ".type_hash" do
    class TestEnumClass2
      def self.valid_value?(v)
        self.values.include?(v)
      end

      def self.values
        %w[a b]
      end

      def self.translate_names?
        false
      end
    end

    before do
      settings.setting(:type_null, nil)
      settings.setting(:type_int, 1, min: -10, max: 10)
      settings.setting(:type_true, true)
      settings.setting(:type_float, 2.3232)
      settings.setting(:type_string, "string")
      settings.setting(:type_url_list, "string", type: "url_list")
      settings.setting(:type_textarea, "string", textarea: true)
      settings.setting(:type_enum_choices, "2", type: "enum", choices: %w[1 2])
      settings.setting(:type_enum_class, "a", enum: "TestEnumClass2")
      settings.setting(:type_list, "a", type: "list", choices: %w[a b], list_type: "compact")
      settings.setting(
        :type_objects,
        "[]",
        type: "objects",
        schema: {
          name: "link",
          properties: {
            name: {
              type: "string",
            },
          },
        },
      )
      settings.refresh!
    end

    it "returns null type" do
      expect(settings.type_supervisor.type_hash(:type_null)[:type]).to eq "null"
    end

    it "returns int type" do
      expect(settings.type_supervisor.type_hash(:type_int)[:type]).to eq "integer"
    end

    it "returns bool type" do
      expect(settings.type_supervisor.type_hash(:type_true)[:type]).to eq "bool"
    end

    it "returns float type" do
      expect(settings.type_supervisor.type_hash(:type_float)[:type]).to eq "float"
    end

    it "returns string type" do
      expect(settings.type_supervisor.type_hash(:type_string)[:type]).to eq "string"
    end

    it "returns url_list type" do
      expect(settings.type_supervisor.type_hash(:type_url_list)[:type]).to eq "url_list"
    end

    it "returns textarea type" do
      expect(settings.type_supervisor.type_hash(:type_textarea)[:textarea]).to eq true
    end

    it "returns enum type" do
      expect(settings.type_supervisor.type_hash(:type_enum_choices)[:type]).to eq "enum"
    end

    it "returns list choices" do
      expect(settings.type_supervisor.type_hash(:type_list)[:choices]).to eq %w[a b]
    end

    it "returns list list_type" do
      expect(settings.type_supervisor.type_hash(:type_list)[:list_type]).to eq "compact"
    end

    it "returns enum choices" do
      hash = settings.type_supervisor.type_hash(:type_enum_choices)
      expect(hash[:valid_values]).to eq [{ name: "1", value: "1" }, { name: "2", value: "2" }]
      expect(hash[:translate_names]).to eq false
    end

    it "returns enum class" do
      hash = settings.type_supervisor.type_hash(:type_enum_class)
      expect(hash[:valid_values]).to eq %w[a b]
      expect(hash[:translate_names]).to eq false
    end

    it "returns objects type" do
      hash = settings.type_supervisor.type_hash(:type_objects)
      expect(hash[:type]).to eq "objects"
      expect(hash[:schema]).to eq({ name: "link", properties: { name: { type: "string" } } })
    end

    it "returns int min/max values" do
      expect(settings.type_supervisor.type_hash(:type_int)[:min]).to eq(-10)
      expect(settings.type_supervisor.type_hash(:type_int)[:max]).to eq(10)
    end
  end
end
