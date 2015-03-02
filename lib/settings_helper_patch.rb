
module SettingsHelperPatch

  def choose_unapproved_color
    colors = {
      :aqua => "#00FFFF",
      :blue => "#0000FF",
      :fuchsia => "#FF00FF",
      :gray => "#808080",
      :green => "#008000",
      :lime => "#00FF00",
      :maroon => "#800000",
      :navy => "#000080",
      :olive => "#808000",
      :orange => "#FFA500",
      :purple => "#800080",
      :red => "#FF0000",
      :silver => "#C0C0C0",
      :teal => "#008080",
      :yellow => "#FFFF00"
    }
    auswahl = '<option value="">' << l(:no_highlighting) << '</option> '

    if Setting.plugin_approval_plugin['unapproved_color'][0,1] == "#"
      color = Setting.plugin_approval_plugin['unapproved_color']
      auswahl << '<option value="' << color << '" style="color: ' << color << '" selected >' << color << "</option>"
    end

    colors.each do |name, col|
      auswahl << build_color_tag(name.to_s, col)
    end

    return auswahl
  end


  def build_color_tag name, col
    color_tag = '<option value="' << col << '" style="color: ' << col << '"'

    if col == Setting.plugin_approval_plugin['unapproved_color']
      color_tag << " selected "
    end

    color_tag << ">" << name << "</option> "
    return color_tag
  end

end
