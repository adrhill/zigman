// main.typ — Zigman: Zig Language Reference for e-readers

#set document(
  title: "Zig Language Reference",
  author: "The Zig Software Foundation",
)

#set page(
  width: 6in,
  height: 9in,
  margin: (
    top: 0.6in,
    bottom: 0.7in,
    inside: 0.7in,
    outside: 0.55in,
  ),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: luma(120))
      emph[Zig Language Reference]
      h(1fr)
      counter(page).display()
    }
  },
  footer: [],
)

// Body text
#set text(
  font: ("New Computer Modern", "Libertinus Serif"),
  size: 9.5pt,
  lang: "en",
)

#set par(
  leading: 0.58em,
  justify: true,
)

// Headings
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 16pt, weight: "bold")
  v(0.5em)
  it
  v(0.4em)
}

#show heading.where(level: 2): it => {
  set text(size: 13pt, weight: "bold")
  v(0.6em)
  it
  v(0.3em)
}

#show heading.where(level: 3): it => {
  set text(size: 11pt, weight: "bold")
  v(0.5em)
  it
  v(0.2em)
}

#show heading.where(level: 4): it => {
  set text(size: 10pt, weight: "bold")
  v(0.4em)
  it
  v(0.15em)
}

// Code blocks
#show raw.where(block: true): it => {
  set text(size: 7.5pt)
  block(
    width: 100%,
    fill: luma(245),
    inset: 8pt,
    radius: 3pt,
    stroke: 0.5pt + luma(210),
    it,
  )
}

// Inline code
#show raw.where(block: false): it => {
  set text(size: 0.9em)
  box(
    fill: luma(240),
    inset: (x: 2pt, y: 0pt),
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
  stroke: 0.5pt + luma(180),
  inset: 6pt,
)

#show table.cell.where(y: 0): set text(weight: "bold", size: 9pt)

// Lists
#set list(indent: 1em, body-indent: 0.4em)
#set enum(indent: 1em, body-indent: 0.4em)

// Title page
#align(center + horizon)[
  #text(size: 28pt, weight: "bold")[Zig Language Reference]
  #v(1em)
  #text(size: 12pt, fill: luma(100))[The Zig Software Foundation]
  #v(0.5em)
  #text(size: 10pt, fill: luma(140))[Typeset for e-readers by Zigman]
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
