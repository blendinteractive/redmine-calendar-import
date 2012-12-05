module Icalendar
  class Parser
    def parse_component(component = Calendar.new)
      @@logger.debug "parsing new component..."

      while (line = next_line)
        fields = parse_line(line)

        name = fields[:name].upcase

        # Although properties are supposed to come before components, we should
        # be able to handle them in any order...
        if name == "END"
          break
        elsif name == "BEGIN" # New component
          case(fields[:value])
            when "VEVENT" # Event
              component.add_component parse_component(Event.new)
            when "VTODO" # Todo entry
              component.add_component parse_component(Todo.new)
#            when "VALARM" # Alarm sub-component for event and todo
#              component.add_component parse_component(Alarm.new)
            when "VJOURNAL" # Journal entry
              component.add_component parse_component(Journal.new)
            when "VFREEBUSY" # Free/Busy section
              component.add_component parse_component(Freebusy.new)
            when "VTIMEZONE" # Timezone specification
              component.add_component parse_component(Timezone.new)
            when "STANDARD" # Standard time sub-component for timezone
              component.add_component parse_component(Standard.new)
            when "DAYLIGHT" # Daylight time sub-component for timezone
              component.add_component parse_component(Daylight.new)
            else # Uknown component type, skip to matching end
              until ((line = next_line) == "END:#{fields[:value]}"); end
              next
          end
        else # If its not a component then it should be a property
          params = fields[:params]
          value = fields[:value]

          # Lookup the property name to see if we have a string to
          # object parser for this property type.
          orig_value = value
          if @parsers.has_key?(name)
            value = @parsers[name].call(name, params, value)
          end

          name = name.downcase

          # TODO: check to see if there are any more conflicts.
          if name == 'class' or name == 'method'
            name = "ip_" + name
          end

          # Replace dashes with underscores
          name = name.gsub('-', '_')

          if component.multi_property?(name)
            adder = "add_" + name
            if component.respond_to?(adder)
              component.send(adder, value, params)
            else
              raise(UnknownPropertyMethod, "Unknown property type: #{adder}")
            end
          else
            if component.respond_to?(name)
              component.send(name, value, params)
            else
              raise(UnknownPropertyMethod, "Unknown property type: #{name}")
            end
          end
        end
      end

      component
    end
  end
end
