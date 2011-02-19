# coding: utf-8
class IsisSchedule < Plugin::Base
  FORMAT = :html
  
  FIRST_DAY = Date.civil(2011, 2, 14)
  CELL_WITH = 80
  WEEKS = 13
  
  def xml
    #record = user.data.for(self, 'xml')
    #record ? record.value : nil
    File.read(File.join(File.dirname(__FILE__), "isis_schedule", "actions.xml"))
  end
  
  def rng_schema
    #record = user.data.for(self, 'rng_schema')
    #record ? record.value : nil
    File.read(File.join(File.dirname(__FILE__), "isis_schedule", "schema.rng"))
  end
  
  def parse_table(element)
    rows = element.node.css("tr:not(.zahlavi)").to_a.select {|node|
      !node.matches?("tr.rozvrh-sep") && !node.matches?("tr[height]")
    }
    rows.collect! {|row|
#      row.css("td[width][align='center']:not(.odsazena)").to_a
      cells = []
      index = 0
      row.css("td:not(.zahlavi)").to_a.each do |cell|
        unless cell.matches?("td[width][colspan][align='center']")
          index += cell.attributes["width"].value.to_i/CELL_WITH
          next
        end
        cells << Event.new(cell, index, rows.index(row))
        index += cells.last.length
      end
      cells
    }
    cal = RiCal.Calendar do |cal|
      cal.default_tzid = "Europe/Prague"
      rows.flatten.each do |event|
        starts, ends = event.interval.first.split(":"), event.interval.last.split(":")
        cal.event do
          summary event.summary
          location event.location
          attendee event.attendee
          rrule "FREQ=WEEKLY;COUNT=#{WEEKS}" 
          comment event.comment
          dtstart event.date.to_time.advance(:hours => starts.first.to_i, :minutes => starts.last.to_i)
          dtend event.date.to_time.advance(:hours => ends.first.to_i, :minutes => ends.last.to_i)
        end
      end
    end
    @ical = cal.to_s
  end
  
  class Event
    INDEXES = ['07:30'..'08:15', '08:15'..'09:00', '09:15'..'10:00', '10:00'..'10:45', '11:00'..'11:45', '11:45'..'12:30', '12:45'..'13:30', '13:30'..'14:15', '14:30'..'15:15', '15:15'..'16:00', '16:15'..'17:00', '17:00'..'17:45', '18:00'..'18:45', '18:45'..'19:30', '19:45'..'20:30', '20:30'..'21:15', '21:15'..'22:00']
    
    attr_reader :summary, :location, :interval, :length, :date, :attendee, :comment
    def initialize(node, column, row)
      @length = node.attributes["colspan"].value.to_i
      range = INDEXES[column, length]
      @interval = range.first.first..range.last.last
      location, summary, attendee = *node.css("a").to_a
      @location = location.text
      @summary = summary.text
      @attendee = attendee.text
      @date =  FIRST_DAY + row
      @comment = case node.attributes["class"].value
      when "rozvrh-pred"
        "přednáška"
      when "rozvrh-cvic"
        "cvičení"
      end
      self
    end
  end
  
  class << self
    def label
      "ISIS schedule to iCal"
    end
    def url
      "https://isis.vse.cz/katalog/rozvrhy_view.pl?zobraz=1;format=html;rozvrh_student=53816;lang=cz"
    end
    def content_type
      "text/calendar"
    end
  end
end
