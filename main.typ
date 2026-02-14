// main.typ — Zigman: Zig Language Reference for e-readers

#set document(
  title: "Zig Language Reference",
  author: "The Zig Software Foundation",
)

#set page(
  width: eval(sys.inputs.at("page-width", default: "4.2in")),
  height: eval(sys.inputs.at("page-height", default: "5.6in")),
  margin: (
    x: 0.15in,
    top: 0.15in,
    bottom: 0.2in,
  ),
  header: [],
  footer: context {
    if counter(page).get().first() > 1 {
      set align(center)
      set text(size: 7.5pt, fill: luma(140))
      counter(page).display()
    }
  },
)

// Body text
#set text(
  font: ("Literata", "Libertinus Serif"),
  size: 9pt,
  lang: "en",
)

#set par(
  leading: 0.65em,
  justify: true,
  justification-limits: (
    tracking: (min: -0.01em, max: 0.02em),
  ),
)

// Headings
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 14pt, weight: "bold")
  v(0.8em)
  it
  v(0.5em)
}

#show heading.where(level: 2): it => {
  set text(size: 11pt, weight: "bold")
  v(1.0em)
  it
  v(0.4em)
}

#show heading.where(level: 3): it => {
  set text(size: 9pt, weight: "bold")
  v(0.8em)
  it
  v(0.3em)
}

#show heading.where(level: 4): it => {
  set text(size: 8pt, weight: "bold")
  v(0.6em)
  it
  v(0.2em)
}

// Captioned code blocks (figures containing code)
#show figure.where(kind: raw): set block(breakable: true)
#show figure.where(kind: raw): it => {
  set align(left)
  set text(font: "Source Code Pro", size: 8pt)
  set par(justify: false)
  let caption-text = it.caption.body.children.filter(c => c.has("text")).map(c => c.text).join("")
  let caption-fill = if caption-text.starts-with("Shell") {
    rgb("#ccc")
  } else if caption-text.ends-with(".c") or caption-text.ends-with(".h") {
    rgb("#a8b9cc")
  } else {
    rgb("#fcdba5") // Zig (default)
  }
  block(
    width: 100%,
    fill: luma(248),
    breakable: true,
    clip: true,
  )[
    #block(
      width:110%,
      fill: caption-fill,
      inset: (x: 5pt, y: 4pt),
      below: 0pt,
      sticky: true,
      {set text(weight: "bold"); it.caption.body},
    )
    #it.body
  ]
}

// Code blocks
#show raw.where(block: true): it => {
  set text(font: "Source Code Pro", size: 8pt)
  set par(justify: false)
  block(
    width: 100%,
    fill: luma(250),
    inset: (x: 5pt, y: 5pt),
    stroke: 0.5pt + luma(215),
    it,
  )
}

// Inline code
#show raw.where(block: false): it => {
  set text(size: 1.05em)
  box(
    fill: luma(243),
    inset: (x: 2.5pt, y: 0pt),
    outset: (y: 2pt),
    radius: 2pt,
    it,
  )
}

// Links
#show link: it => {
  set text(fill: rgb("#2563eb"))
  underline(it)
}

// Tables
#set table(
  stroke: (x: none, y: 0.5pt + luma(200)),
  inset: 7pt,
  fill: (_, y) => if calc.odd(y) { luma(245) },
)

#show table: set align(center)
#set table.cell(align: left)
#show table: set text(size: 7pt)
#show figure.where(kind: table): set block(breakable: true)
#show table: it => {
  set block(breakable: true)
  show raw: set text(size: 7.25pt)
  it
}
#show table.cell.where(y: 0): set text(weight: "bold", size: 7.5pt)
#show table.cell.where(y: 0): set table.cell(fill: luma(225))

// Lists
#set list(indent: 1em, body-indent: 0.5em)
#set enum(indent: 1em, body-indent: 0.5em)

// Title page
#align(center + horizon)[
  #text(size: 18pt, weight: "bold")[Zig Language Reference]
  #v(1em)
  #text(size: 9pt, fill: luma(100))[© Zig Contributors — MIT License]
  #v(0.5em)
  #text(size: 8pt, fill: luma(130))[
    Typeset for e-readers: #link("https://github.com/adrhill/zigman")[github.com/adrhill/zigman]
  ]
]

#pagebreak()

// Table of contents
#outline(
  title: "Contents",
  depth: 3,
  indent: 1em,
)

#pagebreak()

// Include Pandoc-generated content
#include "content.typ"
