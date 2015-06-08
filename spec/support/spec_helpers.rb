module SpecHelpers

  def fixture_path
    File.joing(__FILE__, '../../..', 'fixtures')
  end

  def fixture(filename)
    filename = File.join(fixture_path, filename)
    File.open(filename, 'r')
  end

  def fixture_text(filename)
    fixture(filename).readlines.join
  end

  def hash_from_json(json)
    return JSON.parse(json)
  end

  def set_paper_editor(user=nil)
    if user.is_a?(Symbol)
      user = create(user)
    elsif user.nil?
      user = create(:editor)
    end
    allow(User).to receive(:next_editor).and_return(user)
    user
  end

end
