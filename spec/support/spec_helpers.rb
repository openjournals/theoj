module SpecHelpers

  def fixture_path
    File.joing(__FILE__, '../../..', 'fixtures')
  end

  def fixture(filename)
    filename = File.join(fixture_path, filename)
    File.open(filename, 'r')
  end

end