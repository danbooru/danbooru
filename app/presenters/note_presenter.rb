class NotePresenter
  def initialize(note)
    @note = note
  end

  def formatted_body
    note.body.gsub(/<tn>(.+?)<\/tn>/m, '<br><p class="tn">\1</p>').gsub(/\n/, '<br>')
  end
end
