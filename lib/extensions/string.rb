
class String

  def a_or_an
    self.length==0 ? '' : self[0].downcase.in?(%w{a e i o u }) ? 'an' : 'a'
  end

end
