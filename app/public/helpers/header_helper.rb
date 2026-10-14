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
      metrics_nav_item(current_user),
      {
        text: "View website",
        href: ContentBlockManager.public_root,
      },
      {
        text: "Switch app",
        href: Plek.external_url_for("signon"),
      },
    ].compact
  end

private

  def metrics_nav_item(current_user)
    return unless current_user.has_permission?(User::Permissions::VIEW_METRICS)

    main_nav_item("Metrics", Rails.application.routes.url_helpers.admin_metrics_host_content_path)
  end
end
