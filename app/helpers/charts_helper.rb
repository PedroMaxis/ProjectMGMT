# Gráficos em SVG puro, gerados no servidor (sem biblioteca de JavaScript).
module ChartsHelper
  STATUS_COLORS = { "todo" => "#94a3b8", "doing" => "#8b5cf6", "review" => "#f59e0b", "done" => "#22c55e" }.freeze

  # Burndown: linha ideal (tracejada) e linha real da sprint
  def burndown_chart(data, width: 680, height: 280)
    return unless data
    pad = { l: 40, r: 16, t: 16, b: 34 }
    w = width - pad[:l] - pad[:r]
    h = height - pad[:t] - pad[:b]
    dias = data[:days]
    max = [ data[:total], 1 ].max
    x = ->(i) { pad[:l] + (dias.size > 1 ? w * i.to_f / (dias.size - 1) : 0) }
    y = ->(v) { pad[:t] + h - (v.to_f / max * h) }
    idx = dias.each_with_index.to_h
    ideal = data[:ideal].map { |d, v| "#{x.(idx[d]).round(1)},#{y.(v).round(1)}" }.join(" ")
    real = data[:actual].map { |d, v| [ x.(idx[d]).round(1), y.(v).round(1) ] }
    ticks = (0..4).map { |i| (max * i / 4.0).round }
    passo = [ (dias.size / 7.0).ceil, 1 ].max

    linhas_grade = ticks.map do |t|
      tag.line(x1: pad[:l], x2: width - pad[:r], y1: y.(t), y2: y.(t), class: "grid") +
        tag.text(t, x: pad[:l] - 8, y: y.(t) + 4, "text-anchor": "end", class: "axis")
    end
    rotulos = dias.each_with_index.filter_map do |d, i|
      tag.text(l(d, format: "%d/%m"), x: x.(i), y: height - 10, "text-anchor": "middle", class: "axis") if (i % passo).zero?
    end
    linha_real = (tag.polyline(points: real.map { |a, b| "#{a},#{b}" }.join(" "), class: "line-real", fill: "none") if real.size > 1)
    pontos = real.map { |a, b| tag.circle(cx: a, cy: b, r: 3.5, class: "dot-real") }

    tag.svg(viewBox: "0 0 #{width} #{height}", class: "chart", role: "img", "aria-label": "Gráfico de burndown") do
      safe_join([ *linhas_grade, *rotulos, tag.polyline(points: ideal, class: "line-ideal", fill: "none"), linha_real, *pontos ].compact)
    end
  end

  # Rosca com legenda: segments = [{ label:, value:, color: }]
  def donut_chart(segments, size: 140, thickness: 22, center: nil)
    total = segments.sum { |s| s[:value] }.to_f
    r = (size - thickness) / 2.0
    circ = 2 * Math::PI * r
    offset = 0.0
    arcs = segments.reject { |s| s[:value].zero? }.map do |s|
      len = total.zero? ? 0 : circ * s[:value] / total
      arc = tag.circle(cx: size / 2, cy: size / 2, r: r, fill: "none", stroke: s[:color], "stroke-width": thickness,
                       "stroke-dasharray": "#{len.round(2)} #{(circ - len).round(2)}", "stroke-dashoffset": (-offset).round(2), transform: "rotate(-90 #{size / 2} #{size / 2})")
      offset += len
      arc
    end
    miolo = center ? tag.text(center, x: size / 2, y: size / 2 + 7, "text-anchor": "middle", class: "donut-center") : nil
    tag.svg(viewBox: "0 0 #{size} #{size}", width: size, height: size, class: "donut", role: "img", "aria-label": segments.map { |s| "#{s[:label]}: #{s[:value]}" }.join(", ")) do
      safe_join([ tag.circle(cx: size / 2, cy: size / 2, r: r, fill: "none", class: "donut-track", "stroke-width": thickness), *arcs, miolo ].compact)
    end
  end

  # Barras verticais simples: rows = [[rótulo, valor], ...]
  def bar_chart(rows, width: 460, height: 190)
    return tag.p("Sem dados ainda.", class: "muted") if rows.empty? || rows.all? { |_, v| v.zero? }
    pad = { l: 28, r: 8, t: 14, b: 30 }
    w = width - pad[:l] - pad[:r]
    h = height - pad[:t] - pad[:b]
    max = rows.map(&:last).max
    largura = w.to_f / rows.size
    tag.svg(viewBox: "0 0 #{width} #{height}", class: "chart", role: "img") do
      safe_join([
        tag.line(x1: pad[:l], x2: width - pad[:r], y1: pad[:t] + h, y2: pad[:t] + h, class: "grid"),
        *rows.each_with_index.map do |(rotulo, valor), i|
          alt = h * valor.to_f / max
          x = pad[:l] + i * largura
          tag.g do
            tag.rect(x: x + largura * 0.18, y: pad[:t] + h - alt, width: largura * 0.64, height: alt, rx: 4, class: "bar") +
              tag.text(valor, x: x + largura / 2, y: pad[:t] + h - alt - 5, "text-anchor": "middle", class: "bar-value") +
              tag.text(rotulo.is_a?(Date) ? l(rotulo, format: "%d/%m") : rotulo.to_s.truncate(10), x: x + largura / 2, y: height - 10, "text-anchor": "middle", class: "axis")
          end
        end
      ])
    end
  end

  def status_segments(counts)
    Issue::STATUSES.map { |s| { label: enum_label(:issue, :status, s), value: counts.fetch(s, 0), color: STATUS_COLORS[s] } }
  end

  # posição (%) de uma data dentro de um intervalo de datas, para os cronogramas
  def pct_in(range, date)
    total = (range.end - range.begin).to_f
    return 0 if total.zero?
    (((date - range.begin).to_f / total) * 100).clamp(0, 100).round(2)
  end

  def month_ticks(range)
    (range.begin.beginning_of_month..range.end).select { |d| d.day == 1 }.map { |d| [ d, pct_in(range, d) ] }
  end
end
