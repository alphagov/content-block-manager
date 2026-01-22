module HeaderHelper
  def main_nav_item(name, path)
    {
      text: name,
      href: path,
      active: request.path.end_with?(path),
    }
  end

  def navigation_items(current_user)
    return [] if current_user.nil?

    [
      main_nav_item("Blocks", root_path),
      {
        text: "View website",
        href: ContentBlockManager.public_root,
      },
      {
        text: "Switch app",
        href: Plek.external_url_for("signon"),
      },
    ]
  end
end
