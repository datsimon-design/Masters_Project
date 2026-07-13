#import "@preview/wordometer:0.1.5": word-count, total-words

#let article(
  title: none,
  author: none,
  keywords: none,
  body,
) = {
  set document(title: title, author: "Simon Gendrisch", keywords: keywords)

 page(header: none, footer: none, numbering: none, paper: "a4")[
  #set text(font: "Libertinus Serif", size: 12pt)
  #set par(justify: false, leading: 0.6em)
  #show par: set par(leading: 0.6em, spacing: 0.9em)

  #align(center)[
    #text(size: 17pt, weight: "bold")[Supplemental Information:]

    #v(3em)

    #text(size: 15pt, weight: "bold")[#title]
  ]

  #v(1.4em)

  #text(weight: "bold")[#author#super[1], Dr. Stephen Chan#super[1], Dr. Awantha Dissanyake#super[1] ]

  #v(0.3em)
  #text(size: 9pt)[#super[1]#h(0.35em)School of Marine and Environmental Science, University of Gibraltar, GX11 1AA] 

  #v(1.3em)
  #text(weight: "bold")[\*Correspondence:] \
  #author \
  #text()[SMES\@unigib.edu.gi]

  #v(1.5em)
  #text(style: "italic")[Keywords: #keywords.join(", ").]

  #v(1.5em)
  Word count (excluding References and Appendices): #text( weight: "bold")[#total-words words]

  #pagebreak()

  ]

  

  // Rest of article styling
  set page(
    paper: "a4",
    margin: (
      x: 2.5cm,
      y: 2.5cm,
    )
  )
  
  set text(
    font: "Libertinus Serif",
    size: 12pt,
    top-edge: 1em,
  )
  
  set par(
    spacing: 1.5em,
    justify: true,
    leading: 0.75em
  )

  


  show figure.caption: it => context{
    let head = it.supplement + [ ] + it.counter.display(it.numbering) + [.]

      set align(left)
      set par(justify: false)

      block(width: 100%, grid(
        columns: (2.5cm, 1fr),          // <-- 2.5cm IS the "Space"; change to your tab stop
        column-gutter: 0pt,
        align: (left + top, left + top),
        head,
        it.body,
      ))
  }

  show: word-count.with(exclude: <no-wc>)

  show figure.caption: set text(font: "Source Sans 3", size : 9pt)

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set align(center)

  show figure.where(kind: image): set figure.caption(position: bottom)

  show figure.where(kind: "quarto-float-app"): set block(breakable: true)


  //Add the S prefic to fig and table, remove for journal article
  show figure.where(kind: "quarto-float-fig"): set figure(numbering: (..n) => "S" + str(n.at(-1)))
  show figure.where(kind: "quarto-float-tbl"): set figure(numbering: (..n) => "S" + str(n.at(-1)))

  show table: it => {
  set text(size: 9pt)
  set par(leading: 0.65em, spacing: 0.65em)
  it
  }
  set table(
  stroke: (x, y) => (
    top: if y == 0 { 0.7pt }        // rule above the header
         else if y == 1 { 0.4pt }   // rule below the header
         else { 0pt },              // no inter-row lines
  ),
)


  body

}
