module Microformats2
  class Format
    CLASS_REG_EXP = /^(h-)/

    attr_reader :method_name

    def initialize(element)
      @element = element
      @method_name = to_method_name(format_types.first)
      @property_names = []
    end

    def parse
      format_types
      properties
      self
    end

    def format_types
      @format_types ||= @element.attribute("class").to_s.split.select do |html_class|
        html_class =~ Format::CLASS_REG_EXP
      end
    end

    def properties
      @properties ||= parse_properties.concat parse_implied_properties
    end

    def parse_properties
      PropertyParser.parse(@element.children).each do |property|
        save_property_name(property.method_name)
        define_method(property.method_name)
        set_value(property.method_name, property)
      end
    end

    def parse_implied_properties
      ip = []
      ip << ImpliedProperty::Name.new(@element).parse unless property_present?(:name)
      ip << ImpliedProperty::Photo.new(@element).parse unless property_present?(:photo)
      ip << ImpliedProperty::Url.new(@element).parse unless property_present?(:url)
      ip.compact.each do |property|
        save_property_name(property.method_name)
        define_method(property.method_name)
        set_value(property.method_name, property)
      end
    end

    def property_present?(property)
      !! respond_to?(property) && send(property)
    end

    def to_hash
      hash = { type: format_types, properties: {} }
      @property_names.each do |method_name|
        hash[:properties][method_name.to_sym] = send(method_name).map(&:to_hash)
      end
      hash
    end

    def to_json
      to_hash.to_json
    end

    private

    def to_method_name(html_class)
      # p-class-name -> class_name
      mn = html_class.downcase.split("-")[1..-1].join("_")
      # avoid overriding Object#class
      mn = "klass" if mn == "class"
      mn
    end

    def save_property_name(property_name)
      unless @property_names.include?(property_name)
        @property_names << property_name
      end
    end

    def define_method(mn)
      unless respond_to?(mn)
        self.class.class_eval { attr_accessor mn }
      end
    end

    def set_value(mn, value)
      if current = send(mn)
        current << value
      else
        send("#{mn}=", [value])
      end
    end
  end
end