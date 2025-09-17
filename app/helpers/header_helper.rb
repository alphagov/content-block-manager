module HeaderHelper
  def main_nav_item(name, path)
    {
      text: name,
      href: path,
      active: request.path.end_with?(path),
    }
  end
end
