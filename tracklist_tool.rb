require 'rspotify'

require 'fox16'

RSpotify.authenticate("key", "secret")

include Fox

class TrackListTool < FXMainWindow
  def initialize(app)
    super(app, "Tracklist Tool", :width => 450, :height => 200)
    hFrame1 = FXHorizontalFrame.new(self)
    instructions = FXLabel.new(hFrame1, "Enter the Spotify or Apple Music playlist in the box below, then press submit.")

    hFrame2 = FXHorizontalFrame.new(self)
    label = FXLabel.new(hFrame2, "Playlist Link:")
    link = FXTextField.new(hFrame2, 30)

    hFrame3 = FXHorizontalFrame.new(self)
    submitButton = FXButton.new(hFrame3, "Submit")
    submitButton.connect(SEL_COMMAND) {saveTracklist(link.text)}

    quitButton = FXButton.new(hFrame3, "Quit")
    quitButton.connect(SEL_COMMAND) {exit}

  end

  def seconds_to_minsec(sec)
    "%02d:%02d" % [sec / 60 % 60, sec % 60]
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end

  def saveTracklist(text)
    puts text
    url = (text.split("/")[-1]).split("?")[0]
    playlist = RSpotify::Playlist.find_by_id(url)

    output = ""

    space_just_len = 64

    playlist.tracks.each do |t|
       output += (seconds_to_minsec(t.duration_ms / 1000).ljust(space_just_len, " ") + "\t")
       output += ((t.name).to_s.ljust(space_just_len, " ") + "\t")
       output += ((t.artists[0].name).to_s.ljust(space_just_len, " ") + "\t")
       output += ((t.album.label).to_s.ljust(space_just_len, " ") + "\n")
       puts t.name
       STDOUT.flush
    end

    File.write("playlist.txt", output)
    puts "saved to 'playlist.txt'"
    STDOUT.flush
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    TrackListTool.new(app)
    app.create
    app.run
  end
end