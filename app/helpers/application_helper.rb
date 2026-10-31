module ApplicationHelper
  ICONS = {
    home: "M3 10.5L12 3l9 7.5V20a1 1 0 01-1 1h-5v-6H9v6H4a1 1 0 01-1-1z",
    folder: "M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z",
    box: "M21 8l-9-5-9 5 9 5 9-5zM3 8v8l9 5 9-5V8M12 13v8",
    calendar: "M7 3v4M17 3v4M4 9h16M5 5h14a1 1 0 011 1v13a1 1 0 01-1 1H5a1 1 0 01-1-1V6a1 1 0 011-1z",
    users: "M16 19v-1a4 4 0 00-4-4H7a4 4 0 00-4 4v1M9.5 11a3.5 3.5 0 100-7 3.5 3.5 0 000 7zM21 19v-1a4 4 0 00-3-3.9M16 4.1a3.5 3.5 0 010 6.8",
    search: "M11 18a7 7 0 100-14 7 7 0 000 14zM21 21l-4.5-4.5",
    plus: "M12 5v14M5 12h14",
    check: "M5 12.5l4.5 4.5L19 7.5",
    board: "M4 4h6v16H4zM14 4h6v10h-6z",
    list: "M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01",
    chart: "M4 20V10M10 20V4M16 20v-7M22 20H2",
    file: "M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8zM14 3v5h5M9 13h6M9 17h6",
    flag: "M5 21V4M5 4h11l-2 4 2 4H5",
    moon: "M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z",
    sun: "M12 17a5 5 0 100-10 5 5 0 000 10zM12 1v2M12 21v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M1 12h2M21 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4",
    bug: "M8 8a4 4 0 018 0v6a4 4 0 01-8 0zM3 13h3M18 13h3M4 7l3 2M20 7l-3 2M4 19l3-2M20 19l-3-2M12 4V2",
    bookmark: "M6 3h12v18l-6-4-6 4z",
    layers: "M12 3l9 5-9 5-9-5 9-5zM3 13l9 5 9-5M3 17.5l9 5 9-5",
    target: "M12 21a9 9 0 100-18 9 9 0 000 18zM12 16a4 4 0 100-8 4 4 0 000 8zM12 12h.01",
    clock: "M12 21a9 9 0 100-18 9 9 0 000 18zM12 7v5l3 2",
    alert: "M12 3l10 18H2zM12 10v5M12 18h.01",
    chevron: "M9 6l6 6-6 6",
    x: "M6 6l12 12M18 6L6 18",
    logout: "M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9",
    sprint: "M13 2L4 14h7l-1 8 9-12h-7z",
    link: "M10 14a5 5 0 007 0l3-3a5 5 0 00-7-7l-1 1M14 10a5 5 0 00-7 0l-3 3a5 5 0 007 7l1-1",
    edit: "M12 20h9M16.5 3.5a2.1 2.1 0 013 3L7 19l-4 1 1-4z",
    trash: "M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6M10 11v6M14 11v6",
    menu: "M4 6h16M4 12h16M4 18h16",
    arrow_up: "M12 19V5M5 12l7-7 7 7",
    arrow_down: "M12 5v14M5 12l7 7 7-7",
    minus: "M5 12h14",
    equal: "M5 9h14M5 15h14",
    map: "M9 4L3 6v14l6-2 6 2 6-2V4l-6 2zM9 4v14M15 6v14",
    user: "M20 21v-1a5 5 0 00-5-5H9a5 5 0 00-5 5v1M12 11a4 4 0 100-8 4 4 0 000 8z"
  }.freeze

  def icon(name, size: 18, **opts)
    classes = [ "icon", opts.delete(:class) ].compact.join(" ")
    tag.svg(tag.path(d: ICONS.fetch(name.to_sym)), xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", width: size, height: size,
            fill: "none", stroke: "currentColor", "stroke-width": 1.8, "stroke-linecap": "round", "stroke-linejoin": "round", "aria-hidden": true, class: classes, **opts)
  end

  def enum_label(model, attr, value)
    value.present? ? t("enums.#{model}.#{attr}.#{value}", default: value.to_s.humanize) : "—"
  end

  def avatar(user, size: 26)
    return tag.span("?", class: "avatar avatar-empty", style: "--size: #{size}px", title: "Sem responsável") unless user
    tag.span(user.initials, class: "avatar", style: "--size: #{size}px; --c: #{user.color}", title: user.name)
  end

  def badge(text, tone = :neutral, **opts)
    tag.span(text, class: [ "badge", "badge-#{tone}", opts.delete(:class) ].compact.join(" "), **opts)
  end

  KIND_ICONS = { "task" => :check, "bug" => :bug, "story" => :bookmark, "epic" => :layers }.freeze

  def kind_icon(kind, size: 15)
    tag.span(icon(KIND_ICONS.fetch(kind), size: size), class: "kind kind-#{kind}", title: enum_label(:issue, :kind, kind))
  end

  PRIORITY_ICONS = { "urgent" => :alert, "high" => :arrow_up, "medium" => :equal, "low" => :arrow_down }.freeze

  def priority_icon(priority, size: 15)
    tag.span(icon(PRIORITY_ICONS.fetch(priority), size: size), class: "prio prio-#{priority}", title: "Prioridade #{enum_label(:issue, :priority, priority).downcase}")
  end

  def status_chip(status)
    tag.span(enum_label(:issue, :status, status), class: "chip chip-#{status}")
  end

  def label_chip(label)
    hue = label.bytes.sum * 37 % 360
    tag.span(label, class: "label-chip", style: "--h: #{hue}")
  end

  def progress_bar(percent, tone: nil)
    tag.div(tag.i(style: "width: #{percent.to_i.clamp(0, 100)}%"), class: [ "progress", tone && "progress-#{tone}" ].compact.join(" "), role: "progressbar", "aria-valuenow": percent.to_i, "aria-valuemin": 0, "aria-valuemax": 100)
  end

  HEALTH_TONES = { "on_track" => :ok, "at_risk" => :warn, "late" => :danger, "done" => :accent, "paused" => :neutral }.freeze

  def health_badge(project)
    h = project.health
    badge(enum_label(:project, :health, h), HEALTH_TONES.fetch(h))
  end

  def short_date(date) = date ? l(date, format: "%d/%m") : "—"
  def long_date(date) = date ? l(date, format: "%d/%m/%Y") : "—"

  def due_label(issue)
    return unless issue.due_date
    tag.span(short_date(issue.due_date), class: [ "due", issue.overdue? && "due-late" ].compact.join(" "), title: "Prazo #{long_date(issue.due_date)}")
  end

  def ago(time) = time ? "há #{time_ago_in_words(time)}" : "—"

  def nav_item(label, path, icon_name, match: nil)
    ativo = match ? request.path.start_with?(match) : current_page?(path)
    link_to(path, class: [ "nav-item", ativo && "active" ].compact.join(" ")) { icon(icon_name) + tag.span(label) }
  end

  # Frase do histórico: "mudou o status de A fazer para Em andamento"
  def event_text(event)
    d = event.details.with_indifferent_access
    case event.kind
    when "created" then t("enums.event.created", kind: enum_label(:issue, :kind, d[:kind]).downcase)
    when "status_changed" then t("enums.event.status_changed", from: enum_label(:issue, :status, d[:from]), to: enum_label(:issue, :status, d[:to]))
    when "priority_changed" then t("enums.event.priority_changed", from: enum_label(:issue, :priority, d[:from]), to: enum_label(:issue, :priority, d[:to]))
    when "estimate_changed" then t("enums.event.estimate_changed", from: d[:from] || "—", to: d[:to] || "—")
    when "assigned" then d[:to].present? ? t("enums.event.assigned_to", to: d[:to]) : t("enums.event.assigned_none")
    when "sprint_changed" then d[:to].present? ? t("enums.event.sprint_in", to: d[:to]) : t("enums.event.sprint_out", from: d[:from])
    else t("enums.event.#{event.kind}")
    end
  end

  # Markdown seguro: HTML cru é filtrado e o resultado ainda passa por sanitização.
  def render_markdown(text)
    @markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true, safe_links_only: true, link_attributes: { rel: "nofollow noopener", target: "_blank" }),
      autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, no_intra_emphasis: true, lax_spacing: true
    )
    html = @markdown.render(text.to_s)
    sanitize(mentionize(html), tags: %w[p br strong em del h1 h2 h3 h4 ul ol li blockquote code pre a table thead tbody tr th td hr span], attributes: %w[href rel target class])
  end

  # @maria vira um destaque quando existe alguém com esse primeiro nome
  def mentionize(html)
    @handles ||= User.all.index_by(&:mention_handle)
    html.gsub(/(?<![\w\/])@([a-z]{2,20})\b/i) do
      user = @handles[Regexp.last_match(1).downcase]
      user ? %(<span class="mention">@#{ERB::Util.h(user.first_name)}</span>) : Regexp.last_match(0)
    end
  end

  def flash_tone(type) = type.to_s == "alert" ? "danger" : "ok"

  def project_color_style(project) = "--pc: #{project.color}"
end
