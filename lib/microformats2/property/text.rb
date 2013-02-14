module Microformats2
	module Property
    class Text < Property::Parser
			def parse_flat_element(element)
				Element.new(element).value
			end

			class Element < Struct.new(:element)
				ATTR_MAP = {
					"abbr" => "title",
					"data" => "value",
					"img" => "alt",
					"area" => "alt"
				}

				def value
					value_class_pattern || element_value || text_value
				end

				def value_class_pattern
					# TODO
				end

				def element_value
					element.attribute(attribute).to_s if attribute
				end

				def text_value
					element.inner_text.gsub(/\n+/, " ").gsub(/\s+/, " ").strip
				end

				def attribute
					ATTR_MAP[element.name]
				end
			end
    end
	end
end
