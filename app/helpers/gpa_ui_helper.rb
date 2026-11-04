
module GpaUiHelper
  ICONS = {
    dashboard: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',

    building: '<rect x="4" y="2" width="16" height="20" rx="2"/><path d="M9 22v-4h6v4M8 6h.01M16 6h.01M8 10h.01M16 10h.01M8 14h.01M16 14h.01"/>',

    feed: '<rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/>',

    package: '<path d="m12 2 9 5-9 5-9-5 9-5ZM3 7v10l9 5 9-5V7M12 12v10"/>',

    shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/><path d="m9 12 2 2 4-4"/>',

    users: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M16 3.1a4 4 0 0 1 0 7.8M22 21v-2a4 4 0 0 0-3-3.87"/><circle cx="9" cy="7" r="4"/>',

    menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',

    close: '<path d="M18 6 6 18M6 6l12 12"/>',

    chevron: '<path d="m6 9 6 6 6-6"/>',

    panel: '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 3v18M14 9l3 3-3 3"/>',

    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>',

    moon: '<path d="M20.985 12.486A9 9 0 0 1 11.514 3.015 9 9 0 1 0 20.985 12.486Z"/>',

    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',

    check: '<path d="m5 12 4 4L19 6"/>',

    plus: '<path d="M12 5v14M5 12h14"/>',

    edit: '<path d="M12 20h9M16 4a2 2 0 0 1 3 3L9 17l-4 1 1-4L16 4Z"/>',

    arrow: '<path d="M5 12h14m-6-6 6 6-6 6"/>'
  }.freeze

  def gpa_icon(name, css_class: "gpa-icon")
    content_tag(
      :svg,
      ICONS.fetch(name.to_sym, ICONS[:dashboard]).html_safe,
      class: css_class,
      viewBox: "0 0 24 24",
      width: 20,
      height: 20,
      fill: "none",
      stroke: "currentColor",
      "stroke-width": 1.8,
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "aria-hidden": "true",
      focusable: "false"
    )
  end
end
